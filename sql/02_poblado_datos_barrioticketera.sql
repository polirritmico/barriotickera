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
DECLARE
    v_id_comprador       COMPRADORES.id_comprador%TYPE;
    v_id_venta           VENTAS_ENTRADAS.id_venta_entrada%TYPE;
    v_id_evento          EVENTOS.id_evento%TYPE;
    v_id_tipo_entrada    TIPOS_ENTRADAS.id_tipo_entrada%TYPE;
    v_id_estado_entrada  ESTADOS_ENTRADAS.id_estado_entrada%TYPE;
    v_correo             COMPRADORES.correo%TYPE;
BEGIN
    SELECT id_evento
      INTO v_id_evento
      FROM EVENTOS
     WHERE nombre = 'COMPLETADA PRO GATOS CALLEJEROS';

    SELECT id_estado_entrada
      INTO v_id_estado_entrada
      FROM ESTADOS_ENTRADAS
     WHERE nombre = 'UTILIZADA';

    FOR i IN 6..50 LOOP
        v_correo := 'vecino' || LPAD(i, 2, '0') || '@ejemplo.cl';

        INSERT INTO COMPRADORES (correo)
        VALUES (v_correo)
        RETURNING id_comprador INTO v_id_comprador;

        INSERT INTO VENTAS_ENTRADAS (timestamp_venta, id_comprador)
        VALUES (
            TO_TIMESTAMP('2026-09-06 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
                + NUMTODSINTERVAL(i * 15, 'MINUTE'),
            v_id_comprador
        )
        RETURNING id_venta_entrada INTO v_id_venta;

        IF i <= 40 THEN
            SELECT id_tipo_entrada
              INTO v_id_tipo_entrada
              FROM TIPOS_ENTRADAS
             WHERE nombre = 'ENTRADA GENERAL'
               AND id_evento = v_id_evento;
        ELSE
            SELECT id_tipo_entrada
              INTO v_id_tipo_entrada
              FROM TIPOS_ENTRADAS
             WHERE nombre = 'ENTRADA SOLIDARIA'
               AND id_evento = v_id_evento;
        END IF;

        INSERT INTO ENTRADAS (
            ubicacion, qr, id_tipo_entrada, id_evento,
            id_venta_entrada, id_estado_entrada
        )
        VALUES (
            'MESA ' || LPAD(i, 2, '0'),
            'QR-GATOS-V' || LPAD(i, 4, '0'),
            v_id_tipo_entrada,
            v_id_evento,
            v_id_venta,
            v_id_estado_entrada
        );
    END LOOP;
END;
/

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
