module.exports = {
  // Table configurations - YOUR TRIGGER LOGIC MOVES HERE
  tables: {
    'sales_order_release_line': {
      processor: 'SalesOrderReleaseLineProcessor',
      rootTable: 'sales_order',
      entityLevel: 2,
      contextFields: ['line_detail_id'],
      auditableColumns: ['release_no', 'released_qty', 'release_date'],
      systemColumns: ['id', 'created_at', 'updated_at', 'created_by', 'updated_by', 'update_by_role_id'],
      enabled: true,
      description: 'Sales order release line auditing - replaces trg_audit_sales_order_release'
    },
    'rohs_peers': {
      processor: 'RohsPeersProcessor',
      rootTable: 'rohs_substance',
      entityLevel: 1,
      contextFields: ['source_substance_id', 'target_substance_id'],
      auditableColumns: ['target_substance_id'],
      systemColumns: ['id', 'created_at', 'updated_at', 'created_by', 'updated_by', 'create_by_role_id'],
      enabled: true,
      description: 'RoHS peers auditing - replaces rohs_peers_AFTER_INSERT'
    },
    'sales_order': {
      processor: 'BaseTableProcessor',
      rootTable: 'sales_order',
      entityLevel: 0,
      contextFields: [],
      auditableColumns: ['order_no', 'customer_id', 'order_date', 'status'],
      systemColumns: ['id', 'created_at', 'updated_at', 'version'],
      enabled: true,
      description: 'Sales order base auditing'
    },
    'sales_order_line_detail': {
      processor: 'BaseTableProcessor',
      rootTable: 'sales_order',
      entityLevel: 1,
      contextFields: ['sales_order_id'],
      auditableColumns: ['part_id', 'quantity', 'unit_price'],
      systemColumns: ['id', 'created_at', 'updated_at'],
      enabled: true,
      description: 'Sales order line detail auditing'
    }
  },

  // Batch processing settings
  batch: {
    size: parseInt(process.env.BATCH_SIZE) || 100,
    timeoutMs: parseInt(process.env.BATCH_TIMEOUT_MS) || 5000
  },

  // Retry settings
  retry: {
    maxAttempts: parseInt(process.env.MAX_RETRY_ATTEMPTS) || 3,
    backoffMs: 1000
  },

  // Debezium message routing patterns
  debezium: {
    topicPrefix: 'audit.manufacturing_db',
    routingKeyPattern: 'audit.manufacturing_db.{table}'
  },

  // Windows specific settings
  windows: {
    serviceName: process.env.WINDOWS_SERVICE_NAME || 'AuditSystem',
    logPath: './logs',
    pidFile: './audit-system.pid'
  }
};