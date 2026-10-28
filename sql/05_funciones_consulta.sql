------------------------------------
--- Funcion para contar entradas ---
------------------------------------


--- VARIABLES QUE RECIBE Y DEVUELVE ---
CREATE OR REPLACE FUNCTION fn_cantidad_entradas (
    p_id_evento IN entradas.id_evento%TYPE,
    p_estado    IN estados_entradas.nombre%TYPE DEFAULT NULL
) RETURN NUMBER
IS
    v_id_estado estados_entradas.id_estado_entrada%TYPE;
    v_cantidad  NUMBER;
BEGIN
    -- VALIDACIÓN DE ARGUMENTOS
        -- VALIDAMOS QUE SE INGRESE ID
    IF p_id_evento IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'DEBES INGRESAR ID DEL EVENTO'
        );
    END IF;
        -- VALIDAMOS QUE EL ESTADO SEA VÁLIDO
    IF p_estado IS NOT NULL THEN 
        BEGIN
            SELECT  id_estado_entrada
            INTO    v_id_estado
            FROM    estados_entradas
            WHERE   nombre = UPPER(TRIM(p_estado));
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(
                    -20011,
                    'EL ESTADO DE LA ENTRADA ES INVÁLIDO'
                );
        END;
    END IF;

    -- CONTEO DE ENTRADAS ENCONTRADAS con el filtro
    SELECT COUNT(*)
        INTO    v_cantidad
        FROM    entradas e
        WHERE   e.id_evento = p_id_evento
        AND(
            p_estado IS NULL
            OR e.id_estado_entrada = v_id_estado
        );
    -- RETURN RESULTADO
    RETURN v_cantidad;
END fn_cantidad_entradas;
/


-----------------------------------------
--- Funcion para calcular recaudación ---
-----------------------------------------

--- VARIABLES QUE RECIBE Y DEVUELVE ---
CREATE OR REPLACE FUNCTION fn_recaudacion_evento(
    p_id_evento IN entradas.id_evento%TYPE
) RETURN NUMBER
IS
    v_recaudacion       NUMBER;
    v_inconsistentes    NUMBER;
BEGIN
    -- Validación de argumentos
    IF p_id_evento IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'DEBES INGRESAR ID DEL EVENTO'
        );
    END IF;

    
    SELECT NVL(SUM(t.valor), 0),
        COUNT(
            CASE
                WHEN    e.id_venta_entrada IS NULL
                OR      t.id_evento <> e.id_evento
                THEN    1
            END
        )
        INTO    v_recaudacion,
                v_inconsistentes
        FROM    entradas e
        JOIN    tipos_entradas t
        ON      t.id_tipo_entrada = e.id_tipo_entrada         
        JOIN    estados_entradas es
        ON      es.id_estado_entrada = e.id_estado_entrada
        WHERE   e.id_evento = p_id_evento
        AND     es.nombre IN ('VENDIDA', 'UTILIZADA');
    IF v_inconsistentes > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20012,
            'HAY ENTRADAS SIN VENTA O CON  UN TIPO DE OTRO EVENTO'
        );
    END IF;
    RETURN v_recaudacion;

END fn_recaudacion_evento;
/


-----------------------------------------------
--- Funcion para calcular recaudación total ---
--- de TODOS LOS EVENTOS                    ---
-----------------------------------------------

--- Esta función No recibe parametros

CREATE OR REPLACE FUNCTION fn_recaudacion_total
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN   
    SELECT NVL(
            SUM(FN_RECAUDACION_EVENTO(ev.id_evento)),
            0
        )
        INTO    v_total
        FROM    eventos ev;
    RETURN v_total;
END fn_recaudacion_total;
/

SHOW ERRORS FUNCTION fn_recaudacion_total;