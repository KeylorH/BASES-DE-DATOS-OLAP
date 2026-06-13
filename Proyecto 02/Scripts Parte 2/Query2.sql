USE CatwalkGlowing_OLTP;
GO

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Venta',
    @role_name = NULL;
GO

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Producto',
    @role_name = NULL;
GO