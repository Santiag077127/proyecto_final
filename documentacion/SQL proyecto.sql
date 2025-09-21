CREATE DATABASE LavaRapido_Vehicular;
USE LavaRapido_Vehicular;

CREATE TABLE Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    NombreUsuario NVARCHAR(255) NOT NULL UNIQUE,
    Contrasena NVARCHAR(255) NOT NULL,
    EstadoUsuario BIT DEFAULT 1,
    TipoAutenticacion NVARCHAR(50) NOT NULL,
    FechaCreacion DATETIME2 DEFAULT SYSUTCDATETIME(),
    UltimoAcceso DATETIME2 NULL
);

CREATE TABLE Roles (
    RolID INT IDENTITY(1,1) PRIMARY KEY,
    NombreRol NVARCHAR(50) NOT NULL UNIQUE,
    Descripcion NVARCHAR(255)
);

CREATE TABLE Usuario_Rol (
    UsuarioID INT NOT NULL,
    RolID INT NOT NULL,
    FechaAsignacion DATETIME2 DEFAULT SYSUTCDATETIME(),
    PRIMARY KEY (UsuarioID, RolID),
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID),
    FOREIGN KEY (RolID) REFERENCES Roles(RolID)
);

CREATE TABLE Permisos (
    PermisoID INT IDENTITY(1,1) PRIMARY KEY,
    NombrePermiso NVARCHAR(50) NOT NULL UNIQUE,
    Descripcion NVARCHAR(255)
);

CREATE TABLE Rol_Permiso (
    RolID INT NOT NULL,
    PermisoID INT NOT NULL,
    FechaAsignacion DATETIME2 DEFAULT SYSUTCDATETIME(),
    PRIMARY KEY (RolID, PermisoID),
    FOREIGN KEY (RolID) REFERENCES Roles(RolID),
    FOREIGN KEY (PermisoID) REFERENCES Permisos(PermisoID)
);

CREATE TABLE Configuracion_Seguridad (
    ConfiguracionID INT IDENTITY(1,1) PRIMARY KEY,
    NombreConfiguracion NVARCHAR(100) NOT NULL UNIQUE,
    ValorConfiguracion NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(255)
);

CREATE TABLE Politicas_Contrasenas (
    PoliticaID INT IDENTITY(1,1) PRIMARY KEY,
    MinLongitud INT DEFAULT 8,
    MaxLongitud INT DEFAULT 20,
    RequiereMayusculas BIT DEFAULT 1,
    RequiereNumeros BIT DEFAULT 1,
    RequiereSimbolos BIT DEFAULT 1,
    CaducidadDias INT DEFAULT 90,
    CONSTRAINT CHK_Min_Longitud CHECK (MinLongitud >= 6),
    CONSTRAINT CHK_Max_Longitud CHECK (MaxLongitud >= MinLongitud)
);

CREATE TABLE Auditoria (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT NULL,
    Accion NVARCHAR(255) NOT NULL,
    Fecha DATETIME2 DEFAULT SYSUTCDATETIME(),
    Descripcion NVARCHAR(500),
    IP_Origen NVARCHAR(50),
    Aplicacion NVARCHAR(255),
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID)
);

CREATE TABLE Log_Errores (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATETIME2 DEFAULT SYSUTCDATETIME(),
    UsuarioID INT NULL,
    TipoError NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500),
    IP_Origen NVARCHAR(50),
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID)
);

CREATE TABLE Sesion_Usuario (
    SesionID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT NOT NULL,
    FechaInicio DATETIME2 DEFAULT SYSUTCDATETIME(),
    FechaFin DATETIME2 NULL,
    IP_Origen NVARCHAR(50),
    EstadoSesion NVARCHAR(50) NOT NULL,
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID)
);

CREATE TABLE clientes (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    correo NVARCHAR(100) NOT NULL UNIQUE,
    telefono NVARCHAR(20),
    usuario_id INT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(UsuarioID)
);

