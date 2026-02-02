DROP TRIGGER IF EXISTS `TRG_AI_salesshippingmst`;
CREATE TRIGGER `TRG_AI_salesshippingmst` AFTER INSERT ON `salesshippingmst` FOR EACH ROW BEGIN

	DECLARE vSORevision VARCHAR(20);
	DECLARE vTableName VARCHAR(50) DEFAULT "salesshippingmst"; 
	SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet WHERE id in (select sDetID from salesshippingmst where shippingID=new.shippingID));
    DECLARE vSalesOrderID BIGINT;
    SELECT refSalesOrderID INTO vSalesOrderID FROM salesorderdet sod WHERE sod.id = NEW.sDetID;

	CALL Sproc_Audit_Generic_Update(
        'salesordermst',            -- root_table_name
        vSalesOrderID,                  -- root_ref_id
        'salesshippingmst',            -- table_name
        NEW.shippingID,                  -- ref_trans_id
        2,                       -- entity_level
        NEW.name,                -- entity_display_ref
        /* OLD JSON */
        JSON_OBJECT(
            'qty', '',
			'shippingDate', '',
			'shippingMethodID', '',
			'shippingAddressID', '',
			'shippingContactPersonID', '',
			'description', '',
			'releaseNotes', '',
			'promisedShipDate', '',
			'releaseNumber', '',
			'requestedDockDate', '',
			'carrierID', '',
			'carrierAccountNumber', '',
			'customerReleaseLine', '',
			'revisedRequestedDockDate', '',
			'revisedRequestedShipDate', '',
			'revisedRequestedPromisedDate', '',
			'isAgreeToShip', '',
			'isReadyToShip', '',
			'poReleaseNumber', '',
			'intermediateShipmentId', '',
			'intermediateContactPersonID', ''
        ),

        /* NEW JSON */
        JSON_OBJECT(
			'qty', CAST(NEW.qty AS CHAR),
			'shippingDate', CAST(DATE_FORMAT(NEW.shippingDate, "%m/%d/%y") AS CHAR),
			'shippingMethodID', CAST(fun_getGenericCategoryNameByID(NEW.shippingMethodID) AS CHAR),
			'shippingAddressID', CAST(fun_getCustAddressDetByID(NEW.shippingAddressID) AS CHAR),
			'shippingContactPersonID', CAST(fun_getContactPersonNameById(NEW.shippingContactPersonID) AS CHAR),
			'description', CAST(NEW.description AS CHAR),
			'releaseNotes', CAST(NEW.releaseNotes AS CHAR),
			'promisedShipDate', CAST(DATE_FORMAT(NEW.promisedShipDate, "%m/%d/%y") AS CHAR),
			'releaseNumber', CAST(NEW.releaseNumber AS CHAR),
			'requestedDockDate', CAST(DATE_FORMAT(NEW.requestedDockDate, "%m/%d/%y") AS CHAR),
			'carrierID', CAST(fun_getGenericCategoryNameByID(NEW.carrierID) AS CHAR),
			'carrierAccountNumber', CAST(NEW.carrierAccountNumber AS CHAR),
			'customerReleaseLine', CAST(NEW.customerReleaseLine AS CHAR),
			'revisedRequestedDockDate', CAST(DATE_FORMAT(NEW.revisedRequestedDockDate, "%m/%d/%y") AS CHAR),
			'revisedRequestedShipDate', CAST(DATE_FORMAT(NEW.revisedRequestedShipDate, "%m/%d/%y") AS CHAR),
			'revisedRequestedPromisedDate', CAST(DATE_FORMAT(NEW.revisedRequestedPromisedDate, "%m/%d/%y") AS CHAR),
			'isAgreeToShip', CAST(fun_getIntToText(NEW.isAgreeToShip) AS CHAR),
			'isReadyToShip', CAST(fun_getIntToText(NEW.isReadyToShip) AS CHAR),
			'poReleaseNumber', CAST(NEW.poReleaseNumber AS CHAR),
			'intermediateShipmentId', CAST(fun_getCustAddressDetByID(NEW.intermediateShipmentId) AS CHAR),
			'intermediateContactPersonID', CAST(fun_getContactPersonNameById(NEW.intermediateContactPersonID) AS CHAR)
		),


        /* CONTEXT JSON */
        JSON_OBJECT(                      
            'soRevision', vSORevision
        ),

        NEW.updatedBy,            -- updatedBy
        NEW.updateByRoleId        -- updateByRoleId
        );

	
END;
