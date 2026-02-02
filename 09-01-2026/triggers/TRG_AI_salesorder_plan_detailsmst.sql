DROP TRIGGER IF EXISTS `TRG_AI_salesorder_plan_detailsmst`;
CREATE TRIGGER `TRG_AI_salesorder_plan_detailsmst` AFTER INSERT ON `salesorder_plan_detailsmst` FOR EACH ROW BEGIN  

    DECLARE vSORevision VARCHAR(20);
    DECLARE vTableName VARCHAR(50) DEFAULT "salesorder_plan_detailsmst"; 

    SELECT revision INTO vSORevision FROM salesordermst WHERE id in (SELECT refSalesOrderID FROM salesorderdet 
    WHERE id in (SELECT refSalesOrderdetId FROM kitmst WHERE id in (SELECT refkitmstID FROM salesorder_plan_detailsmst WHERE id=new.id)));
    
    DECLARE vSalesOrderID BIGINT;
    SELECT refSalesOrderID INTO vSalesOrderID FROM salesorderdet WHERE id IN (SELECT refSalesOrderdetId FROM kitmst km WHERE km.id = NEW.refkitmstID);
	INSERT INTO kit_release_return_trans_history  
		(  
			refAssyId, 			refPlanId, 			woID,				plannKitNumber,  
            releaseDate, 		releasedBy, 		releaseStatus, 		releasedNote, 		releaseKitNumber,  
            returnStatus, 		returnDate, 		returnBy, 			initiateReturnBy, 	initiateReturnAt,  
            isDeleted,  		refkitmstID,  		createdAt,			createdBy,			createByRoleId,  
            updatedAt, 			updatedBy, 			updateByRoleId  
		)  
	VALUES  
		(  
			IFNULL(new.subAssyID, new.refAssyId), 		new.id, 			new.woID,  
            new.plannKitNumber, 		new.actualKitReleaseDate, 			new.releasedBy, 		new.kitStatus,  
            new.releasedNote, 			new.releaseKitNumber, 				new.kitReturnStatus, 	new.kitReturnDate,  
            new.kitReturnBy, 			new.initiateReturnBy, 				new.initiateReturnAt,  
            0,							new.refkitmstID,  					NEW.createdAt, 			NEW.createdBy,  
            NEW.createByRoleId,			NEW.createdAt, 						NEW.createdBy,			NEW.createByRoleId  
		);  

  	CALL Sproc_Audit_Generic_Update(
        'salesordermst',                        -- root_table_name
        vSalesOrderID,                          -- root_ref_id
        'salesorder_plan_detailsmst',           -- table_name
        NEW.id,                                 -- ref_trans_id
        2,                                      -- entity_level
        NEW.name,                               -- entity_display_ref
        /* OLD JSON */
        JSON_OBJECT(
          'poQty', '',
          'poDueDate', '',
          'materialDockDate', '',
          'kitReleaseQty', '',
          'mfrLeadTime', '',
          'kitReleaseDate', '',
          'plannKitNumber', '',
          'actualKitReleaseDate', '',
          'releasedBy', '',
          'releaseTimeFeasibility', '',
          'kitStatus', '',
          'woID', '',
          'releasedNote', '',
          'releaseKitNumber', '',
          'kitReturnStatus', '',
          'kitReturnDate', '',
        ),

        /* NEW JSON */
        JSON_OBJECT(
          'poQty', CAST(NEW.poQty AS CHAR),
          'poDueDate', CAST(DATE_FORMAT(NEW.poDueDate, "%m/%d/%y") AS CHAR),
          'materialDockDate', CAST(DATE_FORMAT(NEW.materialDockDate, "%m/%d/%y") AS CHAR),
          'kitReleaseQty', CAST(NEW.kitReleaseQty AS CHAR),
          'mfrLeadTime', CAST(NEW.mfrLeadTime AS CHAR),
          'kitReleaseDate', CAST(DATE_FORMAT(NEW.kitReleaseDate, "%m/%d/%y") AS CHAR),
          'plannKitNumber', CAST(NEW.plannKitNumber AS CHAR),
          'actualKitReleaseDate', CAST(DATE_FORMAT(NEW.actualKitReleaseDate, "%m/%d/%y") AS CHAR),
          'releasedBy', CAST(NEW.releasedBy AS CHAR),
          'releaseTimeFeasibility', CAST(NEW.releaseTimeFeasibility AS CHAR),
          'kitStatus', CAST(
              CASE 
                  WHEN NEW.kitStatus = 'P' THEN 'In Progress'
                  WHEN NEW.kitStatus = 'R' THEN 'Released'
                  ELSE '' 
              END AS CHAR
          ),
          'woID', CAST(NEW.woID AS CHAR),
          'releasedNote', CAST(NEW.releasedNote AS CHAR),
          'releaseKitNumber', CAST(NEW.releaseKitNumber AS CHAR),
          'kitReturnStatus', CAST(
              CASE 
                  WHEN NEW.kitReturnStatus = 'NA' THEN 'N/A'
                  WHEN NEW.kitReturnStatus = 'NR' THEN 'Not Returned'
                  WHEN NEW.kitReturnStatus = 'RR' THEN 'Ready To Return'
                  WHEN NEW.kitReturnStatus = 'PR' THEN 'Partially Returned'
                  WHEN NEW.kitReturnStatus = 'RS' THEN 'Intent to Re-Release'
                  WHEN NEW.kitReturnStatus = 'FR' THEN 'Fully Returned'
                  ELSE '' 
              END AS CHAR
          ),
          'kitReturnDate', CAST(DATE_FORMAT(NEW.kitReturnDate, "%m/%d/%y") AS CHAR)
        ),

        /* CONTEXT JSON */
        JSON_OBJECT(                      
            'soRevision', vSORevision
        ),

        NEW.updatedBy,            -- updatedBy
        NEW.updateByRoleId        -- updateByRoleId
        );
END;
