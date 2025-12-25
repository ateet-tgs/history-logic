-- Change name and email
UPDATE customer
SET customer_name = 'Tata Electronics Pvt Ltd',
    email = 'support@tataelec.com',
    updated_by = 101,
    update_by_role_id = 2
WHERE id = 1001;

-- Change phone and is_active
UPDATE customer
SET phone = '9988776655',
    is_active = 0,
    updated_by = 102,
    update_by_role_id = 2
WHERE id = 1002;

UPDATE rohs_main_category
SET name = 'Heavy Metals Updated',
    is_active = 0,
    updated_by = 101,
    update_by_role_id = 1
WHERE id = 10;

UPDATE rohs_main_category
SET description = 'Restricted flame retardants updated',
    updated_by = 101,
    update_by_role_id = 1
WHERE id = 11;

UPDATE rohs_substance
SET name = 'Lead (Pb) Updated',
    ref_main_category_id = 11,
    updated_by = 101,
    update_by_role_id = 1
WHERE id = 101;

UPDATE rohs_substance
SET ref_parent_id = 101,
    display_order = 3.00000,
    updated_by = 101,
    update_by_role_id = 1
WHERE id = 102;

-- Change status and customer
UPDATE sales_order
SET status = 'Shipped',
    customer_id = 1002,
    updated_by = 201,
    update_by_role_id = 2
WHERE id = 2001;

UPDATE sales_order
SET order_date = '2025-02-01',
    status = 'Cancelled',
    updated_by = 202,
    update_by_role_id = 2
WHERE id = 2002;

UPDATE sales_order_address
SET city = 'Pune',
    country = 'India',
    updated_by = 301,
    update_by_role_id = 2
WHERE id = 3001;

UPDATE sales_order_address
SET city = 'Surat',
    updated_by = 302,
    update_by_role_id = 2
WHERE id = 3002;

UPDATE sales_order_line_detail
SET quantity = 1200,
    price = 260.00,
    updated_by = 401,
    update_by_role_id = 3
WHERE id = 4001;

UPDATE sales_order_line_detail
SET quantity = 1600,
    updated_by = 402,
    update_by_role_id = 3
WHERE id = 4002;

UPDATE sales_order_release_line
SET released_qty = 700,
    release_date = '2025-01-12',
    updated_by = 501,
    update_by_role_id = 4
WHERE id = 5001;

UPDATE sales_order_release_line
SET released_qty = 900,
    release_date = '2025-01-15',
    updated_by = 502,
    update_by_role_id = 4
WHERE id = 5002;

UPDATE sales_order
SET version = version + 1,
    updated_by = 201,
    update_by_role_id = 2
WHERE id = 2001;


UPDATE sales_order_line_detail
SET price = 265.00,
    updated_by = 401,
    update_by_role_id = 3
WHERE id = 4001;

UPDATE sales_order_line_detail
SET quantity = 1700,
    updated_by = 402,
    update_by_role_id = 3
WHERE id = 4002;


UPDATE sales_order_release_line
SET released_qty = 750,
    release_date = '2025-01-18',
    updated_by = 501,
    update_by_role_id = 4
WHERE id = 5001;

UPDATE sales_order_release_line
SET released_qty = 950,
    release_date = '2025-01-20',
    updated_by = 502,
    update_by_role_id = 4
WHERE id = 5002;

UPDATE sales_order
SET version = version + 1,
    updated_by = 201,
    update_by_role_id = 2
WHERE id = 2001;

UPDATE sales_order_line_detail
SET part_id = 501,          -- NEW PART
    quantity = 1000,
    price = 120.00,
    updated_by = 401,
    update_by_role_id = 3
WHERE id = 4001;

UPDATE sales_order_release_line
SET released_qty = 500,
    release_date = '2025-01-22',
    updated_by = 501,
    update_by_role_id = 4
WHERE id = 5001;

UPDATE sales_order_release_line
SET released_qty = 650,
    updated_by = 501,
    update_by_role_id = 4
WHERE id = 5001;
