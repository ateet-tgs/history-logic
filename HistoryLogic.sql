SELECT 
    a.root_table_name,
    a.root_ref_id,
    a.table_name,
    a.ref_trans_id,
    a.entity_level,
    a.entity_display_ref,
    a.col_name,
    a.old_val,
    a.new_val,
    a.updated_at,
    a.updated_by,
    a.update_by_role_id,
    
    -- Nested / Child info
    CASE 
        WHEN a.table_name = 'sales_order_address' THEN CONCAT('Address: ', c.address_type, ', ', c.city, ', ', c.country)
        WHEN a.table_name = 'sales_order_line_detail' THEN CONCAT('Line: ', l.product_code, ', Qty: ', l.quantity, ', Price: ', l.price)
        WHEN a.table_name = 'sales_order_release_line' THEN CONCAT('Release: ', r.release_no, ', Qty: ', r.released_qty)
        ELSE NULL
    END AS nested_info

FROM dataentrychange_auditlog a
LEFT JOIN sales_order_address c ON a.table_name='sales_order_address' AND a.ref_trans_id = c.id
LEFT JOIN sales_order_line_detail l ON a.table_name='sales_order_line_detail' AND a.ref_trans_id = l.id
LEFT JOIN sales_order_release_line r ON a.table_name='sales_order_release_line' AND a.ref_trans_id = r.id
WHERE a.root_table_name = 'sales_order'
  AND a.root_ref_id = 1
ORDER BY a.updated_at DESC;


SELECT
    a.root_table_name,
    a.root_ref_id,
    a.table_name,
    a.ref_trans_id,
    a.entity_level,
    a.entity_display_ref,
    a.col_name,

    -- Replace old_val/new_val IDs with current values from FK tables
    CASE 
        WHEN a.col_name = 'ref_main_category_id' THEN mc_old.name
        WHEN a.col_name = 'ref_parent_id' THEN rp_old.name
        ELSE a.old_val
    END AS old_val_display,

    CASE 
        WHEN a.col_name = 'ref_main_category_id' THEN mc_new.name
        WHEN a.col_name = 'ref_parent_id' THEN rp_new.name
        ELSE a.new_val
    END AS new_val_display,

    a.updated_at,
    a.updated_by,
    a.update_by_role_id

FROM dataentrychange_auditlog a

-- Join old values to FK tables
LEFT JOIN rohs_main_category mc_old 
    ON a.table_name='rohs_substance' 
   AND a.col_name='ref_main_category_id' 
   AND a.old_val = mc_old.id

LEFT JOIN rohs_substance rp_old 
    ON a.table_name='rohs_substance' 
   AND a.col_name='ref_parent_id' 
   AND a.old_val = rp_old.id

-- Join new values to FK tables
LEFT JOIN rohs_main_category mc_new 
    ON a.table_name='rohs_substance' 
   AND a.col_name='ref_main_category_id' 
   AND a.new_val = mc_new.id

LEFT JOIN rohs_substance rp_new 
    ON a.table_name='rohs_substance' 
   AND a.col_name='ref_parent_id' 
   AND a.new_val = rp_new.id

WHERE a.root_table_name = 'rohs_substance'
ORDER BY a.updated_at DESC;