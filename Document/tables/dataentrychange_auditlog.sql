CREATE TABLE dataentrychange_auditlog (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    -- Root context (top-level entity reference)
    root_table_name VARCHAR(100) NOT NULL,
    root_ref_id BIGINT NOT NULL,

    -- Current entity context (child/nested entity reference)
    table_name VARCHAR(100) NOT NULL,
    ref_trans_id BIGINT NOT NULL,
    entity_level TINYINT NOT NULL,
    entity_display_ref VARCHAR(255),

    -- Field change context
    col_name VARCHAR(100),
    old_val LONGTEXT,
    new_val LONGTEXT,

    -- Audit metadata
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    update_by_role_id INT,

    -- Performance indexes
    INDEX idx_root (root_table_name, root_ref_id),
    INDEX idx_entity (table_name, ref_trans_id),
    INDEX idx_col (table_name, col_name)
);