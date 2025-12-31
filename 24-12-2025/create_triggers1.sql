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
DROP TRIGGER IF EXISTS rohs_peers_AFTER_INSERT;
DROP TRIGGER IF EXISTS rohs_peers_AFTER_UPDATE;

DELIMITER $$

/* ============================================================
   CUSTOMER AUDIT
============================================================ */
CREATE TRIGGER trg_audit_customer
AFTER UPDATE ON customer
FOR EACH ROW
BEGIN
    CALL Sproc_Audit_Generic_Update(
        'customer',
        NEW.id,
        'customer',
        NEW.id,
        0,
        NEW.customer_name,
        JSON_OBJECT(
            'customer_name', OLD.customer_name,
            'email', OLD.email,
            'phone', OLD.phone,
            'is_active', OLD.is_active
        ),
        JSON_OBJECT(
            'customer_name', NEW.customer_name,
            'email', NEW.email,
            'phone', NEW.phone,
            'is_active', NEW.is_active
        ),
        null,
        NEW.updated_by,
        NEW.update_by_role_id
    );
END$$

/* ============================================================
   ROHS MAIN CATEGORY AUDIT
============================================================ */
CREATE TRIGGER trg_audit_rohs_main_category
AFTER UPDATE ON rohs_main_category
FOR EACH ROW
BEGIN
    CALL Sproc_Audit_Generic_Update(
        'rohs_main_category',
        NEW.id,
        'rohs_main_category',
        NEW.id,
        0,
        NEW.name,
        JSON_OBJECT(
            'name', OLD.name,
            'description', OLD.description,
            'is_active', OLD.is_active
        ),
        JSON_OBJECT(
            'name', NEW.name,
            'description', NEW.description,
            'is_active', NEW.is_active
        ),
        null,
        NEW.updated_by,
        NEW.update_by_role_id
    );
END$$

/* ============================================================
   ROHS SUBSTANCE AUDIT
============================================================ */
CREATE TRIGGER trg_audit_rohs_substance
AFTER UPDATE ON rohs_substance
FOR EACH ROW
BEGIN
    CALL Sproc_Audit_Generic_Update(
        'rohs_substance',
        NEW.id,
        'rohs_substance',
        NEW.id,
        0,
        NEW.name,
        JSON_OBJECT(
            'name', OLD.name,
            'description', OLD.description,
            'is_active', OLD.is_active,
            'ref_main_category_id', OLD.ref_main_category_id,
            'ref_parent_id', OLD.ref_parent_id,
            'system_generated', OLD.system_generated,
            'rohs_icon', OLD.rohs_icon,
            'display_order', OLD.display_order,
            'source_name', OLD.source_name
        ),
        JSON_OBJECT(
            'name', NEW.name,
            'description', NEW.description,
            'is_active', NEW.is_active,
            'ref_main_category_id', NEW.ref_main_category_id,
            'ref_parent_id', NEW.ref_parent_id,
            'system_generated', NEW.system_generated,
            'rohs_icon', NEW.rohs_icon,
            'display_order', NEW.display_order,
            'source_name', NEW.source_name
        ),
        null,
        NEW.updated_by,
        NEW.update_by_role_id
    );
END$$

/* ============================================================
   SALES ORDER AUDIT (ROOT)
============================================================ */
CREATE TRIGGER trg_audit_sales_order
AFTER UPDATE ON sales_order
FOR EACH ROW
BEGIN
    CALL Sproc_Audit_Generic_Update(
        'sales_order',
        NEW.id,
        'sales_order',
        NEW.id,
        0,
        NEW.order_no,
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
        null,
        NEW.updated_by,
        NEW.update_by_role_id
    );
END$$

/* ============================================================
   SALES ORDER ADDRESS AUDIT (LEVEL 1)
============================================================ */
CREATE TRIGGER trg_audit_sales_order_address
AFTER UPDATE ON sales_order_address
FOR EACH ROW
BEGIN
    DECLARE v_order_no VARCHAR(50);
    SELECT order_no INTO v_order_no FROM sales_order WHERE id = NEW.sales_order_id;

    CALL Sproc_Audit_Generic_Update(
        'sales_order',
        NEW.sales_order_id,
        'sales_order_address',
        NEW.id,
        1,
        v_order_no,
        JSON_OBJECT(
            'address_type', OLD.address_type,
            'city', OLD.city,
            'country', OLD.country
        ),
        JSON_OBJECT(
            'address_type', NEW.address_type,
            'city', NEW.city,
            'country', NEW.country
        ),
        null,
        NEW.updated_by,
        NEW.update_by_role_id
    );
