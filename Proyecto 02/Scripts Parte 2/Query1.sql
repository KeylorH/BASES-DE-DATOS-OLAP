USE CatwalkGlowing_OLTP;
GO

EXEC sys.sp_cdc_enable_db;
GO

SELECT 
    name AS base_datos,
    is_cdc_enabled
FROM sys.databases
WHERE name = 'CatwalkGlowing_OLTP';
GO

