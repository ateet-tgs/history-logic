const { getPool, logger } = require('../config/database');
const RabbitMQService = require('./RabbitMQService');
const AuditProcessor = require('./AuditProcessor');
const auditConfig = require('../config/audit.config');

class AuditConsumer {
  constructor() {
    this.pool = getPool();
    this.rabbitMQ = new RabbitMQService();
    this.auditProcessor = new AuditProcessor();
    this.auditBatch = [];
    this.batchTimer = null;
    this.isRunning = false;
    this.stats = {
      processed: 0,
      errors: 0,
      batches: 0,
      startTime: new Date()
    };
  }

  async init() {
    try {
      logger.info('🔄 Initializing audit consumer...');
      
      await this.rabbitMQ.init();
      
      // Start consuming messages
      await this.rabbitMQ.consumeAuditChanges((data) => this.handleMessage(data));

      // Start batch flush timer
      this.startBatchTimer();
      this.isRunning = true;

      logger.info('✅ Audit consumer initialized and running');
    } catch (err) {
      logger.error('❌ Failed to initialize audit consumer:', err);
      throw err;
    }
  }

  async handleMessage(data) {
    try {
      // Parse Debezium message
      const parsedData = this.parseDebeziumMessage(data);
      
      if (!parsedData) {
        logger.debug('⏭️ Skipping message (no parseable data)');
        return;
      }

      // Skip read operations (snapshots)
      if (parsedData.op === 'r') {
        logger.debug(`⏭️ Skipping snapshot read for ${parsedData.table}`);
        return;
      }

      // Process the change
      const auditRecords = await this.auditProcessor.processChange(parsedData);
      
      if (auditRecords.length > 0) {
        // Add to batch
        this.auditBatch.push(...auditRecords);
        
        logger.debug(`📦 Added ${auditRecords.length} records to batch (total: ${this.auditBatch.length})`);
        
        // Flush if batch is full
        if (this.auditBatch.length >= auditConfig.batch.size) {
          await this.flushAuditBatch();
        }
      }

      this.stats.processed++;

    } catch (err) {
      this.stats.errors++;
      logger.error('❌ Message handling error:', err);
      throw err; // Let RabbitMQ handle retry logic
    }
  }

  parseDebeziumMessage(data) {
    try {
      // Handle different message formats
      let payload = data;
      
      // If it's a string, parse it
      if (typeof data === 'string') {
        payload = JSON.parse(data);
      }

      // Extract Debezium fields
      const { 
        before, 
        after, 
        op, 
        ts_ms, 
        source,
        payload: nestedPayload,
        table // May be added by RabbitMQ service
      } = payload;

      // Handle nested payload structure
      if (nestedPayload && !op) {
        return this.parseDebeziumMessage(nestedPayload);
      }

      // Determine table name
      let tableName = table;
      if (!tableName && source && source.table) {
        tableName = source.table;
      }

      if (!tableName) {
        logger.warn('⚠️ No table name found in message');
        return null;
      }

      // Skip if table not configured
      if (!auditConfig.tables[tableName]) {
        logger.debug(`⏭️ Skipping unconfigured table: ${tableName}`);
        return null;
      }

      return {
        table: tableName,
        op: op,
        before: before,
        after: after,
        ts_ms: ts_ms || Date.now(),
        source: source || {},
        id: after?.id || before?.id || 'unknown'
      };

    } catch (err) {
      logger.error('❌ Failed to parse Debezium message:', err);
      return null;
    }
  }

  startBatchTimer() {
    this.batchTimer = setInterval(async () => {
      if (this.auditBatch.length > 0) {
        logger.debug(`⏰ Timer flush triggered (${this.auditBatch.length} records)`);
        await this.flushAuditBatch();
      }
    }, auditConfig.batch.timeoutMs);
    
    logger.info(`⏰ Batch timer started (${auditConfig.batch.timeoutMs}ms interval)`);
  }

  async flushAuditBatch() {
    if (this.auditBatch.length === 0) return;

    const batchToFlush = [...this.auditBatch];
    this.auditBatch = [];

    const conn = await this.pool.getConnection();
    try {
      await conn.beginTransaction();

      // Insert audit records
      const insertQuery = `
        INSERT INTO dataentrychange_auditlog 
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, 
         entity_display_ref, col_name, old_val, new_val, updated_at, updated_by, 
         update_by_role_id, value_type)
        VALUES ?
      `;

      const values = batchToFlush.map(record => [
        record.root_table_name,
        record.root_ref_id,
        record.table_name,
        record.ref_trans_id,
        record.entity_level,
        record.entity_display_ref,
        record.col_name,
        record.old_val,
        record.new_val,
        record.updated_at,
        record.updated_by,
        record.update_by_role_id,
        record.value_type
      ]);

      await conn.query(insertQuery, [values]);
      await conn.commit();
      
      this.stats.batches++;
      logger.info(`✅ Flushed ${batchToFlush.length} audit records (batch #${this.stats.batches})`);

    } catch (err) {
      await conn.rollback();
      logger.error('❌ Batch flush failed:', err);
      
      // Put records back in batch for retry
      this.auditBatch.unshift(...batchToFlush);
      throw err;
    } finally {
      conn.release();
    }
  }

  async getStats() {
    const queueStats = await this.rabbitMQ.getQueueStats();
    const uptime = Date.now() - this.stats.startTime.getTime();
    
    return {
      consumer: {
        processed: this.stats.processed,
        errors: this.stats.errors,
        batches: this.stats.batches,
        currentBatchSize: this.auditBatch.length,
        isRunning: this.isRunning,
        uptime: Math.floor(uptime / 1000), // seconds
        startTime: this.stats.startTime,
        processingRate: this.stats.processed > 0 ? (this.stats.processed / (uptime / 1000 / 60)).toFixed(2) + '/min' : '0/min'
      },
      queues: queueStats,
      processors: this.auditProcessor.getProcessorStats()
    };
  }

  async stop() {
    logger.info('🛑 Stopping audit consumer...');
    
    this.isRunning = false;
    
    // Clear batch timer
    if (this.batchTimer) {
      clearInterval(this.batchTimer);
      this.batchTimer = null;
    }

    // Flush remaining records
    if (this.auditBatch.length > 0) {
      logger.info(`🔄 Flushing remaining ${this.auditBatch.length} records...`);
      await this.flushAuditBatch();
    }

    // Close RabbitMQ connection
    await this.rabbitMQ.close();

    logger.info('✅ Audit consumer stopped');
  }
}

module.exports = AuditConsumer;