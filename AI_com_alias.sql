CREATE DEFINER=`root`@`localhost` TRIGGER `Trg_AI_component_fields_genericalias_mst` AFTER INSERT ON `component_fields_genericalias_mst` FOR EACH ROW BEGIN
  IF NEW.refTableName = 'countrymst' AND NEW.alias is not null THEN  
        INSERT INTO dataentrychange_auditlog(Tablename, RefTransID, Colname, Oldval, Newval,  
    updatedAt, Updatedby, updateByRoleId, valueDataType)  
        VALUES('COUNTRYMST',CAST(NEW.refId AS CHAR),'COUNTRYMST_ALIAS_ADDED',NULL, CAST(NEW.alias AS CHAR),  
    NEW.updatedAt, NEW.updatedBy, NEW.updateByRoleId, fun_getDataTypeBasedOnTableAndColumnName('countrymst','alias'));  
  END IF;

  IF NEW.refTableName = 'rfq_rohsmst'
  CALL Sproc_Audit_Generic_Update(
        'rfq_rohsmst',              
        NEW.refId,                     
        'component_fields_genericalias_mst',              
        NEW.id,                     
        1,                          
        'Alias Added',                   
        JSON_OBJECT(
            'alias', OLD.alias,
        ),
        JSON_OBJECT(
            'alias', NEW.alias,
        ),
        NEW.updatedBy,              
        NEW.updateByRoleId          
    );

END IF;

END