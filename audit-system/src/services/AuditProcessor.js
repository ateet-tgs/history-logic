const auditConfig = require('../config/audit.config');
const { logger } = require('../config/database');

// Import all processors
const BaseTableProcessor = require('../processors/BaseTableProcessor');
const SalesOrderReleaseLineProcessor = require('../processors/SalesOrderReleaseLineProcessor');
const RohsPeersProcessor = require('../processors/RohsPeersProcessor');

class AuditProcessor {
  constructor() {
    this.processors = new Map();
    this.stats = {
      processed: 0,
      errors: 0,
      byTable: {}
    };
    this.initProcessors();
  }

  initProcessors() {
    // Register processors for each table
    const processorClasses = {
      BaseTableProcessor,
      SalesOrderReleaseLineProcessor,
      RohsPeersProcessor
    };

    for (const [tableName, config] of Object.entries(auditConfig.tables)) {
      const ProcessorClass = processorClasses[config.processor] || BaseTableProcessor;
      this.processors.set(tableName, new ProcessorClass(tableName, config));
      
      // Initialize stats for this table
      this.stats.byTable[tableName] = {
        processed: 0,
        errors: 0,
        lastProcessed: null
      };
      
      logger.info(`✅ Registered ${config.processor} for ${tableName}`);
    }

    logger.info(`✅ Initialized ${this.processors.size} table processors`);
  }

  async processChange(data) {
    const { table, op, before, after, ts_ms, source } = data;
    
    if (!table) {
      logger.warn('⚠️ No table specified in change data');
      return [];
    }

    const processor = this.processors.get(table);
    if (!processor) {
      logger.warn(`⚠️ No processor found for table: ${table}`);
      return [];
    }

    try {
      const timestamp = ts_ms || Date.now();
      const auditRecords = await processor.process(op, before, after, timestamp, source);
      
      // Update stats
      this.stats.processed++;
      this.stats.byTable[table].processed++;
      this.stats.byTable[table].lastProcessed = new Date();
      
      logger.info(`📝 Generated ${auditRecords.length} audit records for ${table}:${after?.id || before?.id}`);
      return auditRecords;
      
    } catch (err) {
      this.stats.errors++;
      this.stats.byTable[table].errors++;
      
      logger.error(`❌ Processing failed for ${table}:${after?.id || before?.id}:`, err);
      throw err;
    }
  }

  getProcessorStats() {
    const stats = {
      summary: {
        totalProcessed: this.stats.processed,
        totalErrors: this.stats.errors,
        errorRate: this.stats.processed > 0 ? (this.stats.errors / this.stats.processed * 100).toFixed(2) + '%' : '0%'
      },
      tables: {}
    };

    for (const [tableName, processor] of this.processors.entries()) {
      stats.tables[tableName] = {
        processor: processor.constructor.name,
        enabled: processor.config.enabled,
        entityLevel: processor.config.entityLevel,
        auditableColumns: processor.config.auditableColumns,
        description: processor.config.description,
        stats: this.stats.byTable[tableName]
      };
    }
    
    return stats;
  }

  resetStats() {
    this.stats = {
      processed: 0,
      errors: 0,
      byTable: {}
    };
    
    for (const tableName of this.processors.keys()) {
      this.stats.byTable[tableName] = {
        processed: 0,
        errors: 0,
        lastProcessed: null
      };
    }
    
    logger.info('📊 Processor stats reset');
  }
}

module.exports = AuditProcessor;