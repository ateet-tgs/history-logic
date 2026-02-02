DROP TRIGGER IF EXISTS `TRG_AU_salesorderdet_commission_attribute`;
CREATE TRIGGER `TRG_AU_salesorderdet_commission_attribute` AFTER UPDATE ON `salesorderdet_commission_attribute` FOR EACH ROW BEGIN

    DECLARE vSORevision VARCHAR(20);
    DECLARE vTableName VARCHAR(50) DEFAULT "salesorderdet_commission_attribute"; 

    SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet WHERE id in 
    (select refSalesorderdetID from salesorderdet_commission_attribute where id=new.id));
    DECLARE vSalesOrderID BIGINT;
    SELECT refSalesOrderID INTO vSalesOrderID FROM salesorderdet sod WHERE sod.id = NEW.refSalesorderdetID;
    CALL Sproc_Audit_Generic_Update(
        'salesordermst',                                -- root_table_name
        vSalesOrderID,                                  -- root_ref_id
        'TRG_AI_salesorderdet_commission_attribute',    -- table_name
        NEW.id,                                         -- ref_trans_id
        2,                                              -- entity_level
        NEW.name,                                       -- entity_display_ref
        /* OLD JSON */
        JSON_OBJECT(
            'unitPrice', CAST(CAST(OLD.unitPrice AS DECIMAL(16,6)) AS CHAR),
            'commissionPercentage', CAST(CAST(OLD.commissionPercentage AS DECIMAL(16,6)) AS CHAR),
            'commissionValue', CAST(CAST(OLD.commissionValue AS DECIMAL(16,6)) AS CHAR),
            'org_commissionPercentage', CAST(CAST(OLD.org_commissionPercentage AS DECIMAL(16,6)) AS CHAR),
            'org_commissionValue', CAST(CAST(OLD.org_commissionValue AS DECIMAL(16,6)) AS CHAR),
            'org_unitPrice', CAST(CAST(OLD.org_unitPrice AS DECIMAL(16,6)) AS CHAR),
            'isDeleted', CAST(fun_getIntToText(OLD.isDeleted) AS CHAR)
        )

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
