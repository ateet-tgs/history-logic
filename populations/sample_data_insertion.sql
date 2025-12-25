INSERT INTO customer
(id, customer_code, customer_name, email, phone, is_active, created_by, create_by_role_id)
VALUES
(1001, 'CUST-IND-001', 'Tata Electronics', 'contact@tataelec.com', '+91-22-40000001', 1, 1, 1),
(1002, 'CUST-IND-002', 'Reliance Industries', 'sales@reliance.com', '+91-22-40000002', 1, 1, 1),
(1003, 'CUST-IND-003', 'L&T Technology', 'info@lnttech.com', '+91-80-40000003', 1, 1, 1),
(1004, 'CUST-IND-004', 'Foxconn India', 'contact@foxconn.com', '+91-44-40000004', 1, 1, 1),
(1005, 'CUST-IND-005', 'Bosch India', 'support@bosch.com', '+91-80-40000005', 1, 1, 1);


INSERT INTO sales_order
(id, order_no, customer_id, order_date, status, updated_by, update_by_role_id)
VALUES
(2001, 'SO-2025-0001', 1001, '2025-01-05', 'Draft', 10, 2),
(2002, 'SO-2025-0002', 1002, '2025-01-06', 'Confirmed', 11, 2),
(2003, 'SO-2025-0003', 1003, '2025-01-07', 'Confirmed', 12, 2),
(2004, 'SO-2025-0004', 1004, '2025-01-08', 'InProgress', 13, 2),
(2005, 'SO-2025-0005', 1005, '2025-01-09', 'Completed', 14, 2);


INSERT INTO sales_order_address
(id, sales_order_id, address_type, city, country, updated_by, update_by_role_id)
VALUES
(3001, 2001, 'Billing',  'Mumbai',      'India', 10, 2),
(3002, 2002, 'Shipping', 'Ahmedabad',   'India', 11, 2),
(3003, 2003, 'Billing',  'Bengaluru',   'India', 12, 2),
(3004, 2004, 'Shipping', 'Chennai',     'India', 13, 2),
(3005, 2005, 'Billing',  'Pune',        'India', 14, 2);


INSERT INTO sales_order_line_detail
(id, sales_order_id, product_code, quantity, price, updated_by, update_by_role_id)
VALUES
(4001, 2001, 'IC-STM32F4',  1000, 250.00, 10, 2),
(4002, 2002, 'RES-10K-1%',  5000,   1.50, 11, 2),
(4003, 2003, 'CAP-100uF',   2000,   5.75, 12, 2),
(4004, 2004, 'DIODE-1N4007',3000,   2.10, 13, 2),
(4005, 2005, 'MOSFET-IRFZ44',1500, 45.00, 14, 2);


INSERT INTO sales_order_release_line
(id, line_detail_id, release_no, released_qty, release_date, updated_by, update_by_role_id)
VALUES
(5001, 4001, 'REL-001', 500, '2025-01-10', 20, 3),
(5002, 4002, 'REL-001', 2000,'2025-01-11', 20, 3),
(5003, 4003, 'REL-002', 1000,'2025-01-12', 21, 3),
(5004, 4004, 'REL-001', 1500,'2025-01-13', 22, 3),
(5005, 4005, 'REL-003', 800, '2025-01-14', 23, 3);


INSERT INTO rohs_main_category
(id, name, description, is_active, created_by)
VALUES
(6001, 'Heavy Metals', 'Restricted heavy metals', 1, 'system'),
(6002, 'Flame Retardants', 'Restricted flame retardants', 1, 'system'),
(6003, 'Plasticizers', 'Restricted plastic additives', 1, 'system'),
(6004, 'Solvents', 'Restricted industrial solvents', 1, 'system'),
(6005, 'Other Substances', 'Other restricted substances', 1, 'system');


INSERT INTO rohs_substance
(id, name, description, is_active, ref_main_category_id, ref_parent_id, system_generated, created_by)
VALUES
(7001, 'Lead (Pb)', 'Lead restriction', 1, 6001, NULL, 1, 'system'),
(7002, 'Mercury (Hg)', 'Mercury restriction', 1, 6001, NULL, 1, 'system'),
(7003, 'Cadmium (Cd)', 'Cadmium restriction', 1, 6001, NULL, 1, 'system'),
(7004, 'PBB', 'Polybrominated biphenyls', 1, 6002, NULL, 1, 'system'),
(7005, 'PBDE', 'Polybrominated diphenyl ethers', 1, 6002, 7004, 0, 'admin');
