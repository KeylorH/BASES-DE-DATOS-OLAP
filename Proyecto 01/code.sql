
CREATE DATABASE Catwalk_Glowing;
GO
 
USE Catwalk_Glowing;
GO

CREATE TABLE Provincia (
    id_provincia INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Canton (
    id_canton INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_provincia INT NOT NULL,
    FOREIGN KEY (id_provincia) REFERENCES Provincia(id_provincia)
);

CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    primer_apellido VARCHAR(100) NOT NULL,
    segundo_apellido VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion_exacta VARCHAR(255),
    codigo_mayorista VARCHAR(50),
    id_canton INT NOT NULL,
    FOREIGN KEY (id_canton) REFERENCES Canton(id_canton)
);

CREATE TABLE Categoria (
    id_categoria INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Marca (
    id_marca INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Producto (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cantidad INT NOT NULL,
    precio_detalle DECIMAL(10,2) NOT NULL,
    precio_mayorista DECIMAL(10,2),
    id_categoria INT NOT NULL,
    id_marca INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
    FOREIGN KEY (id_marca) REFERENCES Marca(id_marca)
);

CREATE TABLE Promocion (
    id_promocion INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('precio_mayorista', 'combo', 'otro')),
    descripcion VARCHAR(255),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activa BIT NOT NULL DEFAULT 1
);

CREATE TABLE PromocionProducto (
    id_promocion INT NOT NULL,
    id_producto INT NOT NULL,
    PRIMARY KEY (id_promocion, id_producto),
    FOREIGN KEY (id_promocion) REFERENCES Promocion(id_promocion),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

CREATE TABLE Venta (
    id_venta INT PRIMARY KEY,
    fecha DATE NOT NULL,
    mensaje VARCHAR(255),
    precio_final DECIMAL(10,2) NOT NULL,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE DetalleVenta (
    id_detalle INT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_venta_unidad DECIMAL(10,2) NOT NULL,
    tipo_precio VARCHAR(20) NOT NULL DEFAULT 'detalle'
        CHECK (tipo_precio IN ('detalle', 'mayorista_volumen', 'mayorista_membresia', 'promocion')),
    id_promocion INT NULL,
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    FOREIGN KEY (id_promocion) REFERENCES Promocion(id_promocion)
);


CREATE DATABASE Catwalk_Glowing_DW;
GO
 
USE Catwalk_Glowing_DW;
GO

-- Dimensiones y Fact Table

CREATE TABLE DimTiempo (
    id_tiempo INT PRIMARY KEY,
    fecha DATE NOT NULL,
    dia INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    trimestre INT NOT NULL,
    anio INT NOT NULL,
    nombre_dia VARCHAR(20) NOT NULL
);


CREATE TABLE DimCliente (
    id_cliente INT PRIMARY KEY,
    nombre_completo VARCHAR(300) NOT NULL,
    es_mayorista BIT NOT NULL,
    tipo_cliente VARCHAR(20) NOT NULL CHECK (tipo_cliente IN ('mayorista', 'minorista')),
    canton VARCHAR(100) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion_exacta VARCHAR(255)
);


CREATE TABLE DimProducto (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    precio_detalle DECIMAL(10,2) NOT NULL,
    precio_mayorista DECIMAL(10,2),
    stock_disponible INT NOT NULL
);


CREATE TABLE DimPromocion (
    id_promocion INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('precio_mayorista', 'combo', 'otro', 'ninguna')),
    descripcion VARCHAR(255),
    activa BIT NOT NULL DEFAULT 1,
    fecha_inicio DATE,
    fecha_fin DATE
);

INSERT INTO DimPromocion VALUES (0, 'Sin promoción', 'ninguna', NULL, 0, NULL, NULL);

CREATE TABLE FactVenta (
    id_fact	INT PRIMARY KEY,
    id_tiempo INT NOT NULL,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    id_promocion INT NOT NULL DEFAULT 0,
    cantidad_vendida INT NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    tipo_precio_aplicado VARCHAR(20) NOT NULL
        CHECK (tipo_precio_aplicado IN ('detalle', 'mayorista_volumen', 'mayorista_membresia', 'promocion')),
    FOREIGN KEY (id_tiempo) REFERENCES DimTiempo(id_tiempo),
    FOREIGN KEY (id_cliente) REFERENCES DimCliente(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES DimProducto(id_producto),
    FOREIGN KEY (id_promocion) REFERENCES DimPromocion(id_promocion)
);

