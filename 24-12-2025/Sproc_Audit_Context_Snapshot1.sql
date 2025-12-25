DROP PROCEDURE IF EXISTS Sproc_Audit_Context_Snapshot;
DELIMITER $$

CREATE PROCEDURE Sproc_Audit_Context_Snapshot
(
    IN p_auditLogId     BIGINT,
    IN p_tableName      VARCHAR(100),
    IN p_refTransID     BIGINT,
    IN p_rootRefID      BIGINT
)
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_contextCol VARCHAR(100);
    DECLARE v_contextVal BIGINT;

    DECLARE cur_ctx CURSOR FOR
        SELECT col_name
        FROM audit_column_metadata
        WHERE table_name = p_tableName
          AND is_context_field = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN cur_ctx;

    read_loop: LOOP
        FETCH cur_ctx INTO v_contextCol;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        /* ================================
           Resolve context values
        ================================= */

        -- PART ID
        IF v_contextCol = 'part_id' THEN
            IF p_tableName = 'sales_order_line_detail' THEN
                SELECT part_id INTO v_contextVal
                FROM sales_order_line_detail
                WHERE id = p_refTransID;

            ELSEIF p_tableName = 'sales_order_release_line' THEN
                SELECT l.part_id INTO v_contextVal
                FROM sales_order_release_line r
                JOIN sales_order_line_detail l
                  ON l.id = r.line_detail_id
                WHERE r.id = p_refTransID;
            END IF;

        -- SALES ORDER VERSION
        ELSEIF v_contextCol = 'version' THEN
            SELECT version INTO v_contextVal
            FROM sales_order
            WHERE id = p_rootRefID;
        END IF;

        /* ================================
           Persist snapshot
        ================================= */
        IF v_contextVal IS NOT NULL THEN
            INSERT INTO audit_change_context_snapshot
            (
                audit_log_id,
                context_field,
                context_value
            )
            VALUES
            (
                p_auditLogId,
                v_contextCol,
                v_contextVal
            );
        END IF;

    END LOOP;

    CLOSE cur_ctx;
END$$
DELIMITER ;
