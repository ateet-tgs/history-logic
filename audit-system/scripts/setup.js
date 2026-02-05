require('dotenv').config();

const { testConnection, logger } = require('../src/config/database');
const rabbitmqConfig = require('../src/config/rabbitmq');
const http = require('http');

async function setupSystem() {
  console.log('🔧 Setting up Audit System for Windows...');

  try {
    // 1. Test database connection
    console.log('1. Testing database connection...');
    await testConnection();
    console.log('✅ Database connection successful');

    // 2. Test RabbitMQ connection
    console.log('2. Testing RabbitMQ connection...');
    await rabbitmqConfig.connect();
    console.log('✅ RabbitMQ connection successful');
    await rabbitmqConfig.close();

    // 3. Check if Debezium is running
    console.log('3. Checking Debezium Server...');
    const debeziumRunning = await checkDebeziumHealth();
    if (debeziumRunning) {
      console.log('✅ Debezium Server is running');
    } else {
      console.log('⚠️ Debezium Server not running. Start with: docker-compose up -d');
    }

    // 4. Verify binlog is enabled
    console.log('4. Checking MySQL binlog configuration...');
    await checkBinlogConfiguration();

    console.log('\n🎉 Setup completed successfully!');
    console.log('\nNext steps:');
    console.log('1. If Debezium not running: cd docker && docker-compose up -d');
    console.log('2. Wait for Debezium to be ready (30-60 seconds)');
    console.log('3. Start the application: npm start');
    console.log('4. Test with a database change');
    console.log('5. Check audit logs: SELECT * FROM dataentrychange_auditlog ORDER BY updated_at DESC LIMIT 10;');

  } catch (err) {
    console.error('❌ Setup failed:', err);
    process.exit(1);
  }
}

async function checkDebeziumHealth() {
  return new Promise((resolve) => {
    const req = http.get('http://localhost:8080/q/health', (res) => {
      resolve(res.statusCode === 200);
    });
    
    req.on('error', () => {
      resolve(false);
    });
    
    req.setTimeout(5000, () => {
      req.destroy();
      resolve(false);
    });
  });
}

async function checkBinlogConfiguration() {
  const { executeQuery } = require('../src/config/database');
  
  try {
    // Check if binlog is enabled
    const binlogStatus = await executeQuery("SHOW VARIABLES LIKE 'log_bin'");
    const binlogFormat = await executeQuery("SHOW VARIABLES LIKE 'binlog_format'");
    const binlogRowImage = await executeQuery("SHOW VARIABLES LIKE 'binlog_row_image'");
    
    console.log('   Binlog enabled:', binlogStatus[0]?.Value || 'OFF');
    console.log('   Binlog format:', binlogFormat[0]?.Value || 'UNKNOWN');
    console.log('   Binlog row image:', binlogRowImage[0]?.Value || 'UNKNOWN');
    
    if (binlogStatus[0]?.Value !== 'ON') {
      console.log('⚠️ MySQL binlog is not enabled. Please add to my.ini:');
      console.log('   [mysqld]');
      console.log('   server-id = 1');
      console.log('   log_bin = mysql-bin');
      console.log('   binlog_format = ROW');
      console.log('   binlog_row_image = FULL');
      console.log('   Then restart MySQL service');
    } else {
      console.log('✅ MySQL binlog configuration looks good');
    }
    
    // Check if debezium user exists
    const users = await executeQuery("SELECT User, Host FROM mysql.user WHERE User = 'debezium_user'");
    if (users.length === 0) {
      console.log('⚠️ Debezium user not found. Run: sql/01_enable_binlog.sql');
    } else {
      console.log('✅ Debezium user exists');
    }
    
  } catch (err) {
    console.log('⚠️ Could not check binlog configuration:', err.message);
  }
}

setupSystem();