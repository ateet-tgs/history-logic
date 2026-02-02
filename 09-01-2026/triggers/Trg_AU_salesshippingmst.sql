DROP TRIGGER IF EXISTS `Trg_AU_salesshippingmst`;
CREATE TRIGGER `Trg_AU_salesshippingmst` AFTER UPDATE ON `salesshippingmst` FOR EACH ROW BEGIN  
	DECLARE vBPOQty INT;  
	DECLARE vBPOTotalQty INT;
	DECLARE vSORevision VARCHAR(20);
	DECLARE vTableName VARCHAR(50) DEFAULT "salesshippingmst"; 

	SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet WHERE id in (select sDetID from salesshippingmst where shippingID=new.shippingID));
	DECLARE vSalesOrderID BIGINT;
    SELECT refSalesOrderID INTO vSalesOrderID FROM salesorderdet sod WHERE sod.id = NEW.sDetID;
	IF(new.sDetID IS NOT NULL)THEN  
		SELECT  SUM(cpd.shipQty) INTO @shipQty   FROM customer_packingslip_det cpd  
		WHERE cpd.isdeleted=0 AND cpd.refsalesorderdetid=new.sDetID AND cpd.transType='P';  
  
		-- SELECT SUM(ss.qty) INTO @qty FROM salesorderdet ss WHERE ss.sDetID=new.sDetID AND ss.isdeleted=0;  
		SELECT refBlanketPOID,qty INTO @bpoID,@qty FROM salesorderdet  WHERE id=new.sDetID AND isdeleted=0; 
		
		IF(@bpoID IS NOT NULL)THEN   
			SELECT  qty INTO vBPOQty FROM  salesorderdet WHERE id=@bpoID;  
			SELECT  SUM(qty) INTO vBPOTotalQty FROM  salesorderdet WHERE refBlanketPOID=@bpoID AND isdeleted=0;  
	  
			IF(IFNULL(@shipQty,0)>=IFNULL(@qty,1)) THEN  
				UPDATE SalesOrderDet SET salesOrderDetStatus=2,completeStatusReason='AUTO' WHERE id=New.sDetID;  
			ELSE  
				UPDATE SalesOrderDet SET salesOrderDetStatus=1,completeStatusReason=NULL WHERE id=New.sDetID;  
			END IF;  
	  
			IF((SELECT COUNT(1) FROM SalesOrderDet WHERE  refBlanketPOID=@bpoID AND isdeleted=0 AND salesOrderDetStatus=1 AND isCancle=0)=0 AND IFNULL(vBPOQty,0)<=IFNULL(vBPOTotalQty,0))THEN  
				UPDATE SalesOrderDet SET salesOrderDetStatus=2,completeStatusReason='AUTO' WHERE (id=@bpoID OR  refSODetID=@bpoID);  
			ELSE  
				UPDATE SalesOrderDet SET salesOrderDetStatus=1,completeStatusReason=NULL WHERE (id=@bpoID OR  refSODetID=@bpoID);  
			END IF;  
  
			SELECT COUNT(1) INTO @shippingQty FROM    salesshippingmst WHERE sDetID=new.sDetID AND isdeleted=0;  
  
			UPDATE SalesOrderDet SET shippingQty=@shippingQty  WHERE id=new.sDetID;  
  
			SELECT COUNT(1) INTO @shippingQty FROM    salesshippingmst WHERE sDetID=@bpoID AND isdeleted=0;  
  
			UPDATE SalesOrderDet SET shippingQty=@shippingQty  WHERE id=@bpoID;  
		END IF;
	END IF;
  
    CALL Sproc_Audit_Generic_Update(
        'salesordermst',            -- root_table_name
        vSalesOrderID,                  -- root_ref_id
        'salesshippingmst',            -- table_name
        NEW.shippingID,                  -- ref_trans_id
        2,                       -- entity_level
        NEW.name,                -- entity_display_ref
        /* OLD JSON */
		JSON_OBJECT(
			'qty', CAST(OLD.qty AS CHAR),
			'shippingDate', CAST(DATE_FORMAT(OLD.shippingDate, "%m/%d/%y") AS CHAR),
			'shippingMethodID', CAST(OLD.shippingMethodID AS CHAR),
			'shippingAddressID', CAST(OLD.shippingAddressID AS CHAR),
			'shippingContactPersonID', CAST(OLD.shippingContactPersonID AS CHAR),
			'description', CAST(OLD.description AS CHAR),
			'releaseNotes', CAST(OLD.releaseNotes AS CHAR),
			'promisedShipDate', CAST(DATE_FORMAT(OLD.promisedShipDate, "%m/%d/%y") AS CHAR),
			'releaseNumber', CAST(OLD.releaseNumber AS CHAR),
			'requestedDockDate', CAST(DATE_FORMAT(OLD.requestedDockDate, "%m/%d/%y") AS CHAR),
			'carrierID', CAST(OLD.carrierID AS CHAR),
			'carrierAccountNumber', CAST(OLD.carrierAccountNumber AS CHAR),
			'customerReleaseLine', CAST(OLD.customerReleaseLine AS CHAR),
			'revisedRequestedDockDate', CAST(DATE_FORMAT(OLD.revisedRequestedDockDate, "%m/%d/%y") AS CHAR),
			'revisedRequestedShipDate', CAST(DATE_FORMAT(OLD.revisedRequestedShipDate, "%m/%d/%y") AS CHAR),
			'revisedRequestedPromisedDate', CAST(DATE_FORMAT(OLD.revisedRequestedPromisedDate, "%m/%d/%y") AS CHAR),
			'isAgreeToShip', CAST(fun_getIntToText(OLD.isAgreeToShip) AS CHAR),
			'isReadyToShip', CAST(fun_getIntToText(OLD.isReadyToShip) AS CHAR),
			'poReleaseNumber', CAST(OLD.poReleaseNumber AS CHAR),
			'intermediateShipmentId', CAST(OLD.intermediateShipmentId AS CHAR),
			'intermediateContactPersonID', CAST(OLD.intermediateContactPersonID AS CHAR)
		)

        /* NEW JSON */
        JSON_OBJECT(
			'qty', CAST(NEW.qty AS CHAR),
			'shippingDate', CAST(DATE_FORMAT(NEW.shippingDate, "%m/%d/%y") AS CHAR),
			'shippingMethodID', CAST(NEW.shippingMethodID AS CHAR),
			'shippingAddressID', CAST(NEW.shippingAddressID AS CHAR),
			'shippingContactPersonID', CAST(NEW.shippingContactPersonID AS CHAR),
			'description', CAST(NEW.description AS CHAR),
			'releaseNotes', CAST(NEW.releaseNotes AS CHAR),
			'promisedShipDate', CAST(DATE_FORMAT(NEW.promisedShipDate, "%m/%d/%y") AS CHAR),
			'releaseNumber', CAST(NEW.releaseNumber AS CHAR),
			'requestedDockDate', CAST(DATE_FORMAT(NEW.requestedDockDate, "%m/%d/%y") AS CHAR),
			'carrierID', CAST(NEW.carrierID AS CHAR),
			'carrierAccountNumber', CAST(NEW.carrierAccountNumber AS CHAR),
			'customerReleaseLine', CAST(NEW.customerReleaseLine AS CHAR),
			'revisedRequestedDockDate', CAST(DATE_FORMAT(NEW.revisedRequestedDockDate, "%m/%d/%y") AS CHAR),
			'revisedRequestedShipDate', CAST(DATE_FORMAT(NEW.revisedRequestedShipDate, "%m/%d/%y") AS CHAR),
			'revisedRequestedPromisedDate', CAST(DATE_FORMAT(NEW.revisedRequestedPromisedDate, "%m/%d/%y") AS CHAR),
			'isAgreeToShip', CAST(fun_getIntToText(NEW.isAgreeToShip) AS CHAR),
			'isReadyToShip', CAST(fun_getIntToText(NEW.isReadyToShip) AS CHAR),
			'poReleaseNumber', CAST(NEW.poReleaseNumber AS CHAR),
			'intermediateShipmentId', CAST(NEW.intermediateShipmentId AS CHAR),
			'intermediateContactPersonID', CAST(NEW.intermediateContactPersonID AS CHAR)
		),


        /* CONTEXT JSON */
        JSON_OBJECT(                      
            'soRevision', vSORevision
        ),

        NEW.updatedBy,            -- updatedBy
        NEW.updateByRoleId        -- updateByRoleId
        );
  
END;
