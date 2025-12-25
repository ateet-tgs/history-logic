CREATE TRIGGER trg_audit_sales_order
AFTER UPDATE ON sales_order
FOR EACH ROW
BEGIN
    -- Track status changes
    IF OLD.status <> NEW.status THEN
        INSERT INTO dataentrychange_auditlog (
            root_table_name, root_ref_id,
            table_name, ref_trans_id,
            entity_level, entity_display_ref,
            col_name, old_val, new_val,
            updated_by, update_by_role_id
        )
        VALUES (
            'sales_order', NEW.id,
            'sales_order', NEW.id,
            0, NEW.order_no,
            'status', OLD.status, NEW.status,
            NEW.updated_by, NEW.update_by_role_id
        );
    END IF;

    -- Track customer name changes
    IF OLD.customer_name <> NEW.customer_name THEN
        INSERT INTO dataentrychange_auditlog VALUES (
            NULL,
            'sales_order', NEW.id,
            'sales_order', NEW.id,
            0, NEW.order_no,
            'customer_name', OLD.customer_name, NEW.customer_name,
            NOW(), NEW.updated_by, NEW.update_by_role_id
        );
    END IF;
END;