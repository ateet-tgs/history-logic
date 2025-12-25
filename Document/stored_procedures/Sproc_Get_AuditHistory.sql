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

    INSERT IGNORE INTO tmp_fk_ids
    SELECT DISTINCT m.refTable, m.refPK, m.refDisplayColumn, a.oldVal
    FROM dataentrychange_auditlog a
    JOIN audit_column_metadata m
      ON m.tableName = a.tableName
     AND m.colName = a.colName
     AND m.isForeignKey = 1
    WHERE a.rootTableName = p_rootTableName
      AND a.rootRefID = p_rootRefID
      AND a.oldVal IS NOT NULL;

    INSERT IGNORE INTO tmp_fk_ids
    SELECT DISTINCT m.refTable, m.refPK, m.refDisplayColumn, a.newVal
    FROM dataentrychange_auditlog a
    JOIN audit_column_metadata m
      ON m.tableName = a.tableName
     AND m.colName = a.colName
     AND m.isForeignKey = 1
    WHERE a.rootTableName = p_rootTableName
      AND a.rootRefID = p_rootRefID
      AND a.newVal IS NOT NULL;

    /* =====================================================
       3. FK Display Tables (two separate MEMORY tables)
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
       4. FK Resolution (Cursor + Dynamic SQL)
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

            /* Insert old values */
            SET @sql = CONCAT(
                'INSERT IGNORE INTO tmp_fk_display_old (refTable, refID, displayVal)
                 SELECT ''', v_refTable, ''', ', v_refPK, ', ', v_refDisplay, '
                 FROM ', v_refTable, '
                 WHERE ', v_refPK, ' IN (
                     SELECT refID FROM tmp_fk_ids
                     WHERE refTable = ''', v_refTable, ''' 
                       AND refID IS NOT NULL
                 )'
            );
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            /* Insert new values */
            SET @sql = CONCAT(
                'INSERT IGNORE INTO tmp_fk_display_new (refTable, refID, displayVal)
                 SELECT ''', v_refTable, ''', ', v_refPK, ', ', v_refDisplay, '
                 FROM ', v_refTable, '
                 WHERE ', v_refPK, ' IN (
                     SELECT refID FROM tmp_fk_ids
                     WHERE refTable = ''', v_refTable, ''' 
                       AND refID IS NOT NULL
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
    WHERE rootTableName = p_rootTableName
      AND rootRefID = p_rootRefID;

    /* =====================================================
       6. Paged Result
    ===================================================== */
    SELECT
        a.id,
        a.tableName,
        a.colName,
        COALESCE(fd_old.displayVal, a.oldVal) AS oldValDisplay,
        COALESCE(fd_new.displayVal, a.newVal) AS newValDisplay,
        a.updatedAt,
        a.updatedBy
    FROM dataentrychange_auditlog a
    LEFT JOIN audit_column_metadata m
           ON m.tableName = a.tableName
          AND m.colName = a.colName
    LEFT JOIN tmp_fk_display_old fd_old
           ON fd_old.refTable = m.refTable
          AND fd_old.refID = a.oldVal
    LEFT JOIN tmp_fk_display_new fd_new
           ON fd_new.refTable = m.refTable
          AND fd_new.refID = a.newVal
    WHERE a.rootTableName = p_rootTableName
      AND a.rootRefID = p_rootRefID
    ORDER BY a.updatedAt DESC
    LIMIT p_pageSize OFFSET v_offset;

    /* =====================================================
       7. Cleanup
    ===================================================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_old;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_new;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_ids;

END