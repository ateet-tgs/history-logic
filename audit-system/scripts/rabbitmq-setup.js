require('dotenv').config();

const amqp = require('amqplib');
const { logger } = require('../src/config/database');

async function setupRabbitMQ() {
  console.log('🐰 Setting up RabbitMQ for Audit System...');

  let connection = null;
  let channel = null;

  try {
    // Connect to RabbitMQ
    const rabbitmqUrl = process.env.RABBITMQ_URL || 'amqp://guest:guest@localhost:5672';
    console.log(`Connecting to: ${rabbitmqUrl}`);
    
    connection = await amqp.connect(rabbitmqUrl);
    channel = await connection.createChannel();

    // Create exchange
    console.log('1. Creating audit exchange...');
    await channel.assertExchange('audit.exchange', 'topic', { durable: true });
    console.log('✅ Exchange created: audit.exchange');

    // Create queues
    console.log('2. Creating queues...');
    
    // Main processing queue
    await channel.assertQueue('audit.changes', {
      durable: true,
      arguments: {
        'x-dead-letter-exchange': 'audit.exchange',
        'x-dead-letter-routing-key': 'audit.dlq'
      }
    });
    console.log('✅ Queue created: audit.changes');

    // Dead letter queue
    await channel.assertQueue('audit.changes.dlq', { durable: true });
    console.log('✅ Queue created: audit.changes.dlq');

    // Retry queue
    await channel.assertQueue('audit.changes.retry', {
      durable: true,
      arguments: {
        'x-message-ttl': 30000,
        'x-dead-letter-exchange': 'audit.exchange',
        'x-dead-letter-routing-key': 'audit.changes'
      }
    });
    console.log('✅ Queue created: audit.changes.retry');

    // Bind queues
    console.log('3. Binding queues to exchange...');
    await channel.bindQueue('audit.changes', 'audit.exchange', 'audit.manufacturing_db.*');
    await channel.bindQueue('audit.changes.dlq', 'audit.exchange', 'audit.dlq');
    await channel.bindQueue('audit.changes.retry', 'audit.exchange', 'audit.retry');
    console.log('✅ Queue bindings created');

    // Get queue stats
    console.log('4. Checking queue status...');
    const mainQueue = await channel.checkQueue('audit.changes');
    const dlqQueue = await channel.checkQueue('audit.changes.dlq');
    const retryQueue = await channel.checkQueue('audit.changes.retry');

    console.log(`   audit.changes: ${mainQueue.messageCount} messages, ${mainQueue.consumerCount} consumers`);
    console.log(`   audit.changes.dlq: ${dlqQueue.messageCount} messages`);
    console.log(`   audit.changes.retry: ${retryQueue.messageCount} messages`);

    console.log('\n🎉 RabbitMQ setup completed successfully!');
    console.log('\nAccess RabbitMQ Management UI:');
    console.log('URL: http://localhost:15672');
    console.log('Username: guest');
    console.log('Password: guest');

  } catch (err) {
    console.error('❌ RabbitMQ setup failed:', err);
    process.exit(1);
  } finally {
    if (channel) await channel.close();
    if (connection) await connection.close();
  }
}

setupRabbitMQ();