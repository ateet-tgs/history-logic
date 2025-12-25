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
