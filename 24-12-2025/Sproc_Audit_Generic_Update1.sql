DROP PROCEDURE IF EXISTS Sproc_Audit_Generic_Update;
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Sproc_Audit_Generic_Update`(
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
main_block: BEGIN

    /* ===============================
       DECLARES
       =============================== */
    DECLARE done INT DEFAULT 0;
    DECLARE v_col VARCHAR(100);
    DECLARE v_old LONGTEXT;
    DECLARE v_new LONGTEXT;

    DECLARE cur CURSOR FOR
        SELECT col_name, old_val, new_val FROM tmp_changed_cols;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    /* ===============================
       Guard
       =============================== */
    IF p_oldJSON IS NULL OR p_newJSON IS NULL THEN
        LEAVE main_block;
    END IF;

    /* ===============================
       Temp diff table
       =============================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_audit_diff;
    CREATE TEMPORARY TABLE tmp_audit_diff
    (
        col_name        VARCHAR(100),
        base_col_name   VARCHAR(100),
        element_idx     INT,
        old_val         LONGTEXT,
        new_val         LONGTEXT
    ) ENGINE=InnoDB;

    /* ===============================
       Detect changed columns
       =============================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_changed_cols;
    CREATE TEMPORARY TABLE tmp_changed_cols AS
    SELECT
        jt.col_name,
        JSON_UNQUOTE(JSON_EXTRACT(p_oldJSON, CONCAT('$.', jt.col_name))) AS old_val,
        JSON_UNQUOTE(JSON_EXTRACT(p_newJSON, CONCAT('$.', jt.col_name))) AS new_val
    FROM JSON_TABLE(
            JSON_KEYS(p_oldJSON),
            '$[*]' COLUMNS (col_name VARCHAR(100) PATH '$')
    ) jt
    WHERE JSON_UNQUOTE(JSON_EXTRACT(p_oldJSON, CONCAT('$.', jt.col_name)))
          <> JSON_UNQUOTE(JSON_EXTRACT(p_newJSON, CONCAT('$.', jt.col_name)));

    /* ===============================
       Cursor loop
       =============================== */
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_col, v_old, v_new;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        /* JSON column */
        IF JSON_VALID(v_old)
           AND JSON_VALID(v_new)
           AND JSON_TYPE(v_old) IN ('OBJECT','ARRAY') THEN

            CALL Sproc_JSON_DetectChanges(v_col, v_old, v_new);

        /* Scalar column */
        ELSE
            INSERT INTO tmp_audit_diff
            (col_name, base_col_name, element_idx, old_val, new_val)
            VALUES
            (v_col, v_col, NULL, v_old, v_new);
        END IF;

    END LOOP;

    CLOSE cur;

    /* ===============================
       Insert audit logs (UPDATED)
       =============================== */
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

        /* JSON / ARRAY display ref handling */
        CASE
            WHEN d.element_idx IS NOT NULL THEN
                CONCAT(
                    p_entityDisplayRef,
                    ', ',
                    d.base_col_name,
                    ' changed in record #',
                    d.element_idx
                    )
            ELSE
                p_entityDisplayRef
        END AS entity_display_ref,

        d.base_col_name,
        d.old_val,
        d.new_val,
        NOW(),
        p_updatedBy,
        p_updateByRoleId
    FROM tmp_audit_diff d
    JOIN audit_column_metadata m
      ON m.table_name = p_tableName
     AND m.col_name   = d.base_col_name
     AND m.is_context_field = 0;

    /* ===============================
       Context snapshot
       =============================== */
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
            JSON_UNQUOTE(JSON_EXTRACT(p_contextJSON, CONCAT('$.', m.col_name)))
        FROM dataentrychange_auditlog a
        JOIN audit_column_metadata m
          ON m.table_name = p_tableName
         AND m.is_context_field = 1
        WHERE a.table_name   = p_tableName
          AND a.ref_trans_id = p_refTransID
          AND JSON_EXTRACT(p_contextJSON, CONCAT('$.', m.col_name)) IS NOT NULL;
    END IF;

    /* ===============================
       Cleanup
       =============================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_changed_cols;
    DROP TEMPORARY TABLE IF EXISTS tmp_audit_diff;

END$$
DELIMITER ;