END$$

/* ============================================================
   SALES ORDER LINE DETAIL AUDIT (LEVEL 1)
============================================================ */
CREATE TRIGGER trg_audit_sales_order_line
AFTER UPDATE ON sales_order_line_detail
FOR EACH ROW
BEGIN
    DECLARE v_order_no VARCHAR(50);
    DECLARE v_version INT;

    SELECT order_no, version
      INTO v_order_no, v_version
    FROM sales_order
    WHERE id = NEW.sales_order_id;

    CALL Sproc_Audit_Generic_Update(
        'sales_order',
        NEW.sales_order_id,
        'sales_order_line_detail',
        NEW.id,
        1,
        v_order_no,
        JSON_OBJECT(
            'part_id', OLD.part_id,
            'quantity', OLD.quantity,
            'price', OLD.price
        ),
        JSON_OBJECT(
            'part_id', NEW.part_id,
            'quantity', NEW.quantity,
            'price', NEW.price
        ),
        JSON_OBJECT(              
            'part_id', NEW.part_id,
            'sales_order_version', v_version
        ),
        NEW.updated_by,
        NEW.update_by_role_id
    );
END$$

/* ============================================================
   SALES ORDER RELEASE LINE AUDIT (LEVEL 2)
============================================================ */
CREATE TRIGGER trg_audit_sales_order_release
AFTER UPDATE ON sales_order_release_line
FOR EACH ROW
BEGIN
    DECLARE v_so_id BIGINT;
    DECLARE v_part_id BIGINT;
    DECLARE v_version INT;
    DECLARE v_order_no VARCHAR(50);

    SELECT l.sales_order_id, l.part_id
      INTO v_so_id, v_part_id
    FROM sales_order_line_detail l
    WHERE l.id = NEW.line_detail_id;

    SELECT order_no, version
      INTO v_order_no, v_version
    FROM sales_order
    WHERE id = v_so_id;

    CALL Sproc_Audit_Generic_Update(
        'sales_order',
        v_so_id,
        'sales_order_release_line',
        NEW.id,
        2,
        v_order_no,
        JSON_OBJECT(
            'release_no', OLD.release_no,
            'released_qty', OLD.released_qty,
            'release_date', OLD.release_date
        ),
        JSON_OBJECT(
            'release_no', NEW.release_no,
            'released_qty', NEW.released_qty,
            'release_date', NEW.release_date
        ),
        JSON_OBJECT(                      -- ✅ CONTEXT
            'part_id', v_part_id,
            'sales_order_version', v_version
        ),
        NEW.updated_by,
        NEW.update_by_role_id
    );
END$$

CREATE TRIGGER `rohs_peers_AFTER_INSERT` AFTER INSERT ON `rohs_peers` FOR EACH ROW BEGIN
	 CALL Sproc_Audit_Generic_Update(
        'rohs_substance',
        NEW.source_substance_id,
        'rohs_peers',
        NEW.id,
        1,
        "Peers Added",
         /* OLD JSON */
        JSON_OBJECT(
            'target_substance_id', ''
        ),
        /* NEW JSON */
        JSON_OBJECT(
            'target_substance_id', NEW.target_substance_id
        ),
        null,
        NEW.created_by,
        NEW.create_by_role_id
    );
END$$

CREATE TRIGGER `rohs_peers_AFTER_UPDATE` AFTER UPDATE ON `rohs_peers` FOR EACH ROW BEGIN
	CALL Sproc_Audit_Generic_Update(
        'rohs_substance',
        NEW.source_substance_id,
        'rohs_peers',
        NEW.id,
        1,
        "Peers Updated",
         /* OLD JSON */
        JSON_OBJECT(
            'target_substance_id', OLD.target_substance_id
        ),
        /* NEW JSON */
        JSON_OBJECT(
            'target_substance_id', NEW.target_substance_id
        ),
        null,
        NEW.updated_by,
        NEW.update_by_role_id
    );
END$$

DELIMITER ;
