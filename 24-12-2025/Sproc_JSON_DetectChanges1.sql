DROP PROCEDURE IF EXISTS Sproc_JSON_DetectChanges;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Sproc_JSON_DetectChanges`(
    IN p_base_col_name VARCHAR(100),
    IN p_oldJSON JSON,
    IN p_newJSON JSON
)
BEGIN
    DECLARE v_type VARCHAR(20);

    SET v_type = JSON_TYPE(p_oldJSON);

    /* =====================================================
       OBJECT (simple JSON object)
       ===================================================== */
    IF v_type = 'OBJECT' THEN

        INSERT INTO tmp_audit_diff
        (
            col_name,
            base_col_name,
            element_idx,
            old_val,
            new_val
        )
        SELECT
            jk.col_name,
            jk.col_name,
            NULL,
            JSON_UNQUOTE(JSON_EXTRACT(p_oldJSON, CONCAT('$.', jk.col_name))),
            JSON_UNQUOTE(JSON_EXTRACT(p_newJSON, CONCAT('$.', jk.col_name)))
        FROM JSON_TABLE(
                JSON_KEYS(p_oldJSON),
                '$[*]' COLUMNS (col_name VARCHAR(100) PATH '$')
        ) jk
        WHERE JSON_UNQUOTE(JSON_EXTRACT(p_oldJSON, CONCAT('$.', jk.col_name)))
              <> JSON_UNQUOTE(JSON_EXTRACT(p_newJSON, CONCAT('$.', jk.col_name)));

    /* =====================================================
       ARRAY of OBJECTS
       ===================================================== */
    ELSEIF v_type = 'ARRAY' THEN

        /* ---------- Flatten OLD array ---------- */
        DROP TEMPORARY TABLE IF EXISTS tmp_old_array;
        CREATE TEMPORARY TABLE tmp_old_array AS
        SELECT
            idx,
            obj
        FROM JSON_TABLE(
                p_oldJSON,
                '$[*]' COLUMNS
                (
                    idx FOR ORDINALITY,
                    obj JSON PATH '$'
                )
        ) jt;

        /* ---------- Flatten NEW array ---------- */
        DROP TEMPORARY TABLE IF EXISTS tmp_new_array;
        CREATE TEMPORARY TABLE tmp_new_array AS
        SELECT
            idx,
            obj
        FROM JSON_TABLE(
                p_newJSON,
                '$[*]' COLUMNS
                (
                    idx FOR ORDINALITY,
                    obj JSON PATH '$'
                )
        ) jt;

        /* =================================================
           1️⃣ VALUE CHANGES (same index, different values)
           ================================================= */
        INSERT INTO tmp_audit_diff
        (
            col_name,
            base_col_name,
            element_idx,
            old_val,
            new_val
        )
        SELECT
            jk.col_name,
            jk.col_name,
            o.idx,
            JSON_UNQUOTE(JSON_EXTRACT(o.obj, CONCAT('$.', jk.col_name))),
            JSON_UNQUOTE(JSON_EXTRACT(n.obj, CONCAT('$.', jk.col_name)))
        FROM tmp_old_array o
        JOIN tmp_new_array n
              ON o.idx = n.idx
        JOIN JSON_TABLE(
                JSON_KEYS(o.obj),
                '$[*]' COLUMNS (col_name VARCHAR(100) PATH '$')
        ) jk
        WHERE JSON_UNQUOTE(JSON_EXTRACT(o.obj, CONCAT('$.', jk.col_name)))
              <> JSON_UNQUOTE(JSON_EXTRACT(n.obj, CONCAT('$.', jk.col_name)));

        /* =================================================
           2️⃣ REMOVED ELEMENTS (exists in OLD, missing in NEW)
           ================================================= */
        INSERT INTO tmp_audit_diff
        (
            col_name,
            base_col_name,
            element_idx,
            old_val,
            new_val
        )
        SELECT
            jk.col_name,
            jk.col_name,
            o.idx,
            JSON_UNQUOTE(JSON_EXTRACT(o.obj, CONCAT('$.', jk.col_name))),
            NULL
        FROM tmp_old_array o
        LEFT JOIN tmp_new_array n
               ON o.idx = n.idx
        JOIN JSON_TABLE(
                JSON_KEYS(o.obj),
                '$[*]' COLUMNS (col_name VARCHAR(100) PATH '$')
        ) jk
        WHERE n.idx IS NULL;

        /* ---------- Cleanup ---------- */
        DROP TEMPORARY TABLE IF EXISTS tmp_old_array;
        DROP TEMPORARY TABLE IF EXISTS tmp_new_array;

    END IF;

END
$$
DELIMITER ;
