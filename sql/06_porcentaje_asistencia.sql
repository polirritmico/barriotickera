-- APLICAR SCRIPT EN EL CONTENEDOR Y ESQUEMA DEL APLICATIVO
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = TICKETERA_APP;

--------------------------------------------------
--- Funcion para calcular % de asistencia      ---
--- (de las entradas vendidas, cuantas se      ---
---  usaron en la puerta del evento)           ---
--------------------------------------------------

--- VARIABLES QUE RECIBE Y DEVUELVE ---
CREATE OR REPLACE FUNCTION fn_porcentaje_asistencia (
    p_id_evento IN entradas.id_evento%TYPE
) RETURN NUMBER
IS
    v_existe      NUMBER;
    v_vendidas    NUMBER;   -- VENDIDA + UTILIZADA (toda entrada utilizada fue vendida antes)
    v_utilizadas  NUMBER;   -- solo UTILIZADA (la persona llego al evento)
BEGIN
    -- VALIDACIÓN DE ARGUMENTOS
        -- VALIDAMOS QUE SE INGRESE ID
    IF p_id_evento IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'DEBES INGRESAR ID DEL EVENTO'
        );
    END IF;
        -- VALIDAMOS QUE EL EVENTO EXISTA
    SELECT  COUNT(*)
    INTO    v_existe
    FROM    eventos
    WHERE   id_evento = p_id_evento;

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20013,
            'EL EVENTO NO EXISTE'
        );
    END IF;

    -- CONTEO DE VENDIDAS Y UTILIZADAS EN UNA SOLA CONSULTA
    SELECT  COUNT(*),
            COUNT(CASE WHEN es.nombre = 'UTILIZADA' THEN 1 END)
    INTO    v_vendidas,
            v_utilizadas
    FROM    entradas e
    JOIN    estados_entradas es
    ON      es.id_estado_entrada = e.id_estado_entrada
    WHERE   e.id_evento = p_id_evento
    AND     es.nombre IN ('VENDIDA', 'UTILIZADA');

    -- SI NO SE VENDIO NADA NO SE PUEDE DIVIDIR POR CERO
    IF v_vendidas = 0 THEN
        RETURN 0;
    END IF;

    -- RETURN RESULTADO: UTILIZADAS / VENDIDAS * 100, CON 2 DECIMALES
    RETURN ROUND(v_utilizadas * 100 / v_vendidas, 2);
END fn_porcentaje_asistencia;
/

SHOW ERRORS FUNCTION fn_porcentaje_asistencia;


--------------------------------------------------
--- Funcion para calcular % de asistencia      ---
--- juntando TODOS LOS EVENTOS                 ---
--------------------------------------------------

--- Esta función No recibe parametros
CREATE OR REPLACE FUNCTION fn_porcentaje_asistencia_todos_eventos
RETURN NUMBER
IS
    v_vendidas    NUMBER;   -- VENDIDA + UTILIZADA de todos los eventos
    v_utilizadas  NUMBER;   -- solo UTILIZADA de todos los eventos
BEGIN
    -- CONTEO SIN FILTRAR POR EVENTO: SE JUNTAN TODOS
    SELECT  COUNT(*),
            COUNT(CASE WHEN es.nombre = 'UTILIZADA' THEN 1 END)
    INTO    v_vendidas,
            v_utilizadas
    FROM    entradas e
    JOIN    estados_entradas es
    ON      es.id_estado_entrada = e.id_estado_entrada
    WHERE   es.nombre IN ('VENDIDA', 'UTILIZADA');

    -- SI NO SE VENDIO NADA NO SE PUEDE DIVIDIR POR CERO
    IF v_vendidas = 0 THEN
        RETURN 0;
    END IF;

    -- RETURN RESULTADO: UTILIZADAS / VENDIDAS * 100, CON 2 DECIMALES
    RETURN ROUND(v_utilizadas * 100 / v_vendidas, 2);
END fn_porcentaje_asistencia_todos_eventos;
/

SHOW ERRORS FUNCTION fn_porcentaje_asistencia_todos_eventos;
