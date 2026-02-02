DROP TRIGGER IF EXISTS `TRG_AU_salesorderdet_commission_attribute_mstdet`;
CREATE TRIGGER `TRG_AU_salesorderdet_commission_attribute_mstdet` AFTER UPDATE ON `salesorderdet_commission_attribute_mstdet` FOR EACH ROW BEGIN

    DECLARE vSORevision VARCHAR(20);
    DECLARE vTableName VARCHAR(50) DEFAULT "salesorderdet_commission_attribute_mstdet"; 
    SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet WHERE id in 
    (select refSalesOrderDetID from salesorderdet_commission_attribute_mstdet where id=new.id));
    DECLARE vSalesOrderID BIGINT;
    SELECT refSalesOrderID INTO vSalesOrderID FROM salesorderdet sod WHERE sod.id = NEW.refSalesOrderDetID;
    
    CALL Sproc_Audit_Generic_Update(
        'salesordermst',            -- root_table_name
        vSalesOrderID,                  -- root_ref_id
        'salesorderdet_commission_attribute_mstdet',            -- table_name
        NEW.id,                  -- ref_trans_id
        2,                       -- entity_level
        NEW.name,                -- entity_display_ref
        /* OLD JSON */
        JSON_OBJECT(
            'unitPrice', CAST(CAST(OLD.unitPrice AS DECIMAL(16,6)) AS CHAR),
            'commissionPercentage', CAST(CAST(OLD.commissionPercentage AS DECIMAL(16,6)) AS CHAR),
            'commissionValue', CAST(CAST(OLD.commissionValue AS DECIMAL(16,6)) AS CHAR),
            'quoted_commissionPercentage', CAST(CAST(OLD.quoted_commissionPercentage AS DECIMAL(16,6)) AS CHAR),
            'quoted_commissionValue', CAST(CAST(OLD.quoted_commissionValue AS DECIMAL(16,6)) AS CHAR),
            'quoted_unitPrice', CAST(CAST(OLD.quoted_unitPrice AS DECIMAL(16,6)) AS CHAR),
            'poQty', CAST(OLD.poQty AS CHAR),
            'quotedQty', CAST(OLD.quotedQty AS CHAR),
            'type', 
                CAST(
                    CASE
                        WHEN OLD.type = 1 THEN 'From MPN Sales Price'
                        WHEN OLD.type = 2 THEN 'From RFQ'
                        WHEN OLD.type = 3 THEN 'MISC'
                        ELSE ''
                    END
                AS CHAR),
            'commissionCalculateFrom', 
                CAST(
                    CASE
                        WHEN OLD.commissionCalculateFrom = 1 THEN 'Sales Price Matrix'
                        WHEN OLD.commissionCalculateFrom = 2 THEN 'RFQ Quote Summary'
                        WHEN OLD.commissionCalculateFrom = 3 THEN 'Manual'
                        ELSE ''
                    END
                AS CHAR),
            'salesCommissionNotes', CAST(OLD.salesCommissionNotes AS CHAR),
            'isDeleted', CAST(fun_getIntToText(OLD.isDeleted) AS CHAR)
        )

        /* NEW JSON */
        JSON_OBJECT(
            'unitPrice', CAST(NEW.unitPrice AS DECIMAL(16,6)),
            'commissionPercentage', CAST(NEW.commissionPercentage AS DECIMAL(16,6)),
            'commissionValue', CAST(NEW.commissionValue AS DECIMAL(16,6)),
            'quoted_commissionPercentage', CAST(NEW.quoted_commissionPercentage AS DECIMAL(16,6)),
            'quoted_commissionValue', CAST(NEW.quoted_commissionValue AS DECIMAL(16,6)),
            'quoted_unitPrice', CAST(NEW.quoted_unitPrice AS DECIMAL(16,6)),
            'poQty', NEW.poQty,
            'quotedQty', NEW.quotedQty,
            'type',
                CASE
                    WHEN NEW.type = 1 THEN 'From MPN Sales Price'
                    WHEN NEW.type = 2 THEN 'From RFQ'
                    WHEN NEW.type = 3 THEN 'MISC'
                    ELSE NULL
                END,
            'commissionCalculateFrom',
                CASE
                    WHEN NEW.commissionCalculateFrom = 1 THEN 'Sales Price Matrix'
                    WHEN NEW.commissionCalculateFrom = 2 THEN 'RFQ Quote Summary'
                    WHEN NEW.commissionCalculateFrom = 3 THEN 'Manual'
                    ELSE NULL
                END,

            'salesCommissionNotes', NEW.salesCommissionNotes
        ),

        /* CONTEXT JSON */
        JSON_OBJECT(                      
            'soRevision', vSORevision
        ),

        NEW.updatedBy,            -- updatedBy
        NEW.updateByRoleId        -- updateByRoleId
        ); 
END;
