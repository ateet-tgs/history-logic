DROP PROCEDURE IF EXISTS `Sproc_Get_AuditHistory`;
DELIMITER $$

CREATE PROCEDURE `Sproc_Get_AuditHistory`(
    IN p_rootTableName VARCHAR(100),
    IN p_rootRefID BIGINT,
    IN p_pageIndex INT,
    IN p_pageSize INT
)
BEGIN
    DECLARE v_offset INT DEFAULT (p_pageIndex - 1) * p_pageSize;
    DECLARE context_cols LONGTEXT DEFAULT '';

    /* =====================================================
       1. Cleanup
    ===================================================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_ids;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_old;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_new;
    DROP TEMPORARY TABLE IF EXISTS tmp_context_display;

    /* =====================================================
       2. FK ID Pool (Audit Column Changes + Context Fields)
    ===================================================== */
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

    /* =====================================================
       3. FK Display Tables (Batch Insert)
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_fk_display_old (
        refTable VARCHAR(100),
        refID BIGINT,
        displayVal VARCHAR(255),
        PRIMARY KEY (refTable, refID)
    ) ENGINE=InnoDB;

    CREATE TEMPORARY TABLE tmp_fk_display_new (
        refTable VARCHAR(100),
        refID BIGINT,
        displayVal VARCHAR(255),
        PRIMARY KEY (refTable, refID)
    ) ENGINE=InnoDB;

    /* Insert all old display values in batch */
    SET @sql = (
        SELECT GROUP_CONCAT(
            CONCAT(
                'INSERT IGNORE INTO tmp_fk_display_old (refTable, refID, displayVal) ',
                'SELECT ''', refTable, ''', ', refPK, ', ', refDisplayColumn, ' FROM ', refTable,
                ' WHERE ', refPK, ' IN (SELECT refID FROM tmp_fk_ids WHERE refTable = ''', refTable, ''')'
            ) SEPARATOR '; '
        )
        FROM (SELECT DISTINCT refTable, refPK, refDisplayColumn FROM tmp_fk_ids) t
    );
    IF @sql IS NOT NULL THEN
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    /* Insert all new display values in batch */
    SET @sql = (
        SELECT GROUP_CONCAT(
            CONCAT(
                'INSERT IGNORE INTO tmp_fk_display_new (refTable, refID, displayVal) ',
                'SELECT ''', refTable, ''', ', refPK, ', ', refDisplayColumn, ' FROM ', refTable,
                ' WHERE ', refPK, ' IN (SELECT refID FROM tmp_fk_ids WHERE refTable = ''', refTable, ''')'
            ) SEPARATOR '; '
        )
        FROM (SELECT DISTINCT refTable, refPK, refDisplayColumn FROM tmp_fk_ids) t
    );
    IF @sql IS NOT NULL THEN
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    /* =====================================================
       4. Context Display Table
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_context_display (
        audit_log_id BIGINT,
        context_field VARCHAR(100),
        context_display VARCHAR(255),
        PRIMARY KEY (audit_log_id, context_field)
    ) ENGINE=InnoDB;

    INSERT IGNORE INTO tmp_context_display
    SELECT c.audit_log_id, c.context_field, COALESCE(fd.displayVal, c.context_value) AS context_display
    FROM (
        SELECT audit_log_id, context_field, context_value,
               ROW_NUMBER() OVER (PARTITION BY audit_log_id, context_field ORDER BY audit_log_id) AS rn
        FROM audit_change_context_snapshot
    ) c
    JOIN dataentrychange_auditlog a ON a.id = c.audit_log_id
    JOIN audit_column_metadata m
      ON m.table_name = a.table_name
     AND m.col_name = c.context_field
     AND m.is_context_field = 1
    LEFT JOIN tmp_fk_display_new fd
      ON fd.refTable = m.ref_table AND fd.refID = c.context_value
    WHERE a.root_table_name = p_rootTableName
      AND a.root_ref_id = p_rootRefID
      AND c.rn = 1;

    /* =====================================================
       5. Prepare Dynamic Context Columns
    ===================================================== */
    SELECT GROUP_CONCAT(DISTINCT
        CONCAT('MAX(CASE WHEN context_field = ''', context_field, ''' THEN context_display END) AS `', context_field, '`')
        SEPARATOR ', '
    ) INTO context_cols
    FROM tmp_context_display;

    /* =====================================================
       6. Final Query
    ===================================================== */
    SET @sql = CONCAT(
        'SELECT
            a.table_name,
            a.col_name,
            COALESCE(fd_old.displayVal, a.old_val) AS oldVal,
            COALESCE(fd_new.displayVal, a.new_val) AS newVal',
        IF(context_cols IS NOT NULL, CONCAT(', ', context_cols), ''), ',
            a.updated_at,
            a.updated_by
         FROM dataentrychange_auditlog a
         LEFT JOIN tmp_fk_display_old fd_old ON fd_old.refTable = a.table_name AND fd_old.refID = a.old_val
         LEFT JOIN tmp_fk_display_new fd_new ON fd_new.refTable = a.table_name AND fd_new.refID = a.new_val
         LEFT JOIN tmp_context_display cs ON cs.audit_log_id = a.id
         WHERE a.root_table_name = ''', p_rootTableName, ''' 
           AND a.root_ref_id = ', p_rootRefID, '
         GROUP BY a.id
         ORDER BY a.updated_at DESC
         LIMIT ', p_pageSize, ' OFFSET ', v_offset
    );

    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    /* =====================================================
       7. Cleanup
    ===================================================== */
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_ids;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_old;
    DROP TEMPORARY TABLE IF EXISTS tmp_fk_display_new;
    DROP TEMPORARY TABLE IF EXISTS tmp_context_display;

END$$

DELIMITER ;
