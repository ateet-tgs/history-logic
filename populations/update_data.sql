/* ============================================================
   1️⃣ SALES ORDER (ROOT)
   Business Case:
   - Order moves from Draft → Confirmed
   - Customer reassigned
============================================================ */

UPDATE sales_order
SET
    status = 'Confirmed',
    customer_id = 1003,
    updated_by = 99,
    update_by_role_id = 5
WHERE id = 2001;


/* ============================================================
   2️⃣ SALES ORDER ADDRESS (CHILD)
   Business Case:
   - Shipping city correction
============================================================ */

UPDATE sales_order_address
SET
    city = 'Navi Mumbai',
    updated_by = 99,
    update_by_role_id = 5
WHERE id = 3001;


/* ============================================================
   3️⃣ SALES ORDER LINE DETAIL (CHILD)
   Business Case:
   - Quantity increased due to demand change
   - Price updated after negotiation
============================================================ */

UPDATE sales_order_line_detail
SET
    quantity = 1200,
    price = 255.00,
    updated_by = 99,
    update_by_role_id = 5
WHERE id = 4001;


/* ============================================================
   4️⃣ SALES ORDER RELEASE LINE (NESTED CHILD)
   Business Case:
   - Partial release quantity adjusted
============================================================ */

UPDATE sales_order_release_line
SET
    released_qty = 600,
    updated_by = 99,
    update_by_role_id = 5
WHERE id = 5001;


/* ============================================================
   5️⃣ CUSTOMER (MASTER)
   Business Case:
   - Customer contact details updated
============================================================ */

UPDATE customer
SET
    email = 'procurement@tataelec.com',
    phone = '+91-22-49999999',
    updated_by = 99,
    update_by_role_id = 5
WHERE id = 1001;


/* ============================================================
   6️⃣ RoHS SUBSTANCE (FK + SELF-FK)
   Business Case:
   - Substance reclassified under new category
   - Parent substance assigned
============================================================ */

UPDATE rohs_substance
SET
    ref_main_category_id = 6003,
    ref_parent_id = 7003,
    updated_by = 99,
    update_by_role_id = 5
WHERE id = 7001;


/* ============================================================
   7️⃣ RoHS SUBSTANCE (ATTRIBUTE CHANGE)
   Business Case:
   - Substance name clarified for compliance
============================================================ */

UPDATE rohs_substance
SET
    name = 'Lead (Pb) – Restricted',
    updated_by = 99,
    update_by_role_id = 5
WHERE id = 7001;


UPDATE customer
SET
    customer_name = 'Acme Corp Updated',
    email = 'contact@acme-updated.com',
    phone = '9998887777',
    is_active = 1,
    updated_by = 101,
    update_by_role_id = 1
WHERE id = 1001;


UPDATE sales_order
SET
    status = 'Completed',
    customer_id = 2,
    updated_by = 102,
    update_by_role_id = 2
WHERE id = 2001;
