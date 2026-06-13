USE CatwalkGlowing_OLTP;
GO

SELECT *
FROM cdc.dbo_Venta_CT
WHERE __$operation = 2;
GO