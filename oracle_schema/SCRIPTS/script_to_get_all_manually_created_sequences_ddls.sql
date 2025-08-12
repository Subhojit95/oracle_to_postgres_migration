BEGIN
    DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);
END;
/

SELECT 
    CASE 
        WHEN row_num = 1 THEN '-- ' || table_name || CHR(10)
        ELSE NULL
    END
    || TO_CHAR(DBMS_METADATA.GET_DDL('SEQUENCE', sequence_name, sequence_owner))
    || CHR(10) AS sequence_ddl
FROM (
    SELECT 
        s.sequence_owner,
        s.sequence_name,
        -- Derive table name from sequence name if following naming convention
        REGEXP_REPLACE(sequence_name, '^SEQ_', '') AS table_name,
        ROW_NUMBER() OVER (
            PARTITION BY REGEXP_REPLACE(sequence_name, '^SEQ_', '') 
            ORDER BY sequence_name
        ) AS row_num
    FROM 
        all_sequences s
    WHERE 
        s.sequence_owner = 'UOFFICE'
        AND s.sequence_name NOT LIKE 'ISEQ$$_%' -- exclude identity sequences
)
ORDER BY 
    table_name,
    sequence_name;
