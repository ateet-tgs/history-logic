
-- ========================================================================
-- 7. SAMPLE DATA - SALES ORDER DOMAIN
-- ========================================================================
-- Insert sample sales orders
INSERT INTO sales_order (order_no, customer_name, order_date, status, created_by, created_by_role_id)
VALUES ('SO-1001', 'ABC Corp', CURDATE(), 'NEW', 1, 1);

INSERT INTO sales_order (order_no, customer_name, order_date, status, updated_by, update_by_role_id)
VALUES ('SO-1002', 'XYZ Corp', CURDATE(), 'NEW', 101, 1);

-- Insert sample addresses for sales orders
INSERT INTO sales_order_address (sales_order_id, address_type, city, country, created_by, created_by_role_id)
VALUES (1, 'Shipping', 'Mumbai', 'India', 1, 1);

INSERT INTO sales_order_address (sales_order_id, address_type, city, country, updated_by, update_by_role_id)
VALUES 
(2, 'Billing', 'Delhi', 'India', 101, 1),
(2, 'Shipping', 'Bangalore', 'India', 101, 1);

-- Insert sample sales order line details
INSERT INTO sales_order_line_detail (sales_order_id, product_code, quantity, price, created_by, created_by_role_id)
VALUES (1, 'PRD-001', 10, 250.00, 1, 1);

INSERT INTO sales_order_line_detail (sales_order_id, product_code, quantity, price, updated_by, update_by_role_id)
VALUES 
(2, 'PRD-101', 5, 500.00, 101, 1),
(2, 'PRD-102', 10, 250.00, 101, 1);

-- Insert sample release lines
INSERT INTO sales_order_release_line (line_detail_id, release_no, released_qty, release_date, updated_by, update_by_role_id)
VALUES 
(1, 'REL-001', 3, CURDATE(), 101, 1),
(2, 'REL-002', 10, CURDATE(), 101, 1);

-- ========================================================================
-- 8. SAMPLE DATA - ROHS MASTER DATA
-- ========================================================================
-- Insert sample RoHS main categories
INSERT INTO rohs_main_category (name, description, is_active, created_by, created_by_role_id)
VALUES 
('Category A', 'Main Category A', 1, 1, 1),
('Category B', 'Main Category B', 1, 1, 1);

-- Insert sample RoHS substances (parent and child records)
INSERT INTO rohs_substance
(name, description, is_active, created_by, created_by_role_id, ref_main_category_id, ref_parent_id)
VALUES
('ROHS 1', 'Description 1', 1, 1, 1, 1, NULL),
('ROHS 2', 'Description 2', 1, 1, 1, 1, 1),
('ROHS 3', 'Description 3', 1, 1, 1, 2, NULL);
