DROP TRIGGER IF EXISTS trg_audit_sales_order;
DELIMITER $$

CREATE TRIGGER trg_audit_sales_order
AFTER UPDATE ON sales_order
FOR EACH ROW
BEGIN
    CALL Sproc_Audit_Generic_Update(
        'sales_order',          -- root_table_name
        NEW.id,                 -- root_ref_id
        'sales_order',          -- table_name
        NEW.id,                 -- ref_trans_id
        0,                      -- entity_level
        NEW.order_no,           -- entity_display_ref
        JSON_OBJECT(
            'status', OLD.status,
            'customer_id', OLD.customer_id,
            'order_date', OLD.order_date
        ),
        JSON_OBJECT(
            'status', NEW.status,
            'customer_id', NEW.customer_id,
            'order_date', NEW.order_date
        ),
        NEW.updated_by,
        NEW.update_by_role_id
    );
END$$
DELIMITER ;
