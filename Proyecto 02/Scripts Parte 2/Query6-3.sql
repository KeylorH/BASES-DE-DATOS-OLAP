USE CatwalkGlowing_OLTP;
GO

SELECT 
    s.name AS esquema,
    t.name AS tabla
FROM sys.tables t
INNER JOIN sys.schemas s 
    ON t.schema_id = s.schema_id
WHERE s.name = 'cdc';
GO