USE CatwalkGlowing_OLTP;
GO

SELECT 
    name AS tabla_cdc
FROM sys.tables
WHERE schema_id = SCHEMA_ID('cdc');
GO