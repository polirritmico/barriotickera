-- ============================================================
-- CARGA DE DATOS: COMPLETADA PRO GATOS CALLEJEROS
-- UBICACION: VILLA LAS 6 TORRES, LA FLORIDA
-- ============================================================
-- IMPORTANTE:
-- 1. Ejecutar primero creacion_barrioticketera.sql.
-- 2. Ejecutar este archivo una sola vez.
-- 3. Este archivo no crea ni modifica tablas: solo inserta datos.
-- 4. Todos los nombres, correos, RUT y codigos QR son ficticios.
-- ============================================================

SET DEFINE OFF;

-- ============================================================
-- 1. UBICACION GEOGRAFICA
-- El modelo no contiene una tabla PAISES. Chile queda representado
-- mediante la Region Metropolitana, Santiago y sus comunas.
-- ============================================================

INSERT INTO REGIONES (nombre)
VALUES ('REGION METROPOLITANA DE SANTIAGO');

INSERT INTO CIUDADES (nombre, id_region)
SELECT 'SANTIAGO', id_region
FROM REGIONES
WHERE nombre = 'REGION METROPOLITANA DE SANTIAGO';

INSERT INTO COMUNAS (nombre, id_ciudad)
SELECT 'LA FLORIDA', id_ciudad FROM CIUDADES WHERE nombre = 'SANTIAGO';

INSERT INTO COMUNAS (nombre, id_ciudad)
SELECT 'SANTIAGO', id_ciudad FROM CIUDADES WHERE nombre = 'SANTIAGO';

INSERT INTO COMUNAS (nombre, id_ciudad)
SELECT 'PUENTE ALTO', id_ciudad FROM CIUDADES WHERE nombre = 'SANTIAGO';

INSERT INTO COMUNAS (nombre, id_ciudad)
SELECT 'MAIPU', id_ciudad FROM CIUDADES WHERE nombre = 'SANTIAGO';

INSERT INTO COMUNAS (nombre, id_ciudad)
SELECT 'NUNOA', id_ciudad FROM CIUDADES WHERE nombre = 'SANTIAGO';

INSERT INTO COMUNAS (nombre, id_ciudad)
SELECT 'PROVIDENCIA', id_ciudad FROM CIUDADES WHERE nombre = 'SANTIAGO';

INSERT INTO COMUNAS (nombre, id_ciudad)
SELECT 'MACUL', id_ciudad FROM CIUDADES WHERE nombre = 'SANTIAGO';

INSERT INTO COMUNAS (nombre, id_ciudad)
SELECT 'PENALOLEN', id_ciudad FROM CIUDADES WHERE nombre = 'SANTIAGO';

-- ============================================================
-- 2. ORGANIZACION Y SUS MIEMBROS
-- ============================================================

INSERT INTO TIPOS_ORGANIZACIONES (nombre)
VALUES ('AGRUPACION COMUNITARIA');

INSERT INTO TIPOS_ORGANIZACIONES (nombre)
VALUES ('JUNTA DE VECINOS');

INSERT INTO TIPOS_ORGANIZACIONES (nombre)
VALUES ('FUNDACION');

INSERT INTO ORGANIZACIONES (
    nombre, rut, dv, id_tipo_organizacion
)
SELECT
    'AGRUPACION GATOS CALLEJEROS LAS 6 TORRES',
    99999999,
    '9',
    id_tipo_organizacion
FROM TIPOS_ORGANIZACIONES
WHERE nombre = 'AGRUPACION COMUNITARIA';

INSERT INTO PERSONAS_ORGANIZACION (
    rut, dv, primer_nombre, segundo_nombre,
    primer_apellido, segundo_apellido,
    correo, fono, direccion, id_comuna
)
SELECT
    11111111, '1', 'CAMILA', 'ANDREA',
    'ROJAS', 'SOTO',
    'camila.rojas@ejemplo.cl', '+56911111111',
    'PASAJE TORRE 1 120', id_comuna
FROM COMUNAS
WHERE nombre = 'LA FLORIDA';

INSERT INTO PERSONAS_ORGANIZACION (
    rut, dv, primer_nombre, segundo_nombre,
    primer_apellido, segundo_apellido,
    correo, fono, direccion, id_comuna
)
SELECT
    22222222, '2', 'DIEGO', 'IGNACIO',
    'MORALES', 'PEREZ',
    'diego.morales@ejemplo.cl', '+56922222222',
    'PASAJE TORRE 3 245', id_comuna
FROM COMUNAS
WHERE nombre = 'LA FLORIDA';

