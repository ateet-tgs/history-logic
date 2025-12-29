DROP PROCEDURE IF EXISTS Sproc_Get_AuditHistory;
DELIMITER $$

CREATE PROCEDURE Sproc_Get_AuditHistory(
    IN p_rootTableName VARCHAR(100),
    IN p_rootRefID BIGINT,
    IN p_pageIndex INT,
    IN p_pageSize INT
)
BEGIN
    /* =====================================================
       1. VARIABLES
    ===================================================== */
    DECLARE v_offset INT DEFAULT (p_pageIndex - 1) * p_pageSize;
    DECLARE v_context_cols LONGTEXT;

    DECLARE done_fk INT DEFAULT 0;
    DECLARE v_table_name VARCHAR(100);
    DECLARE v_col_name VARCHAR(100);
    DECLARE v_ref_table VARCHAR(100);
    DECLARE v_ref_pk VARCHAR(100);
    DECLARE v_ref_display VARCHAR(100);

    DECLARE fk_cursor CURSOR FOR
        SELECT DISTINCT table_name, col_name, ref_table, ref_pk, ref_display
        FROM tmp_fk_ids;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_fk = 1;

    /* =====================================================
       2. CLEANUP
    ===================================================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_ids;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_old;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_new;
    DROP TEMPORARY TABLE IF EXISTS tmp_context_display;

    /* =====================================================
       3. FK IDS (NORMALIZED DISPLAY COLUMNS)
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_fk_ids (
        table_name VARCHAR(100),
        col_name VARCHAR(100),
        ref_table VARCHAR(100),
        ref_pk VARCHAR(100),
        ref_display VARCHAR(100),
        ref_id BIGINT,
        PRIMARY KEY (table_name, col_name, ref_display, ref_id)
    ) ENGINE=InnoDB;

    /* ---------- OLD + NEW VALUES ---------- */
    INSERT IGNORE INTO tmp_fk_ids
    SELECT
        a.table_name,
        a.col_name,
        m.ref_table,
        m.ref_pk,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(m.ref_display_column, ',', n.n), ',', -1)),
        CAST(v.ref_id AS SIGNED)
    FROM dataentrychange_auditlog a
    JOIN audit_column_metadata m
        ON m.table_name = a.table_name
       AND m.col_name = a.col_name
       AND m.is_foreign_key = 1
    JOIN (
        SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
        SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL
        SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) n
    JOIN (
        SELECT id, old_val AS ref_id FROM dataentrychange_auditlog WHERE old_val IS NOT NULL
        UNION ALL
        SELECT id, new_val FROM dataentrychange_auditlog WHERE new_val IS NOT NULL
    ) v
        ON v.id = a.id
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID
      AND n.n <= 1 + LENGTH(m.ref_display_column)
                     - LENGTH(REPLACE(m.ref_display_column, ',', ''));

    /* ---------- CONTEXT SNAPSHOT FK ---------- */
    INSERT IGNORE INTO tmp_fk_ids
    SELECT
        a.table_name,
        c.context_field,
        m.ref_table,
        m.ref_pk,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(m.ref_display_column, ',', n.n), ',', -1)),
        CAST(c.context_value AS SIGNED)
    FROM audit_change_context_snapshot c
    JOIN dataentrychange_auditlog a
        ON a.id = c.audit_log_id
    JOIN audit_column_metadata m
        ON m.table_name = a.table_name
       AND m.col_name = c.context_field
       AND m.is_foreign_key = 1
       AND m.is_context_field = 1
    JOIN (
        SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
        SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL
        SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) n
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID
      AND n.n <= 1 + LENGTH(m.ref_display_column)
                     - LENGTH(REPLACE(m.ref_display_column, ',', ''));

    /* =====================================================
       4. FK DISPLAY TABLES
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_fk_display_old (
        table_name VARCHAR(100),
        col_name VARCHAR(100),
        ref_display VARCHAR(100),
        ref_id BIGINT,
        display_val VARCHAR(255),
        PRIMARY KEY (table_name, col_name, ref_display, ref_id)
    ) ENGINE=InnoDB;

    CREATE TEMPORARY TABLE tmp_fk_display_new LIKE tmp_fk_display_old;

    /* =====================================================
       5. FK DISPLAY RESOLUTION
    ===================================================== */
    OPEN fk_cursor;

    fk_loop: LOOP
        FETCH fk_cursor
        INTO v_table_name, v_col_name, v_ref_table, v_ref_pk, v_ref_display;

        IF done_fk = 1 THEN
            LEAVE fk_loop;
        END IF;

        SET @sql = CONCAT(
            'INSERT IGNORE INTO tmp_fk_display_old
             SELECT fk.table_name, fk.col_name, fk.ref_display, fk.ref_id,
                    t.', v_ref_display, '
             FROM tmp_fk_ids fk
             JOIN ', v_ref_table, ' t
               ON t.', v_ref_pk, ' = fk.ref_id
             WHERE fk.table_name = ''', v_table_name, '''
               AND fk.col_name = ''', v_col_name, '''
               AND fk.ref_display = ''', v_ref_display, ''''
        );
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT(
            'INSERT IGNORE INTO tmp_fk_display_new
             SELECT fk.table_name, fk.col_name, fk.ref_display, fk.ref_id,
                    t.', v_ref_display, '
             FROM tmp_fk_ids fk
             JOIN ', v_ref_table, ' t
               ON t.', v_ref_pk, ' = fk.ref_id
             WHERE fk.table_name = ''', v_table_name, '''
               AND fk.col_name = ''', v_col_name, '''
               AND fk.ref_display = ''', v_ref_display, ''''
        );
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    END LOOP;
    CLOSE fk_cursor;

    /* =====================================================
       6. CONTEXT DISPLAY (FK + NON-FK)
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_context_display (
        audit_log_id BIGINT,
        context_field VARCHAR(100),
        context_display VARCHAR(255),
        PRIMARY KEY (audit_log_id, context_field)
    ) ENGINE=InnoDB;

    /* ---------- FK CONTEXT ---------- */
    INSERT IGNORE INTO tmp_context_display
    SELECT
        c.audit_log_id,
        fk.ref_display,
        COALESCE(fd.display_val, c.context_value)
    FROM audit_change_context_snapshot c
    JOIN dataentrychange_auditlog a
        ON a.id = c.audit_log_id
    JOIN tmp_fk_ids fk
        ON fk.table_name = a.table_name
       AND fk.col_name = c.context_field
       AND fk.ref_id = c.context_value
    LEFT JOIN tmp_fk_display_new fd
        ON fd.table_name = fk.table_name
       AND fd.col_name = fk.col_name
       AND fd.ref_display = fk.ref_display
       AND fd.ref_id = fk.ref_id
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID;

    /* ---------- NON-FK CONTEXT ---------- */
    INSERT IGNORE INTO tmp_context_display
    SELECT
        c.audit_log_id,
        c.context_field,
        c.context_value
    FROM audit_change_context_snapshot c
    JOIN dataentrychange_auditlog a
        ON a.id = c.audit_log_id
    JOIN audit_column_metadata m
        ON m.table_name = a.table_name
       AND m.col_name = c.context_field
       AND m.is_foreign_key = 0
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID;

    SELECT GROUP_CONCAT(DISTINCT
        CONCAT(
            'MAX(CASE WHEN cs.context_field = ''',
            context_field,
            ''' THEN cs.context_display END) AS `',
            context_field,
            '`'
        )
    ) INTO v_context_cols
    FROM tmp_context_display;

    /* =====================================================
       7. FINAL RESULT (ONLY_FULL_GROUP_BY SAFE)
    ===================================================== */
    SET @sql = CONCAT(
        'SELECT
            a.id,
            MAX(a.table_name) AS table_name,
            MAX(a.col_name) AS col_name,
            MAX(COALESCE(fd_old.display_val, a.old_val)) AS oldVal,
            MAX(COALESCE(fd_new.display_val, a.new_val)) AS newVal',
        IF(v_context_cols IS NOT NULL, CONCAT(', ', v_context_cols), ''),
        ',
            MAX(a.updated_at) AS updated_at,
            MAX(a.updated_by) AS updated_by
         FROM dataentrychange_auditlog a
         LEFT JOIN tmp_fk_display_old fd_old
           ON fd_old.table_name = a.table_name
          AND fd_old.col_name = a.col_name
          AND fd_old.ref_id = a.old_val
         LEFT JOIN tmp_fk_display_new fd_new
           ON fd_new.table_name = a.table_name
          AND fd_new.col_name = a.col_name
          AND fd_new.ref_id = a.new_val
         LEFT JOIN tmp_context_display cs
           ON cs.audit_log_id = a.id
         WHERE a.root_table_name = ''', p_rootTableName, '''
           AND a.root_ref_id = ', p_rootRefID, '
         GROUP BY a.id
         ORDER BY updated_at DESC
         LIMIT ', p_pageSize, ' OFFSET ', v_offset
    );

    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    /* =====================================================
       8. CLEANUP
    ===================================================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_ids;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_old;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_new;
    DROP TEMPORARY TABLE IF EXISTS tmp_context_display;

END$$
DELIMITER ;
