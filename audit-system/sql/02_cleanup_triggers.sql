-- Backup existing triggers before dropping
USE manufacturing_db;

-- Show existing triggers
SHOW TRIGGERS LIKE 'sales_order_release_line';
SHOW TRIGGERS LIKE 'rohs_peers';

-- Drop existing triggers (run after new system is verified)
DROP TRIGGER IF EXISTS trg_audit_sales_order_release;
DROP TRIGGER IF EXISTS rohs_peers_AFTER_INSERT;

-- Drop any related stored procedures
DROP PROCEDURE IF EXISTS Sproc_Audit_Generic_Update;

-- Add indexes for better audit performance
CREATE INDEX IF NOT EXISTS idx_audit_root_table_ref 
ON dataentrychange_auditlog(root_table_name, root_ref_id);

CREATE INDEX IF NOT EXISTS idx_audit_table_ref 
ON dataentrychange_auditlog(table_name, ref_trans_id);

CREATE INDEX IF NOT EXISTS idx_audit_updated_at 
ON dataentrychange_auditlog(updated_at DESC);

-- Verify audit table structure
DESCRIBE dataentrychange_auditlog;