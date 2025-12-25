INSERT INTO audit_column_metadata
(table_name, col_name, is_foreign_key, ref_table, ref_pk, ref_display_column)
VALUES
/* ================================
   SALES ORDER (ROOT ENTITY)
================================ */
('sales_order', 'status', 0, NULL, NULL, NULL),

-- FK → customer master
('sales_order', 'customer_id', 1, 'customer', 'id', 'customer_name'),

/* ================================
   SALES ORDER ADDRESS
================================ */
('sales_order_address', 'address_type', 0, NULL, NULL, NULL),
('sales_order_address', 'city', 0, NULL, NULL, NULL),
('sales_order_address', 'country', 0, NULL, NULL, NULL),

/* ================================
   SALES ORDER LINE DETAIL
================================ */
('sales_order_line_detail', 'product_code', 0, NULL, NULL, NULL),
('sales_order_line_detail', 'quantity', 0, NULL, NULL, NULL),
('sales_order_line_detail', 'price', 0, NULL, NULL, NULL),

/* ================================
   SALES ORDER RELEASE LINE
================================ */
('sales_order_release_line', 'released_qty', 0, NULL, NULL, NULL),
('sales_order_release_line', 'release_no', 0, NULL, NULL, NULL),
('sales_order_release_line', 'release_date', 0, NULL, NULL, NULL),

/* ================================
   CUSTOMER MASTER
================================ */
('customer', 'customer_name', 0, NULL, NULL, NULL),
('customer', 'email', 0, NULL, NULL, NULL),
('customer', 'phone', 0, NULL, NULL, NULL),
('customer', 'is_active', 0, NULL, NULL, NULL),

/* ================================
   RoHS SUBSTANCE
================================ */
('rohs_substance', 'name', 0, NULL, NULL, NULL),
('rohs_substance', 'description', 0, NULL, NULL, NULL),
('rohs_substance', 'is_active', 0, NULL, NULL, NULL),

-- FK → RoHS main category
('rohs_substance', 'ref_main_category_id', 1, 'rohs_main_category', 'id', 'name'),

-- Self-referencing FK → parent substance
('rohs_substance', 'ref_parent_id', 1, 'rohs_substance', 'id', 'name'),

('rohs_substance', 'display_order', 0, NULL, NULL, NULL),
('rohs_substance', 'system_generated', 0, NULL, NULL, NULL),
('rohs_substance', 'rohs_icon', 0, NULL, NULL, NULL),
('rohs_substance', 'source_name', 0, NULL, NULL, NULL);
