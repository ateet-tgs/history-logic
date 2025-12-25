CREATE TABLE sales_order_address (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sales_order_id BIGINT NOT NULL,
    address_type VARCHAR(20), -- 'Billing' or 'Shipping'
    city VARCHAR(100),
    country VARCHAR(100),
    updated_by BIGINT,
    update_by_role_id INT,

    CONSTRAINT fk_address_sales_order
        FOREIGN KEY (sales_order_id)
        REFERENCES sales_order(id)
);