--- Funciones ---

--- VARIABLES QUE RECIBE Y DEVUELVE ---
CREATE OR REPLACE FUNCTION fn_cantidad_entradas (
    p_id_evento IN entradas.id_eventos%TYPE,
    p_estado    IN estados__entradas.nombre%TYPE DEFAULT NULL
) RETURN NUMBER
IS
    v_id_estado estados_entradas_.id_estado_entrada%TYPE;
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


