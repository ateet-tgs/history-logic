CREATE TABLE sales_order_release_line (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    line_detail_id BIGINT NOT NULL,
    release_no VARCHAR(50),
    released_qty INT,
    release_date DATE,
    updated_by BIGINT,
    update_by_role_id INT,

    CONSTRAINT fk_release_line
        FOREIGN KEY (line_detail_id)
        REFERENCES sales_order_line_detail(id)
);