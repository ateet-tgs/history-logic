const BaseTableProcessor = require('./BaseTableProcessor');
const { logger } = require('../config/database');

class RohsPeersProcessor extends BaseTableProcessor {
  // THIS REPLACES YOUR TRIGGER: rohs_peers_AFTER_INSERT

  async getContext(row) {
    // Your original trigger logic was:
    // INSERT INTO dataentrychange_auditlog (
    //   root_table_name, root_ref_id, entity_display_ref, ...
    // ) VALUES (
    //   'rohs_substance', NEW.source_substance_id, 'Peers Added', ...
    // );
    
    return {
      rootTableName: 'rohs_substance',
      rootRefId: row.source_substance_id,
      displayRef: 'Peers Added'
    };
  }

  async processInsert(row, timestamp, source) {
    // Your original trigger only audited target_substance_id on INSERT
    const context = await this.getContext(row);

    return [{
      root_table_name: context.rootTableName,
      root_ref_id: context.rootRefId,
      table_name: this.tableName,
      ref_trans_id: row.id,
      entity_level: this.config.entityLevel,
      entity_display_ref: context.displayRef,
      col_name: 'target_substance_id',
      old_val: '', // Your original trigger used empty string
      new_val: this.serializeValue(row.target_substance_id),
      updated_at: new Date(timestamp),
      updated_by: row.created_by || null,
      update_by_role_id: row.create_by_role_id || null,
      value_type: 'reference'
    }];
  }

  // Override to handle updates differently if needed
  async processUpdate(before, after, timestamp, source) {
    // If you want different logic for updates vs the base class
    return await super.processUpdate(before, after, timestamp, source);
  }

  async processDelete(row, timestamp, source) {
    // Handle delete operations for rohs_peers
    const context = await this.getContext(row);

    return [{
      root_table_name: context.rootTableName,
      root_ref_id: context.rootRefId,
      table_name: this.tableName,
      ref_trans_id: row.id,
      entity_level: this.config.entityLevel,
      entity_display_ref: 'Peers Removed',
      col_name: 'target_substance_id',
      old_val: this.serializeValue(row.target_substance_id),
      new_val: null,
      updated_at: new Date(timestamp),
      updated_by: null,
      update_by_role_id: null,
      value_type: 'reference'
    }];
  }
}

module.exports = RohsPeersProcessor;