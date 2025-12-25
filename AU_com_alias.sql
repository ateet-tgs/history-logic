CREATE DEFINER = `root` @`localhost` TRIGGER `Trg_AU_component_fields_genericalias_mst`
AFTER
UPDATE
  ON `component_fields_genericalias_mst` FOR EACH ROW BEGIN IF NEW.refTableName = 'countrymst'
  AND IFNULL(OLD.isDeleted, 0) != IFNULL(NEW.isDeleted, 0) THEN
INSERT INTO
  dataentrychange_auditlog(
    Tablename,
    RefTransID,
    Colname,
    Oldval,
    Newval,
    updatedAt,
    Updatedby,
    updateByRoleId,
    valueDataType
  )
VALUES
  (
    'COUNTRYMST',
    CAST(new.refId AS CHAR),
    'COUNTRYMST_ALIAS_REMOVED',
    CAST(OLD.alias AS CHAR),
    CAST(NEW.alias AS CHAR),
    NEW.updatedAt,
    NEW.updatedBy,
    NEW.updateByRoleId,
    fun_getDataTypeBasedOnTableAndColumnName('countrymst', 'alias')
  );
END IF;

IF NEW.refTableName = 'rfq_rohsmst'
  CALL Sproc_Audit_Generic_Update(
        'rfq_rohsmst',              -- root_table_name
        NEW.refId,                     -- root_ref_id
        'component_fields_genericalias_mst',              -- table_name
        NEW.id,                     -- ref_trans_id
        1,                          -- entity_level
        'Alias',                   -- entity_display_ref

        /* OLD JSON */
        JSON_OBJECT(
            'alias', OLD.alias,
        ),

        /* NEW JSON */
        JSON_OBJECT(
            'alias', NEW.alias,
        ),

        NEW.updatedBy,              -- updatedBy
        NEW.updateByRoleId          -- updateByRoleId
    );

END IF;
END