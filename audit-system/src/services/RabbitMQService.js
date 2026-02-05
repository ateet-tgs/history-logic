const rabbitmqConfig = require('../config/rabbitmq');
const { logger } = require('../config/database');

class RabbitMQService {
  constructor() {
    this.connection = null;
    this.channel = null;
    this.isConnected = false;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }

  async init() {
    try {
      const { connection, channel } = await rabbitmqConfig.connect();
      this.connection = connection;
      this.channel = channel;
      this.isConnected = true;
      this.reconnectAttempts = 0;
      
      // Set up channel error handling
      this.channel.on('error', (err) => {
        logger.error('❌ RabbitMQ channel error:', err);
        this.isConnected = false;
      });

      this.channel.on('close', () => {
        logger.warn('⚠️ RabbitMQ channel closed');
        this.isConnected = false;
      });

      logger.info('✅ RabbitMQ service initialized');
    } catch (err) {
      logger.error('❌ Failed to initialize RabbitMQ service:', err);
      throw err;
    }
  }

  async ensureConnection() {
    if (!this.isConnected && this.reconnectAttempts < this.maxReconnectAttempts) {
      logger.info(`🔄 Reconnecting to RabbitMQ (attempt ${this.reconnectAttempts + 1}/${this.maxReconnectAttempts})...`);
      this.reconnectAttempts++;
      
      try {
        await this.init();
      } catch (err) {
        if (this.reconnectAttempts >= this.maxReconnectAttempts) {
          logger.error('❌ Max reconnection attempts reached');
          throw err;
        }
        
        // Wait before retry
        await new Promise(resolve => setTimeout(resolve, 2000 * this.reconnectAttempts));
        return this.ensureConnection();
      }
    }
  }

  async consumeAuditChanges(callback) {
    await this.ensureConnection();

    try {
      // Set prefetch to control message flow
      await this.channel.prefetch(10);

      await this.channel.consume(
        rabbitmqConfig.config.queues.AUDIT_CHANGES,
        async (msg) => {
          if (!msg) return;

          const startTime = Date.now();
          let data = null;

          try {
            // Parse message content
            const content = msg.content.toString();
            data = JSON.parse(content);
            
            // Extract routing key to determine table
            const routingKey = msg.fields.routingKey;
            const tableName = this.extractTableFromRoutingKey(routingKey);
            
            if (tableName) {
              data.table = tableName;
            }
            
            logger.debug(`📥 Processing message: ${routingKey}`, { 
              table: data.table, 
              operation: data.op || 'unknown' 
            });
            
            // Process the message
            await callback(data);
            
            // Acknowledge successful processing
            this.channel.ack(msg);
            
            const processingTime = Date.now() - startTime;
            logger.info(`✅ Processed ${data.table}:${data.after?.id || data.before?.id} in ${processingTime}ms`);

          } catch (err) {
            logger.error('❌ Message processing failed:', err);
            
            // Get retry count from headers
            const retryCount = (msg.properties.headers?.['x-retry-count'] || 0) + 1;
            const maxRetries = 3;
            
            if (retryCount <= maxRetries) {
              // Send to retry queue with delay
              logger.info(`🔄 Retrying message (attempt ${retryCount}/${maxRetries})`);
              
              await this.channel.publish(
                rabbitmqConfig.config.exchanges.AUDIT,
                rabbitmqConfig.config.routingKeys.RETRY,
                msg.content,
                {
                  ...msg.properties,
                  headers: {
                    ...msg.properties.headers,
                    'x-retry-count': retryCount,
                    'x-retry-reason': err.message,
                    'x-retry-timestamp': Date.now(),
                    'x-original-routing-key': msg.fields.routingKey
                  }
                }
              );
            } else {
              // Send to dead letter queue
              logger.error(`💀 Sending to DLQ after ${maxRetries} retries`);
              
              await this.channel.publish(
                rabbitmqConfig.config.exchanges.AUDIT,
                rabbitmqConfig.config.routingKeys.DLQ,
                msg.content,
                {
                  ...msg.properties,
                  headers: {
                    ...msg.properties.headers,
                    'x-error': err.message,
                    'x-error-timestamp': Date.now(),
                    'x-final-retry-count': retryCount,
                    'x-original-routing-key': msg.fields.routingKey
                  }
                }
              );
            }
            
            // Acknowledge the message (it's been handled)
            this.channel.ack(msg);
          }
        },
        { 
          noAck: false,
          consumerTag: `audit-consumer-${process.pid}-${Date.now()}`
        }
      );

      logger.info('✅ Started consuming audit changes from RabbitMQ');
    } catch (err) {
      logger.error('❌ Failed to start consumer:', err);
      throw err;
    }
  }

  extractTableFromRoutingKey(routingKey) {
    // Extract table name from routing key: audit.manufacturing_db.table_name
    const parts = routingKey.split('.');
    if (parts.length >= 3 && parts[0] === 'audit' && parts[1] === 'manufacturing_db') {
      return parts[2];
    }
    return null;
  }

  async getQueueStats() {
    await this.ensureConnection();

    try {
      const mainQueue = await this.channel.checkQueue(rabbitmqConfig.config.queues.AUDIT_CHANGES);
      const dlqQueue = await this.channel.checkQueue(rabbitmqConfig.config.queues.AUDIT_DLQ);
      const retryQueue = await this.channel.checkQueue(rabbitmqConfig.config.queues.AUDIT_RETRY);

      return {
        main: {
          name: rabbitmqConfig.config.queues.AUDIT_CHANGES,
          messages: mainQueue.messageCount,
          consumers: mainQueue.consumerCount
        },
        dlq: {
          name: rabbitmqConfig.config.queues.AUDIT_DLQ,
          messages: dlqQueue.messageCount,
          consumers: dlqQueue.consumerCount
        },
        retry: {
          name: rabbitmqConfig.config.queues.AUDIT_RETRY,
          messages: retryQueue.messageCount,
          consumers: retryQueue.consumerCount
        },
        connection: {
          connected: this.isConnected,
          reconnectAttempts: this.reconnectAttempts
        }
      };
    } catch (err) {
      logger.error('❌ Failed to get queue stats:', err);
      return null;
    }
  }

  async close() {
    try {
      this.isConnected = false;
      await rabbitmqConfig.close();
      logger.info('✅ RabbitMQ service closed');
    } catch (err) {
      logger.error('❌ Error closing RabbitMQ service:', err);
    }
  }
}

module.exports = RabbitMQService;