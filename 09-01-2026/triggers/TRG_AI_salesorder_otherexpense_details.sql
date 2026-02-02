DROP TRIGGER IF EXISTS `TRG_AI_salesorder_otherexpense_details`;
CREATE TRIGGER `TRG_AI_salesorder_otherexpense_details` AFTER INSERT ON `salesorder_otherexpense_details` FOR EACH ROW BEGIN 


		DECLARE vSORevision VARCHAR(20);
		DECLARE vTableName VARCHAR(50) DEFAULT "salesorder_otherexpense_details"; 
		DECLARE newReleaseNumber INT;
        
		SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet 
		WHERE id in (select refSalesOrderDetID from salesorder_otherexpense_details where id=new.id));
		
		SELECT releaseNumber INTO newReleaseNumber from salesshippingmst where shippingID = NEW.refReleaseLineID;
        DECLARE vSalesOrderID BIGINT;
        SELECT refSalesOrderID INTO vSalesOrderID FROM salesorderdet sod WHERE sod.id = NEW.refSalesOrderDetID;

   IF (NEW.extendedPrice IS NOT NULL) THEN  
		SELECT refSalesOrderID INTO @soID  
        FROM salesorderdet  
        WHERE id = NEW.refSalesOrderDetID;  
  
		UPDATE salesordermst  
        SET totalAmount = IFNULL(totalAmount,0) + IFNULL(NEW.extendedPrice,0),  
		lineMiscCharge = IFNULL(lineMiscCharge,0) + IFNULL(NEW.extendedPrice,0) ,  
        updatedBy = NEW.createdBy, updateByRoleId =NEW.createByRoleId , updatedAt = NEW.createdAt  
        WHERE id = @soID;  
  
        UPDATE salesorderdet  
        SET otherCharges = IFNULL(otherCharges,0) + IFNULL(NEW.extendedPrice,0)  
        WHERE id = NEW.refSalesOrderDetID;  
    END IF;  
  
	CALL Sproc_Audit_Generic_Update(
        'salesordermst',                        -- root_table_name
        vSalesOrderID,                          -- root_ref_id
        'salesorder_otherexpense_details',      -- table_name
        NEW.id,                                 -- ref_trans_id
        2,                                      -- entity_level
        NEW.name,                               -- entity_display_ref
        /* OLD JSON */
        JSON_OBJECT(
            'partID', '',
			'qty', '',
			'price', '',
			'frequency', '',
			'lineComment', '',
			'lineInternalComment', '',
			'frequencyType', '',
			'refReleaseLineID', '',
			'partDescription', '',
			'specialNote', '',
			'extendedPrice', '',
        ),

        /* NEW JSON */
        JSON_OBJECT(
            'partID', CAST(fun_getComponentNameByID(new.partID) AS CHAR),
			'qty', CAST(fun_getComponentNameByID(new.partID) AS CHAR),
			'price', CAST(CAST(new.price AS DECIMAL(15,8)) AS CHAR),
			'frequency', CAST(CASE WHEN new.frequency=1 THEN 'Every' WHEN new.frequency=2 THEN 'First' WHEN new.frequency=3 THEN 'Last' ELSE '' END  AS CHAR),
			'lineComment', CAST(new.lineComment AS CHAR),
			'lineInternalComment', CAST(new.lineInternalComment AS CHAR),
			'frequencyType', CAST(CASE WHEN new.frequencyType=1 THEN 'Release' WHEN new.frequencyType=2 THEN 'Shipment'  ELSE '' END  AS CHAR),
			'refReleaseLineID', newReleaseNumber,
			'partDescription', CAST(new.partDescription AS CHAR),
			'specialNote', CAST(new.specialNote AS CHAR),
			'extendedPrice', CAST(CAST(new.extendedPrice AS DECIMAL(18, 8)) AS CHAR),
        ),

        /* CONTEXT JSON */
        JSON_OBJECT(                      
            'soRevision', vSORevision
        ),

        NEW.updatedBy,            -- updatedBy
        NEW.updateByRoleId        -- updateByRoleId
        );
END;
