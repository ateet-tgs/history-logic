require('dotenv').config();

const express = require('express');
const AuditConsumer = require('./services/AuditConsumer');
const { testConnection, logger } = require('./config/database');

const app = express();
app.use(express.json());

// Global variables
let auditConsumer = null;

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    const stats = auditConsumer ? await auditConsumer.getStats() : null;
    
    // Check Debezium health
    let debeziumHealth = 'unknown';
    try {
      const debeziumUrl = process.env.DEBEZIUM_HEALTH_URL || 'http://localhost:8080/q/health';
      const response = await fetch(debeziumUrl);
      debeziumHealth = response.ok ? 'healthy' : 'unhealthy';
    } catch (err) {
      debeziumHealth = 'unreachable';
    }

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      debezium: debeziumHealth,
      stats: stats
    });
  } catch (err) {
    logger.error('❌ Health check failed:', err);
    res.status(500).json({
      status: 'unhealthy',
      error: err.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Detailed stats endpoint
app.get('/stats', async (req, res) => {
  try {
    if (!auditConsumer) {
      return res.status(503).json({ error: 'Consumer not initialized' });
    }

    const stats = await auditConsumer.getStats();
    res.json(stats);
  } catch (err) {
    logger.error('❌ Stats endpoint error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Reset stats endpoint
app.post('/stats/reset', async (req, res) => {
  try {
    if (!auditConsumer) {
      return res.status(503).json({ error: 'Consumer not initialized' });
    }

    auditConsumer.auditProcessor.resetStats();
    res.json({ message: 'Stats reset successfully' });
  } catch (err) {
    logger.error('❌ Stats reset error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Manual flush endpoint (for testing)
app.post('/flush', async (req, res) => {
  try {
    if (!auditConsumer) {
      return res.status(503).json({ error: 'Consumer not initialized' });
    }

    await auditConsumer.flushAuditBatch();
    res.json({ message: 'Batch flushed successfully' });
  } catch (err) {
    logger.error('❌ Manual flush error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Start the application
async function startApplication() {
  try {
    logger.info('🚀 Starting Audit System...');

    // Test database connection
    logger.info('🔍 Testing database connection...');
    await testConnection();
    logger.info('✅ Database connection successful');

    // Initialize audit consumer
    logger.info('🔍 Initializing audit consumer...');
    auditConsumer = new AuditConsumer();
    await auditConsumer.init();
    logger.info('✅ Audit consumer started');

    // Start HTTP server for health checks
    const port = process.env.HEALTH_CHECK_PORT || 3001;
    app.listen(port, () => {
      logger.info(`✅ Health check server running on port ${port}`);
      logger.info(`📊 Stats: http://localhost:${port}/stats`);
      logger.info(`❤️ Health: http://localhost:${port}/health`);
      logger.info(`🔄 Manual flush: POST http://localhost:${port}/flush`);
    });

    logger.info('🎉 Audit System started successfully!');
    logger.info('📋 RabbitMQ Management: http://localhost:15672');
    logger.info('🔧 Debezium Health: http://localhost:8080/q/health');

  } catch (err) {
    logger.error('❌ Failed to start application:', err);
    process.exit(1);
  }
}

// Graceful shutdown
async function gracefulShutdown(signal) {
  logger.info(`\n🛑 Received ${signal}. Starting graceful shutdown...`);

  try {
    if (auditConsumer) {
      await auditConsumer.stop();
    }
    
    logger.info('✅ Graceful shutdown completed');
    process.exit(0);
  } catch (err) {
    logger.error('❌ Error during shutdown:', err);
    process.exit(1);
  }
}

// Handle shutdown signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  logger.error('❌ Uncaught Exception:', err);
  gracefulShutdown('uncaughtException');
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
  gracefulShutdown('unhandledRejection');
});

// Start the application
startApplication();