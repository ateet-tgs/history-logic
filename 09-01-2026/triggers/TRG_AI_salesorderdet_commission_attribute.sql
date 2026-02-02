DROP TRIGGER IF EXISTS `TRG_AI_salesorderdet_commission_attribute`;
CREATE TRIGGER `TRG_AI_salesorderdet_commission_attribute` AFTER INSERT ON `salesorderdet_commission_attribute` FOR EACH ROW BEGIN

    DECLARE vSORevision VARCHAR(20);
    DECLARE vTableName VARCHAR(50) DEFAULT "salesorderdet_commission_attribute"; 

    SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet WHERE id in 
    (select refSalesorderdetID from salesorderdet_commission_attribute where id=new.id));
    DECLARE vSalesOrderID BIGINT;
    SELECT refSalesOrderID INTO vSalesOrderID FROM salesorderdet sod WHERE sod.id = NEW.refSalesorderdetID;
    
    CALL Sproc_Audit_Generic_Update(
        'salesordermst',            -- root_table_name
        vSalesOrderID,                  -- root_ref_id
        'TRG_AI_salesorderdet_commission_attribute',            -- table_name
        NEW.id,                  -- ref_trans_id
        2,                       -- entity_level
        NEW.name,                -- entity_display_ref
        /* OLD JSON */
        JSON_OBJECT(
            'unitPrice', '',
            'commissionPercentage', '',
            'commissionValue', '',
            'org_commissionPercentage', '',
            'org_commissionValue', '',
            'org_unitPrice', ''
        ),

        /* NEW JSON */
        JSON_OBJECT(
            'unitPrice', CAST(CAST(new.unitPrice AS DECIMAL(16,6)) AS CHAR),
            'commissionPercentage', CAST(CAST(new.commissionPercentage AS DECIMAL(16,6)) AS CHAR),
            'commissionValue', CAST(CAST(new.commissionValue AS DECIMAL(16,6)) AS CHAR),
            'org_commissionPercentage', CAST(CAST(new.org_commissionPercentage AS DECIMAL(16,6)) AS CHAR),
            'org_commissionValue', CAST(CAST(new.org_commissionValue AS DECIMAL(16,6)) AS CHAR),
            'org_unitPrice', CAST(CAST(new.org_unitPrice AS DECIMAL(16,6)) AS CHAR)
        ),

        /* CONTEXT JSON */
        JSON_OBJECT(                      
            'soRevision', vSORevision
        ),

        NEW.updatedBy,            -- updatedBy
        NEW.updateByRoleId        -- updateByRoleId
        );
END;
