const amqp = require('amqplib');
const { logger } = require('./database');

const config = {
  url: process.env.RABBITMQ_URL || 'amqp://guest:guest@localhost:5672',
  exchanges: {
    AUDIT: 'audit.exchange'
  },
  queues: {
    AUDIT_CHANGES: 'audit.changes',
    AUDIT_DLQ: 'audit.changes.dlq',
    AUDIT_RETRY: 'audit.changes.retry'
  },
  routingKeys: {
    SALES_ORDER_RELEASE_LINE: 'audit.manufacturing_db.sales_order_release_line',
    ROHS_PEERS: 'audit.manufacturing_db.rohs_peers',
    SALES_ORDER: 'audit.manufacturing_db.sales_order',
    SALES_ORDER_LINE_DETAIL: 'audit.manufacturing_db.sales_order_line_detail',
    DLQ: 'audit.dlq',
    RETRY: 'audit.retry'
  }
};

let connection = null;
let channel = null;

const connect = async () => {
  if (connection && !connection.connection.destroyed) {
    return { connection, channel };
  }

  try {
    logger.info('🔄 Connecting to RabbitMQ...');
    connection = await amqp.connect(config.url);
    channel = await connection.createChannel();

    // Handle connection events
    connection.on('error', (err) => {
      logger.error('❌ RabbitMQ connection error:', err);
    });

    connection.on('close', () => {
      logger.warn('⚠️ RabbitMQ connection closed');
      connection = null;
      channel = null;
    });

    // Handle channel events
    channel.on('error', (err) => {
      logger.error('❌ RabbitMQ channel error:', err);
    });

    channel.on('close', () => {
      logger.warn('⚠️ RabbitMQ channel closed');
    });

    // Setup exchanges and queues
    await setupRabbitMQTopology(channel);

    logger.info('✅ Connected to RabbitMQ');
    return { connection, channel };
  } catch (err) {
    logger.error('❌ RabbitMQ connection failed:', err);
    throw err;
  }
};

const setupRabbitMQTopology = async (channel) => {
  // Create exchange
  await channel.assertExchange(config.exchanges.AUDIT, 'topic', {
    durable: true
  });

  // Create main processing queue
  await channel.assertQueue(config.queues.AUDIT_CHANGES, {
    durable: true,
    arguments: {
      'x-dead-letter-exchange': config.exchanges.AUDIT,
      'x-dead-letter-routing-key': config.routingKeys.DLQ
    }
  });

  // Create dead letter queue
  await channel.assertQueue(config.queues.AUDIT_DLQ, {
    durable: true
  });

  // Create retry queue with TTL
  await channel.assertQueue(config.queues.AUDIT_RETRY, {
    durable: true,
    arguments: {
      'x-message-ttl': 30000, // 30 seconds
      'x-dead-letter-exchange': config.exchanges.AUDIT,
      'x-dead-letter-routing-key': 'audit.changes'
    }
  });

  // Bind queues to exchange
  await channel.bindQueue(config.queues.AUDIT_CHANGES, config.exchanges.AUDIT, 'audit.manufacturing_db.*');
  await channel.bindQueue(config.queues.AUDIT_DLQ, config.exchanges.AUDIT, config.routingKeys.DLQ);
  await channel.bindQueue(config.queues.AUDIT_RETRY, config.exchanges.AUDIT, config.routingKeys.RETRY);

  logger.info('✅ RabbitMQ topology setup complete');
};

const close = async () => {
  try {
    if (channel) await channel.close();
    if (connection) await connection.close();
  } catch (err) {
    logger.error('❌ Error closing RabbitMQ connection:', err);
  } finally {
    connection = null;
    channel = null;
  }
};

const getChannel = () => channel;

module.exports = {
  config,
  connect,
  close,
  getChannel,
  setupRabbitMQTopology
};