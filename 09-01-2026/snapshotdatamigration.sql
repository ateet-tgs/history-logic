START TRANSACTION;
INSERT INTO audit_change_context_snapshot
(
    auditLogId,
    contextField,
    contextValue,
    valueType
)
SELECT
    dal.ID AS auditLogId,
    'soRevision' AS contextField,
    dal.revision AS contextValue,
    'STRING' AS valueType
FROM dataentrychange_auditlog dal
LEFT JOIN audit_change_context_snapshot acs
    ON acs.auditLogId = dal.ID
   AND acs.contextField = 'soRevision'
WHERE dal.Tablename IN (
        'salesorderdet_commission_attribute_mstdet',
        'salesorderdet_commission_attribute',
        'salesorder_otherexpense_details',
        'salesshippingmst',
        'salesorderdet',
        'salesordermst',
        'salesorder_plan_detailsmst'
    )
  AND dal.revision IS NOT NULL
  AND acs.id IS NULL;

-- COMMIT;