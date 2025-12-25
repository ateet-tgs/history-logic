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
    IN p_updatedBy            BIGINT,
    IN p_updateByRoleId       INT
)
BEGIN
    DECLARE v_colName VARCHAR(100);
    DECLARE v_oldVal LONGTEXT;
    DECLARE v_newVal LONGTEXT;

    /* =====================================================
       Only run if old and new JSON exist
    ===================================================== */
    IF p_oldJSON IS NOT NULL AND p_newJSON IS NOT NULL THEN

        /* =====================================================
           1. Temporary diff table
        ===================================================== */
        DROP TEMPORARY TABLE IF EXISTS tmp_audit_diff;

        CREATE TEMPORARY TABLE tmp_audit_diff
        (
            col_name VARCHAR(100),
            old_val LONGTEXT,
            new_val LONGTEXT,
            PRIMARY KEY (col_name)
        ) ENGINE=InnoDB;

        /* =====================================================
           2. Extract column-wise diff from JSON
        ===================================================== */
        INSERT INTO tmp_audit_diff (col_name, old_val, new_val)
        SELECT
            jt.col_name,
            JSON_UNQUOTE(JSON_EXTRACT(p_oldJSON, CONCAT('$.', jt.col_name))) AS old_val,
            JSON_UNQUOTE(JSON_EXTRACT(p_newJSON, CONCAT('$.', jt.col_name))) AS new_val
        FROM
            JSON_TABLE(
                JSON_KEYS(p_oldJSON),
                '$[*]' COLUMNS (
                    col_name VARCHAR(100) PATH '$'
                )
            ) jt
        WHERE
            JSON_UNQUOTE(JSON_EXTRACT(p_oldJSON, CONCAT('$.', jt.col_name)))
            <> JSON_UNQUOTE(JSON_EXTRACT(p_newJSON, CONCAT('$.', jt.col_name)));

        /* =====================================================
           3. Insert audit rows (metadata-driven)
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
            p_updatedBy,
            p_updateByRoleId
        FROM tmp_audit_diff d
        JOIN audit_column_metadata m
          ON m.table_name = p_tableName
         AND m.col_name = d.col_name;

        /* =====================================================
           4. Cleanup
        ===================================================== */
        DROP TEMPORARY TABLE IF EXISTS tmp_audit_diff;

    END IF;

END$$
DELIMITER ;
