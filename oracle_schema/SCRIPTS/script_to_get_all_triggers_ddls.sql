BEGIN
    DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);
END;
/

SELECT 
    CASE 
        WHEN row_num = 1 THEN '-- ' || table_name || CHR(10)
        ELSE NULL 
    END
    || TO_CHAR(DBMS_METADATA.GET_DDL('TRIGGER', trigger_name, owner))
    || CHR(10) AS trigger_ddl
FROM (
    SELECT 
        owner,
        trigger_name,
        table_name,
        ROW_NUMBER() OVER (PARTITION BY table_name ORDER BY trigger_name) AS row_num
    FROM 
        all_triggers
    WHERE 
        owner = 'UOFFICE'
        AND trigger_name NOT LIKE 'BIN$%'  -- Exclude recycle bin objects
)
ORDER BY 
    table_name, 
    trigger_name;