CREATE TABLE catalogo_vehiculos (
    id_catalogo_vehiculos INT IDENTITY(1,1) PRIMARY KEY,
    marca NVARCHAR(50) NOT NULL,
    modelo NVARCHAR(50) NOT NULL,
    color NVARCHAR(30),
    tipo NVARCHAR(50)
);

CREATE TABLE vehiculos (
    id_vehiculo INT IDENTITY(1,1) PRIMARY KEY,
    fk_id_catalogo_vehiculos INT NOT NULL,
    fk_id_cliente INT NOT NULL,
    placa NVARCHAR(20) NOT NULL UNIQUE,
    FOREIGN KEY (fk_id_catalogo_vehiculos) REFERENCES catalogo_vehiculos(id_catalogo_vehiculos),
    FOREIGN KEY (fk_id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE ubicacion (
    id_ubicacion INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    tarifa_zona DECIMAL(10,2) NOT NULL,
    altitud DECIMAL(10,6),
    latitud DECIMAL(10,6),
    longitud DECIMAL(10,6),
    timestand DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE cliente_ubicacion (
    id_direcciones INT IDENTITY(1,1) PRIMARY KEY,
    fk_id_cliente INT NOT NULL,
    fk_id_ubicacion INT NOT NULL,
    FOREIGN KEY (fk_id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (fk_id_ubicacion) REFERENCES ubicacion(id_ubicacion)
);

CREATE TABLE servicios (
    id_servicio INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(MAX),
    duracion INT,
    precio DECIMAL(10,2) NOT NULL
);

CREATE TABLE promociones (
    id_promocion INT IDENTITY(1,1) PRIMARY KEY,
    descripcion NVARCHAR(MAX),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    monto_minimo DECIMAL(10,2),
    CONSTRAINT CHK_promocion_fechas CHECK (fecha_fin >= fecha_inicio)
);

CREATE TABLE operadores (
    id_operadores INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    telefono NVARCHAR(20),
    correo NVARCHAR(100),
    licencia NVARCHAR(50) NOT NULL
);

CREATE TABLE disponibilidad (
    id_disponibilidad INT IDENTITY(1,1) PRIMARY KEY,
    fk_id_operador INT NOT NULL,
    horario_operador NVARCHAR(100),
    hora_inicio TIME,
    hora_salida TIME,
    activo BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (fk_id_operador) REFERENCES operadores(id_operadores)
);

CREATE TABLE reservas (
    id_reserva INT IDENTITY(1,1) PRIMARY KEY,
    fk_id_cliente INT NOT NULL,
    fk_id_vehiculo INT NOT NULL,
    fk_id_direccion INT NOT NULL,
    fk_id_servicio INT NOT NULL,
    fk_id_promocion INT NULL,
    fecha_hora_inicio DATETIME2 NOT NULL,
    fecha_hora_fin DATETIME2,
    estado NVARCHAR(50) NOT NULL,
    precio_final DECIMAL(10,2),
    fecha_reserva DATE NOT NULL,
    fk_creado_por_usuario_id INT NULL,
    FOREIGN KEY (fk_id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (fk_id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    FOREIGN KEY (fk_id_direccion) REFERENCES cliente_ubicacion(id_direcciones),
    FOREIGN KEY (fk_id_servicio) REFERENCES servicios(id_servicio),
    FOREIGN KEY (fk_id_promocion) REFERENCES promociones(id_promocion),
    FOREIGN KEY (fk_creado_por_usuario_id) REFERENCES Usuarios(UsuarioID)
);

CREATE TABLE asignaciones (
    id_asignacion INT IDENTITY(1,1) PRIMARY KEY,
    fk_id_reserva INT NOT NULL,
    fk_id_operador INT NOT NULL,
    fecha_hora_asignado DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    llegada_estimada DATETIME2,
    completado BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (fk_id_reserva) REFERENCES reservas(id_reserva),
    FOREIGN KEY (fk_id_operador) REFERENCES operadores(id_operadores)
);

CREATE TABLE pagos (
    id_pagos INT IDENTITY(1,1) PRIMARY KEY,
    fk_id_reserva INT NOT NULL,
    metodo_pago NVARCHAR(50) NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    estado NVARCHAR(50) NOT NULL,
    fecha_pago DATE NOT NULL,
    FOREIGN KEY (fk_id_reserva) REFERENCES reservas(id_reserva)
);

CREATE TABLE calificaciones (
    id_calificacion INT IDENTITY(1,1) PRIMARY KEY,
    fk_id_reserva INT NOT NULL,
    fk_id_cliente INT NOT NULL,
    fk_id_operador INT NOT NULL,
    calificacion TINYINT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    comentario NVARCHAR(1000),
    fecha_comentario DATE NOT NULL,
    FOREIGN KEY (fk_id_reserva) REFERENCES reservas(id_reserva),
    FOREIGN KEY (fk_id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (fk_id_operador) REFERENCES operadores(id_operadores)
);

----INSERT


INSERT INTO clientes (nombre, correo, telefono) 
VALUES (N'Juan Pérez', N'juanperez@mail.com', N'3001112233');
INSERT INTO clientes (nombre, correo, telefono) 
VALUES (N'Ana Gómez', N'anagomez@mail.com', N'3012223344');


INSERT INTO catalogo_vehiculos (marca, modelo, color, tipo)
VALUES (N'Toyota', N'Corolla', N'Blanco', N'Sedán');
INSERT INTO catalogo_vehiculos (marca, modelo, color, tipo)
VALUES (N'Chevrolet', N'Spark', N'Rojo', N'Hatchback');


INSERT INTO vehiculos (fk_id_catalogo_vehiculos, fk_id_cliente, placa)
VALUES (1, 1, N'ABC123');
INSERT INTO vehiculos (fk_id_catalogo_vehiculos, fk_id_cliente, placa)
VALUES (2, 2, N'DEF456');


INSERT INTO ubicacion (nombre, tarifa_zona, altitud, latitud, longitud)
VALUES (N'Centro', 15000.00, 1250.45, 4.609710, -74.081750);
INSERT INTO ubicacion (nombre, tarifa_zona, altitud, latitud, longitud)
VALUES (N'Chapinero', 18000.00, 1270.22, 4.648283, -74.065372);


INSERT INTO cliente_ubicacion (fk_id_cliente, fk_id_ubicacion)
VALUES (1, 1);
INSERT INTO cliente_ubicacion (fk_id_cliente, fk_id_ubicacion)
VALUES (2, 2);

INSERT INTO servicios (nombre, descripcion, duracion, precio)
VALUES (N'Lavado Básico', N'Lavado exterior rápido', 30, 20000.00);
INSERT INTO servicios (nombre, descripcion, duracion, precio)
VALUES (N'Lavado Premium', N'Lavado completo con encerado', 60, 45000.00);

INSERT INTO promociones (descripcion, fecha_inicio, fecha_fin, monto_minimo)
VALUES (N'Descuento 10% en servicios premium', '2025-09-01', '2025-09-30', 30000.00);
INSERT INTO promociones (descripcion, fecha_inicio, fecha_fin, monto_minimo)
VALUES (N'2x1 en lavados básicos', '2025-10-01', '2025-10-15', 15000.00);


INSERT INTO operadores (nombre, telefono, correo, licencia)
VALUES (N'Carlos Rodríguez', N'3205556677', N'carlos@mail.com', N'LIC123');
INSERT INTO operadores (nombre, telefono, correo, licencia)
VALUES (N'María Fernández', N'3104445566', N'maria@mail.com', N'LIC456');

INSERT INTO disponibilidad (fk_id_operador, horario_operador, hora_inicio, hora_salida, activo)
VALUES (1, N'Lunes a Viernes', '08:00', '17:00', 1);
INSERT INTO disponibilidad (fk_id_operador, horario_operador, hora_inicio, hora_salida, activo)
VALUES (2, N'Sábados y Domingos', '09:00', '14:00', 1);


INSERT INTO reservas (fk_id_cliente, fk_id_vehiculo, fk_id_direccion, fk_id_servicio, fk_id_promocion,
    fecha_hora_inicio, fecha_hora_fin, estado, precio_final, fecha_reserva)
VALUES (1, 1, 1, 1, 1, '2025-09-21 09:00', '2025-09-21 09:30', N'Confirmada', 18000.00, '2025-09-20');

INSERT INTO reservas (fk_id_cliente, fk_id_vehiculo, fk_id_direccion, fk_id_servicio, fk_id_promocion,
    fecha_hora_inicio, fecha_hora_fin, estado, precio_final, fecha_reserva)
VALUES (2, 2, 2, 2, 2, '2025-09-22 10:00', '2025-09-22 11:00', N'Pendiente', 40000.00, '2025-09-21');

INSERT INTO asignaciones (fk_id_reserva, fk_id_operador, llegada_estimada, completado)
VALUES (1, 1, '2025-09-21 09:05', 0);
INSERT INTO asignaciones (fk_id_reserva, fk_id_operador, llegada_estimada, completado)
VALUES (2, 2, '2025-09-22 10:10', 0);

INSERT INTO pagos (fk_id_reserva, metodo_pago, monto, estado, fecha_pago)
VALUES (1, N'Tarjeta Crédito', 18000.00, N'Pagado', '2025-09-21');
INSERT INTO pagos (fk_id_reserva, metodo_pago, monto, estado, fecha_pago)
VALUES (2, N'Efectivo', 40000.00, N'Pendiente', '2025-09-22');


INSERT INTO calificaciones (fk_id_reserva, fk_id_cliente, fk_id_operador, calificacion, comentario, fecha_comentario)
VALUES (1, 1, 1, 5, N'Excelente servicio, rápido y eficiente.', '2025-09-21');
INSERT INTO calificaciones (fk_id_reserva, fk_id_cliente, fk_id_operador, calificacion, comentario, fecha_comentario)
VALUES (2, 2, 2, 4, N'Buen servicio, pero demoró un poco.', '2025-09-22');

INSERT INTO Usuarios (NombreUsuario, Contrasena, EstadoUsuario, TipoAutenticacion)
VALUES (N'admin', N'Admin@123', 1, N'Local');
INSERT INTO Usuarios (NombreUsuario, Contrasena, EstadoUsuario, TipoAutenticacion)
VALUES (N'cliente1', N'Cliente@123', 1, N'Local');

INSERT INTO Roles (NombreRol, Descripcion)
VALUES (N'Administrador', N'Acceso completo al sistema');
INSERT INTO Roles (NombreRol, Descripcion)
VALUES (N'Cliente', N'Acceso limitado a reservas y pagos');

INSERT INTO Usuario_Rol (UsuarioID, RolID)
VALUES (1, 1);
INSERT INTO Usuario_Rol (UsuarioID, RolID)
VALUES (2, 2); 


INSERT INTO Permisos (NombrePermiso, Descripcion)
VALUES (N'GestionarUsuarios', N'Permite crear, editar y eliminar usuarios');
INSERT INTO Permisos (NombrePermiso, Descripcion)
VALUES (N'CrearReserva', N'Permite crear reservas de servicio');


INSERT INTO Rol_Permiso (RolID, PermisoID)
VALUES (1, 1); 
INSERT INTO Rol_Permiso (RolID, PermisoID)
VALUES (2, 2);

INSERT INTO Configuracion_Seguridad (NombreConfiguracion, ValorConfiguracion, Descripcion)
VALUES (N'MaxIntentosLogin', N'5', N'Número máximo de intentos de inicio de sesión fallidos');
INSERT INTO Configuracion_Seguridad (NombreConfiguracion, ValorConfiguracion, Descripcion)
VALUES (N'TiempoBloqueoMinutos', N'15', N'Tiempo de bloqueo tras superar intentos fallidos');

INSERT INTO Politicas_Contrasenas (MinLongitud, MaxLongitud, RequiereMayusculas, RequiereNumeros, RequiereSimbolos, CaducidadDias)
VALUES (8, 20, 1, 1, 1, 90);
INSERT INTO Politicas_Contrasenas (MinLongitud, MaxLongitud, RequiereMayusculas, RequiereNumeros, RequiereSimbolos, CaducidadDias)
VALUES (10, 25, 1, 1, 0, 120);

INSERT INTO Auditoria (UsuarioID, Accion, Descripcion, IP_Origen, Aplicacion)
VALUES (1, N'Creación Usuario', N'Se creó el usuario admin', N'192.168.1.10', N'Sistema');
INSERT INTO Auditoria (UsuarioID, Accion, Descripcion, IP_Origen, Aplicacion)
VALUES (2, N'Inicio Sesión', N'Cliente1 inició sesión', N'192.168.1.20', N'WebApp');


INSERT INTO Log_Errores (UsuarioID, TipoError, Descripcion, IP_Origen)
VALUES (2, N'LoginFallido', N'Contraseña incorrecta en inicio de sesión', N'192.168.1.20');
INSERT INTO Log_Errores (UsuarioID, TipoError, Descripcion, IP_Origen)
VALUES (NULL, N'Sistema', N'Error de conexión a la base de datos', N'127.0.0.1');


INSERT INTO Sesion_Usuario (UsuarioID, IP_Origen, EstadoSesion)
VALUES (1, N'192.168.1.10', N'Activa');
INSERT INTO Sesion_Usuario (UsuarioID, IP_Origen, EstadoSesion)
VALUES (2, N'192.168.1.20', N'Finalizada');


----PROCEDIMIENTOS ALMACENADOS MARCO SEGURIDAD


GO
CREATE OR ALTER PROCEDURE sp_CrearUsuario
    @NombreUsuario NVARCHAR(255),
    @Contrasena NVARCHAR(255),
    @TipoAutenticacion NVARCHAR(50) = N'Local'
AS
BEGIN
    INSERT INTO Usuarios (NombreUsuario, Contrasena, EstadoUsuario, TipoAutenticacion)
    VALUES (@NombreUsuario, @Contrasena, 1, @TipoAutenticacion);

    DECLARE @NuevoID INT = SCOPE_IDENTITY();

    INSERT INTO Auditoria (UsuarioID, Accion, Descripcion, IP_Origen, Aplicacion)
    VALUES (@NuevoID, N'Creación Usuario', N'Se creó un nuevo usuario', N'127.0.0.1', N'Sistema');
END;
GO

CREATE OR ALTER PROCEDURE sp_AsignarRolAUsuario
    @UsuarioID INT,
    @RolID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuario_Rol WHERE UsuarioID=@UsuarioID AND RolID=@RolID)
    BEGIN
        INSERT INTO Usuario_Rol (UsuarioID, RolID) VALUES (@UsuarioID, @RolID);

        INSERT INTO Auditoria (UsuarioID, Accion, Descripcion, IP_Origen, Aplicacion)
        VALUES (@UsuarioID, N'Asignación Rol', N'Se asignó un rol al usuario', N'127.0.0.1', N'Sistema');
    END
END;
GO

CREATE OR ALTER PROCEDURE sp_LoginUsuario
    @NombreUsuario NVARCHAR(255),
    @Contrasena NVARCHAR(255)
AS
BEGIN
    DECLARE @UsuarioID INT;

    SELECT @UsuarioID = UsuarioID
    FROM Usuarios
    WHERE NombreUsuario=@NombreUsuario AND Contrasena=@Contrasena AND EstadoUsuario=1;

    IF @UsuarioID IS NOT NULL
    BEGIN
        INSERT INTO Sesion_Usuario (UsuarioID, IP_Origen, EstadoSesion)
        VALUES (@UsuarioID, N'127.0.0.1', N'Activa');

        SELECT 'Login exitoso' AS Resultado, @UsuarioID AS UsuarioID;
    END
    ELSE
    BEGIN
        INSERT INTO Log_Errores (TipoError, Descripcion, IP_Origen)
        VALUES (N'LoginFallido', N'Usuario o contraseña incorrectos', N'127.0.0.1');

        SELECT 'Login fallido' AS Resultado, NULL AS UsuarioID;
    END
END;
GO

EXEC sp_LoginUsuario 
   @NombreUsuario = 'usuario_demo', 
   @Contrasena = '12345';

   EXEC sp_AsignarRolAUsuario 
    @UsuarioID = 1, 
    @RolID = 1;

-------------------------------
-----------PROCEDIMIENTO ALMACENADO negocio

GO
CREATE OR ALTER PROCEDURE sp_CrearCliente
    @Nombre NVARCHAR(100),
    @Correo NVARCHAR(100),
    @Telefono NVARCHAR(20)
AS
BEGIN
    INSERT INTO clientes (nombre, correo, telefono)
    VALUES (@Nombre, @Correo, @Telefono);
END;
GO

CREATE OR ALTER PROCEDURE sp_CrearReserva
    @ClienteID INT,
    @VehiculoID INT,
    @DireccionID INT,
    @ServicioID INT,
    @PromocionID INT = NULL,
    @FechaHoraInicio DATETIME2,
    @FechaHoraFin DATETIME2,
    @PrecioFinal DECIMAL(10,2),
    @Estado NVARCHAR(50) = N'Pendiente'
AS
BEGIN
    INSERT INTO reservas (
        fk_id_cliente, fk_id_vehiculo, fk_id_direccion, fk_id_servicio, fk_id_promocion,
        fecha_hora_inicio, fecha_hora_fin, estado, precio_final, fecha_reserva
    )
    VALUES (
        @ClienteID, @VehiculoID, @DireccionID, @ServicioID, @PromocionID,
        @FechaHoraInicio, @FechaHoraFin, @Estado, @PrecioFinal, CAST(GETDATE() AS DATE)
    );
END;
GO

CREATE OR ALTER PROCEDURE sp_RegistrarPago
    @ReservaID INT,
    @Metodo NVARCHAR(50),
    @Monto DECIMAL(10,2)
AS
BEGIN
    INSERT INTO pagos (fk_id_reserva, metodo_pago, monto, estado, fecha_pago)
    VALUES (@ReservaID, @Metodo, @Monto, N'Pagado', CAST(GETDATE() AS DATE));
END;
GO

CREATE OR ALTER PROCEDURE sp_ConsultarReservasCliente
    @ClienteID INT
AS
BEGIN
    SELECT r.id_reserva, s.nombre AS Servicio, r.estado, r.precio_final, r.fecha_reserva,
           v.placa, c.nombre AS Cliente, u.nombre AS Ubicacion
    FROM reservas r
    INNER JOIN servicios s ON r.fk_id_servicio = s.id_servicio
    INNER JOIN vehiculos v ON r.fk_id_vehiculo = v.id_vehiculo
    INNER JOIN clientes c ON r.fk_id_cliente = c.id_cliente
    INNER JOIN cliente_ubicacion cu ON r.fk_id_direccion = cu.id_direcciones
    INNER JOIN ubicacion u ON cu.fk_id_ubicacion = u.id_ubicacion
    WHERE r.fk_id_cliente = @ClienteID;
END;
GO

EXEC sp_CrearCliente 
    @Nombre = 'Carlos Pérez', 
    @Correo = 'carlos@example.com', 
    @Telefono = '3001234567';

    EXEC sp_CrearReserva 
    @ClienteID = 1, 
    @VehiculoID = 1, 
    @DireccionID = 1, 
    @ServicioID = 1, 
    @PromocionID = NULL, 
    @FechaHoraInicio = '2025-09-22 10:00', 
    @FechaHoraFin = '2025-09-22 12:00', 
    @PrecioFinal = 50000, 
    @Estado = 'Pendiente';

    EXEC sp_RegistrarPago 
    @ReservaID = 1, 
    @Metodo = 'Tarjeta', 
    @Monto = 50000;


    EXEC sp_ConsultarReservasCliente 
    @ClienteID = 1;


CREATE NONCLUSTERED INDEX IX_Usuarios_NombreUsuario ON Usuarios (NombreUsuario);


CREATE NONCLUSTERED INDEX IX_Roles_NombreRol ON Roles (NombreRol);


CREATE NONCLUSTERED INDEX IX_Permisos_NombrePermiso ON Permisos (NombrePermiso);


----------Indices Negocio


CREATE NONCLUSTERED INDEX IX_Clientes_Correo ON clientes (correo);
CREATE NONCLUSTERED INDEX IX_Clientes_Telefono ON clientes (telefono);


CREATE UNIQUE NONCLUSTERED INDEX IX_Vehiculos_Placa ON vehiculos (placa);


CREATE NONCLUSTERED INDEX IX_Ubicacion_Nombre ON ubicacion (nombre);

CREATE NONCLUSTERED INDEX IX_Reservas_Cliente ON reservas (fk_id_cliente);
CREATE NONCLUSTERED INDEX IX_Reservas_Vehiculo ON reservas (fk_id_vehiculo);
CREATE NONCLUSTERED INDEX IX_Reservas_Estado ON reservas (estado);

CREATE NONCLUSTERED INDEX IX_Pagos_Estado ON pagos (estado);
CREATE NONCLUSTERED INDEX IX_Pagos_Fecha ON pagos (fecha_pago);


CREATE NONCLUSTERED INDEX IX_Calificaciones_Operador ON calificaciones (fk_id_operador);


-------VISTAS
CREATE VIEW vw_Disponibilidad_Operadores
AS
SELECT 
    o.nombre AS Operador,
    d.horario_operador,
    d.hora_inicio,
    d.hora_salida,
    d.activo
FROM disponibilidad d
INNER JOIN operadores o ON d.fk_id_operador = o.id_operadores;


CREATE VIEW vw_Calificaciones
AS
SELECT 
    cal.id_calificacion,
    c.nombre AS Cliente,
    o.nombre AS Operador,
    cal.calificacion,
    cal.comentario,
    cal.fecha_comentario
FROM calificaciones cal
INNER JOIN clientes c ON cal.fk_id_cliente = c.id_cliente
INNER JOIN operadores o ON cal.fk_id_operador = o.id_operadores;


CREATE VIEW vw_Pagos_Detalle
AS
SELECT 
    p.id_pagos,
    c.nombre AS Cliente,
    r.id_reserva,
    p.metodo_pago,
    p.monto,
    p.estado,
    p.fecha_pago
FROM pagos p
INNER JOIN reservas r ON p.fk_id_reserva = r.id_reserva
INNER JOIN clientes c ON r.fk_id_cliente = c.id_cliente;


CREATE VIEW vw_Reservas_Detalle
AS
SELECT 
    r.id_reserva,
    c.nombre AS Cliente,
    v.placa AS Vehiculo,
    s.nombre AS Servicio,
    r.fecha_hora_inicio,
    r.fecha_hora_fin,
    r.estado,
    r.precio_final
FROM reservas r
INNER JOIN clientes c ON r.fk_id_cliente = c.id_cliente
INNER JOIN vehiculos v ON r.fk_id_vehiculo = v.id_vehiculo
INNER JOIN servicios s ON r.fk_id_servicio = s.id_servicio;



SELECT TOP 10 * 
FROM vw_Reservas_Detalle;

SELECT TOP 10 * 
FROM vw_Pagos_Detalle;

SELECT TOP 10 * 
FROM vw_Calificaciones;


SELECT TOP 10 * 
FROM vw_Disponibilidad_Operadores;

