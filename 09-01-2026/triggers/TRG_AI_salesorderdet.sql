DROP TRIGGER IF EXISTS `TRG_AI_salesorderdet`;
CREATE TRIGGER `TRG_AI_salesorderdet` AFTER INSERT ON `salesorderdet` FOR EACH ROW BEGIN  

	DECLARE vSORevision VARCHAR(20);
	DECLARE vTableName VARCHAR(50) DEFAULT "salesorderdet"; 
	DECLARE vNewCustPoLineNumber VARCHAR(50);  
	DECLARE newReleaseNumber INT;

	SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet WHERE id=new.id);

	IF(NEW.refBlanketPOID IS NOT NULL)THEN  
  
		INSERT INTO salesorder_otherexpense_details(refSalesOrderDetID,partID,qty,price,extendedPrice,frequency,lineComment,  
			lineInternalComment,createdBy,updatedBy,frequencyType,createdAt,updatedAt)  
		 SELECT NEW.id,partID,qty,price,extendedPrice,frequency,lineComment,  
         lineInternalComment,NEW.createdBy,NEW.createdBy,frequencyType,NEW.createdAt,NEW.createdAt  FROM  
		 salesorder_otherexpense_details WHERE refSalesOrderDetID=NEW.refBlanketPOID AND isdeleted=0;  
	END IF;  
    IF (NEW.extendedPrice IS NOT NULL) THEN  
		UPDATE salesordermst  
        SET totalAmount = IFNULL(totalAmount,0) + NEW.extendedPrice,  
		lineTotalAmount = IFNULL(lineTotalAmount,0) + NEW.extendedPrice ,  
        updatedBy = NEW.createdBy, updateByRoleId =NEW.createByRoleId , updatedAt = NEW.createdAt  
        WHERE id = NEW.refSalesOrderID;  
    END IF; 
	
	CALL Sproc_Audit_Generic_Update(
        'salesordermst',            -- root_table_name
        NEW.refSalesOrderID,                  -- root_ref_id
        'salesorderdet',            -- table_name
        NEW.id,                  -- ref_trans_id
        2,                       -- entity_level
        NEW.name,                -- entity_display_ref
        /* OLD JSON */
        JSON_OBJECT(
			'qty','',
			'price','',
			'extendedPrice','',
			'otherCharges','',
			'mrpQty','',
			'shippingQty','',
			'remark','',
			'materialTentitiveDocDate','',
			'prcNumberofWeek','',
			'isHotJob','',
			'materialDueDate','',
			'partID','',
			'isCancle','',
			'cancleReason','',
			'tentativeBuild','',
			'uom','',
			'lineID','',
			'salesCommissionTo','',
			'refRFQGroupID','',
			'refRFQQtyTurnTimeID','',
			'custPOLineNumber','',
			'partType','',
			'salesOrderDetStatus','',
			'completeStatusReason','',
			'isSkipKitCreation','',
			'partDescription','',
			'quoteNumber','',
			'quoteFrom','',
			'assyQtyTurnTimeText','',
			'internalComment','',
			'isCustomerConsign','',
			'frequency','',
			'refSODetID','',
			'originalPOQty','',
			'frequencyType','',
			'releaseLevelComment','',
			'woComment','',
			'custOrgPOLineNumber','',
			'requestedBPOStartDate','',
			'blanketPOEndDate','',
			'specialNote','',
			'isUnitPriceRevised','',
			'isNonInventoryItem','',
			'isDoNotIssueCofc','',
			'isShipAsNonInventory','',
			'isLotChargeItem','',
			'isTariffApplicable','',
			'refSOReleaseLineID','',
			'soLineShippingStatus',''
		)

        /* NEW JSON */
		JSON_OBJECT(
			'qty', CAST(NEW.qty AS CHAR),
			'price', CAST(CAST(NEW.price AS DECIMAL(15,8)) AS CHAR),
			'extendedPrice', CAST(CAST(NEW.extendedPrice AS DECIMAL(18,8)) AS CHAR),
			'otherCharges', CAST(CAST(NEW.otherCharges AS DECIMAL(18,8)) AS CHAR),
			'mrpQty', CAST(NEW.mrpQty AS CHAR),
			'shippingQty', CAST(NEW.shippingQty AS CHAR),
			'remark', CAST(NEW.remark AS CHAR),
			'materialTentitiveDocDate', CAST(DATE_FORMAT(NEW.materialTentitiveDocDate,"%m/%d/%Y") AS CHAR),
			'prcNumberofWeek', CAST(NEW.prcNumberofWeek AS CHAR),
			'isHotJob', CAST(fun_getIntToText(NEW.isHotJob) AS CHAR),
			'materialDueDate', CAST(DATE_FORMAT(NEW.materialDueDate,"%m/%d/%Y") AS CHAR),
			'partID', CAST(fun_getAssyPIDCodeByID(NEW.partID) AS CHAR),
			'isCancle', CAST(fun_getIntToText(NEW.isCancle) AS CHAR),
			'cancleReason', CAST(NEW.cancleReason AS CHAR),
			'tentativeBuild', CAST(NEW.tentativeBuild AS CHAR),
			'uom', CAST(fun_getUnitNameByID(NEW.uom) AS CHAR),
			'lineID', CAST(NEW.lineID AS CHAR),
			'salesCommissionTo', CAST(fun_GetSalesCommissionToPerson(NEW.salesCommissionTo) AS CHAR),
			'refRFQGroupID', CAST(NEW.refRFQGroupID AS CHAR),
			'refRFQQtyTurnTimeID', CAST(fun_GetQuoteQtyTurnTimeById(NEW.refRFQQtyTurnTimeID) AS CHAR),
			'custPOLineNumber', CAST(NEW.custPOLineNumber AS CHAR),
			'partType', CAST(fun_getPartCategoryByID(NEW.partType) AS CHAR),
			'salesOrderDetStatus',
				CAST(
					CASE
						WHEN NEW.salesOrderDetStatus = 1 THEN 'In Progress'
						WHEN NEW.salesOrderDetStatus = 2 THEN 'Completed'
						ELSE ''
					END AS CHAR
				),
			'completeStatusReason', CAST(NEW.completeStatusReason AS CHAR),
			'isSkipKitCreation', CAST(fun_getIntToText(NEW.isSkipKitCreation) AS CHAR),
			'partDescription', CAST(NEW.partDescription AS CHAR),
			'quoteNumber', CAST(NEW.quoteNumber AS CHAR),
			'quoteFrom',
				CAST(
					CASE
						WHEN NEW.quoteFrom = 1 THEN 'RFQ'
						WHEN NEW.quoteFrom = 2 THEN 'MPN Sale Price'
						WHEN NEW.quoteFrom = 3 THEN 'Manual'
						ELSE ''
					END AS CHAR
				),
			'assyQtyTurnTimeText', CAST(NEW.assyQtyTurnTimeText AS CHAR),
			'internalComment', CAST(NEW.internalComment AS CHAR),
			'isCustomerConsign', CAST(fun_getIntToText(NEW.isCustomerConsign) AS CHAR),
			'frequency',
				CAST(
					CASE
						WHEN NEW.frequency = 1 THEN 'Every'
						WHEN NEW.frequency = 2 THEN 'First'
						WHEN NEW.frequency = 3 THEN 'Last'
						ELSE ''
					END AS CHAR
				),
			'refSODetID', CAST(NEW.refSODetID AS CHAR),
			'originalPOQty', CAST(NEW.originalPOQty AS CHAR),
			'frequencyType',
				CAST(
					CASE
						WHEN NEW.frequencyType = 1 THEN 'Release'
						WHEN NEW.frequencyType = 2 THEN 'Shipment'
						ELSE ''
					END AS CHAR
				),
			'releaseLevelComment', CAST(NEW.releaseLevelComment AS CHAR),
			'woComment', CAST(NEW.woComment AS CHAR),
			'custOrgPOLineNumber', CAST(NEW.custOrgPOLineNumber AS CHAR),
			'requestedBPOStartDate', CAST(DATE_FORMAT(NEW.requestedBPOStartDate,"%m/%d/%Y") AS CHAR),
			'blanketPOEndDate', CAST(DATE_FORMAT(NEW.blanketPOEndDate,"%m/%d/%Y") AS CHAR),
			'specialNote', CAST(NEW.specialNote AS CHAR),
			'isUnitPriceRevised', CAST(fun_getIntToText(NEW.isUnitPriceRevised) AS CHAR),
			'isNonInventoryItem', CAST(fun_getIntToText(NEW.isNonInventoryItem) AS CHAR),
			'isDoNotIssueCofc', CAST(fun_getIntToText(NEW.isDoNotIssueCofc) AS CHAR),
			'isShipAsNonInventory', CAST(fun_getIntToText(NEW.isShipAsNonInventory) AS CHAR),
			'isLotChargeItem', CAST(fun_getIntToText(NEW.isLotChargeItem) AS CHAR),
			'isTariffApplicable', CAST(fun_getIntToText(NEW.isTariffApplicable) AS CHAR),
			'refSOReleaseLineID',
				CAST(
					(SELECT releaseNumber FROM salesshippingmst WHERE shippingID = NEW.refSOReleaseLineID)
					AS CHAR
				),
			'soLineShippingStatus',
				CAST(
					CASE
						WHEN NEW.soLineShippingStatus = -1 THEN 'Canceled'
						WHEN NEW.soLineShippingStatus = 1 THEN 'Not Shipped'
						WHEN NEW.soLineShippingStatus = 2 THEN 'Partially Shipped'
						WHEN NEW.soLineShippingStatus = 3 THEN 'Completed'
						WHEN NEW.soLineShippingStatus = 4 THEN 'Completed & Reopened'
						ELSE 'Not Shipped'
					END AS CHAR
				)
		)

        /* CONTEXT JSON */
        JSON_OBJECT(                      
            'soRevision', vSORevision
        ),
        NEW.updatedBy,            -- updatedBy
        NEW.updateByRoleId        -- updateByRoleId
        );
    
END;
