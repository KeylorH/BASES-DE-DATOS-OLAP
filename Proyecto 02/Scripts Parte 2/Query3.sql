USE CatwalkGlowing_OLTP;
GO

SELECT 
    name AS tabla,
    is_tracked_by_cdc
FROM sys.tables
WHERE name IN ('Venta', 'Producto');
GO