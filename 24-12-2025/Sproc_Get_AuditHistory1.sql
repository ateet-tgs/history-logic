DROP PROCEDURE IF EXISTS `Sproc_Get_AuditHistory`;
DELIMITER $$

CREATE PROCEDURE `Sproc_Get_AuditHistory`(
    IN p_rootTableName VARCHAR(100),
    IN p_rootRefID BIGINT,
    IN p_pageIndex INT,
    IN p_pageSize INT
)
BEGIN
    /* ==========================
       1. Variable Declarations
    ========================== */
    DECLARE v_offset INT DEFAULT (p_pageIndex - 1) * p_pageSize;
    DECLARE v_refTable VARCHAR(100);
    DECLARE v_refPK VARCHAR(100);
    DECLARE v_refDisplay VARCHAR(100);
    DECLARE done INT DEFAULT 0;
    DECLARE context_cols LONGTEXT;

    DECLARE fk_cursor CURSOR FOR
        SELECT DISTINCT refTable, refPK, refDisplayColumn FROM tmp_fk_ids;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    /* ==========================
       2. Cleanup any temp tables
    ========================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_ids;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_old;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_new;
    DROP TEMPORARY TABLE IF EXISTS tmp_context_display;

    /* ==========================
       3. FK ID Pool
    ========================== */
    CREATE TEMPORARY TABLE tmp_fk_ids (
        refTable VARCHAR(100),
        refPK VARCHAR(100),
        refDisplayColumn VARCHAR(100),
        refID BIGINT,
        PRIMARY KEY (refTable, refID)
    ) ENGINE=InnoDB;

    INSERT IGNORE INTO tmp_fk_ids
    SELECT DISTINCT m.ref_table, m.ref_pk, m.ref_display_column, a.old_val
    FROM dataentrychange_auditlog a
    JOIN audit_column_metadata m
      ON m.table_name = a.table_name
     AND m.col_name = a.col_name
     AND m.is_foreign_key = 1
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID
      AND a.old_val IS NOT NULL

    UNION

    SELECT DISTINCT m.ref_table, m.ref_pk, m.ref_display_column, a.new_val
    FROM dataentrychange_auditlog a
    JOIN audit_column_metadata m
      ON m.table_name = a.table_name
     AND m.col_name = a.col_name
     AND m.is_foreign_key = 1
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID
      AND a.new_val IS NOT NULL

    UNION

    SELECT DISTINCT m.ref_table, m.ref_pk, m.ref_display_column, c.context_value
    FROM audit_change_context_snapshot c
    JOIN dataentrychange_auditlog a ON a.id = c.audit_log_id
    JOIN audit_column_metadata m
      ON m.table_name = a.table_name
     AND m.col_name = c.context_field
     AND m.is_foreign_key = 1
     AND m.is_context_field = 1
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID
      AND c.context_value IS NOT NULL;

    /* ==========================
       4. FK Display Tables
    ========================== */
    CREATE TEMPORARY TABLE tmp_fk_display_old (
        refTable VARCHAR(100),
        refID BIGINT,
        displayVal VARCHAR(255),
        PRIMARY KEY (refTable, refID)
    ) ENGINE=InnoDB;

    CREATE TEMPORARY TABLE tmp_fk_display_new LIKE tmp_fk_display_old;

    /* ==========================
       5. Cursor-based FK Resolution
    ========================== */
    OPEN fk_cursor;

    fk_loop: LOOP
        FETCH fk_cursor INTO v_refTable, v_refPK, v_refDisplay;
        IF done = 1 THEN
            LEAVE fk_loop;
        END IF;

        /* OLD VALUES */
        SET @sql = CONCAT(
            'INSERT IGNORE INTO tmp_fk_display_old (refTable, refID, displayVal)
             SELECT ''', v_refTable, ''', ', v_refPK, ', ', v_refDisplay, '
             FROM ', v_refTable, '
             WHERE ', v_refPK, ' IN (
                 SELECT refID FROM tmp_fk_ids WHERE refTable = ''', v_refTable, ''')'
        );
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        /* NEW VALUES */
        SET @sql = CONCAT(
            'INSERT IGNORE INTO tmp_fk_display_new (refTable, refID, displayVal)
             SELECT ''', v_refTable, ''', ', v_refPK, ', ', v_refDisplay, '
             FROM ', v_refTable, '
             WHERE ', v_refPK, ' IN (
                 SELECT refID FROM tmp_fk_ids WHERE refTable = ''', v_refTable, ''')'
        );
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    END LOOP;

    CLOSE fk_cursor;

    /* ==========================
       6. Context Display
    ========================== */
    CREATE TEMPORARY TABLE tmp_context_display (
        audit_log_id BIGINT,
        context_field VARCHAR(100),
        context_display VARCHAR(255),
        PRIMARY KEY (audit_log_id, context_field)
    ) ENGINE=InnoDB;

    INSERT IGNORE INTO tmp_context_display
    SELECT
        c.audit_log_id,
        c.context_field,
        COALESCE(fd.displayVal, c.context_value) AS context_display
    FROM audit_change_context_snapshot c
    JOIN dataentrychange_auditlog a
      ON a.id = c.audit_log_id
    JOIN audit_column_metadata m
      ON m.table_name = a.table_name
     AND m.col_name = c.context_field
     AND m.is_context_field = 1
    LEFT JOIN tmp_fk_display_new fd
      ON fd.refTable = m.ref_table
     AND fd.refID = c.context_value
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID;

    /* ==========================
       7. Dynamic Context Columns
    ========================== */
    SELECT GROUP_CONCAT(DISTINCT
        CONCAT(
            'MAX(CASE WHEN context_field = ''',
            context_field,
            ''' THEN context_display END) AS `',
            context_field,
            '`'
        )
        SEPARATOR ', '
    ) INTO context_cols
    FROM tmp_context_display;

    /* ==========================
       8. Final Result
    ========================== */
    SET @sql = CONCAT(
        'SELECT
            a.table_name,
            a.col_name,
            COALESCE(fd_old.displayVal, a.old_val) AS oldVal,
            COALESCE(fd_new.displayVal, a.new_val) AS newVal',
        IF(context_cols IS NOT NULL, CONCAT(', ', context_cols), ''),
        ',
            a.updated_at,
            a.updated_by
         FROM dataentrychange_auditlog a
         LEFT JOIN tmp_fk_display_old fd_old
           ON fd_old.refTable = a.table_name
          AND fd_old.refID = a.old_val
         LEFT JOIN tmp_fk_display_new fd_new
           ON fd_new.refTable = a.table_name
          AND fd_new.refID = a.new_val
         LEFT JOIN tmp_context_display cs
           ON cs.audit_log_id = a.id
         WHERE a.root_table_name = ''', p_rootTableName, '''
           AND a.root_ref_id = ', p_rootRefID, '
         GROUP BY a.id
         ORDER BY a.updated_at DESC
         LIMIT ', p_pageSize,
        ' OFFSET ', v_offset
    );

    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    /* ==========================
       9. Cleanup
    ========================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_ids;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_old;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_new;
    DROP TEMPORARY TABLE IF EXISTS tmp_context_display;

END$$
DELIMITER ;
