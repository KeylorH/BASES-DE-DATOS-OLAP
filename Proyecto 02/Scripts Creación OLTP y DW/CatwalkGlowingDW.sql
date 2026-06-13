CREATE DATABASE CatwalkGlowing_DW;
GO
 
USE CatwalkGlowing_DW;
GO
 
-- =========================================
-- LIMPIEZA PREVIA SI LAS TABLAS YA EXISTEN
-- =========================================
 
IF OBJECT_ID('dbo.StgVentaDetalle', 'U') IS NOT NULL
    DROP TABLE dbo.StgVentaDetalle;
GO
 
IF OBJECT_ID('dbo.StgTipoDePrecio', 'U') IS NOT NULL
    DROP TABLE dbo.StgTipoDePrecio;
GO
 
IF OBJECT_ID('dbo.StgTiempo', 'U') IS NOT NULL
    DROP TABLE dbo.StgTiempo;
GO
 
IF OBJECT_ID('dbo.StgPromocion', 'U') IS NOT NULL
    DROP TABLE dbo.StgPromocion;
GO
 
IF OBJECT_ID('dbo.StgProducto', 'U') IS NOT NULL
    DROP TABLE dbo.StgProducto;
GO
 
IF OBJECT_ID('dbo.StgCliente', 'U') IS NOT NULL
    DROP TABLE dbo.StgCliente;
GO
 
 
-- =========================================
-- STAGING DE CLIENTES
-- Fuente OLTP:
--   Cliente, Canton, Provincia
-- Destino final:
--   DimCliente
-- =========================================
 
CREATE TABLE dbo.StgCliente (
    id_cliente INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    primer_apellido VARCHAR(100) NOT NULL,
    segundo_apellido VARCHAR(100) NULL,
    nombre_completo VARCHAR(300) NULL,
    canton VARCHAR(100) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT GETDATE()
);
GO
 
 
-- =========================================
-- STAGING DE PRODUCTOS
-- Fuente OLTP:
--   Producto, Categoria, Marca
-- Carga: CDC incremental
-- Destino final:
--   DimProducto
-- =========================================
 
CREATE TABLE dbo.StgProducto (
    id_producto INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT GETDATE()
);
GO
 
 
-- =========================================
-- STAGING DE PROMOCIONES
-- Fuente OLTP:
--   Promocion
-- Destino final:
--   DimPromocion
-- =========================================
 
CREATE TABLE dbo.StgPromocion (
    id_promocion INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fecha_carga DATETIME NOT NULL DEFAULT GETDATE()
);
GO
 
 
-- =========================================
-- STAGING DE TIEMPO
-- Fuente OLTP:
--   Venta.fecha
-- Destino final:
--   DimTiempo
-- =========================================
 
CREATE TABLE dbo.StgTiempo (
    id_tiempo INT NOT NULL,
    fecha DATE NOT NULL,
    dia INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    trimestre INT NOT NULL,
    anio INT NOT NULL,
    nombre_dia VARCHAR(20) NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT GETDATE()
);
GO
 
 
-- =========================================
-- STAGING DE TIPO DE PRECIO
-- Fuente OLTP:
--   Producto.precio_detalle, Producto.precio_mayorista
-- Destino final:
--   DimTipoDePrecio
-- =========================================
 
CREATE TABLE dbo.StgTipoDePrecio (
    id_tipo_de_precio INT NOT NULL,
    precio_detalle DECIMAL(10,2) NOT NULL,
    precio_mayorista DECIMAL(10,2) NULL,
    fecha_carga DATETIME NOT NULL DEFAULT GETDATE()
);
GO
 
 
-- =========================================
-- STAGING DE VENTAS Y DETALLE
-- Fuente OLTP:
--   Venta, DetalleVenta, Producto (para tipo de precio)
-- Carga: CDC incremental
-- Destino final:
--   FactVenta
-- =========================================
 
