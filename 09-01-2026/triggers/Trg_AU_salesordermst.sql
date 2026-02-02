DROP TRIGGER IF EXISTS `Trg_AU_salesordermst`;
CREATE TRIGGER `Trg_AU_salesordermst` AFTER UPDATE ON `salesordermst` FOR EACH ROW BEGIN  

      DECLARE vTableName VARCHAR(50) DEFAULT "salesordermst";
      DECLARE vOldCustomer VARCHAR(100);  
      DECLARE vNewCustomer VARCHAR(100);
      DECLARE vMfgCodeFormat INT;
      DECLARE v_contactFormatType INT;
      DECLARE vOldConcatPerson VARCHAR(100);  
      DECLARE vNewConcatPerson VARCHAR(100);

      SELECT fun_getMFGCodeNameFormat() INTO vMfgCodeFormat;
      SELECT fun_getContPersonNameDisplayFormat() INTO v_contactFormatType;   

    IF ( IFNULL(OLD.blanketPOOption,0)=3 AND IFNULL(NEW.blanketPOOption,0)!=3) OR (IFNULL(OLD.blanketPOOption,0)!=3 AND IFNULL(NEW.blanketPOOption,0)=3) THEN  
    CREATE TEMPORARY TABLE IF NOT EXISTS tempsalesDet  
       SELECT sd.id FROM salesorderdet sd WHERE sd.refSalesOrderID=NEW.id AND NEW.isDeleted=0;  
       IF(IFNULL(OLD.blanketPOOption,0)=3 AND IFNULL(NEW.blanketPOOption,0)!=3)THEN  
		UPDATE salesshippingmst ss SET ss.poReleaseNumber=NULL WHERE ss.sDetID IN (SELECT sd.id FROM tempsalesDet sd) AND ss.isdeleted=0;  
		UPDATE salesorderdet sd SET sd.requestedBPOStartDate=NULL,sd.blanketPOEndDate=NULL WHERE sd.refSalesOrderID=NEW.id AND NEW.isDeleted=0;  
       END IF;  
       IF(IFNULL(OLD.blanketPOOption,0)!=3 AND IFNULL(NEW.blanketPOOption,0)=3)THEN  
		UPDATE salesshippingmst ss SET ss.poReleaseNumber=CONCAT(new.poNumber,'-',ss.customerReleaseLine) WHERE ss.sDetID IN (SELECT sd.id FROM tempsalesDet sd) AND ss.isdeleted=0;  
       END IF;  
      DROP TEMPORARY TABLE IF EXISTS tempsalesDet;  
    END IF;  
     IF(IFNULL(OLD.blanketPOOption,0)=2 AND IFNULL(NEW.blanketPOOption,0)!=2)THEN  
		UPDATE salesorderdet sd SET sd.requestedBPOStartDate=NULL,sd.blanketPOEndDate=NULL WHERE sd.refSalesOrderID=NEW.id AND NEW.isDeleted=0;  
      END IF;  
  
    IF IFNULL(OLD.salesOrderNumber,0) != IFNULL(NEW.salesOrderNumber,0) THEN  
       UPDATE customer_packingslip SET soNumber=NEW.salesOrderNumber,updatedBy=NEW.updatedBy,updatedAt=NEW.updatedAt WHERE refSalesOrderID=NEW.id;  
	END IF;  
    IF IFNULL(OLD.poNumber,0) != IFNULL(NEW.poNumber,0) THEN  
		UPDATE salesorderdet_tariff sotar JOIN (
				SELECT sod.id refSalesOrderDetID
				FROM salesordermst so JOIN salesorderdet sod ON so.id = sod.refSalesOrderID AND sod.isDeleted = 0
				WHERE so.isDeleted = 0 AND so.id = NEW.id 
			) soLine
		SET sotar.custPONumber = NEW.poNumber
		WHERE sotar.isDeleted = 0 AND sotar.refSalesOrderDetID = soLine.refSalesOrderDetID;
    UPDATE customer_packingslip SET poNumber=NEW.poNumber,updatedBy=NEW.updatedBy,updatedAt=NEW.updatedAt WHERE refSalesOrderID=NEW.id;  
    END IF;  
    IF IFNULL(OLD.poDate,0) != IFNULL(NEW.poDate,0) THEN  
		UPDATE salesorderdet_tariff sotar JOIN (
				SELECT sod.id refSalesOrderDetID
				FROM salesordermst so JOIN salesorderdet sod ON so.id = sod.refSalesOrderID AND sod.isDeleted = 0
				WHERE so.isDeleted = 0 AND so.id = NEW.id 
			) soLine
		SET sotar.custPODate = NEW.poDate
		WHERE sotar.isDeleted = 0 AND sotar.refSalesOrderDetID = soLine.refSalesOrderDetID;    

    UPDATE customer_packingslip SET poDate=NEW.poDate,updatedBy=NEW.updatedBy,updatedAt=NEW.updatedAt WHERE refSalesOrderID=NEW.id;  
    END IF;    
  /*  IF IFNULL(OLD.status ,0) != IFNULL(NEW.status ,0) THEN  
     INSERT INTO dataentrychange_auditlog(Tablename, RefTransID, Colname, Oldval, Newval,  
				updatedAt, updatedBy, updateByRoleId, revision, valueDataType) 
    VALUES("SALESORDERMST",CAST(new.id AS CHAR),'STATUS', CASE WHEN OLD.status=0 THEN 'Draft'  WHEN OLD.status=1 THEN 'Published' ELSE '' END,  
       CASE WHEN new.status=0 THEN 'Draft'  WHEN new.status=1 THEN 'Published' ELSE '' END,  
				NEW.updatedAt, NEW.updatedBy, NEW.updateByRoleId, NEW.revision, fun_getDataTypeBasedOnTableAndColumnName(vTableName,'status'));  
    END IF;  */

    CALL Sproc_Audit_Generic_Update(
        'salesordermst',            -- root_table_name
        NEW.refSalesOrderID,                  -- root_ref_id
        'salesorderdet',            -- table_name
        NEW.id,                  -- ref_trans_id
        2,                       -- entity_level
        NEW.name,                -- entity_display_ref
        /* OLD JSON */
        JSON_OBJECT(
			'salesOrderNumber', CAST(OLD.salesOrderNumber AS CHAR),
         'poNumber', CAST(OLD.poNumber AS CHAR),
         'poDate', CAST(DATE_FORMAT(OLD.poDate, "%m/%d/%Y") AS CHAR),
         'customerID', CAST(OLD.customerID AS CHAR),
         'contactPersonID', CAST(OLD.contactPersonID AS CHAR),
         'billingAddress', CAST(OLD.billingAddress AS CHAR),
         'shippingAddress', CAST(OLD.shippingAddress AS CHAR),
         'shippingMethodID', CAST(OLD.shippingMethodID AS CHAR),
         'revision', CAST(OLD.revision AS CHAR),
         'shippingComment', CAST(OLD.shippingComment AS CHAR),
         'internalComment', CAST(OLD.internalComment AS CHAR),
         'termsID', CAST(OLD.termsID AS CHAR),
         'soDate', CAST(DATE_FORMAT(OLD.soDate, "%m/%d/%Y") AS CHAR),
         'revisionChangeNote', CAST(OLD.revisionChangeNote AS CHAR),
         'isBlanketPO', CAST(fun_getIntToText(OLD.isBlanketPO) AS CHAR),
         'poRevision', CAST(OLD.poRevision AS CHAR),
         'isDeleted', CAST(fun_getIntToText(OLD.isDeleted) AS CHAR),
         'isRmaPO', CAST(fun_getIntToText(OLD.isRmaPO) AS CHAR),
         'isLegacyPO', CAST(fun_getIntToText(OLD.isLegacyPO) AS CHAR),
         'originalPODate', CAST(DATE_FORMAT(OLD.originalPODate, "%m/%d/%Y") AS CHAR),
         'rmaNumber', CAST(OLD.rmaNumber AS CHAR),
         'isDebitedByCustomer', CAST(fun_getIntToText(OLD.isDebitedByCustomer) AS CHAR),
         'orgPONumber', CAST(OLD.orgPONumber AS CHAR),
         'isReworkRequired', CAST(fun_getIntToText(OLD.isReworkRequired) AS CHAR),
         'reworkPONumber', CAST(OLD.reworkPONumber AS CHAR),
         'blanketPOOption',
            CASE
                  WHEN OLD.blanketPOOption = 1 THEN 'Use This BPO# for All Releases (Non-Rolling PO)'
                  WHEN OLD.blanketPOOption = 2 THEN 'Link Future PO(s) to This BPO'
                  WHEN OLD.blanketPOOption = 3 THEN 'Use This BPO# and Release# for All Releases'
                  WHEN OLD.blanketPOOption = 4 THEN 'Use This BPO# for All Releases (Rolling PO)'
                  ELSE ''
            END,
         'linkToBlanketPO', CAST(fun_getIntToText(OLD.linkToBlanketPO) AS CHAR),
         'workingStatus',
            CASE
                  WHEN OLD.workingStatus = 1 THEN 'In Progress'
                  WHEN OLD.workingStatus = 2 THEN 'Completed'
                  WHEN OLD.workingStatus = 3 THEN 'Waiting To Publish'
                  WHEN OLD.workingStatus = 4 THEN 'Reopened & In Progress'
                  ELSE ''
            END,
         'subStatus',
            CASE
                  WHEN OLD.subStatus = 1 THEN 'Draft'
                  WHEN OLD.subStatus = 2 THEN 'Under Investigation'
                  WHEN OLD.subStatus = 3 THEN 'Published'
                  ELSE ''
            END,
         'poRevisionDate', CAST(DATE_FORMAT(OLD.poRevisionDate, "%m/%d/%Y") AS CHAR),
         'salesCommissionTo', CAST(OLD.salesCommissionTo AS CHAR),
         'carrierID', CAST(OLD.carrierID AS CHAR),
         'carrierAccountNumber', CAST(OLD.carrierAccountNumber AS CHAR),
         'freeOnBoardId', CAST(OLD.freeOnBoardId AS CHAR),
         'serialNumber', CAST(OLD.serialNumber AS CHAR),
         'totalAmount', CAST(CAST(OLD.totalAmount AS DECIMAL(15,8)) AS CHAR),
         'lineTotalAmount', CAST(CAST(OLD.lineTotalAmount AS DECIMAL(15,8)) AS CHAR),
         'lineMiscCharge', CAST(CAST(OLD.lineMiscCharge AS DECIMAL(15,8)) AS CHAR),
         'billingContactPerson', CAST(OLD.billingContactPerson AS CHAR),
         'shippingContactPerson', CAST(OLD.shippingContactPerson AS CHAR),
         'intermediateAddress', CAST(OLD.intermediateAddress AS CHAR),
         'intermediateContactPerson', CAST(OLD.intermediateContactPerson AS CHAR),
         'soShippingStatus',
            CASE
                  WHEN OLD.soShippingStatus = -1 THEN 'Canceled'
                  WHEN OLD.soShippingStatus = 1 THEN 'Not Shipped'
                  WHEN OLD.soShippingStatus = 2 THEN 'Partially Shipped'
                  WHEN OLD.soShippingStatus = 3 THEN 'Completed'
                  WHEN OLD.soShippingStatus = 4 THEN 'Completed & Reopened'
                  ELSE ''
            END
		)

        /* NEW JSON */
		JSON_OBJECT(
			'salesOrderNumber', CAST(NEW.salesOrderNumber AS CHAR),
         'poNumber', CAST(NEW.poNumber AS CHAR),
         'poDate', CAST(DATE_FORMAT(NEW.poDate, "%m/%d/%Y") AS CHAR),
         'customerID', CAST(NEW.customerID AS CHAR),
         'contactPersonID', CAST(NEW.contactPersonID AS CHAR),
         'billingAddress', CAST(NEW.billingAddress AS CHAR),
         'shippingAddress', CAST(NEW.shippingAddress AS CHAR),
         'shippingMethodID', CAST(NEW.shippingMethodID AS CHAR),
         'revision', CAST(NEW.revision AS CHAR),
         'shippingComment', CAST(NEW.shippingComment AS CHAR),
         'internalComment', CAST(NEW.internalComment AS CHAR),
         'termsID', CAST(NEW.termsID AS CHAR),
         'soDate', CAST(DATE_FORMAT(NEW.soDate, "%m/%d/%Y") AS CHAR),
         'revisionChangeNote', CAST(NEW.revisionChangeNote AS CHAR),
         'isBlanketPO', CAST(fun_getIntToText(NEW.isBlanketPO) AS CHAR),
         'poRevision', CAST(NEW.poRevision AS CHAR),
         'isDeleted', CAST(fun_getIntToText(NEW.isDeleted) AS CHAR),
         'isRmaPO', CAST(fun_getIntToText(NEW.isRmaPO) AS CHAR),
         'isLegacyPO', CAST(fun_getIntToText(NEW.isLegacyPO) AS CHAR),
         'originalPODate', CAST(DATE_FORMAT(NEW.originalPODate, "%m/%d/%Y") AS CHAR),
         'rmaNumber', CAST(NEW.rmaNumber AS CHAR),
         'isDebitedByCustomer', CAST(fun_getIntToText(NEW.isDebitedByCustomer) AS CHAR),
         'orgPONumber', CAST(NEW.orgPONumber AS CHAR),
         'isReworkRequired', CAST(fun_getIntToText(NEW.isReworkRequired) AS CHAR),
         'reworkPONumber', CAST(NEW.reworkPONumber AS CHAR),
         'blanketPOOption',
            CASE
                  WHEN NEW.blanketPOOption = 1 THEN 'Use This BPO# for All Releases (Non-Rolling PO)'
                  WHEN NEW.blanketPOOption = 2 THEN 'Link Future PO(s) to This BPO'
                  WHEN NEW.blanketPOOption = 3 THEN 'Use This BPO# and Release# for All Releases'
                  WHEN NEW.blanketPOOption = 4 THEN 'Use This BPO# for All Releases (Rolling PO)'
                  ELSE ''
            END,
         'linkToBlanketPO', CAST(fun_getIntToText(NEW.linkToBlanketPO) AS CHAR),
         'workingStatus',
            CASE
                  WHEN NEW.workingStatus = 1 THEN 'In Progress'
                  WHEN NEW.workingStatus = 2 THEN 'Completed'
                  WHEN NEW.workingStatus = 3 THEN 'Waiting To Publish'
                  WHEN NEW.workingStatus = 4 THEN 'Reopened & In Progress'
                  ELSE ''
            END,
         'subStatus',
            CASE
                  WHEN NEW.subStatus = 1 THEN 'Draft'
                  WHEN NEW.subStatus = 2 THEN 'Under Investigation'
                  WHEN NEW.subStatus = 3 THEN 'Published'
                  ELSE ''
            END,
         'poRevisionDate', CAST(DATE_FORMAT(NEW.poRevisionDate, "%m/%d/%Y") AS CHAR),
         'salesCommissionTo', CAST(NEW.salesCommissionTo AS CHAR),
         'carrierID', CAST(NEW.carrierID AS CHAR),
         'carrierAccountNumber', CAST(NEW.carrierAccountNumber AS CHAR),
         'freeOnBoardId', CAST(NEW.freeOnBoardId AS CHAR),
         'serialNumber', CAST(NEW.serialNumber AS CHAR),
         'totalAmount', CAST(CAST(NEW.totalAmount AS DECIMAL(15,8)) AS CHAR),
         'lineTotalAmount', CAST(CAST(NEW.lineTotalAmount AS DECIMAL(15,8)) AS CHAR),
         'lineMiscCharge', CAST(CAST(NEW.lineMiscCharge AS DECIMAL(15,8)) AS CHAR),
         'billingContactPerson', CAST(NEW.billingContactPerson AS CHAR),
         'shippingContactPerson', CAST(NEW.shippingContactPerson AS CHAR),
         'intermediateAddress', CAST(NEW.intermediateAddress AS CHAR),
         'intermediateContactPerson', CAST(NEW.intermediateContactPerson AS CHAR),
         'soShippingStatus',
            CASE
                  WHEN NEW.soShippingStatus = -1 THEN 'Canceled'
                  WHEN NEW.soShippingStatus = 1 THEN 'Not Shipped'
                  WHEN NEW.soShippingStatus = 2 THEN 'Partially Shipped'
                  WHEN NEW.soShippingStatus = 3 THEN 'Completed'
                  WHEN NEW.soShippingStatus = 4 THEN 'Completed & Reopened'
                  ELSE ''
            END
            )
        /* CONTEXT JSON */
        JSON_OBJECT(                      
            'soRevision', NEW.revision
        ),
        NEW.updatedBy,            -- updatedBy
        NEW.updateByRoleId        -- updateByRoleId
        );
END;
