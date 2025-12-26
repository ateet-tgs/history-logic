-- sales_order
INSERT INTO audit_column_metadata
(table_name, col_name, is_foreign_key, ref_table, ref_pk, ref_display_column, is_context_field)
VALUES
('sales_order', 'customer_id', 1, 'customer', 'id', 'customer_name', 0),
('sales_order', 'order_no', 0, NULL, NULL, NULL, 0),
('sales_order', 'order_date', 0, NULL, NULL, NULL, 0),
('sales_order', 'status', 0, NULL, NULL, NULL, 0);

-- sales_order_address
INSERT INTO audit_column_metadata
(table_name, col_name, is_foreign_key, ref_table, ref_pk, ref_display_column, is_context_field)
VALUES
('sales_order_address', 'address_type', 0, NULL, NULL, NULL, 0),
('sales_order_address', 'city', 0, NULL, NULL, NULL, 0),
('sales_order_address', 'country', 0, NULL, NULL, NULL, 0);

-- parts
INSERT INTO audit_column_metadata
(table_name, col_name, is_foreign_key, ref_table, ref_pk, ref_display_column, is_context_field)
VALUES
('parts', 'part_no', 0, NULL, NULL, NULL, 0),
('parts', 'name', 0, NULL, NULL, NULL, 0),
('parts', 'description', 0, NULL, NULL, NULL, 0);

-- sales_order_line_detail
INSERT INTO audit_column_metadata
(table_name, col_name, is_foreign_key, ref_table, ref_pk, ref_display_column, is_context_field)
VALUES
('sales_order_line_detail', 'part_id', 1, 'parts', 'id', 'name', 0),
('sales_order_line_detail', 'quantity', 0, NULL, NULL, NULL, 0),
('sales_order_line_detail', 'price', 0, NULL, NULL, NULL, 0);

-- sales_order_release_line
INSERT INTO audit_column_metadata
(table_name, col_name, is_foreign_key, ref_table, ref_pk, ref_display_column, is_context_field)
VALUES
('sales_order_release_line', 'release_no', 0, NULL, NULL, NULL, 0),
('sales_order_release_line', 'released_qty', 0, NULL, NULL, NULL, 0),
('sales_order_release_line', 'release_date', 0, NULL, NULL, NULL, 0);

INSERT INTO audit_column_metadata
(table_name, col_name, is_foreign_key, ref_table, ref_pk, ref_display_column, is_context_field)
VALUES
('customer', 'customer_code', 0, NULL, NULL, NULL, 0),
('customer', 'customer_name', 0, NULL, NULL, NULL, 0),
('customer', 'email', 0, NULL, NULL, NULL, 0),
('customer', 'phone', 0, NULL, NULL, NULL, 0),
('customer', 'is_active', 0, NULL, NULL, NULL, 0);

-- rohs_main_category
INSERT INTO audit_column_metadata
(table_name, col_name, is_foreign_key, ref_table, ref_pk, ref_display_column, is_context_field)
VALUES
('rohs_main_category', 'name', 0, NULL, NULL, NULL, 0),
('rohs_main_category', 'description', 0, NULL, NULL, NULL, 0),
('rohs_main_category', 'is_active', 0, NULL, NULL, NULL, 0);

-- rohs_substance
INSERT INTO audit_column_metadata
(table_name, col_name, is_foreign_key, ref_table, ref_pk, ref_display_column, is_context_field)
VALUES
('rohs_substance', 'name', 0, NULL, NULL, NULL, 0),
('rohs_substance', 'description', 0, NULL, NULL, NULL, 0),
('rohs_substance', 'ref_main_category_id', 1, 'rohs_main_category', 'id', 'name', 0),
('rohs_substance', 'ref_parent_id', 1, 'rohs_substance', 'id', 'name', 0),
('rohs_substance', 'display_order', 0, NULL, NULL, NULL, 0),
('rohs_substance', 'system_generated', 0, NULL, NULL, NULL, 0),
('rohs_substance', 'rohs_icon', 0, NULL, NULL, NULL, 0);



-- Snapshot configs
INSERT INTO audit_column_metadata
(
    table_name,
    col_name,
    is_foreign_key,
    ref_table,
    ref_pk,
    ref_display_column,
    is_context_field
)
VALUES
-- Context: Part
(
    'sales_order_line_detail',
    'part_id',
    1,
    'parts',
    'id',
    'part_no',
    1
),
-- Context: Sales Order Version
(
    'sales_order_line_detail',
    'sales_order_version',
    0,
    'sales_order',
    'id',
    'version',
    1
);



-- part_id context (derived via line detail)
INSERT INTO audit_column_metadata
(
    table_name,
    col_name,
    is_foreign_key,
    ref_table,
    ref_pk,
    ref_display_column,
    is_context_field
)
VALUES
(
    'sales_order_release_line',
    'part_id',
    1,
    'parts',
    'id',
    'part_no',
    1
);

-- sales order version context
INSERT INTO audit_column_metadata
(
    table_name,
    col_name,
    is_foreign_key,
    ref_table,
    ref_pk,
    ref_display_column,
    is_context_field
)
VALUES
(
    'sales_order_release_line',
    'sales_order_version',
    0,
    'sales_order',
    'id',
    'version',
    1
);
