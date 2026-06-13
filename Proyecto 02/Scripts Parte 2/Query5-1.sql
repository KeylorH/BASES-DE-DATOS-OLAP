USE CatwalkGlowing_OLTP;
GO

INSERT INTO Producto (
    id_producto,
    nombre,
    stock_disponible,
    precio_detalle,
    precio_mayorista,
    id_categoria,
    id_marca
)
VALUES (
    21,
    'Tinta Labial Velvet',
    90,
    4900.00,
    4200.00,
    9,
    3
);
GO