UPDATE
    dataentrychange_auditlog AS da
    JOIN SALESORDERMST AS r ON da.RefTransID = r.id
SET
    da.rootTableName = 'SALESORDERMST',
    da.rootRefId = r.id,
    da.entityLevel = 0,
    da.entityDisplayRef = r.id
WHERE
    da.Tablename = 'SALESORDERMST';
-- ====================
UPDATE
    dataentrychange_auditlog AS da
    JOIN SALESORDERDET AS c ON da.RefTransID = c.id
    JOIN SALESORDERMST AS p ON c.refSalesOrderID = p.id
    JOIN SALESORDERMST AS r ON p.id = r.id
SET
    da.rootTableName = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootTableName
        ELSE 'SALESORDERMST'
    END,
    da.rootRefId = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootRefId
        ELSE r.id
    END,
    da.entityLevel = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityLevel
        ELSE 1
    END,
    da.entityDisplayRef = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityDisplayRef
        ELSE c.lineID
    END
WHERE
    da.Tablename = 'SALESORDERDET';
-- ====================
UPDATE
    dataentrychange_auditlog AS da
    JOIN salesshippingmst AS c ON da.RefTransID = c.shippingID
    JOIN SALESORDERDET AS p ON c.sDetID = p.id
    JOIN SALESORDERMST AS t0 ON p.refSalesOrderID = t0.id
    JOIN SALESORDERMST AS r ON t0.id = r.id
SET
    da.rootTableName = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootTableName
        ELSE 'SALESORDERMST'
    END,
    da.rootRefId = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootRefId
        ELSE r.id
    END,
    da.entityLevel = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityLevel
        ELSE 2
    END,
    da.entityDisplayRef = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityDisplayRef
        ELSE c.shippingID
    END
WHERE
    da.Tablename = 'salesshippingmst';
-- ====================
UPDATE
    dataentrychange_auditlog AS da
    JOIN SALESORDER_OTHEREXPENSE_DETAILS AS c ON da.RefTransID = c.id
    JOIN SALESORDERDET AS p ON c.refSalesOrderDetID = p.id
    JOIN SALESORDERMST AS t0 ON p.refSalesOrderID = t0.id
    JOIN SALESORDERMST AS r ON t0.id = r.id
SET
    da.rootTableName = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootTableName
        ELSE 'SALESORDERMST'
    END,
    da.rootRefId = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootRefId
        ELSE r.id
    END,
    da.entityLevel = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityLevel
        ELSE 3
    END,
    da.entityDisplayRef = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityDisplayRef
        ELSE c.id
    END
WHERE
    da.Tablename = 'SALESORDER_OTHEREXPENSE_DETAILS';
-- ====================
UPDATE
    dataentrychange_auditlog AS da
    JOIN SALESORDERDET_COMMISSION_ATTRIBUTE AS c ON da.RefTransID = c.id
    JOIN SALESORDERDET AS p ON c.refSalesorderdetID = p.id
    JOIN SALESORDERMST AS t0 ON p.refSalesOrderID = t0.id
    JOIN SALESORDERMST AS r ON t0.id = r.id
SET
    da.rootTableName = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootTableName
        ELSE 'SALESORDERMST'
    END,
    da.rootRefId = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootRefId
        ELSE r.id
    END,
    da.entityLevel = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityLevel
        ELSE 4
    END,
    da.entityDisplayRef = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityDisplayRef
        ELSE c.id
    END
WHERE
    da.Tablename = 'SALESORDERDET_COMMISSION_ATTRIBUTE';
-- ====================
UPDATE
    dataentrychange_auditlog AS da
    JOIN SALESORDERDET_COMMISSION_ATTRIBUTE_MSTDET AS c ON da.RefTransID = c.id
    JOIN SALESORDERDET AS p ON c.refSalesOrderDetID = p.id
    JOIN SALESORDERMST AS t0 ON p.refSalesOrderID = t0.id
    JOIN SALESORDERMST AS r ON t0.id = r.id
SET
    da.rootTableName = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootTableName
        ELSE 'SALESORDERMST'
    END,
    da.rootRefId = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootRefId
        ELSE r.id
    END,
    da.entityLevel = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityLevel
        ELSE 5
    END,
    da.entityDisplayRef = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityDisplayRef
        ELSE c.id
    END
WHERE
    da.Tablename = 'SALESORDERDET_COMMISSION_ATTRIBUTE_MSTDET';
-- ====================
UPDATE
    dataentrychange_auditlog AS da
    JOIN KITMST AS c ON da.RefTransID = c.id
    JOIN SALESORDERDET AS p ON c.refSalesOrderdetId = p.id
    JOIN SALESORDERMST AS t0 ON p.refSalesOrderID = t0.id
    JOIN SALESORDERMST AS r ON t0.id = r.id
SET
    da.rootTableName = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootTableName
        ELSE 'SALESORDERMST'
    END,
    da.rootRefId = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootRefId
        ELSE r.id
    END,
    da.entityLevel = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityLevel
        ELSE 6
    END,
    da.entityDisplayRef = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityDisplayRef
        ELSE c.id
    END
WHERE
    da.Tablename = 'KITMST';
-- ====================
UPDATE
    dataentrychange_auditlog AS da
    JOIN SALESORDER_PLAN_DETAILSMST AS c ON da.RefTransID = c.id
    JOIN KITMST AS p ON c.refkitmstID = p.id
    JOIN SALESORDERDET AS t5 ON p.refSalesOrderdetId = t5.id
    JOIN SALESORDERMST AS t0 ON t5.refSalesOrderID = t0.id
    JOIN SALESORDERMST AS r ON t0.id = r.id
SET
    da.rootTableName = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootTableName
        ELSE 'SALESORDERMST'
    END,
    da.rootRefId = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.rootRefId
        ELSE r.id
    END,
    da.entityLevel = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityLevel
        ELSE 7
    END,
    da.entityDisplayRef = CASE
        WHEN da.Tablename = 'SALESORDERMST' THEN da.entityDisplayRef
        ELSE c.id
    END
WHERE
    da.Tablename = 'SALESORDER_PLAN_DETAILSMST';
-- ====================