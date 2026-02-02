DROP TRIGGER IF EXISTS `Trg_AU_salesorderdet`;
CREATE TRIGGER `Trg_AU_salesorderdet` AFTER UPDATE ON `salesorderdet` FOR EACH ROW BEGIN 

	DECLARE vSORevision VARCHAR(20);
	DECLARE vTableName VARCHAR(50) DEFAULT "salesorderdet"; 
	DECLARE vNewCustPoLineNumber VARCHAR(50);  
	DECLARE vOldCustPoLineNumber VARCHAR(50);  
    DECLARE vNewReleaseNumber INT;
    DECLARE vOldReleaseNumber INT;

	SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet WHERE id=new.id);
	IF IFNULL(OLD.extendedPrice,0) != IFNULL(NEW.extendedPrice,0) THEN  
        UPDATE salesordermst  
        SET totalAmount = IFNULL(totalAmount,0) - IFNULL(OLD.extendedPrice,0) + IFNULL(NEW.extendedPrice,0),  
		lineTotalAmount = IFNULL(lineTotalAmount,0) -IFNULL(OLD.extendedPrice,0) + IFNULL(NEW.extendedPrice,0) ,  
        updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt  
        WHERE id = NEW.refSalesOrderID;  
  
	END IF;
      IF IFNULL(OLD.isDeleted,0) != IFNULL(NEW.isDeleted,0) THEN  
		/*Case : In case sales order line2 removed and line 1 is already  completed    */  
       SELECT COUNT(1) , SUM(CASE WHEN sod.salesOrderDetStatus = 2 THEN 1  
									WHEN sod.isCancle = 1 THEN 1 ELSE 0 END)  
	   INTO @totalDetLine, @totalDetCompleteLine  
	   FROM salesorderdet sod  
	   WHERE sod.refSalesOrderID = new.refSalesOrderID  
	   AND sod.isDeleted = 0  
       GROUP BY sod.refSalesOrderID;  
  
	   IF(@totalDetLine = @totalDetCompleteLine) THEN  
				UPDATE salesordermst  
				SET workingStatus = 2 , isAlreadyCompleted = 1,
					updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt
				WHERE id =new.refSalesOrderID AND isDeleted = 0;  
       ELSEIF(@totalDetLine <> @totalDetCompleteLine) THEN  
				UPDATE salesordermst  
				SET workingStatus = (CASE WHEN `status` = 0 THEN 3 ELSE 1 END),
					updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt
				WHERE id =new.refSalesOrderID AND isDeleted = 0  AND workingStatus <> 4;  
	   END IF;  
	    UPDATE salesordermst  
        SET totalAmount = IFNULL(totalAmount,0) - IFNULL(OLD.extendedPrice,0),  
		lineTotalAmount = IFNULL(lineTotalAmount,0) - IFNULL(OLD.extendedPrice,0) ,  
        updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt  
        WHERE id = NEW.refSalesOrderID;  
	END IF;  
  /*IF IFNULL(OLD.kitQty,0) != IFNULL(NEW.kitQty,0) THEN  
     INSERT INTO dataentrychange_auditlog(Tablename, RefTransID, Colname, Oldval, Newval, updatedAt, updatedBy,updateByRoleId, revision, valueDataType)  
       VALUES("SALESORDERDET",CAST(new.id AS CHAR),'KIT_QTY',CAST(OLD.kitQty AS CHAR),  
       CAST(new.kitQty AS CHAR),NEW.updatedAt,NEW.updatedBy,NEW.updateByRoleId, vSORevision, fun_getDataTypeBasedOnTableAndColumnName(vTableName,'kitQty'));   
	END IF;   
  IF IFNULL(OLD.kitNumber,0) != IFNULL(NEW.kitNumber,0) THEN  
     INSERT INTO dataentrychange_auditlog(Tablename, RefTransID, Colname, Oldval, Newval, updatedAt, updatedBy,updateByRoleId, revision, valueDataType)  
       VALUES("SALESORDERDET",CAST(new.id AS CHAR),'KIT_NUMBER',CAST(OLD.kitNumber AS CHAR),  
       CAST(new.kitNumber AS CHAR),NEW.updatedAt,NEW.updatedBy,NEW.updateByRoleId, vSORevision, fun_getDataTypeBasedOnTableAndColumnName(vTableName,'kitNumber'));   
	END IF;*/   
	IF IFNULL(old.custPOLineNumber,"")!=IFNULL(NEW.custPOLineNumber,"")THEN  
		UPDATE salesorderdet_tariff sotar 
		SET sotar.custPOLine = NEW.custPOLineNumber
		WHERE sotar.isDeleted = 0 AND sotar.refSalesOrderDetID = NEW.id;
       END IF;  
   IF IFNULL(old.salesOrderDetStatus,0)!=IFNULL(NEW.salesOrderDetStatus,0)THEN  
	   SELECT COUNT(1) , SUM(CASE WHEN sod.salesOrderDetStatus = 2 THEN 1  
							WHEN sod.isCancle = 1 THEN 1 ELSE 0 END)  
	   INTO @totalDetLine, @totalDetCompleteLine  
	   FROM salesorderdet sod  
	   WHERE sod.refSalesOrderID = new.refSalesOrderID  
	   AND sod.isDeleted = 0 ;  
  
	   IF(@totalDetLine = @totalDetCompleteLine) THEN  
				UPDATE salesordermst  
				SET workingStatus = 2 , isAlreadyCompleted = 1,
					updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt
				WHERE id =new.refSalesOrderID AND isDeleted = 0;  
       ELSEIF(@totalDetLine <> @totalDetCompleteLine) THEN  
				UPDATE salesordermst  
				SET workingStatus = 1,
					updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt
				WHERE id =new.refSalesOrderID AND isDeleted = 0  AND workingStatus <> 4;  
	   END IF;  
   END IF;  
  IF IFNULL(OLD.isCancle,0) != IFNULL(NEW.isCancle,0)  THEN  
       SELECT COUNT(1) , SUM(CASE WHEN sod.salesOrderDetStatus = 2 THEN 1  
									WHEN sod.isCancle = 1 THEN 1 ELSE 0 END)  
	   INTO @totalDetLine, @totalDetCompleteLine  
	   FROM salesorderdet sod  
	   WHERE sod.refSalesOrderID = new.refSalesOrderID  
	   AND sod.isDeleted = 0  
       GROUP BY sod.refSalesOrderID;  
  
	   IF(@totalDetLine = @totalDetCompleteLine) THEN  
				UPDATE salesordermst  
				SET workingStatus = 2 , isAlreadyCompleted = 1,
					updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt
				WHERE id =new.refSalesOrderID AND isDeleted = 0;  
		 ELSEIF(@totalDetLine <> @totalDetCompleteLine) THEN  
				UPDATE salesordermst  
				SET workingStatus = 1,
					updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt
				WHERE id =new.refSalesOrderID AND isDeleted = 0  AND workingStatus <> 4 AND subStatus <> 1;  
  
                UPDATE salesordermst  
				SET workingStatus = 3,
					updatedBy = NEW.updatedBy, updateByRoleId =NEW.updateByRoleId , updatedAt = NEW.updatedAt
				WHERE id =new.refSalesOrderID AND isDeleted = 0  AND workingStatus <> 4 AND subStatus = 1;  
  
		END IF;  
	END IF;  
    /*Start SO Shipment status update*/
    IF IFNULL(OLD.isCancle,0) != IFNULL(NEW.isCancle,0) OR IFNULL(OLD.qty,0) != IFNULL(NEW.qty,0)  THEN 
			CALL Sproc_UpdateSOShippingStatus(NEW.refSalesOrderID, NEW.updatedBy, NEW.updateByRoleId, false);
    END IF;
    /*end SO Shipment status update*/
	
	CALL Sproc_Audit_Generic_Update(
        'salesordermst',            		-- root_table_name
        NEW.refSalesOrderID,                -- root_ref_id
        'salesorderdet',            		-- table_name
        NEW.id,                  			-- ref_trans_id
        2,                       			-- entity_level
        NEW.name,                			-- entity_display_ref
        /* OLD JSON */
		JSON_OBJECT(
			'qty', CAST(OLD.qty AS CHAR),
			'price', CAST(CAST(OLD.price AS DECIMAL(15,8)) AS CHAR),
			'extendedPrice', CAST(CAST(OLD.extendedPrice AS DECIMAL(18,8)) AS CHAR),
			'otherCharges', CAST(CAST(OLD.otherCharges AS DECIMAL(18,8)) AS CHAR),
			'mrpQty', CAST(OLD.mrpQty AS CHAR),
			'shippingQty', CAST(OLD.shippingQty AS CHAR),
			'remark', CAST(OLD.remark AS CHAR),
			'materialTentitiveDocDate', CAST(DATE_FORMAT(OLD.materialTentitiveDocDate,"%m/%d/%Y") AS CHAR),
			'prcNumberofWeek', CAST(OLD.prcNumberofWeek AS CHAR),
			'isHotJob', CAST(fun_getIntToText(OLD.isHotJob) AS CHAR),
			'materialDueDate', CAST(DATE_FORMAT(OLD.materialDueDate,"%m/%d/%Y") AS CHAR),
			'partID', CAST(OLD.partID AS CHAR),
			'isCancle', CAST(fun_getIntToText(OLD.isCancle) AS CHAR),
			'cancleReason', CAST(OLD.cancleReason AS CHAR),
			'tentativeBuild', CAST(OLD.tentativeBuild AS CHAR),
			'uom', CAST(OLD.uom AS CHAR),
			'lineID', CAST(OLD.lineID AS CHAR),
			'salesCommissionTo', CAST(OLD.salesCommissionTo AS CHAR),
			'refRFQGroupID', CAST(OLD.refRFQGroupID AS CHAR),
			'refRFQQtyTurnTimeID', CAST(OLD.refRFQQtyTurnTimeID AS CHAR),
			'custPOLineNumber', CAST(OLD.custPOLineNumber AS CHAR),
			'partType', CAST(OLD.partType AS CHAR),
			'salesOrderDetStatus',
				CAST(
					CASE
						WHEN OLD.salesOrderDetStatus = 1 THEN 'In Progress'
						WHEN OLD.salesOrderDetStatus = 2 THEN 'Completed'
						ELSE ''
					END AS CHAR
				),
			'completeStatusReason', CAST(OLD.completeStatusReason AS CHAR),
			'isSkipKitCreation', CAST(fun_getIntToText(OLD.isSkipKitCreation) AS CHAR),
			'partDescription', CAST(OLD.partDescription AS CHAR),
			'quoteNumber', CAST(OLD.quoteNumber AS CHAR),
			'quoteFrom',
				CAST(
					CASE
						WHEN OLD.quoteFrom = 1 THEN 'RFQ'
						WHEN OLD.quoteFrom = 2 THEN 'MPN Sale Price'
						WHEN OLD.quoteFrom = 3 THEN 'Manual'
						ELSE ''
					END AS CHAR
				),
			'assyQtyTurnTimeText', CAST(OLD.assyQtyTurnTimeText AS CHAR),
			'internalComment', CAST(OLD.internalComment AS CHAR),
			'isCustomerConsign', CAST(fun_getIntToText(OLD.isCustomerConsign) AS CHAR),
			'frequency',
				CAST(
					CASE
						WHEN OLD.frequency = 1 THEN 'Every'
						WHEN OLD.frequency = 2 THEN 'First'
						WHEN OLD.frequency = 3 THEN 'Last'
						ELSE ''
					END AS CHAR
				),
			'refSODetID', CAST(OLD.refSODetID AS CHAR),
			'originalPOQty', CAST(OLD.originalPOQty AS CHAR),
			'frequencyType',
				CAST(
					CASE
						WHEN OLD.frequencyType = 1 THEN 'Release'
						WHEN OLD.frequencyType = 2 THEN 'Shipment'
						ELSE ''
					END AS CHAR
				),
			'releaseLevelComment', CAST(OLD.releaseLevelComment AS CHAR),
			'woComment', CAST(OLD.woComment AS CHAR),
			'custOrgPOLineNumber', CAST(OLD.custOrgPOLineNumber AS CHAR),
			'requestedBPOStartDate',
				CAST(DATE_FORMAT(OLD.requestedBPOStartDate,"%m/%d/%Y") AS CHAR),
			'blanketPOEndDate',
				CAST(DATE_FORMAT(OLD.blanketPOEndDate,"%m/%d/%Y") AS CHAR),
			'specialNote', CAST(OLD.specialNote AS CHAR),
			'isUnitPriceRevised', CAST(fun_getIntToText(OLD.isUnitPriceRevised) AS CHAR),
			'isNonInventoryItem', CAST(fun_getIntToText(OLD.isNonInventoryItem) AS CHAR),
			'isDoNotIssueCofc', CAST(fun_getIntToText(OLD.isDoNotIssueCofc) AS CHAR),
			'isShipAsNonInventory', CAST(fun_getIntToText(OLD.isShipAsNonInventory) AS CHAR),
			'isLotChargeItem', CAST(fun_getIntToText(OLD.isLotChargeItem) AS CHAR),
			'isTariffApplicable', CAST(fun_getIntToText(OLD.isTariffApplicable) AS CHAR),
			'refSOReleaseLineID', CAST(OLD.refSOReleaseLineID AS CHAR),
			'soLineShippingStatus',
				CAST(
					CASE
						WHEN OLD.soLineShippingStatus = -1 THEN 'Canceled'
						WHEN OLD.soLineShippingStatus = 1 THEN 'Not Shipped'
						WHEN OLD.soLineShippingStatus = 2 THEN 'Partially Shipped'
						WHEN OLD.soLineShippingStatus = 3 THEN 'Completed'
						WHEN OLD.soLineShippingStatus = 4 THEN 'Completed & Reopened'
						ELSE 'Not Shipped'
					END AS CHAR
				)
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
			'partID', CAST(NEW.partID AS CHAR),
			'isCancle', CAST(fun_getIntToText(NEW.isCancle) AS CHAR),
			'cancleReason', CAST(NEW.cancleReason AS CHAR),
			'tentativeBuild', CAST(NEW.tentativeBuild AS CHAR),
			'uom', CAST(NEW.uom AS CHAR),
			'lineID', CAST(NEW.lineID AS CHAR),
			'salesCommissionTo', CAST(NEW.salesCommissionTo AS CHAR),
			'refRFQGroupID', CAST(NEW.refRFQGroupID AS CHAR),
			'refRFQQtyTurnTimeID', CAST(NEW.refRFQQtyTurnTimeID AS CHAR),
			'custPOLineNumber', CAST(NEW.custPOLineNumber AS CHAR),
			'partType', CAST(NEW.partType AS CHAR),
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
			'refSOReleaseLineID', CAST(NEW.refSOReleaseLineID AS CHAR),
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
