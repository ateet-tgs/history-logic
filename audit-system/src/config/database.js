const mysql = require('mysql2/promise');
const winston = require('winston');

// Configure logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

const config = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'manufacturing_db',
  waitForConnections: true,
  connectionLimit: 20,
  queueLimit: 0,
  acquireTimeout: 60000,
  timeout: 60000,
  charset: 'utf8mb4',
  timezone: '+00:00'
};

let pool = null;

const getPool = () => {
  if (!pool) {
    pool = mysql.createPool(config);
    
    // Handle pool events
    pool.on('connection', (connection) => {
      logger.info(`New DB connection established as id ${connection.threadId}`);
    });

    pool.on('error', (err) => {
      logger.error('Database pool error:', err);
      if (err.code === 'PROTOCOL_CONNECTION_LOST') {
        handleDisconnect();
      } else {
        throw err;
      }
    });

    logger.info('✅ Database pool created');
  }
  return pool;
};

const handleDisconnect = () => {
  logger.warn('🔄 Reconnecting to database...');
  pool = null;
  setTimeout(() => {
    getPool();
  }, 2000);
};

const closePool = async () => {
  if (pool) {
    await pool.end();
    pool = null;
    logger.info('✅ Database pool closed');
  }
};

const testConnection = async () => {
  const testPool = mysql.createPool(config);
  try {
    const connection = await testPool.getConnection();
    await connection.ping();
    
    // Test audit table access
    const [rows] = await connection.query('SELECT COUNT(*) as count FROM dataentrychange_auditlog LIMIT 1');
    logger.info(`✅ Database test successful. Audit table has ${rows[0].count} records`);
    
    connection.release();
    await testPool.end();
    return true;
  } catch (err) {
    await testPool.end();
    logger.error('❌ Database test failed:', err);
    throw err;
  }
};

const executeQuery = async (query, params = []) => {
  const pool = getPool();
  const connection = await pool.getConnection();
  try {
    const [results] = await connection.execute(query, params);
    return results;
  } finally {
    connection.release();
  }
};

module.exports = {
  getPool,
  closePool,
  testConnection,
  executeQuery,
  config,
  logger
};