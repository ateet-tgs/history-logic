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