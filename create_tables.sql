CREATE TABLE customer (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    customer_code VARCHAR(50) UNIQUE,
    customer_name VARCHAR(150) NOT NULL,

    email VARCHAR(150),
    phone VARCHAR(30),

    is_active TINYINT DEFAULT 1,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    create_by_role_id INT,

    updated_at DATETIME,
    updated_by BIGINT,
    update_by_role_id INT,

    deleted_at DATETIME,
    deleted_by BIGINT,
    delete_by_role_id INT
);

CREATE TABLE rohs_main_category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    description VARCHAR(250),
    is_active TINYINT,
    created_by VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(255),
    updated_at DATETIME,
    deleted_by VARCHAR(255),
    deleted_at DATETIME,
    is_deleted TINYINT(1) DEFAULT 0,
    create_by_role_id INT,
    update_by_role_id INT,
    delete_by_role_id INT
);

CREATE TABLE rohs_substance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    description VARCHAR(250),
    is_active TINYINT,
    created_by VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(255),
    updated_at DATETIME,
    deleted_by VARCHAR(255),
    deleted_at DATETIME,
    is_deleted TINYINT(1) DEFAULT 0,
    system_generated TINYINT,
    rohs_icon VARCHAR(255),
    ref_main_category_id INT,
    create_by_role_id INT,
    update_by_role_id INT,
    delete_by_role_id INT,
    display_order DECIMAL(10,5),
    ref_parent_id INT,
    source_name VARCHAR(50),
    unq_date DATETIME,

    CONSTRAINT fk_rohs_substance_category FOREIGN KEY (ref_main_category_id)
        REFERENCES rohs_main_category(id)
);

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

CREATE TABLE sales_order_line_detail (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sales_order_id BIGINT NOT NULL,
    product_code VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2),
    updated_by BIGINT,
    update_by_role_id INT,

    CONSTRAINT fk_line_sales_order
        FOREIGN KEY (sales_order_id)
        REFERENCES sales_order(id)
);

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

CREATE TABLE audit_column_metadata (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    col_name VARCHAR(100) NOT NULL,

    -- Foreign key configuration
    is_foreign_key TINYINT(1) DEFAULT 0,
    ref_table VARCHAR(100),
    ref_pk VARCHAR(100),
    ref_display_column VARCHAR(100),

    UNIQUE KEY uq_table_col (table_name, col_name)
);

CREATE TABLE dataentrychange_auditlog (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    -- Root context (top-level entity reference)
    root_table_name VARCHAR(100) NOT NULL,
    root_ref_id BIGINT NOT NULL,

    -- Current entity context (child/nested entity reference)
    table_name VARCHAR(100) NOT NULL,
    ref_trans_id BIGINT NOT NULL,
    entity_level TINYINT NOT NULL,
    entity_display_ref VARCHAR(255),

    -- Field change context
    col_name VARCHAR(100),
    old_val LONGTEXT,
    new_val LONGTEXT,

    -- Audit metadata
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    update_by_role_id INT,

    -- Performance indexes
    INDEX idx_root (root_table_name, root_ref_id),
    INDEX idx_entity (table_name, ref_trans_id),
    INDEX idx_col (table_name, col_name)
);