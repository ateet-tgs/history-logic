/* ============================================================
   CDC QUEUE INSERT PROCEDURE
   Purpose: Fast, lightweight procedure called by triggers
   Design: Minimal processing, just insert JSON payloads
   Created: 30-01-2026
============================================================ */

DROP PROCEDURE IF EXISTS Sproc_Audit_Queue_Insert;
DELIMITER $$

CREATE PROCEDURE Sproc_Audit_Queue_Insert(
    IN p_rootTableName        VARCHAR(100),
    IN p_rootRefID            BIGINT,
    IN p_tableName            VARCHAR(100),
    IN p_refTransID           BIGINT,
    IN p_entityLevel          TINYINT,
    IN p_entityDisplayRef     VARCHAR(255),
    IN p_oldJSON              JSON,
    IN p_newJSON              JSON,
    IN p_contextJSON          JSON,
    IN p_updatedBy            VARCHAR(255),
    IN p_updateByRoleId       INT
)
BEGIN
    /* Guard: Skip if no changes */
    IF p_oldJSON IS NOT NULL AND p_newJSON IS NOT NULL THEN
        INSERT INTO audit_change_queue (
            root_table_name,
            root_ref_id,
            table_name,
            ref_trans_id,
            entity_level,
            entity_display_ref,
            old_json,
            new_json,
            context_json,
            updated_by,
            update_by_role_id,
            status,
            created_at
        ) VALUES (
            p_rootTableName,
            p_rootRefID,
            p_tableName,
            p_refTransID,
            p_entityLevel,
            p_entityDisplayRef,
            p_oldJSON,
            p_newJSON,
            p_contextJSON,
            p_updatedBy,
            p_updateByRoleId,
            0,
            NOW()
        );
    END IF;
END$$

DELIMITER ;
