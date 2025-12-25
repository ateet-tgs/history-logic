CREATE DEFINER=`root`@`localhost` PROCEDURE `Sproc_Get_AuditHistory_WithFK_FAST`(
    IN p_root_table_name VARCHAR(100),
    IN p_root_ref_id BIGINT
)
BEGIN
    /* =====================================================
       1. RAW AUDIT DATA
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_audit_raw AS
    SELECT 
        a.id,
        a.table_name,
        a.col_name,
        a.old_val,
        a.new_val,
        a.updated_at,
        a.updated_by,
        IFNULL(m.is_foreign_key, 0) AS is_fk,
        m.ref_table,
        m.ref_pk,
        m.ref_display_column
    FROM dataentrychange_auditlog a
    LEFT JOIN audit_column_metadata m
           ON m.table_name = a.table_name
          AND m.col_name  = a.col_name
    WHERE a.root_table_name = p_root_table_name
      AND a.root_ref_id    = p_root_ref_id;

    /* =====================================================
       2. FK VALUE POOL (DISTINCT)
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_fk_ids (
        ref_table VARCHAR(100),
        ref_pk VARCHAR(100),
        ref_display_column VARCHAR(100),
        ref_id BIGINT
    );

    INSERT INTO tmp_fk_ids
    SELECT DISTINCT ref_table, ref_pk, ref_display_column, old_val
    FROM tmp_audit_raw
    WHERE is_fk = 1 AND old_val IS NOT NULL

    UNION

    SELECT DISTINCT ref_table, ref_pk, ref_display_column, new_val
    FROM tmp_audit_raw
    WHERE is_fk = 1 AND new_val IS NOT NULL;

    /* =====================================================
       3. FK RESOLUTION TABLE
    ===================================================== */
    CREATE TEMPORARY TABLE tmp_fk_display (
        ref_table VARCHAR(100),
        ref_id BIGINT,
        display_val LONGTEXT
    );

    /* =====================================================
       4. DYNAMIC FK LOOKUP (PER TABLE, NOT PER ROW)
    ===================================================== */
    BEGIN
        DECLARE done INT DEFAULT 0;
        DECLARE v_ref_table VARCHAR(100);
        DECLARE v_ref_pk VARCHAR(100);
        DECLARE v_ref_display VARCHAR(100);

        DECLARE fk_cur CURSOR FOR
            SELECT DISTINCT ref_table, ref_pk, ref_display_column
            FROM tmp_fk_ids;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

        OPEN fk_cur;

        fk_loop: LOOP
            FETCH fk_cur INTO v_ref_table, v_ref_pk, v_ref_display;
            IF done = 1 THEN LEAVE fk_loop; END IF;

            SET @sql = CONCAT(
                'INSERT INTO tmp_fk_display (ref_table, ref_id, display_val)
                 SELECT ''', v_ref_table, ''', ',
                        v_ref_pk, ', ',
                        v_ref_display, '
                 FROM ', v_ref_table, '
                 WHERE ', v_ref_pk, ' IN (
                     SELECT ref_id FROM tmp_fk_ids
                     WHERE ref_table = ''', v_ref_table, '''
                 )'
            );

            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END LOOP;

        CLOSE fk_cur;
    END;

    /* =====================================================
       5. FINAL RESULT (SET-BASED JOIN)
    ===================================================== */
    SELECT
        r.id,
        r.table_name,
        r.col_name,

        CASE
            WHEN r.is_fk = 1
            THEN COALESCE(f1.display_val, r.old_val)
            ELSE r.old_val
        END AS old_val_display,

        CASE
            WHEN r.is_fk = 1
            THEN COALESCE(f2.display_val, r.new_val)
            ELSE r.new_val
        END AS new_val_display,

        r.updated_at,
        r.updated_by
    FROM tmp_audit_raw r
    LEFT JOIN tmp_fk_display f1
           ON r.is_fk = 1
          AND f1.ref_table = r.ref_table
          AND f1.ref_id = r.old_val
    LEFT JOIN tmp_fk_display f2
           ON r.is_fk = 1
          AND f2.ref_table = r.ref_table
          AND f2.ref_id = r.new_val
    ORDER BY r.updated_at DESC;

    /* =====================================================
       6. CLEANUP
    ===================================================== */
    DROP TEMPORARY TABLE tmp_fk_display;
    DROP TEMPORARY TABLE tmp_fk_ids;
    DROP TEMPORARY TABLE tmp_audit_raw;

END;