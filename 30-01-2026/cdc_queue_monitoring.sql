/* ============================================================
   CDC QUEUE MONITORING & UTILITIES
   Purpose: Monitor queue health and manage processing
   Created: 30-01-2026
============================================================ */

-- View queue status
DROP PROCEDURE IF EXISTS Sproc_Audit_Queue_Status;
DELIMITER $$

CREATE PROCEDURE Sproc_Audit_Queue_Status()
BEGIN
    SELECT
        status,
        CASE status
            WHEN 0 THEN 'Pending'
            WHEN 1 THEN 'Processing'
            WHEN 2 THEN 'Completed'
            WHEN 3 THEN 'Error'
            ELSE 'Unknown'
        END AS status_name,
        COUNT(*) AS count,
        MIN(created_at) AS oldest_pending,
        MAX(created_at) AS newest_pending,
        AVG(retry_count) AS avg_retries
    FROM audit_change_queue
    GROUP BY status;

    SELECT
        processor_name,
        last_run_at,
        items_processed,
        items_failed,
        processing_time_ms,
        status
    FROM audit_queue_processor_status
    ORDER BY last_run_at DESC
    LIMIT 10;
END$$

DELIMITER ;

-- Cleanup old processed items
DROP PROCEDURE IF EXISTS Sproc_Audit_Queue_Cleanup;
DELIMITER $$

CREATE PROCEDURE Sproc_Audit_Queue_Cleanup(
    IN p_daysToKeep INT DEFAULT 7
)
BEGIN
    DELETE FROM audit_change_queue
    WHERE status = 2
      AND processed_at < DATE_SUB(NOW(), INTERVAL p_daysToKeep DAY);

    SELECT ROW_COUNT() AS deleted_count;
END$$

DELIMITER ;

-- Retry failed items
DROP PROCEDURE IF EXISTS Sproc_Audit_Queue_Retry_Failed;
DELIMITER $$

CREATE PROCEDURE Sproc_Audit_Queue_Retry_Failed()
BEGIN
    UPDATE audit_change_queue
    SET status = 0, error_message = NULL
    WHERE status = 3
      AND retry_count < (SELECT COALESCE(CAST(config_value AS UNSIGNED), 3)
                         FROM audit_queue_config WHERE config_key = 'max_retries' LIMIT 1);

    SELECT ROW_COUNT() AS retried_count;
END$$

DELIMITER ;
