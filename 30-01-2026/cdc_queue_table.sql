/* ============================================================
   CDC AUDIT QUEUE TABLE
   Purpose: Fast write-only queue for audit changes
   Design: Optimized for INSERT performance, minimal indexes
   Created: 30-01-2026
============================================================ */

CREATE TABLE IF NOT EXISTS audit_change_queue (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    -- Audit metadata (same as dataentrychange_auditlog)
    root_table_name VARCHAR(100) NOT NULL,
    root_ref_id BIGINT NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    ref_trans_id BIGINT NOT NULL,
    entity_level TINYINT NOT NULL COMMENT '0=Header,1=Line,2=Release',
    entity_display_ref VARCHAR(255),

    -- JSON payloads (stored as-is for fast write)
    old_json JSON NOT NULL,
    new_json JSON NOT NULL,
    context_json JSON,

    -- User info
    updated_by VARCHAR(255),
    update_by_role_id INT,

    -- Queue management
    status TINYINT DEFAULT 0 COMMENT '0=Pending,1=Processing,2=Completed,3=Error',
    retry_count INT DEFAULT 0,
    error_message TEXT,

    -- Timestamps
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME NULL,

    -- Index for queue processing
    INDEX idx_status_created (status, created_at),
    INDEX idx_root (root_table_name, root_ref_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='CDC Queue for audit changes - fast write path';

/* ============================================================
   CONFIGURATION TABLE
   Purpose: Control queue processing behavior
============================================================ */

CREATE TABLE IF NOT EXISTS audit_queue_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value VARCHAR(500),
    description TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Default configuration
INSERT INTO audit_queue_config (config_key, config_value, description) VALUES
('batch_size', '100', 'Number of queue items to process per batch'),
('max_retries', '3', 'Maximum retry attempts for failed items'),
('processor_enabled', '1', 'Enable/disable queue processor (1=enabled, 0=disabled)'),
('processing_delay_ms', '100', 'Delay between batches in milliseconds')
ON DUPLICATE KEY UPDATE config_value = VALUES(config_value);

/* ============================================================
   PROCESSOR STATUS TABLE
   Purpose: Track processor status and metrics
============================================================ */

CREATE TABLE IF NOT EXISTS audit_queue_processor_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    processor_name VARCHAR(100) NOT NULL,
    last_run_at DATETIME,
    last_processed_id BIGINT,
    items_processed INT DEFAULT 0,
    items_failed INT DEFAULT 0,
    processing_time_ms INT,
    status VARCHAR(50) COMMENT 'RUNNING, IDLE, ERROR',
    error_message TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_processor_name (processor_name),
    INDEX idx_last_run (last_run_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