CREATE TABLE dbo.StgVentaDetalle (
    id_venta INT NOT NULL,
    id_detalle INT NOT NULL,
    fecha DATE NOT NULL,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    id_promocion INT NULL,
    id_tipo_de_precio INT NOT NULL,
    cantidad_vendida INT NOT NULL,
    precio_aplicado DECIMAL(10,2) NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    tipo_precio_aplicado VARCHAR(50) NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT GETDATE()
);
GO
 
 
-- =========================================
-- TABLA DE ESTADO PARA CDC MANUAL
-- Almacena el ultimo LSN procesado
-- por cada tabla con carga incremental
-- =========================================
 
CREATE TABLE dbo.cdc_state (
    table_name NVARCHAR(100) NOT NULL PRIMARY KEY,
    last_lsn BINARY(10) NOT NULL
);
GO
 
INSERT INTO dbo.cdc_state (table_name, last_lsn) VALUES ('Venta',    0x00000000000000000000);
INSERT INTO dbo.cdc_state (table_name, last_lsn) VALUES ('Producto', 0x00000000000000000000);
GO
 
CREATE INDEX IX_StgCliente_id_cliente
ON dbo.StgCliente(id_cliente);
GO
 
CREATE INDEX IX_StgProducto_id_producto
ON dbo.StgProducto(id_producto);
GO
 
CREATE INDEX IX_StgPromocion_id_promocion
ON dbo.StgPromocion(id_promocion);
GO
 
CREATE INDEX IX_StgTiempo_fecha
ON dbo.StgTiempo(fecha);
GO
 
CREATE INDEX IX_StgTipoDePrecio_id
ON dbo.StgTipoDePrecio(id_tipo_de_precio);
GO
 
CREATE INDEX IX_StgVentaDetalle_id_venta
ON dbo.StgVentaDetalle(id_venta);
GO
 
CREATE INDEX IX_StgVentaDetalle_id_cliente
ON dbo.StgVentaDetalle(id_cliente);
GO
 
CREATE INDEX IX_StgVentaDetalle_id_producto
ON dbo.StgVentaDetalle(id_producto);
GO

-- Dimensiones y Fact Table
 
CREATE TABLE DimTiempo (
    id_tiempo INT PRIMARY KEY,
    fecha DATE NOT NULL,
    dia INT NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    trimestre INT NOT NULL,
    anio INT NOT NULL,
    nombre_dia VARCHAR(20) NOT NULL
);
 
CREATE TABLE DimCliente (
    id_cliente INT PRIMARY KEY,
    nombre_completo VARCHAR(300) NOT NULL,
    canton VARCHAR(100) NOT NULL,
    provincia VARCHAR(100) NOT NULL
);
 
CREATE TABLE DimProducto (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL
);
 
CREATE TABLE DimTipoDePrecio (
    id_tipo_de_precio INT PRIMARY KEY,
    precio_detalle DECIMAL(10,2) NOT NULL,
    precio_mayorista DECIMAL(10,2) NULL
);
 
CREATE TABLE DimPromocion (
    id_promocion INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL 
        CHECK (tipo IN ('precio_mayorista', 'combo', 'otro', 'ninguna')),
    descripcion VARCHAR(255),
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL
);
 
INSERT INTO DimPromocion (id_promocion, nombre, tipo, descripcion, fecha_inicio, fecha_fin)
VALUES (0, 'Sin promoción', 'ninguna', NULL, NULL, NULL);
 
CREATE TABLE FactVenta (
    id_fact INT IDENTITY(1,1) PRIMARY KEY,
    id_tiempo INT NOT NULL,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    id_promocion INT NOT NULL DEFAULT 0,
    id_tipo_de_precio INT NOT NULL,
    cantidad_vendida INT NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    tipo_precio_aplicado VARCHAR(20) NOT NULL
        CHECK (tipo_precio_aplicado IN ('detalle', 'mayorista')),
    FOREIGN KEY (id_tiempo) REFERENCES DimTiempo(id_tiempo),
    FOREIGN KEY (id_cliente) REFERENCES DimCliente(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES DimProducto(id_producto),
    FOREIGN KEY (id_promocion) REFERENCES DimPromocion(id_promocion),
    FOREIGN KEY (id_tipo_de_precio) REFERENCES DimTipoDePrecio(id_tipo_de_precio)
);