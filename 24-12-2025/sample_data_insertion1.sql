INSERT INTO customer
(id, customer_code, customer_name, email, phone, is_active, created_by, create_by_role_id)
VALUES
(1001, 'CUST-IND-001', 'Tata Electronics', 'contact@tataelec.com', '9876543210', 1, 1, 1),
(1002, 'CUST-IND-002', 'Reliance Components', 'info@reliancecomp.com', '9123456780', 1, 1, 1);


INSERT INTO rohs_main_category
(id, name, description, is_active, created_by, create_by_role_id)
VALUES
(10, 'Heavy Metals', 'Restricted heavy metals', 1, 'system', 1),
(11, 'Flame Retardants', 'Restricted flame retardants', 1, 'system', 1);


INSERT INTO rohs_substance
(id, name, description, is_active, system_generated,
 ref_main_category_id, display_order, source_name, create_by_role_id)
VALUES
(101, 'Lead (Pb)', 'Lead substance', 1, 1, 10, 1.00000, 'EU-RoHS', 1),
(102, 'Mercury (Hg)', 'Mercury substance', 1, 1, 10, 2.00000, 'EU-RoHS', 1);


INSERT INTO parts
(id, part_no, name, description, is_active, updated_by, update_by_role_id)
VALUES
(501, 'IC-STM32F4', 'STM32F4 Microcontroller', 'ARM Cortex-M4 MCU', 1, 1, 1),
(502, 'MOSFET-IRFZ44', 'IRFZ44 MOSFET', 'N-Channel Power MOSFET', 1, 1, 1),
(503, 'RES-10K-0603', '10K Ohm Resistor', 'SMD Resistor 10KΩ 0603 Package', 1, 1, 1),
(504, 'CAP-100NF-50V', '100nF Ceramic Capacitor', 'Ceramic Capacitor 100nF 50V', 1, 1, 1),
(505, 'IC-ATMEGA328P', 'ATmega328P Microcontroller', '8-bit AVR MCU used in Arduino Uno', 1, 1, 1),
(506, 'DIODE-1N4007', '1N4007 Diode', 'General Purpose Rectifier Diode 1A 1000V', 1, 1, 1),
(507, 'TRANS-BC547', 'BC547 Transistor', 'NPN General Purpose Transistor', 1, 1, 1),
(508, 'REG-LM7805', 'LM7805 Voltage Regulator', '5V Linear Voltage Regulator', 1, 1, 1),
(509, 'IC-ESP32-WROOM', 'ESP32-WROOM Module', 'Wi-Fi and Bluetooth MCU Module', 1, 1, 1),
(510, 'CON-USB-TYPEC', 'USB Type-C Connector', 'USB Type-C Female PCB Connector', 1, 1, 1);


INSERT INTO sales_order
(id, order_no, customer_id, order_date, status, updated_by, update_by_role_id)
VALUES
(2001, 'SO-2025-0001', 1001, '2025-01-05', 'Confirmed', 10, 2),
(2002, 'SO-2025-0002', 1002, '2025-01-06', 'Completed', 11, 2);


INSERT INTO sales_order_address
(id, sales_order_id, address_type, city, country, updated_by, update_by_role_id)
VALUES
(3001, 2001, 'Billing', 'Mumbai', 'India', 10, 2),
(3002, 2002, 'Shipping', 'Ahmedabad', 'India', 11, 2);


INSERT INTO sales_order_line_detail
(id, sales_order_id, part_id, quantity, price, updated_by, update_by_role_id)
VALUES
(4001, 2001, 501, 1000, 255.00, 20, 3),
(4002, 2002, 502, 1500, 45.00, 21, 3);


INSERT INTO sales_order_release_line
(id, line_detail_id, release_no, released_qty, release_date, updated_by, update_by_role_id)
VALUES
(5001, 4001, 'REL-001', 600, '2025-01-10', 30, 4),
(5002, 4002, 'REL-002', 800, '2025-01-12', 31, 4);


INSERT INTO rohs_peers
(id, source_substance_id, target_substance_id, relationship_type, is_active, created_by, create_by_role_id)
VALUES
(6001, 101, 102, 'Related', 1, 2, 1),
(6002, 102, 101, 'Related', 1, 2, 1);