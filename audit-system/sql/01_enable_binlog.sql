-- Enable MySQL binlog for Debezium (run as root)

-- Check current binlog status
SHOW VARIABLES LIKE 'log_bin';
SHOW VARIABLES LIKE 'binlog_format';
SHOW VARIABLES LIKE 'binlog_row_image';

-- If binlog is not enabled, add to my.ini (Windows MySQL config):
-- [mysqld]
-- server-id = 1
-- log_bin = mysql-bin
-- binlog_format = ROW
-- binlog_row_image = FULL
-- gtid_mode = ON
-- enforce_gtid_consistency = ON
-- expire_logs_days = 7

-- Create Debezium user with proper permissions
DROP USER IF EXISTS 'debezium_user'@'%';
CREATE USER 'debezium_user'@'%' IDENTIFIED BY 'debezium_pass';

-- Grant necessary permissions
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium_user'@'%';
GRANT SELECT ON mysql.* TO 'debezium_user'@'%';
GRANT SELECT ON performance_schema.* TO 'debezium_user'@'%';
GRANT SELECT ON manufacturing_db.* TO 'debezium_user'@'%';

FLUSH PRIVILEGES;

-- Verify permissions
SELECT User, Host FROM mysql.user WHERE User = 'debezium_user';
SHOW GRANTS FOR 'debezium_user'@'%';

-- Test binlog position
SHOW MASTER STATUS;

-- Verify tables exist
USE manufacturing_db;
SHOW TABLES LIKE 'sales_order%';
SHOW TABLES LIKE 'rohs_peers';
DESCRIBE dataentrychange_auditlog;