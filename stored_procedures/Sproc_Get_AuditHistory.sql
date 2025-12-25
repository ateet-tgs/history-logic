CREATE DEFINER=`root`@`localhost` PROCEDURE `Sproc_Get_AuditHistory`(
    IN p_rootTableName VARCHAR(100),
    IN p_rootRefID BIGINT,
    IN p_pageIndex INT,
    IN p_pageSize INT
)
BEGIN
    DECLARE v_offset INT DEFAULT 0;
    DECLARE done INT DEFAULT 0;

    DECLARE v_refTable VARCHAR(100);
    DECLARE v_refPK VARCHAR(100);
    DECLARE v_refDisplay VARCHAR(100);

    SET v_offset = (p_pageIndex - 1) * p_pageSize;

    /* =====================================================
       1. Cleanup
    ===================================================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_ids;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_old;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_new;

    /* =====================================================
       2. FK ID Pool
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_fk_ids (
        refTable VARCHAR(100),
        refPK VARCHAR(100),
        refDisplayColumn VARCHAR(100),
        refID BIGINT,
        PRIMARY KEY (refTable, refID)
    ) ENGINE=MEMORY;

    /* Old values */
    INSERT IGNORE INTO tmp_fk_ids
    SELECT DISTINCT
        m.ref_table,
        m.ref_pk,
        m.ref_display_column,
        a.old_val
    FROM dataentrychange_auditlog a
    JOIN audit_column_metadata m
      ON m.table_name = a.table_name
     AND m.col_name = a.col_name
     AND m.is_foreign_key = 1
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID
      AND a.old_val IS NOT NULL;

    /* New values */
    INSERT IGNORE INTO tmp_fk_ids
    SELECT DISTINCT
        m.ref_table,
        m.ref_pk,
        m.ref_display_column,
        a.new_val
    FROM dataentrychange_auditlog a
    JOIN audit_column_metadata m
      ON m.table_name = a.table_name
     AND m.col_name = a.col_name
     AND m.is_foreign_key = 1
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID
      AND a.new_val IS NOT NULL;

    /* =====================================================
       3. FK Display Tables
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_fk_display_old (
        refTable VARCHAR(100),
        refID BIGINT,
        displayVal VARCHAR(255),
        PRIMARY KEY (refTable, refID)
    ) ENGINE=MEMORY;

    CREATE TEMPORARY TABLE tmp_fk_display_new (
        refTable VARCHAR(100),
        refID BIGINT,
        displayVal VARCHAR(255),
        PRIMARY KEY (refTable, refID)
    ) ENGINE=MEMORY;

    /* =====================================================
       4. FK Resolution
    ===================================================== */
    BEGIN
        DECLARE fk_cur CURSOR FOR
            SELECT DISTINCT refTable, refPK, refDisplayColumn
            FROM tmp_fk_ids;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

        OPEN fk_cur;

        fk_loop: LOOP
            FETCH fk_cur INTO v_refTable, v_refPK, v_refDisplay;
            IF done = 1 THEN LEAVE fk_loop; END IF;

            /* Old values */
            SET @sql = CONCAT(
                'INSERT IGNORE INTO tmp_fk_display_old (refTable, refID, displayVal)
                 SELECT ''', v_refTable, ''', ', v_refPK, ', ', v_refDisplay, '
                 FROM ', v_refTable, '
                 WHERE ', v_refPK, ' IN (
                     SELECT refID FROM tmp_fk_ids
                     WHERE refTable = ''', v_refTable, '''
                 )'
            );
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            /* New values */
            SET @sql = CONCAT(
                'INSERT IGNORE INTO tmp_fk_display_new (refTable, refID, displayVal)
                 SELECT ''', v_refTable, ''', ', v_refPK, ', ', v_refDisplay, '
                 FROM ', v_refTable, '
                 WHERE ', v_refPK, ' IN (
                     SELECT refID FROM tmp_fk_ids
                     WHERE refTable = ''', v_refTable, '''
                 )'
            );
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

        END LOOP;

        CLOSE fk_cur;
    END;

    /* =====================================================
       5. Total Count
    ===================================================== */
    SELECT COUNT(*) AS totalCount
    FROM dataentrychange_auditlog
    WHERE root_table_name = p_rootTableName
      AND root_ref_id = p_rootRefID;

    /* =====================================================
       6. Paged Result
    ===================================================== */
    SELECT
        a.id,
        a.table_name,
        a.col_name,
        a.entity_display_ref,
        m.ref_display_column,
        COALESCE(fd_old.displayVal, a.old_val) AS oldValDisplay,
        COALESCE(fd_new.displayVal, a.new_val) AS newValDisplay,
        a.updated_at,
        a.updated_by
    FROM dataentrychange_auditlog a
    LEFT JOIN audit_column_metadata m
           ON m.table_name = a.table_name
          AND m.col_name = a.col_name
    LEFT JOIN tmp_fk_display_old fd_old
           ON fd_old.refTable = m.ref_table
          AND fd_old.refID = a.old_val
    LEFT JOIN tmp_fk_display_new fd_new
           ON fd_new.refTable = m.ref_table
          AND fd_new.refID = a.new_val
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID
    ORDER BY a.updated_at DESC
    LIMIT p_pageSize OFFSET v_offset;

    /* =====================================================
       7. Cleanup
    ===================================================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_old;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_new;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_ids;

END