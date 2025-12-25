DROP TRIGGER IF EXISTS trg_audit_customer;
DELIMITER $$

CREATE TRIGGER trg_audit_customer
AFTER UPDATE ON customer
FOR EACH ROW
BEGIN

    /* ================================
       Track CUSTOMER NAME change
    ================================ */
    IF OLD.customer_name <> NEW.customer_name THEN
        INSERT INTO dataentrychange_auditlog
        (
            root_table_name, root_ref_id,
            table_name, ref_trans_id,
            entity_level, entity_display_ref,
            col_name, old_val, new_val,
            updated_by, update_by_role_id
        )
        VALUES
        (
            'customer', NEW.id,
            'customer', NEW.id,
            0, NEW.customer_name,
            'customer_name', OLD.customer_name, NEW.customer_name,
            NEW.updated_by, NEW.update_by_role_id
        );
    END IF;

    /* ================================
       Track EMAIL change
    ================================ */
    IF OLD.email <> NEW.email THEN
        INSERT INTO dataentrychange_auditlog
        (
            root_table_name, root_ref_id,
            table_name, ref_trans_id,
            entity_level, entity_display_ref,
            col_name, old_val, new_val,
            updated_by, update_by_role_id
        )
        VALUES
        (
            'customer', NEW.id,
            'customer', NEW.id,
            0, NEW.customer_name,
            'email', OLD.email, NEW.email,
            NEW.updated_by, NEW.update_by_role_id
        );
    END IF;

    /* ================================
       Track PHONE change
    ================================ */
    IF OLD.phone <> NEW.phone THEN
        INSERT INTO dataentrychange_auditlog
        (
            root_table_name, root_ref_id,
            table_name, ref_trans_id,
            entity_level, entity_display_ref,
            col_name, old_val, new_val,
            updated_by, update_by_role_id
        )
        VALUES
        (
            'customer', NEW.id,
            'customer', NEW.id,
            0, NEW.customer_name,
            'phone', OLD.phone, NEW.phone,
            NEW.updated_by, NEW.update_by_role_id
        );
    END IF;

    /* ================================
       Track ACTIVE FLAG change
    ================================ */
    IF OLD.is_active <> NEW.is_active THEN
        INSERT INTO dataentrychange_auditlog
        (
            root_table_name, root_ref_id,
            table_name, ref_trans_id,
            entity_level, entity_display_ref,
            col_name, old_val, new_val,
            updated_by, update_by_role_id
        )
        VALUES
        (
            'customer', NEW.id,
            'customer', NEW.id,
            0, NEW.customer_name,
            'is_active', OLD.is_active, NEW.is_active,
            NEW.updated_by, NEW.update_by_role_id
        );
    END IF;

END$$
DELIMITER ;
