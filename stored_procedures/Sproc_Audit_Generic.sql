CREATE PROCEDURE Sproc_Audit_Generic (
    IN p_tableName VARCHAR(100),
    IN p_refID BIGINT,
    IN p_old JSON,
    IN p_new JSON
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_colName VARCHAR(100);
    DECLARE v_oldVal TEXT;
    DECLARE v_newVal TEXT;

    DECLARE cur_columns CURSOR FOR
        SELECT columnName
        FROM audit_column_metadata
        WHERE tableName = p_tableName
          AND includeInAudit = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur_columns;

    read_loop: LOOP
        FETCH cur_columns INTO v_colName;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_oldVal = JSON_UNQUOTE(JSON_EXTRACT(p_old, CONCAT('$.', v_colName)));
        SET v_newVal = JSON_UNQUOTE(JSON_EXTRACT(p_new, CONCAT('$.', v_colName)));

        IF NOT (v_oldVal <=> v_newVal) THEN
            INSERT INTO dataentrychange_auditlog (
                rootTableName,
                rootRefID,
                tableName,
                refTransID,
                colName,
                oldValue,
                newValue,
                changedAt
            )
            VALUES (
                p_tableName,
                p_refID,
                p_tableName,
                p_refID,
                v_colName,
                v_oldVal,
                v_newVal,
                NOW()
            );
        END IF;

    END LOOP;

    CLOSE cur_columns;
END;
