SELECT 
    'CREATE INDEX ' || 
    CASE 
        WHEN index_name LIKE 'BIN$%' THEN 
            -- Ignore Oracle recycle-bin objects
            NULL
        ELSE 
            -- Generate standard index DDL
            index_name || ' ON ' || table_name || '(' || 
            LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY column_position) || ');'
    END AS index_ddl
FROM 
    all_ind_columns
WHERE 
    index_owner = 'UOFFICE'  -- Replace with your schema name
    AND index_name NOT LIKE 'BIN$%'  -- Exclude recycle-bin objects
GROUP BY 
    index_name, table_name
HAVING 
    index_name IS NOT NULL  -- Skip NULL entries (recycle-bin filtered above)
ORDER BY 
    table_name, index_name;
