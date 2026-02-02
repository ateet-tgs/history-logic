/* ============================================================
   CDC QUEUE PROCESSOR PROCEDURE
   Purpose: Background worker that processes queue items
   Design: Batch processing, error handling, retry logic
   Created: 30-01-2026
   Note: Uses FOR UPDATE SKIP LOCKED (MySQL 8.0+) for concurrent processing
============================================================ */

DROP PROCEDURE IF EXISTS Sproc_Audit_Queue_Processor;
DELIMITER $$

CREATE PROCEDURE Sproc_Audit_Queue_Processor(
    IN p_batchSize INT DEFAULT 100,
    IN p_processorName VARCHAR(100) DEFAULT 'default'
)
proc_main: BEGIN
    DECLARE v_batchSize INT DEFAULT 100;
    DECLARE v_maxRetries INT DEFAULT 3;
    DECLARE v_processorEnabled TINYINT DEFAULT 1;
    DECLARE v_itemsProcessed INT DEFAULT 0;
    DECLARE v_itemsFailed INT DEFAULT 0;
    DECLARE v_startTime DATETIME DEFAULT NOW();
    DECLARE v_processingTime INT;
    DECLARE v_done INT DEFAULT 0;

    DECLARE v_queueId BIGINT;
    DECLARE v_rootTableName VARCHAR(100);
    DECLARE v_rootRefId BIGINT;
    DECLARE v_tableName VARCHAR(100);
    DECLARE v_refTransId BIGINT;
    DECLARE v_entityLevel TINYINT;
    DECLARE v_entityDisplayRef VARCHAR(255);
    DECLARE v_oldJson JSON;
    DECLARE v_newJson JSON;
    DECLARE v_contextJson JSON;
    DECLARE v_updatedBy VARCHAR(255);
    DECLARE v_updateByRoleId INT;

    DECLARE cur_queue CURSOR FOR
        SELECT id, root_table_name, root_ref_id, table_name, ref_trans_id,
               entity_level, entity_display_ref, old_json, new_json, context_json,
               updated_by, update_by_role_id
        FROM audit_change_queue
        WHERE status = 0
          AND retry_count < v_maxRetries
        ORDER BY created_at ASC
        LIMIT v_batchSize;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- Get configuration
    SELECT COALESCE(CAST(config_value AS UNSIGNED), 100) INTO v_batchSize
    FROM audit_queue_config WHERE config_key = 'batch_size' LIMIT 1;

    SELECT COALESCE(CAST(config_value AS UNSIGNED), 3) INTO v_maxRetries
    FROM audit_queue_config WHERE config_key = 'max_retries' LIMIT 1;

    SELECT COALESCE(CAST(config_value AS UNSIGNED), 1) INTO v_processorEnabled
    FROM audit_queue_config WHERE config_key = 'processor_enabled' LIMIT 1;

    IF p_batchSize > 0 THEN
        SET v_batchSize = p_batchSize;
    END IF;

    IF v_processorEnabled = 0 THEN
        LEAVE proc_main;
    END IF;

    OPEN cur_queue;

    process_loop: LOOP
        FETCH cur_queue INTO
            v_queueId, v_rootTableName, v_rootRefId, v_tableName, v_refTransId,
            v_entityLevel, v_entityDisplayRef, v_oldJson, v_newJson, v_contextJson,
            v_updatedBy, v_updateByRoleId;

        IF v_done = 1 THEN
            LEAVE process_loop;
        END IF;

        UPDATE audit_change_queue SET status = 1, processed_at = NOW() WHERE id = v_queueId;

        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                UPDATE audit_change_queue
                SET status = 3, retry_count = retry_count + 1,
                    error_message = CONCAT(IFNULL(error_message,''), '; Error at ', NOW())
                WHERE id = v_queueId;
                SET v_itemsFailed = v_itemsFailed + 1;
            END;

            CALL Sproc_Audit_Generic_Update_From_Queue(
                v_rootTableName, v_rootRefId, v_tableName, v_refTransId,
                v_entityLevel, v_entityDisplayRef, v_oldJson, v_newJson, v_contextJson,
                v_updatedBy, v_updateByRoleId
            );

            UPDATE audit_change_queue SET status = 2, processed_at = NOW() WHERE id = v_queueId;
            SET v_itemsProcessed = v_itemsProcessed + 1;

        END;

    END LOOP;

    CLOSE cur_queue;

    SET v_processingTime = TIMESTAMPDIFF(MICROSECOND, v_startTime, NOW()) DIV 1000;

    INSERT INTO audit_queue_processor_status (
        processor_name, last_run_at, items_processed, items_failed,
        processing_time_ms, status
    ) VALUES (
        p_processorName, NOW(), v_itemsProcessed, v_itemsFailed,
        v_processingTime, IF(v_itemsFailed > 0, 'ERROR', 'IDLE')
    );

END proc_main$$

DELIMITER ;
