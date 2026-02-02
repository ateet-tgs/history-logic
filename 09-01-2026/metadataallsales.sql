/* ============================================================
   salesorderdet_commission_attribute_mstdet
============================================================ */
INSERT INTO audit_column_metadata
(tableName,colName,isForeignKey,refTable,refPk,refDisplayColumn,isContextField,displayOrder,refLabel,
 createdBy,createdAt,createByRoleId,updatedBy,updatedAt,updateByRoleId,isDeleted)
VALUES
('salesorderdet_commission_attribute_mstdet','unitPrice',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PRICE_EA_INCLUDING_COMMISSION_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','commissionPercentage',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='COMMISSION_EA_PERCENTAGE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','commissionValue',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='COMMISSION_EA_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','quoted_commissionPercentage',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTED_COMMISSION_EA_PERCENTAGE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','quoted_commissionValue',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTED_COMMISSION_EA_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','quoted_unitPrice',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTED_PRICE_EA_INCLUDING_COMMISSION_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','poQty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='OPEN_PO_QTY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','quotedQty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTED_QTY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','type',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='TYPE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','commissionCalculateFrom',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='COMMISSION_CALC_FROM'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute_mstdet','salesCommissionNotes',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SALES_COMMISSION_NOTES'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0);

/* ============================================================
   salesorderdet_commission_attribute
============================================================ */
INSERT INTO audit_column_metadata
(tableName,colName,isForeignKey,refTable,refPk,refDisplayColumn,isContextField,displayOrder,refLabel,
 createdBy,createdAt,createByRoleId,updatedBy,updatedAt,updateByRoleId,isDeleted)
VALUES
('salesorderdet_commission_attribute','unitPrice',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PRICE_EA_INCLUDING_COMMISSION_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute','commissionPercentage',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='COMMISSION_EA_PERCENTAGE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute','commissionValue',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='COMMISSION_EA_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute','org_commissionPercentage',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTED_COMMISSION_EA_PERCENTAGE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute','org_commissionValue',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTED_COMMISSION_EA_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet_commission_attribute','org_unitPrice',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTED_PRICE_EA_INCLUDING_COMMISSION_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0);

/* ============================================================
   salesorder_otherexpense_details
============================================================ */
INSERT INTO audit_column_metadata
(tableName,colName,isForeignKey,refTable,refPk,refDisplayColumn,isContextField,displayOrder,refLabel,
 createdBy,createdAt,createByRoleId,updatedBy,updatedAt,updateByRoleId,isDeleted)
VALUES
('salesorder_otherexpense_details','partID',1,'component','id','mfgPN',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='ASSY_ID_PID'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','qty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QTY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','price',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','frequency',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CHARGE_FREQUENCY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','lineComment',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='COMMENTS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','lineInternalComment',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='INTERNAL_NOTES'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','frequencyType',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CHARGE_FREQUENCY_TYPE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','refReleaseLineID',1,'salesshippingmst', 'shippingID', 'releaseNumber',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='OF_RELEASE_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','partDescription',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='DESCRIPTION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','specialNote',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SPECIAL_NOTES'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_otherexpense_details','extendedPrice',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='EXTENDED_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0);

/* ============================================================
   salesshippingmst
============================================================ */
INSERT INTO audit_column_metadata
(tableName,colName,isForeignKey,refTable,refPk,refDisplayColumn,isContextField,displayOrder,refLabel,
 createdBy,createdAt,createByRoleId,updatedBy,updatedAt,updateByRoleId,isDeleted)
VALUES
('salesshippingmst','qty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QTY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','shippingDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='REQUESTED_SHIP_DATE_ORIG'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','shippingMethodID',1,'genericcategory','gencCategoryID','name',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SHIPPING_METHOD'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','shippingAddressID',1,'customer_addresses','id','address',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SHIPPING_ADDRESS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','shippingContactPersonID',1,'contactperson','personId','name',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CONTACT_PERSON_SHIPPING_ADDRESS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','description',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='ADDITIONAL_NOTES'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','releaseNotes',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='RELEASE_NOTES'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','promisedShipDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PROMISED_SHIP_DATE_ORIG'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','releaseNumber',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SO_LINE_RELEASE_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','requestedDockDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='REQUESTED_DOCK_DATE_ORIG'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','carrierID',1,'genericcategory','gencCategoryID','name',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CARRIER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','carrierAccountNumber',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CARRIER_ACCOUNT_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','customerReleaseLine',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CUST_PO_LINE_RELEASE_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','revisedRequestedDockDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='REQUESTED_DOCK_DATE_REVISED'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','revisedRequestedShipDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='REQUESTED_SHIP_DATE_REVISED'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','revisedRequestedPromisedDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PROMISED_SHIP_DATE_REVISED'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','isAgreeToShip',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_LOCK_ORIG_DATES'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','isReadyToShip',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_REL_QTY_READY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','poReleaseNumber',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='RELEASE_PO_NUMBER_BPO_ONLY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','intermediateShipmentId',1,'customer_addresses','id','address',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='INTERMEDIATE_ADDRESS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesshippingmst','intermediateContactPersonID',1,'contactperson','personId','name',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CONTACT_PERSON_INTERMEDIATE_SHIPPING_ADDRESS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0);


/* ============================================================
   salesorderdet
============================================================ */
INSERT INTO audit_column_metadata
(tableName,colName,isForeignKey,refTable,refPk,refDisplayColumn,isContextField,displayOrder,refLabel,
 createdBy,createdAt,createByRoleId,updatedBy,updatedAt,updateByRoleId,isDeleted)
VALUES

('salesorderdet','qty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PO_QTY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','price',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','extendedPrice',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='EXTENDED_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','otherCharges',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='TOT_OTHER_CHARGES_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','mrpQty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='MR_PQTY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','shippingQty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SHIPPING_QTY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','originalPOQty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='ORIGINAL_PO_QTY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','materialTentitiveDocDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CUST_CONSIGNED_MATERIAL_PROMISED_DOCK_DATE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','materialDueDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PURCHASED_MATERIAL_DOCK_DATE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','requestedBPOStartDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='REQUESTED_BLANKET_PO_START_DATE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','blanketPOEndDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='BLANKET_PO_END_DATE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','partID',1,'component','id','mfgPN',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='ASSY_ID_PID'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','partType',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PART_TYPE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','partDescription',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PART_DESCRIPTION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','uom',1,'uoms','id','unitName',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='UOM'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','lineID',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SO_LINE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','custPOLineNumber',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PO_LINE_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','custOrgPOLineNumber',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='ORG_PO_LINE_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','refSODetID',1,'salesorderdet','id','lineID',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='ASSOCIATE_TO_PO'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','refRFQGroupID',1,'rfqforms','id','rfqNumber',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTE_GROUP'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','refRFQQtyTurnTimeID',1,'rfq_assy_quantity_turn_time','id','qty',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTE_QTY_TURN_TIME'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','assyQtyTurnTimeText',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTE_QTY_TURN_TIME'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','quoteNumber',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTE_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','quoteFrom',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='QUOTE_FROM'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','prcNumberofWeek',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='BUILD_WEEK'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','tentativeBuild',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='TENTATIVE_BUILD'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','salesOrderDetStatus',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='LINE_STATUS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','completeStatusReason',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='COMPLETE_STATUS_REASON'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','soLineShippingStatus',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SO_LINE_SHIPPING_STATUS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isHotJob',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_HOT_JOB'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isCancle',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_SO_CANCEL'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isSkipKitCreation',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_SKIP_KIT_CREATION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isUnitPriceRevised',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_SO_REVISED_PRICE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isCustomerConsign',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_CUSTOMER_CONSIGN'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isNonInventoryItem',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_NON_INVENTORY_ITEM'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isDoNotIssueCofc',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_DO_NOT_ISSUE_COFC'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isShipAsNonInventory',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_SHIP_AS_NON_INVENTORY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isLotChargeItem',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_LOT_CHARGE_ITEM'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','isTariffApplicable',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='IS_TARIFF_APPLICABLE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','remark',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='LINE_SHIPPING_COMMENTS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','internalComment',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='LINE_INTERNAL_NOTES'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','releaseLevelComment',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='COMMENTS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','woComment',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='WO_COMMENT'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','specialNote',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SPECIAL_NOTES'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','cancleReason',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CANCEL_REASON'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','salesCommissionTo',1,'employees','id','initialName',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SALES_COMMISSION_TO'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','frequency',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CHARGE_FREQUENCY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','frequencyType',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='CHARGE_FREQUENCY_TYPE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorderdet','refSOReleaseLineID',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='OF_RELEASE_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0);



/* ============================================================
   salesordermst
============================================================ */
INSERT INTO audit_column_metadata
(tableName,colName,isForeignKey,refTable,refPk,refDisplayColumn,isContextField,displayOrder,refLabel,
 createdBy,createdAt,createByRoleId,updatedBy,updatedAt,updateByRoleId,isDeleted)
VALUES
('salesordermst','salesOrderNumber',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SO_NUMBER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','poNumber',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='PO_NUMBER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','poDate',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='PO_DATE'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','customerID',1,'mfgcodemst','id','code',0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='CUSTOMER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','contactPersonID',1,'contactperson','personId','personName',0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='CONTACT_PERSON'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','billingAddress',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='BILLING_ADDRESS'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','shippingAddress',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SHIPPING_ADDRESS'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','shippingMethodID',1,'genericcategory','gencCategoryID','categoryName',0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SHIPPING_METHOD'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','revision',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SO_REVISION'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','shippingComment',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SHIPPING_COMMENT'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','internalComment',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='INTERNAL_COMMENT'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','termsID',1,'genericcategory','gencCategoryID','categoryName',0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='TERM'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','soDate',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SO_DATE'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','revisionChangeNote',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='REVISION_CHANGE_NOTE'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','isBlanketPO',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='IS_BLANKET_PO'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','poRevision',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='PO_REVISION'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','isDeleted',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='IS_SO_DELETED'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','isRmaPO',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='IS_RMA_PO'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','isLegacyPO',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='IS_LEGACY_PO'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','originalPODate',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='ORIGINAL_PO_DATE'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','rmaNumber',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='RMA_NUMBER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','isDebitedByCustomer',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='IS_DEBITED_BY_CUSTOMER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','orgPONumber',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='ORG_PO_NUMBER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','isReworkRequired',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='IS_REWORK_REQUIRED'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','reworkPONumber',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='REWORK_PO_NUMBER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','blanketPOOption',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='BLANKET_PO_OPTION'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','linkToBlanketPO',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='LINK_TO_BLANKET_PO'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','workingStatus',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SO_WORKING_STATUS'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','subStatus',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='STATUS'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','poRevisionDate',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='PO_REVISION_DATE'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','salesCommissionTo',1,'employees','id','initialName',0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SALES_COMMISSION_TO'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','carrierID',1,'genericcategory','gencCategoryID','categoryName',0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='CARRIER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','carrierAccountNumber',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='CARRIER_ACCOUNT_NUMBER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','freeOnBoardId',1,'freeonboardmst','id','fobName',0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='FREE_ON_BOARD'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','serialNumber',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SERIAL_NUMBER'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','totalAmount',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='TOTAL_AMOUNT'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','lineTotalAmount',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='LINE_TOTAL_AMOUNT'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','lineMiscCharge',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='LINE_MISC_CHARGE'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','billingContactPerson',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='BILLING_CONTACT_PERSON'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','shippingContactPerson',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SHIPPING_CONTACT_PERSON'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','intermediateAddress',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='INTERMEDIATE_ADDRESS'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','intermediateContactPerson',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='INTERMEDIATE_CONTACT_PERSON'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','soShippingStatus',0,NULL,NULL,NULL,0,NULL,(SELECT id FROM app_label_constant 
WHERE keyName='SO_SHIPPING_STATUS'),-2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','billingContactPersonID',1,'contactperson','personId','personName',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='BILLING_CONTACT_PERSON'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','intermediateContactPersonID',1,'contactperson','personId','personName',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='INTERMEDIATE_CONTACT_PERSON'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','intermediateShipmentId',1,'customer_addresses','id','street1',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='INTERMEDIATE_ADDRESS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','billingAddressID',1,'customer_addresses','id','street1',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='BILLING_ADDRESS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','shippingAddressID',1,'customer_addresses','id','street1',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SHIPPING_ADDRESS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesordermst','shippingContactPersonID',1,'contactperson','personId','personName',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='SHIPPING_CONTACT_PERSON'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0);


/* ============================================================
   salesorder_plan_detailsmst
============================================================ */
INSERT INTO audit_column_metadata
(tableName,colName,isForeignKey,refTable,refPk,refDisplayColumn,isContextField,displayOrder,refLabel,
 createdBy,createdAt,createByRoleId,updatedBy,updatedAt,updateByRoleId,isDeleted)
VALUES
('salesorder_plan_detailsmst','poQty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PROMISED_SHIP_QTY_FROM_PO'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','poDueDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PROMISED_SHIP_DATE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','materialDockDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='MATERIAL_DOCK_DATE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','kitReleaseQty',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PLANNED_KIT_AND_BUILD_QTY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','mfrLeadTime',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='BUILD_LEAD_TIME_BUSINESS_DAYS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','kitReleaseDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PLANNED_KIT_RELEASE_DATE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','plannKitNumber',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='PLANNED_KIT_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','actualKitReleaseDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='ACTUAL_KIT_RELEASE_DATE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','releasedBy',1,'initialName','id','initialName',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='RELEASED_BY'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','releaseTimeFeasibility',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='FEASIBILITY_AT_THE_TIME_OF_THE_RELEASE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','kitStatus',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='KIT_STATUS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','woID',1,'workorder','woID','woNumber',0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='WO_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','releasedNote',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='RELEASED_COMMENT'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','releaseKitNumber',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='KIT_RELEASE_NUMBER'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','kitReturnStatus',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='KIT_RETURN_STATUS'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),

('salesorder_plan_detailsmst','kitReturnDate',0,NULL,NULL,NULL,0,NULL,
 (SELECT id FROM app_label_constant WHERE keyName='KIT_RETURN_DATE'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0);


/* ============================================================ 
   audit_change_context_snapshot
 ============================================================ */

INSERT INTO audit_column_metadata
(tableName,colName,isForeignKey,refTable,refPk,refDisplayColumn,isContextField,displayOrder,refLabel,
 createdBy,createdAt,createByRoleId,updatedBy,updatedAt,updateByRoleId,isDeleted)
VALUES
('salesorderdet_commission_attribute','soRevision',0,NULL,NULL,NULL,1,2,
 (SELECT id FROM app_label_constant WHERE keyName='SO_REVISION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),
 
('salesorder_otherexpense_details','soRevision',0,NULL,NULL,NULL,1,2,
 (SELECT id FROM app_label_constant WHERE keyName='SO_REVISION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),
 
('salesshippingmst','soRevision',0,NULL,NULL,NULL,1,2,
 (SELECT id FROM app_label_constant WHERE keyName='SO_REVISION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),
 
('salesorderdet','soRevision',0,NULL,NULL,NULL,1,2,
 (SELECT id FROM app_label_constant WHERE keyName='SO_REVISION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),
 
('salesordermst','soRevision',0,NULL,NULL,NULL,1,2,
 (SELECT id FROM app_label_constant WHERE keyName='SO_REVISION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),
 
('salesorder_plan_detailsmst','soRevision',0,NULL,NULL,NULL,1,2,
 (SELECT id FROM app_label_constant WHERE keyName='SO_REVISION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0),
 
('salesorderdet_commission_attribute_mstdet','soRevision',0,NULL,NULL,NULL,1,2,
 (SELECT id FROM app_label_constant WHERE keyName='SO_REVISION'),
 -2,fun_DatetimetoUTCDateTime(),-1,-2,fun_DatetimetoUTCDateTime(),-1,0);