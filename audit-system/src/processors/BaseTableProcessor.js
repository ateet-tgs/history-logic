const { getPool, logger } = require('../config/database');

class BaseTableProcessor {
  constructor(tableName, config) {
    this.tableName = tableName;
    this.config = config;
    this.pool = getPool();
  }

  async process(operation, before, after, timestamp, source) {
    if (!this.config.enabled) {
      logger.info(`⏭️ Skipping disabled table: ${this.tableName}`);
      return [];
    }

    try {
      const op = this.normalizeOperation(operation);
      
      switch (op) {
        case 'INSERT':
          return await this.processInsert(after, timestamp, source);
        case 'UPDATE':
          return await this.processUpdate(before, after, timestamp, source);
        case 'DELETE':
          return await this.processDelete(before, timestamp, source);
        case 'READ':
          return []; // Skip snapshot reads
        default:
          logger.warn(`Unknown operation: ${operation} for table ${this.tableName}`);
          return [];
      }
    } catch (err) {
      logger.error(`❌ Processing error for ${this.tableName}:`, err);
      throw err;
    }
  }

  normalizeOperation(operation) {
    // Handle both Debezium operations (c,u,d) and standard operations
    const opMap = {
      'c': 'INSERT',
      'u': 'UPDATE',
      'd': 'DELETE',
      'r': 'READ', // Skip read operations
      'INSERT': 'INSERT',
      'UPDATE': 'UPDATE',
      'DELETE': 'DELETE'
    };
    return opMap[operation] || operation;
  }

  async processInsert(row, timestamp, source) {
    if (!row) return [];

    const context = await this.getContext(row);
    const auditRecords = [];

    // Audit all non-system columns for inserts
    for (const [col, val] of Object.entries(row)) {
      if (this.config.systemColumns.includes(col)) continue;
      if (this.config.contextFields.includes(col)) continue;
      if (val === null || val === undefined) continue;

      auditRecords.push({
        root_table_name: context.rootTableName,
        root_ref_id: context.rootRefId,
        table_name: this.tableName,
        ref_trans_id: row.id,
        entity_level: this.config.entityLevel,
        entity_display_ref: context.displayRef,
        col_name: col,
        old_val: null,
        new_val: this.serializeValue(val),
        updated_at: new Date(timestamp),
        updated_by: row.created_by || null,
        update_by_role_id: row.create_by_role_id || null,
        value_type: this.getValueType(col, val)
      });
    }

    return auditRecords;
  }

  async processUpdate(before, after, timestamp, source) {
    if (!before || !after) return [];

    // Detect changed columns
    const changes = {};
    for (const col of this.config.auditableColumns) {
      if (this.serializeValue(before[col]) !== this.serializeValue(after[col])) {
        changes[col] = { old: before[col], new: after[col] };
      }
    }

    if (Object.keys(changes).length === 0) {
      logger.debug(`⏭️ No auditable changes for ${this.tableName}:${after.id}`);
      return [];
    }

    const context = await this.getContext(after);
    const auditRecords = [];

    for (const [col, { old, new: newVal }] of Object.entries(changes)) {
      auditRecords.push({
        root_table_name: context.rootTableName,
        root_ref_id: context.rootRefId,
        table_name: this.tableName,
        ref_trans_id: after.id,
        entity_level: this.config.entityLevel,
        entity_display_ref: context.displayRef,
        col_name: col,
        old_val: this.serializeValue(old),
        new_val: this.serializeValue(newVal),
        updated_at: new Date(timestamp),
        updated_by: after.updated_by || null,
        update_by_role_id: after.update_by_role_id || null,
        value_type: this.getValueType(col, newVal)
      });
    }

    return auditRecords;
  }

  async processDelete(row, timestamp, source) {
    if (!row) return [];

    const context = await this.getContext(row);
    const auditRecords = [];

    for (const col of this.config.auditableColumns) {
      if (row[col] !== undefined && row[col] !== null) {
        auditRecords.push({
          root_table_name: context.rootTableName,
          root_ref_id: context.rootRefId,
          table_name: this.tableName,
          ref_trans_id: row.id,
          entity_level: this.config.entityLevel,
          entity_display_ref: context.displayRef,
          col_name: col,
          old_val: this.serializeValue(row[col]),
          new_val: null,
          updated_at: new Date(timestamp),
          updated_by: null,
          update_by_role_id: null,
          value_type: this.getValueType(col, row[col])
        });
      }
    }

    return auditRecords;
  }

  async getContext(row) {
    // Default implementation - override in subclasses for complex logic
    return {
      rootTableName: this.config.rootTable,
      rootRefId: row.id,
      displayRef: `Record #${row.id}`
    };
  }

  getValueType(columnName, value) {
    // Determine value type based on column name or value
    if (typeof value === 'number') return 'number';
    if (typeof value === 'boolean') return 'boolean';
    if (value instanceof Date) return 'date';
    if (columnName.includes('_id')) return 'reference';
    if (columnName.includes('_at')) return 'timestamp';
    return 'text';
  }

  serializeValue(value) {
    if (value === null || value === undefined) return null;
    if (typeof value === 'string') return value;
    return JSON.stringify(value);
  }
}

module.exports = BaseTableProcessor;