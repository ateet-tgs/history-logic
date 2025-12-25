DROP PROCEDURE IF EXISTS Sproc_Audit_Generic_Update;
DELIMITER $$

CREATE PROCEDURE Sproc_Audit_Generic_Update
(
    IN p_rootTableName        VARCHAR(100),
    IN p_rootRefID            BIGINT,
    IN p_tableName            VARCHAR(100),
    IN p_refTransID           BIGINT,
    IN p_entityLevel          TINYINT,
    IN p_entityDisplayRef     VARCHAR(255),
    IN p_oldJSON              JSON,
    IN p_newJSON              JSON,
    IN p_contextJSON          JSON,
    IN p_updatedBy            BIGINT,
    IN p_updateByRoleId       INT
)
BEGIN

    /* =====================================================
       Only proceed if both JSONs exist
    ===================================================== */
    IF p_oldJSON IS NOT NULL AND p_newJSON IS NOT NULL THEN

        /* =====================================================
           1. TEMP DIFF TABLE
        ===================================================== */
        DROP TEMPORARY TABLE IF EXISTS tmp_audit_diff;

        CREATE TEMPORARY TABLE tmp_audit_diff
        (
            col_name VARCHAR(100),
            old_val  LONGTEXT,
            new_val  LONGTEXT,
            PRIMARY KEY (col_name)
        ) ENGINE=InnoDB;

        /* =====================================================
           2. DIFF EXTRACTION
        ===================================================== */
        INSERT INTO tmp_audit_diff (col_name, old_val, new_val)
        SELECT
            jt.col_name,
            JSON_UNQUOTE(JSON_EXTRACT(p_oldJSON, CONCAT('$.', jt.col_name))),
            JSON_UNQUOTE(JSON_EXTRACT(p_newJSON, CONCAT('$.', jt.col_name)))
        FROM JSON_TABLE(
                JSON_KEYS(p_oldJSON),
                '$[*]' COLUMNS (
                    col_name VARCHAR(100) PATH '$'
                )
             ) jt
        WHERE
            JSON_UNQUOTE(JSON_EXTRACT(p_oldJSON, CONCAT('$.', jt.col_name)))
            <> JSON_UNQUOTE(JSON_EXTRACT(p_newJSON, CONCAT('$.', jt.col_name)));

        /* =====================================================
           3. INSERT AUDIT LOGS
        ===================================================== */
        INSERT INTO dataentrychange_auditlog
        (
            root_table_name,
            root_ref_id,
            table_name,
            ref_trans_id,
            entity_level,
            entity_display_ref,
            col_name,
            old_val,
            new_val,
            updated_at,
            updated_by,
            update_by_role_id
        )
        SELECT
            p_rootTableName,
            p_rootRefID,
            p_tableName,
            p_refTransID,
            p_entityLevel,
            p_entityDisplayRef,
            d.col_name,
            d.old_val,
            d.new_val,
            NOW(),
            p_updatedBy,
            p_updateByRoleId
        FROM tmp_audit_diff d
        JOIN audit_column_metadata m
          ON m.table_name = p_tableName
         AND m.col_name   = d.col_name
         AND m.is_context_field = 0;

        /* =====================================================
           4. CONTEXT SNAPSHOT (FULLY DYNAMIC)
        ===================================================== */
        IF p_contextJSON IS NOT NULL THEN

            INSERT INTO audit_change_context_snapshot
            (
                audit_log_id,
                context_field,
                context_value
            )
            SELECT
                a.id,
                m.col_name,
                JSON_UNQUOTE(
                    JSON_EXTRACT(p_contextJSON, CONCAT('$.', m.col_name))
                )
            FROM dataentrychange_auditlog a
            JOIN audit_column_metadata m
              ON m.table_name = p_tableName
             AND m.is_context_field = 1
            WHERE a.table_name   = p_tableName
              AND a.ref_trans_id = p_refTransID
              AND JSON_EXTRACT(p_contextJSON, CONCAT('$.', m.col_name)) IS NOT NULL;

        END IF;

        /* =====================================================
           5. CLEANUP
        ===================================================== */
        DROP TEMPORARY TABLE IF EXISTS tmp_audit_diff;

    END IF;

END$$
DELIMITER ;
