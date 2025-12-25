/* ============================================================
   DROP EXISTING TRIGGERS
============================================================ */

DROP TRIGGER IF EXISTS trg_audit_customer;
DROP TRIGGER IF EXISTS trg_audit_rohs_main_category;
DROP TRIGGER IF EXISTS trg_audit_rohs_substance;
DROP TRIGGER IF EXISTS trg_audit_sales_order;
DROP TRIGGER IF EXISTS trg_audit_sales_order_address;
DROP TRIGGER IF EXISTS trg_audit_sales_order_line;
DROP TRIGGER IF EXISTS trg_audit_sales_order_release;


/* ============================================================
   CREATE TRIGGERS
============================================================ */
DELIMITER $$

/* ============================================================
   CUSTOMER AUDIT
============================================================ */
CREATE TRIGGER trg_audit_customer
AFTER UPDATE ON customer
FOR EACH ROW
BEGIN
    IF OLD.customer_name <> NEW.customer_name THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('customer', NEW.id, 'customer', NEW.id, 0, NEW.customer_name,
         'customer_name', OLD.customer_name, NEW.customer_name,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.email <> NEW.email THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('customer', NEW.id, 'customer', NEW.id, 0, NEW.customer_name,
         'email', OLD.email, NEW.email,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.phone <> NEW.phone THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('customer', NEW.id, 'customer', NEW.id, 0, NEW.customer_name,
         'phone', OLD.phone, NEW.phone,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.is_active <> NEW.is_active THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('customer', NEW.id, 'customer', NEW.id, 0, NEW.customer_name,
         'is_active', OLD.is_active, NEW.is_active,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;
END$$


/* ============================================================
   ROHS MAIN CATEGORY AUDIT
============================================================ */
CREATE TRIGGER trg_audit_rohs_main_category
AFTER UPDATE ON rohs_main_category
FOR EACH ROW
BEGIN
    IF OLD.name <> NEW.name THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('rohs_main_category', NEW.id, 'rohs_main_category', NEW.id, 0, NEW.name,
         'name', OLD.name, NEW.name,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.is_active <> NEW.is_active THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('rohs_main_category', NEW.id, 'rohs_main_category', NEW.id, 0, NEW.name,
         'is_active', OLD.is_active, NEW.is_active,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;
END$$


/* ============================================================
   ROHS SUBSTANCE AUDIT
============================================================ */
CREATE TRIGGER trg_audit_rohs_substance
AFTER UPDATE ON rohs_substance
FOR EACH ROW
BEGIN
    IF OLD.name <> NEW.name THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('rohs_substance', NEW.id, 'rohs_substance', NEW.id, 0, NEW.name,
         'name', OLD.name, NEW.name,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.ref_main_category_id <> NEW.ref_main_category_id THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('rohs_substance', NEW.id, 'rohs_substance', NEW.id, 0, NEW.name,
         'ref_main_category_id', OLD.ref_main_category_id, NEW.ref_main_category_id,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.ref_parent_id <> NEW.ref_parent_id THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('rohs_substance', NEW.id, 'rohs_substance', NEW.id, 0, NEW.name,
         'ref_parent_id', OLD.ref_parent_id, NEW.ref_parent_id,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;
END$$


/* ============================================================
   SALES ORDER (ROOT)
============================================================ */
CREATE TRIGGER trg_audit_sales_order
AFTER UPDATE ON sales_order
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('sales_order', NEW.id, 'sales_order', NEW.id, 0, NEW.order_no,
         'status', OLD.status, NEW.status,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.customer_id <> NEW.customer_id THEN
        INSERT INTO dataentrychange_auditlog
        (root_table_name, root_ref_id, table_name, ref_trans_id, entity_level, entity_display_ref,
         col_name, old_val, new_val, updated_by, update_by_role_id)
        VALUES
        ('sales_order', NEW.id, 'sales_order', NEW.id, 0, NEW.order_no,
         'customer_id', OLD.customer_id, NEW.customer_id,
         NEW.updated_by, NEW.update_by_role_id);
    END IF;
END$$


/* ============================================================
   SALES ORDER ADDRESS (LEVEL 1)
============================================================ */
CREATE TRIGGER trg_audit_sales_order_address
AFTER UPDATE ON sales_order_address
FOR EACH ROW
BEGIN
    DECLARE v_order_no VARCHAR(50);

    SELECT order_no INTO v_order_no
    FROM sales_order WHERE id = NEW.sales_order_id;

    IF OLD.city <> NEW.city THEN
        INSERT INTO dataentrychange_auditlog
        VALUES (NULL, 'sales_order', NEW.sales_order_id,
                'sales_order_address', NEW.id,
                1, v_order_no,
                'city', OLD.city, NEW.city,
                NOW(), NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.country <> NEW.country THEN
        INSERT INTO dataentrychange_auditlog
        VALUES (NULL, 'sales_order', NEW.sales_order_id,
                'sales_order_address', NEW.id,
                1, v_order_no,
                'country', OLD.country, NEW.country,
                NOW(), NEW.updated_by, NEW.update_by_role_id);
    END IF;
END$$


/* ============================================================
   SALES ORDER LINE DETAIL (LEVEL 1)
============================================================ */
CREATE TRIGGER trg_audit_sales_order_line
AFTER UPDATE ON sales_order_line_detail
FOR EACH ROW
BEGIN
    DECLARE v_order_no VARCHAR(50);

    SELECT order_no INTO v_order_no
    FROM sales_order WHERE id = NEW.sales_order_id;

    IF OLD.quantity <> NEW.quantity THEN
        INSERT INTO dataentrychange_auditlog
        VALUES (NULL, 'sales_order', NEW.sales_order_id,
                'sales_order_line_detail', NEW.id,
                1, v_order_no,
                'quantity', OLD.quantity, NEW.quantity,
                NOW(), NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.price <> NEW.price THEN
        INSERT INTO dataentrychange_auditlog
        VALUES (NULL, 'sales_order', NEW.sales_order_id,
                'sales_order_line_detail', NEW.id,
                1, v_order_no,
                'price', OLD.price, NEW.price,
                NOW(), NEW.updated_by, NEW.update_by_role_id);
    END IF;
END$$


/* ============================================================
   SALES ORDER RELEASE LINE (LEVEL 2)
============================================================ */
CREATE TRIGGER trg_audit_sales_order_release
AFTER UPDATE ON sales_order_release_line
FOR EACH ROW
BEGIN
    DECLARE v_sales_order_id BIGINT;
    DECLARE v_order_no VARCHAR(50);

    SELECT sales_order_id INTO v_sales_order_id
    FROM sales_order_line_detail WHERE id = NEW.line_detail_id;

    SELECT order_no INTO v_order_no
    FROM sales_order WHERE id = v_sales_order_id;

    IF OLD.released_qty <> NEW.released_qty THEN
        INSERT INTO dataentrychange_auditlog
        VALUES (NULL, 'sales_order', v_sales_order_id,
                'sales_order_release_line', NEW.id,
                2, v_order_no,
                'released_qty', OLD.released_qty, NEW.released_qty,
                NOW(), NEW.updated_by, NEW.update_by_role_id);
    END IF;

    IF OLD.release_date <> NEW.release_date THEN
        INSERT INTO dataentrychange_auditlog
        VALUES (NULL, 'sales_order', v_sales_order_id,
                'sales_order_release_line', NEW.id,
                2, v_order_no,
                'release_date', OLD.release_date, NEW.release_date,
                NOW(), NEW.updated_by, NEW.update_by_role_id);
    END IF;
END$$

DELIMITER ;
