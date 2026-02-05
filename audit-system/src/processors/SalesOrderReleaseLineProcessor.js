const BaseTableProcessor = require('./BaseTableProcessor');
const { logger } = require('../config/database');

class SalesOrderReleaseLineProcessor extends BaseTableProcessor {
  // THIS REPLACES YOUR TRIGGER: trg_audit_sales_order_release

  async getContext(row) {
    const conn = await this.pool.getConnection();
    try {
      // Your original trigger logic:
      // DECLARE v_so_id BIGINT;
      // DECLARE v_part_id BIGINT;
      // DECLARE v_version INT;
      // DECLARE v_order_no VARCHAR(50);

      // SELECT l.sales_order_id, l.part_id
      //   INTO v_so_id, v_part_id
      // FROM sales_order_line_detail l
      // WHERE l.id = NEW.line_detail_id;
      
      const [lineDetails] = await conn.query(
        'SELECT sales_order_id, part_id FROM sales_order_line_detail WHERE id = ?',
        [row.line_detail_id]
      );

      if (lineDetails.length === 0) {
        logger.warn(`⚠️ No line detail found for line_detail_id: ${row.line_detail_id}`);
        return {
          rootTableName: 'sales_order',
          rootRefId: null,
          displayRef: `Release #${row.id}`
        };
      }

      const { sales_order_id, part_id } = lineDetails[0];

      // SELECT order_no, version
      //   INTO v_order_no, v_version
      // FROM sales_order
      // WHERE id = v_so_id;
      
      const [salesOrders] = await conn.query(
        'SELECT order_no, version FROM sales_order WHERE id = ?',
        [sales_order_id]
      );

      const orderInfo = salesOrders[0] || {};

      return {
        rootTableName: 'sales_order',
        rootRefId: sales_order_id,
        displayRef: orderInfo.order_no || `SO #${sales_order_id}`,
        contextData: {
          part_id: part_id,
          sales_order_version: orderInfo.version,
          line_detail_id: row.line_detail_id
        }
      };

    } catch (err) {
      logger.error(`❌ Error getting context for sales_order_release_line:${row.id}:`, err);
      // Return fallback context
      return {
        rootTableName: 'sales_order',
        rootRefId: null,
        displayRef: `Release #${row.id}`
      };
    } finally {
      conn.release();
    }
  }

  async processUpdate(before, after, timestamp, source) {
    // Call parent method to get base audit records
    const auditRecords = await super.processUpdate(before, after, timestamp, source);

    // Add context snapshots if needed (your original context JSON logic)
    const context = await this.getContext(after);
    
    if (context.contextData && auditRecords.length > 0) {
      // Store context snapshot for complex auditing
      await this.storeContextSnapshot(after.id, context.contextData, timestamp);
    }

    return auditRecords;
  }

  async storeContextSnapshot(refTransId, contextData, timestamp) {
    const conn = await this.pool.getConnection();
    try {
      await conn.query(
        `INSERT INTO audit_change_context_snapshot 
         (table_name, ref_trans_id, context_json, created_at) 
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE 
         context_json = VALUES(context_json), 
         updated_at = VALUES(created_at)`,
        [this.tableName, refTransId, JSON.stringify(contextData), new Date(timestamp)]
      );
      
      logger.debug(`📸 Stored context snapshot for ${this.tableName}:${refTransId}`);
    } catch (err) {
      logger.error('❌ Failed to store context snapshot:', err);
      // Don't throw - context snapshot is supplementary
    } finally {
      conn.release();
    }
  }
}

module.exports = SalesOrderReleaseLineProcessor;