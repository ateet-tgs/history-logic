DROP PROCEDURE IF EXISTS migrate_auditlog_recursive;
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `migrate_auditlog_recursive`(IN hierarchyJSON JSON)
BEGIN
    DECLARE curIndex INT DEFAULT 0;
    DECLARE totalRows INT;

    -- Variables for each hierarchy element
    DECLARE v_parent VARCHAR(100);
    DECLARE v_parentPK VARCHAR(100);
    DECLARE v_child VARCHAR(100);
    DECLARE v_childPK VARCHAR(100);
    DECLARE v_childFK VARCHAR(100);
    DECLARE v_display VARCHAR(100);

    -- Root table
    DECLARE rootTable VARCHAR(100);
    DECLARE rootPK VARCHAR(100);

    DECLARE entityLevel INT;
    DECLARE joinSQL TEXT;

    -- Join traversal helpers
    DECLARE i INT;
    DECLARE curParent VARCHAR(100);
    DECLARE curParentPK VARCHAR(100);
    DECLARE curChildFK VARCHAR(100);
    DECLARE aliasPrev VARCHAR(50);

    -- Total hierarchy rows
    SET totalRows = JSON_LENGTH(hierarchyJSON);

    -- Identify root table
    SET rootTable = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, '$[0].parent'));
    SET rootPK    = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, '$[0].parentPK'));

    /* =====================================================
       STEP 1: ROOT TABLE UPDATE
       ===================================================== */
    SET @sql = CONCAT(
        'UPDATE dataentrychange_auditlog AS da ',
        'JOIN ', rootTable, ' AS r ON da.RefTransID = r.', rootPK, ' ',
        'SET da.rootTableName = ''', rootTable, ''', ',
        'da.rootRefId = r.', rootPK, ', ',
        'da.entityLevel = 0, ',
        'da.entityDisplayRef = r.', rootPK, ' ',
        'WHERE da.Tablename = ''', rootTable, ''''
    );
    SELECT @sql;
    PREPARE stmt FROM @sql;
    -- EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    /* =====================================================
       STEP 2: CHILD TABLES
       ===================================================== */
    SET curIndex = 0;
    WHILE curIndex < totalRows DO

        -- Extract JSON values
        SET v_parent   = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', curIndex, '].parent')));
        SET v_parentPK = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', curIndex, '].parentPK')));
        SET v_child    = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', curIndex, '].child')));
        SET v_childPK  = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', curIndex, '].childPK')));
        SET v_childFK  = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', curIndex, '].childFK')));
        SET v_display  = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', curIndex, '].display')));

        SET entityLevel = curIndex + 1;

        /* -----------------------------------------------------
           BASE JOIN: child → its direct parent
           ----------------------------------------------------- */
        SET joinSQL = CONCAT(
            'JOIN ', v_parent, ' AS p ON c.', v_childFK, ' = p.', v_parentPK, ' '
        );

        /* -----------------------------------------------------
           FIXED JOIN BUILDER (JSON-DRIVEN)
           ----------------------------------------------------- */
        IF v_parent = rootTable THEN

            SET joinSQL = CONCAT(
                joinSQL,
                'JOIN ', rootTable, ' AS r ON p.', v_parentPK, ' = r.', rootPK, ' '
            );

        ELSE
            SET aliasPrev = 'p';
            SET curParent = v_parent;

            WHILE curParent <> rootTable DO
                SET i = 0;
                SET curParentPK = NULL;
                SET curChildFK  = NULL;

                search_parent: WHILE i < totalRows DO
                    IF JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', i, '].child'))) = curParent THEN
                        SET curChildFK  = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', i, '].childFK')));
                        SET curParentPK = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', i, '].parentPK')));
                        SET curParent   = JSON_UNQUOTE(JSON_EXTRACT(hierarchyJSON, CONCAT('$[', i, '].parent')));
                        LEAVE search_parent;
                    END IF;
                    SET i = i + 1;
                END WHILE search_parent;

                IF curParentPK IS NULL THEN
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Invalid hierarchy JSON: broken parent chain';
                END IF;

                SET joinSQL = CONCAT(
                    joinSQL,
                    'JOIN ', curParent, ' AS t', i,
                    ' ON ', aliasPrev, '.', curChildFK,
                    ' = t', i, '.', curParentPK, ' '
                );

                SET aliasPrev = CONCAT('t', i);
            END WHILE;

            SET joinSQL = CONCAT(
                joinSQL,
                'JOIN ', rootTable, ' AS r ON ',
                aliasPrev, '.', rootPK, ' = r.', rootPK, ' '
            );
        END IF;

        /* -----------------------------------------------------
           FINAL UPDATE SQL (CASE-WHEN GUARD ADDED)
           ----------------------------------------------------- */
        SET @sql = CONCAT(
            'UPDATE dataentrychange_auditlog AS da ',
            'JOIN ', v_child, ' AS c ON da.RefTransID = c.', v_childPK, ' ',
            joinSQL,
            'SET ',
                'da.rootTableName = CASE ',
                    'WHEN da.Tablename = ''', rootTable, ''' ',
                    'THEN da.rootTableName ',
                    'ELSE ''', rootTable, ''' END, ',

                'da.rootRefId = CASE ',
                    'WHEN da.Tablename = ''', rootTable, ''' ',
                    'THEN da.rootRefId ',
                    'ELSE r.', rootPK, ' END, ',

                'da.entityLevel = CASE ',
                    'WHEN da.Tablename = ''', rootTable, ''' ',
                    'THEN da.entityLevel ',
                    'ELSE ', entityLevel, ' END, ',

                'da.entityDisplayRef = CASE ',
                    'WHEN da.Tablename = ''', rootTable, ''' ',
                    'THEN da.entityDisplayRef ',
                    'ELSE c.', v_display, ' END ',

            'WHERE da.Tablename = ''', v_child, ''''
        );
        SELECT @sql;
        PREPARE stmt FROM @sql;
        -- EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET curIndex = curIndex + 1;
    END WHILE;

END$$
DELIMITER ;