INSERT INTO PERSONAS_ORGANIZACION (
    rut, dv, primer_nombre, segundo_nombre,
    primer_apellido, segundo_apellido,
    correo, fono, direccion, id_comuna
)
SELECT
    33333333, '3', 'VALENTINA', 'PAZ',
    'SILVA', 'CONTRERAS',
    'valentina.silva@ejemplo.cl', '+56933333333',
    'PASAJE TORRE 5 318', id_comuna
FROM COMUNAS
WHERE nombre = 'LA FLORIDA';

INSERT INTO MIEMBROS_ORGANIZACIONES (
    rol, id_persona_org, id_organizacion
)
SELECT
    'COORDINADORA GENERAL',
    p.id_persona_org,
    o.id_organizacion
FROM PERSONAS_ORGANIZACION p
CROSS JOIN ORGANIZACIONES o
WHERE p.rut = 11111111
  AND o.rut = 99999999;

INSERT INTO MIEMBROS_ORGANIZACIONES (
    rol, id_persona_org, id_organizacion
)
SELECT
    'ENCARGADO DE VENTAS',
    p.id_persona_org,
    o.id_organizacion
FROM PERSONAS_ORGANIZACION p
CROSS JOIN ORGANIZACIONES o
WHERE p.rut = 22222222
  AND o.rut = 99999999;

INSERT INTO MIEMBROS_ORGANIZACIONES (
    rol, id_persona_org, id_organizacion
)
SELECT
    'ENCARGADA DE ACCESO Y CANJES',
    p.id_persona_org,
    o.id_organizacion
FROM PERSONAS_ORGANIZACION p
CROSS JOIN ORGANIZACIONES o
WHERE p.rut = 33333333
  AND o.rut = 99999999;

-- ============================================================
-- 3. LOCACION Y EVENTO
-- ============================================================

INSERT INTO LOCACIONES (
    nombre, capacidad_max, direccion,
    fono_contacto, correo_contacto, id_comuna
)
SELECT
    'SEDE VECINAL VILLA LAS 6 TORRES',
    300,
    'PASAJE LAS TORRES 600',
    '+56222226000',
    'contacto.6torres@ejemplo.cl',
    id_comuna
FROM COMUNAS
WHERE nombre = 'LA FLORIDA';

