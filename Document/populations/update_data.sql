
-- ========================================================================
-- 9. DATA UPDATE OPERATIONS
-- ========================================================================
-- Update sample sales order status
UPDATE sales_order
SET status = 'CONFIRMED', updated_by = 101, update_by_role_id = 1
WHERE id = 1;

UPDATE sales_order
SET status = 'CONFIRMED', updated_by = 102, update_by_role_id = 2
WHERE id = 2;

-- Update sample address
UPDATE sales_order_address
SET city = 'Mumbai', updated_by = 102, update_by_role_id = 2
WHERE id = 1;

-- Update sample sales order line detail
UPDATE sales_order_line_detail
SET quantity = 8, price = 520.00, updated_by = 102, update_by_role_id = 2
WHERE id = 1;

-- Update sample release line
UPDATE sales_order_release_line
SET released_qty = 4, release_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY), 
    updated_by = 102, update_by_role_id = 2
WHERE id = 1;

-- Update RoHS substance parent reference
UPDATE rohs_substance
SET ref_parent_id = 3, updated_by = 1, update_by_role_id = 2
WHERE id = 2;

-- Update RoHS substance category reference
UPDATE rohs_substance
SET ref_main_category_id = 2, updated_by = 1, update_by_role_id = 2
WHERE id = 1;