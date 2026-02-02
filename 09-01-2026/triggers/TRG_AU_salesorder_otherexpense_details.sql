DROP TRIGGER IF EXISTS `TRG_AU_salesorder_otherexpense_details`;
CREATE TRIGGER `TRG_AU_salesorder_otherexpense_details` AFTER UPDATE ON `salesorder_otherexpense_details` FOR EACH ROW BEGIN  

	DECLARE vSORevision VARCHAR(20);
	DECLARE vTableName VARCHAR(50) DEFAULT "salesorder_otherexpense_details"; 
	DECLARE vNewReleaseNumber INT;
    DECLARE vOldReleaseNumber INT;
    
	SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet 
	WHERE id in (select refSalesOrderDetID from salesorder_otherexpense_details where id=new.id));
	DECLARE vSalesOrderID BIGINT;
    SELECT refSalesOrderID INTO vSalesOrderID FROM salesorderdet sod WHERE sod.id = NEW.refSalesOrderDetID;
   IF IFNULL(OLD.extendedPrice,0) != IFNULL(NEW.extendedPrice,0) THEN  
		SELECT refSalesOrderID INTO @soID  
        FROM salesorderdet  
        WHERE id = NEW.refSalesOrderDetID;  
  
		UPDATE salesordermst  
        SET totalAmount = IFNULL(totalAmount,0) - IFNULL(OLD.extendedPrice,0) +IFNULL(NEW.extendedPrice,0),  
		lineMiscCharge = IFNULL(lineMiscCharge,0) - IFNULL(OLD.extendedPrice,0) + IFNULL(NEW.extendedPrice,0) ,  
        updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt  
        WHERE id = @soID;  
  
        UPDATE salesorderdet  
        SET otherCharges = IFNULL(otherCharges,0) - IFNULL(OLD.extendedPrice,0) + IFNULL(NEW.extendedPrice,0),  
        updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt  
        WHERE id = NEW.refSalesOrderDetID;  
    END IF;  
    IF  (old.isDeleted = 0 AND new.isDeleted = 1) THEN  
			SELECT refSalesOrderID INTO @soID  
			FROM salesorderdet  
			WHERE id = NEW.refSalesOrderDetID;  
  
			UPDATE salesorderdet  
			SET otherCharges = IFNULL(otherCharges,0) - IFNULL(OLD.extendedPrice,0)  
			WHERE isDeleted = 0  
            AND id = NEW.refSalesOrderDetID;  
            UPDATE salesordermst  
			SET totalAmount = totalAmount - OLD.extendedPrice,  
			lineMiscCharge = IFNULL(lineMiscCharge,0) - OLD.extendedPrice  
			WHERE id = @soID;  
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
			'partID', CAST(OLD.partID AS CHAR),
			'qty', CAST(OLD.qty AS CHAR),
			'price', CAST(CAST(OLD.price AS DECIMAL(15,8)) AS CHAR),
			'frequency', CAST(CASE WHEN OLD.frequency = 1 THEN 'Every' WHEN OLD.frequency = 2 THEN 'First' WHEN OLD.frequency = 3 THEN 'Last' ELSE '' END AS CHAR),
			'lineComment', CAST(OLD.lineComment AS CHAR),
			'lineInternalComment', CAST(OLD.lineInternalComment AS CHAR),
			'frequencyType', CAST(CASE WHEN OLD.frequencyType = 1 THEN 'Release' WHEN OLD.frequencyType = 2 THEN 'Shipment' ELSE '' END AS CHAR),
			'refReleaseLineID', CAST(OLD.refReleaseLineID AS CHAR),
			'partDescription', CAST(OLD.partDescription AS CHAR),
			'specialNote', CAST(OLD.specialNote AS CHAR),
			'extendedPrice', CAST(CAST(OLD.extendedPrice AS DECIMAL(18,8)) AS CHAR)
		),

        /* NEW JSON */
        JSON_OBJECT(
            'partID', CAST(NEW.partID AS CHAR),
			'qty', CAST(NEW.qty AS CHAR),
			'price', CAST(CAST(NEW.price AS DECIMAL(15,8)) AS CHAR),
			'frequency', CAST(CASE WHEN NEW.frequency=1 THEN 'Every' WHEN NEW.frequency=2 THEN 'First' WHEN NEW.frequency=3 THEN 'Last' ELSE '' END  AS CHAR),
			'lineComment', CAST(NEW.lineComment AS CHAR),
			'lineInternalComment', CAST(NEW.lineInternalComment AS CHAR),
			'frequencyType', CAST(CASE WHEN NEW.frequencyType=1 THEN 'Release' WHEN NEW.frequencyType=2 THEN 'Shipment'  ELSE '' END  AS CHAR),
			'refReleaseLineID', CAST(NEW.refReleaseLineID AS CHAR),
			'partDescription', CAST(NEW.partDescription AS CHAR),
			'specialNote', CAST(NEW.specialNote AS CHAR),
			'extendedPrice', CAST(CAST(NEW.extendedPrice AS DECIMAL(18, 8)) AS CHAR),
        ),

        /* CONTEXT JSON */
        JSON_OBJECT(                      
            'soRevision', vSORevision
        ),

        NEW.updatedBy,            -- updatedBy
        NEW.updateByRoleId        -- updateByRoleId
        );
END;