-- Los estados de eventos ya fueron creados por Desarrollo_ticketera.sql.
INSERT INTO EVENTOS (
    nombre, descripcion, hora_apertura, hora_cierre,
    id_estado_evento, id_locacion, id_organizacion
)
SELECT
    'COMPLETADA PRO GATOS CALLEJEROS',
    'Actividad solidaria realizada por vecinos de Villa Las 6 Torres para reunir fondos destinados a alimento, esterilizacion y atencion veterinaria de gatos callejeros de La Florida.',
    TO_TIMESTAMP('2026-09-12 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2026-09-12 20:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    ee.id_estado_evento,
    l.id_locacion,
    o.id_organizacion
FROM ESTADOS_EVENTOS ee
CROSS JOIN LOCACIONES l
CROSS JOIN ORGANIZACIONES o
WHERE ee.nombre = 'FINALIZADO'
  AND l.nombre = 'SEDE VECINAL VILLA LAS 6 TORRES'
  AND o.rut = 99999999;

-- ============================================================
-- 4. TIPOS DE ENTRADAS Y SERVICIOS DEL EVENTO
-- ============================================================

INSERT INTO TIPOS_ENTRADAS (nombre, valor, id_evento)
SELECT 'ENTRADA GENERAL', 5000, id_evento
FROM EVENTOS
WHERE nombre = 'COMPLETADA PRO GATOS CALLEJEROS';

INSERT INTO TIPOS_ENTRADAS (nombre, valor, id_evento)
SELECT 'ENTRADA SOLIDARIA', 8000, id_evento
FROM EVENTOS
WHERE nombre = 'COMPLETADA PRO GATOS CALLEJEROS';

INSERT INTO SERVICIOS_EVENTOS (nombre, descripcion, valor, id_evento)
SELECT
    'COMPLETO ITALIANO',
    'Completo con tomate, palta y mayonesa',
    3000,
    id_evento
FROM EVENTOS
WHERE nombre = 'COMPLETADA PRO GATOS CALLEJEROS';

INSERT INTO SERVICIOS_EVENTOS (nombre, descripcion, valor, id_evento)
SELECT
    'BEBIDA',
    'Vaso de bebida de 350 ml',
    1500,
    id_evento
FROM EVENTOS
WHERE nombre = 'COMPLETADA PRO GATOS CALLEJEROS';

INSERT INTO SERVICIOS_EVENTOS (nombre, descripcion, valor, id_evento)
SELECT
    'DONACION ALIMENTO PARA GATOS',
    'Aporte voluntario destinado a comprar alimento para gatos callejeros',
    2000,
    id_evento
FROM EVENTOS
WHERE nombre = 'COMPLETADA PRO GATOS CALLEJEROS';

-- ============================================================
-- 5. COMPRADORES Y VENTAS
-- ============================================================

INSERT INTO COMPRADORES (correo) VALUES ('ana.torres@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('bruno.diaz@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('carla.munoz@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('felipe.vera@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('sofia.leiva@ejemplo.cl');

INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT
    TO_TIMESTAMP('2026-09-01 18:15:00', 'YYYY-MM-DD HH24:MI:SS'),
    id_comprador
FROM COMPRADORES WHERE correo = 'ana.torres@ejemplo.cl';

INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT
    TO_TIMESTAMP('2026-09-02 10:30:00', 'YYYY-MM-DD HH24:MI:SS'),
    id_comprador
FROM COMPRADORES WHERE correo = 'bruno.diaz@ejemplo.cl';

INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT
    TO_TIMESTAMP('2026-09-03 16:45:00', 'YYYY-MM-DD HH24:MI:SS'),
    id_comprador
FROM COMPRADORES WHERE correo = 'carla.munoz@ejemplo.cl';

INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT
    TO_TIMESTAMP('2026-09-04 12:20:00', 'YYYY-MM-DD HH24:MI:SS'),
    id_comprador
FROM COMPRADORES WHERE correo = 'felipe.vera@ejemplo.cl';

INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT
    TO_TIMESTAMP('2026-09-05 19:05:00', 'YYYY-MM-DD HH24:MI:SS'),
    id_comprador
FROM COMPRADORES WHERE correo = 'sofia.leiva@ejemplo.cl';

-- Se agregan 45 vecinos ficticios. Junto con los cinco compradores
-- anteriores, el evento queda con 50 personas compradoras.
-- Cada uno de estos 45 vecinos compra una entrada y la utiliza.

-- COMPRADORES
INSERT INTO COMPRADORES (correo) VALUES ('vecino06@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino07@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino08@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino09@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino10@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino11@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino12@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino13@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino14@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino15@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino16@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino17@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino18@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino19@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino20@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino21@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino22@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino23@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino24@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino25@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino26@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino27@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino28@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino29@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino30@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino31@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino32@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino33@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino34@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino35@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino36@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino37@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino38@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino39@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino40@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino41@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino42@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino43@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino44@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino45@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino46@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino47@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino48@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino49@ejemplo.cl');
INSERT INTO COMPRADORES (correo) VALUES ('vecino50@ejemplo.cl');

-- VENTAS
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 11:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino06@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 11:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino07@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino08@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 12:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino09@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 12:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino10@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 12:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino11@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino12@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 13:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino13@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 13:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino14@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 13:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino15@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino16@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 14:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino17@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 14:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino18@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 14:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino19@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino20@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 15:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino21@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 15:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino22@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 15:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino23@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino24@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 16:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino25@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 16:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino26@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 16:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino27@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino28@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 17:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino29@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 17:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino30@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 17:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino31@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino32@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 18:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino33@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 18:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino34@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 18:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino35@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino36@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 19:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino37@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 19:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino38@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 19:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino39@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino40@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 20:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino41@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 20:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino42@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 20:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino43@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 21:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino44@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 21:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino45@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino46@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 21:45:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino47@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino48@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 22:15:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino49@ejemplo.cl';
INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
SELECT TO_TIMESTAMP('2026-09-06 22:30:00', 'YYYY-MM-DD HH24:MI:SS'), id_comprador
FROM COMPRADORES
WHERE correo = 'vecino50@ejemplo.cl';

-- ENTRADAS
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 06', 'QR-GATOS-V0006',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino06@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 07', 'QR-GATOS-V0007',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino07@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 08', 'QR-GATOS-V0008',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino08@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 09', 'QR-GATOS-V0009',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino09@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 10', 'QR-GATOS-V0010',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino10@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 11', 'QR-GATOS-V0011',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino11@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 12', 'QR-GATOS-V0012',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino12@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 13', 'QR-GATOS-V0013',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino13@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 14', 'QR-GATOS-V0014',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino14@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 15', 'QR-GATOS-V0015',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino15@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 16', 'QR-GATOS-V0016',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino16@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 17', 'QR-GATOS-V0017',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino17@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 18', 'QR-GATOS-V0018',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino18@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 19', 'QR-GATOS-V0019',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino19@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 20', 'QR-GATOS-V0020',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino20@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 21', 'QR-GATOS-V0021',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino21@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 22', 'QR-GATOS-V0022',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino22@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 23', 'QR-GATOS-V0023',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino23@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 24', 'QR-GATOS-V0024',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino24@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 25', 'QR-GATOS-V0025',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino25@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 26', 'QR-GATOS-V0026',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino26@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 27', 'QR-GATOS-V0027',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino27@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 28', 'QR-GATOS-V0028',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino28@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 29', 'QR-GATOS-V0029',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino29@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 30', 'QR-GATOS-V0030',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino30@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 31', 'QR-GATOS-V0031',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino31@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 32', 'QR-GATOS-V0032',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino32@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 33', 'QR-GATOS-V0033',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino33@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 34', 'QR-GATOS-V0034',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino34@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 35', 'QR-GATOS-V0035',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino35@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 36', 'QR-GATOS-V0036',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino36@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 37', 'QR-GATOS-V0037',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino37@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 38', 'QR-GATOS-V0038',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino38@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 39', 'QR-GATOS-V0039',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino39@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 40', 'QR-GATOS-V0040',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino40@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 41', 'QR-GATOS-V0041',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino41@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 42', 'QR-GATOS-V0042',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino42@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 43', 'QR-GATOS-V0043',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino43@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 44', 'QR-GATOS-V0044',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino44@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 45', 'QR-GATOS-V0045',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino45@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 46', 'QR-GATOS-V0046',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino46@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 47', 'QR-GATOS-V0047',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino47@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 48', 'QR-GATOS-V0048',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino48@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 49', 'QR-GATOS-V0049',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino49@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 50', 'QR-GATOS-V0050',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
JOIN EVENTOS e ON e.id_evento = te.id_evento
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'vecino50@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';


-- ============================================================
-- 6. ENTRADAS DIGITALES
-- Ademas de las 45 entradas creadas en el bloque anterior,
-- se crean 8 entradas: 5 utilizadas, 1 vendida sin utilizar,
-- 1 anulada y 1 disponible. En total quedan 53 entradas emitidas.
-- ============================================================

INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 01', 'QR-GATOS-0001',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
CROSS JOIN EVENTOS e
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND te.id_evento = e.id_evento
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'ana.torres@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';

INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 02', 'QR-GATOS-0002',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
CROSS JOIN EVENTOS e
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND te.id_evento = e.id_evento
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'bruno.diaz@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';

INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 03', 'QR-GATOS-0003',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
CROSS JOIN EVENTOS e
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND te.id_evento = e.id_evento
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'carla.munoz@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';

INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 04', 'QR-GATOS-0004',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
CROSS JOIN EVENTOS e
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND te.id_evento = e.id_evento
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'felipe.vera@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';

INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 05', 'QR-GATOS-0005',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
CROSS JOIN EVENTOS e
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA SOLIDARIA'
  AND te.id_evento = e.id_evento
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'sofia.leiva@ejemplo.cl'
  AND ee.nombre = 'UTILIZADA';

-- La compradora Ana adquiere una segunda entrada que finalmente no utiliza.
INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'MESA 06', 'QR-GATOS-0006',
    te.id_tipo_entrada, e.id_evento,
    ve.id_venta_entrada, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
CROSS JOIN EVENTOS e
CROSS JOIN VENTAS_ENTRADAS ve
JOIN COMPRADORES c ON c.id_comprador = ve.id_comprador
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND te.id_evento = e.id_evento
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND c.correo = 'ana.torres@ejemplo.cl'
  AND ee.nombre = 'VENDIDA';

INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'SIN ASIGNAR', 'QR-GATOS-0007',
    te.id_tipo_entrada, e.id_evento,
    NULL, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
CROSS JOIN EVENTOS e
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND te.id_evento = e.id_evento
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND ee.nombre = 'ANULADA';

INSERT INTO ENTRADAS (
    ubicacion, qr, id_tipo_entrada, id_evento,
    id_venta_entrada, id_estado_entrada
)
SELECT
    'SIN ASIGNAR', 'QR-GATOS-0008',
    te.id_tipo_entrada, e.id_evento,
    NULL, ee.id_estado_entrada
FROM TIPOS_ENTRADAS te
CROSS JOIN EVENTOS e
CROSS JOIN ESTADOS_ENTRADAS ee
WHERE te.nombre = 'ENTRADA GENERAL'
  AND te.id_evento = e.id_evento
  AND e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
  AND ee.nombre = 'DISPONIBLE';

-- ============================================================
-- 7. CONSUMOS CANJEADOS
-- Las 50 entradas utilizadas canjearon un completo y una bebida.
-- ============================================================

INSERT INTO CONSUMOS_ENTRADAS (canjeado, id_entrada, id_servicio_evento)
SELECT 'S', en.id_entrada, se.id_servicio_evento
FROM ENTRADAS en
CROSS JOIN SERVICIOS_EVENTOS se
JOIN ESTADOS_ENTRADAS ee
  ON ee.id_estado_entrada = en.id_estado_entrada
WHERE ee.nombre = 'UTILIZADA'
  AND se.nombre = 'COMPLETO ITALIANO'
  AND se.id_evento = en.id_evento;

INSERT INTO CONSUMOS_ENTRADAS (canjeado, id_entrada, id_servicio_evento)
SELECT 'S', en.id_entrada, se.id_servicio_evento
FROM ENTRADAS en
CROSS JOIN SERVICIOS_EVENTOS se
JOIN ESTADOS_ENTRADAS ee
  ON ee.id_estado_entrada = en.id_estado_entrada
WHERE ee.nombre = 'UTILIZADA'
  AND se.nombre = 'BEBIDA'
  AND se.id_evento = en.id_evento;

-- ============================================================
-- 8. CIERRE DEL EVENTO
-- Recaudacion por entradas:
-- 39 entradas generales x $5.000 = $195.000
-- 12 entradas solidarias x $8.000 = $96.000
-- Total = $291.000
-- ============================================================

INSERT INTO REGISTROS_EVENTOS (
    fecha_finalizacion, total_asistentes, entradas_emitidas,
    entradas_utilizadas, entradas_anuladas,
    recaudacion_total, id_evento
)
SELECT
    TO_TIMESTAMP('2026-09-12 20:15:00', 'YYYY-MM-DD HH24:MI:SS'),
    50,
    53,
    50,
    1,
    291000,
    id_evento
FROM EVENTOS
WHERE nombre = 'COMPLETADA PRO GATOS CALLEJEROS';

COMMIT;

-- ============================================================
-- 9. CONSULTAS DE COMPROBACION
-- ============================================================

SELECT e.nombre AS evento,
       e.hora_apertura,
       e.hora_cierre,
       l.nombre AS locacion,
       c.nombre AS comuna,
       ee.nombre AS estado
FROM EVENTOS e
JOIN LOCACIONES l ON l.id_locacion = e.id_locacion
JOIN COMUNAS c ON c.id_comuna = l.id_comuna
JOIN ESTADOS_EVENTOS ee ON ee.id_estado_evento = e.id_estado_evento
WHERE e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS';

SELECT es.nombre AS estado_entrada,
       COUNT(*) AS cantidad
FROM ENTRADAS en
JOIN ESTADOS_ENTRADAS es
  ON es.id_estado_entrada = en.id_estado_entrada
JOIN EVENTOS ev
  ON ev.id_evento = en.id_evento
WHERE ev.nombre = 'COMPLETADA PRO GATOS CALLEJEROS'
GROUP BY es.nombre
ORDER BY es.nombre;

SELECT COUNT(DISTINCT c.id_comprador) AS personas_compradoras,
       COUNT(en.id_entrada) AS entradas_vendidas
FROM EVENTOS e
JOIN ENTRADAS en
  ON en.id_evento = e.id_evento
JOIN VENTAS_ENTRADAS ve
  ON ve.id_venta_entrada = en.id_venta_entrada
JOIN COMPRADORES c
  ON c.id_comprador = ve.id_comprador
WHERE e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS';

SELECT r.total_asistentes,
       r.entradas_emitidas,
       r.entradas_utilizadas,
       r.entradas_anuladas,
       r.recaudacion_total
FROM REGISTROS_EVENTOS r
JOIN EVENTOS e ON e.id_evento = r.id_evento
WHERE e.nombre = 'COMPLETADA PRO GATOS CALLEJEROS';
