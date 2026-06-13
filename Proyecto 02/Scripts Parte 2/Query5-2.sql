USE CatwalkGlowing_OLTP;
GO

INSERT INTO Venta (
    id_venta,
    fecha,
    mensaje,
    precio_final,
    id_cliente
)
VALUES (
    501,
    '2026-04-15',
    'Venta incremental de prueba CDC',
    9800.00,
    1
);
GO