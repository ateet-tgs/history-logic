START TRANSACTION;
SET SESSION SQL_SAFE_UPDATES = 0;
CALL migrate_auditlog_recursive(
  '[
  {
    "parent": "SALESORDERMST",
    "parentPK": "id",
    "child": "SALESORDERDET",
    "childPK": "id",
    "childFK": "refSalesOrderID",
    "display": "lineID"
  },
  {
    "parent": "SALESORDERDET",
    "parentPK": "id",
    "child": "salesshippingmst",
    "childPK": "shippingID",
    "childFK": "sDetID",
    "display": "shippingID"
  },
  {
    "parent": "SALESORDERDET",
    "parentPK": "id",
    "child": "SALESORDER_OTHEREXPENSE_DETAILS",
    "childPK": "id",
    "childFK": "refSalesOrderDetID",
    "display": "id"
  },
  {
    "parent": "SALESORDERDET",
    "parentPK": "id",
    "child": "SALESORDERDET_COMMISSION_ATTRIBUTE",
    "childPK": "id",
    "childFK": "refSalesorderdetID",
    "display": "id"
  },
  {
    "parent": "SALESORDERDET",
    "parentPK": "id",
    "child": "SALESORDERDET_COMMISSION_ATTRIBUTE_MSTDET",
    "childPK": "id",
    "childFK": "refSalesOrderDetID",
    "display": "id"
  },
  {
    "parent": "SALESORDERDET",
    "parentPK": "id",
    "child": "KITMST",
    "childPK": "id",
    "childFK": "refSalesOrderdetId",
    "display": "id"
  },
  {
    "parent": "KITMST",
    "parentPK": "id",
    "child": "SALESORDER_PLAN_DETAILSMST",
    "childPK": "id",
    "childFK": "refkitmstID",
    "display": "id"
  }
]
'
);
COMMIT;