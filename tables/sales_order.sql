CREATE TABLE sales_order (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    order_no VARCHAR(50) NOT NULL,
    customer_id BIGINT NOT NULL,

    order_date DATE,
    status VARCHAR(20),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    update_by_role_id INT,

    CONSTRAINT fk_sales_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(id)
);
