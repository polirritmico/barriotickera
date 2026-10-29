-- APLICAR SCRIPT EN EL CONTENEDOR Y ESQUEMA DEL APLICATIVO
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = TICKETERA_APP;

--------------------------------------------------
--- Funcion para calcular cupos disponibles    ---
--- (capacidad del lugar - entradas ocupadas)  ---
--------------------------------------------------

--- VARIABLES QUE RECIBE Y DEVUELVE ---
CREATE OR REPLACE FUNCTION fn_cupos_disponibles (
    p_id_evento IN entradas.id_evento%TYPE
) RETURN NUMBER
IS
    v_capacidad  locaciones.capacidad_max%TYPE;
    v_ocupadas   NUMBER;   -- DISPONIBLE + VENDIDA + UTILIZADA (las ANULADAS liberan su cupo)
BEGIN
    -- VALIDACIÓN DE ARGUMENTOS
        -- VALIDAMOS QUE SE INGRESE ID
    IF p_id_evento IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'DEBES INGRESAR ID DEL EVENTO'
        );
    END IF;
        -- BUSCAMOS LA CAPACIDAD DEL LUGAR DONDE SE HACE EL EVENTO
    BEGIN
        SELECT  l.capacidad_max
        INTO    v_capacidad
        FROM    eventos ev
        JOIN    locaciones l
        ON      l.id_locacion = ev.id_locacion
        WHERE   ev.id_evento = p_id_evento;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20013,
                'EL EVENTO NO EXISTE'
            );
    END;

    -- CONTEO DE ENTRADAS QUE OCUPAN UN LUGAR (TODAS MENOS LAS ANULADAS)
    SELECT  COUNT(*)
    INTO    v_ocupadas
    FROM    entradas e
    JOIN    estados_entradas es
    ON      es.id_estado_entrada = e.id_estado_entrada
    WHERE   e.id_evento = p_id_evento
    AND     es.nombre <> 'ANULADA';

    -- RETURN RESULTADO: LUGARES QUE QUEDAN
    RETURN v_capacidad - v_ocupadas;
END fn_cupos_disponibles;
/

SHOW ERRORS FUNCTION fn_cupos_disponibles;


--------------------------------------------------
--- Trigger: no crear entradas si el evento    ---
--- ya no tiene cupos                          ---
--- Fila · BEFORE INSERT sobre ENTRADAS        ---
--------------------------------------------------

CREATE OR REPLACE TRIGGER trg_cupos_entradas
BEFORE INSERT ON entradas
FOR EACH ROW
BEGIN
    -- :NEW ES LA ENTRADA QUE SE QUIERE GUARDAR (TODAVIA NO ESTA EN LA TABLA)
    IF fn_cupos_disponibles(:NEW.id_evento) <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20014,
            'NO QUEDAN CUPOS PARA EL EVENTO ' || :NEW.id_evento
        );
    END IF;
END trg_cupos_entradas;
/

SHOW ERRORS TRIGGER trg_cupos_entradas;
