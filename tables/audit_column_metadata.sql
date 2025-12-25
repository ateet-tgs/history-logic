CREATE TABLE audit_column_metadata (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    col_name VARCHAR(100) NOT NULL,

    -- Foreign key configuration
    is_foreign_key TINYINT(1) DEFAULT 0,
    ref_table VARCHAR(100),
    ref_pk VARCHAR(100),
    ref_display_column VARCHAR(100),

    UNIQUE KEY uq_table_col (table_name, col_name)
);