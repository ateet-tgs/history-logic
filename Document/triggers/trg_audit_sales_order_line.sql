CREATE TRIGGER trg_audit_sales_order_line
AFTER UPDATE ON sales_order_line_detail
FOR EACH ROW
BEGIN
    DECLARE v_order_no VARCHAR(50);

    -- Retrieve parent order number for context
    SELECT order_no
    INTO v_order_no
    FROM sales_order
    WHERE id = NEW.sales_order_id;

    -- Track quantity changes
    IF OLD.quantity <> NEW.quantity THEN
        INSERT INTO dataentrychange_auditlog VALUES (
            NULL,
            'sales_order', NEW.sales_order_id,
            'sales_order_line_detail', NEW.id,
            1, v_order_no,
            'quantity', OLD.quantity, NEW.quantity,
            NOW(), NEW.updated_by, NEW.update_by_role_id
        );
    END IF;

    -- Track price changes
    IF OLD.price <> NEW.price THEN
        INSERT INTO dataentrychange_auditlog VALUES (
            NULL,
            'sales_order', NEW.sales_order_id,
            'sales_order_line_detail', NEW.id,
            1, v_order_no,
            'price', OLD.price, NEW.price,
            NOW(), NEW.updated_by, NEW.update_by_role_id
        );
    END IF;
END;