require('dotenv').config();

const http = require('http');

async function healthCheck() {
  const port = process.env.HEALTH_CHECK_PORT || 3001;
  
  console.log('🏥 Running health check...');
  
  try {
    const health = await makeRequest(`http://localhost:${port}/health`);
    console.log('📊 Health Check Results:');
    console.log(JSON.stringify(health, null, 2));
    
    // Check individual components
    console.log('\n🔍 Component Status:');
    console.log(`Application: ${health.status}`);
    console.log(`Debezium: ${health.debezium}`);
    console.log(`Uptime: ${Math.floor(health.uptime)}s`);
    
    if (health.stats) {
      console.log(`Messages Processed: ${health.stats.consumer.processed}`);
      console.log(`Current Batch Size: ${health.stats.consumer.currentBatchSize}`);
      console.log(`Processing Rate: ${health.stats.consumer.processingRate}`);
    }
    
    process.exit(0);
  } catch (err) {
    console.error('❌ Health check failed:', err.message);
    
    // Try to get more details
    try {
      const stats = await makeRequest(`http://localhost:${port}/stats`);
      console.log('\n📊 Available Stats:');
      console.log(JSON.stringify(stats, null, 2));
    } catch (statsErr) {
      console.error('❌ Could not retrieve stats:', statsErr.message);
    }
    
    process.exit(1);
  }
}

function makeRequest(url) {
  return new Promise((resolve, reject) => {
    const req = http.get(url, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          resolve(result);
        } catch (err) {
          reject(new Error(`Invalid JSON response: ${data}`));
        }
      });
    });
    
    req.on('error', (err) => {
      reject(err);
    });
    
    req.setTimeout(10000, () => {
      req.destroy();
      reject(new Error('Health check timeout'));
    });
  });
}

healthCheck();