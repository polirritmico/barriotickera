/*
-- ============================================================================
-- CÓDIGOS DE ERROR
-- ============================================================================

-20101: Error de venta: La entrada está reservada
-20102: Error de venta: La entrada no está disponible
-20103: Error de compra: La reserva no es valida o ya expiró
-20999: Error inesperado


-- ============================================================================
-- REGLAS DEL NEGOCIO / PSEUDO CÓDIGO
-- ============================================================================

El flujo de venta de entradas se divide en tres etapas:

1. Reserva de entradas
2. Compra de entradas
3. Generación de servicios asociados

--------------------------------------------------------------------------------
Estas son las funciones utilizadas por los procedimientos:

función eliminar_reserva(id_entrada):
    - quita la entrada de Reserva_Entradas
    - cambia el estado de la entrada a disponible

función reservar_entrada(id_entrada):
    - agrega la entrada a Reserva_Entradas
    - cambia el estado de la entrada a reservada
    - retorna el id_reserva_entradas
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- DESCRIPCIÓN PASO A PASO
--------------------------------------------------------------------------------

Se recibe una lista de entradas:

1. reservar_entradas(id_entradas) se revisa por cada entrada:
    - Verificar_reserva(id_entrada); Se revisa si la entrada está en la tabla Reserva_Entradas.
        - Si se encuentra y el timeout >= ahora, se arroja el error 20101.
        - Si se encuentra y el timeout está en el pasado se ejecuta eliminar_reserva
    - Verificar_disponibilidad(id_entrada);
        - Se revisa el estado de la entrada. Si no es disponible se arroja el error 20102
    - Se ejecuta reservar_entrada(id_entrada) en cada entrada y se retorna el id de cada reserva

Tras la reserva se espera el resultado de la venta.

2. comprar_entradas(id_reservadas, venta_exitosa):
    - Por cada reserva, si id_reserva no existe en Reserva_Entradas:
        - Se arroja error -20103 (en el front se podría reintentar
          automáticamente desde el principio si se recibe este error)
    - Si venta_exitosa es false y no ha pasado el tiempo de reserva no pasa nada
    - Si venta_exitosa es false y ha pasado el tiempo de reserva se ejecuta
      eliminar_reserva a cada entrada.
    - venta_exitosa es true:
        - Se cambia el estado de entradas a vendida
        - Se quitan de la reserva
        - Se procesan los datos del comprador:
            - Si se recibe un id_comprador válido, se utiliza directamente
            - Si solo se recibe el correo, se busca en la tabla Compradores:
                - Si no existe, se guarda una nueva fila y se obtiene nuevo id_comprador
                - Si existe, se obtiene su id_comprador
        - Se guarda la venta en Ventas_Entradas con timestamp, id_comprador y
          se actualiza el id_venta en cada entrada

Tras la venta se generan los servicios asociados a cada entrada (si compete)

3. generar_servicios_entradas(id_entradas, id_evento):
    - por cada entrada, se revisa si su tipo tiene servicios asociados en la
      tabla puente Tipos_Entradas_Servicios.
        - Si tiene servicios asociados se genera, por cada uno, una fila en
          Consumos_Entradas con fecha_hora_canje en null.

-- ============================================================================
*/


-- Aplicar el script en el contenedor y esquema usado por la aplicación
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = TICKETERA_APP;

CREATE OR REPLACE PACKAGE pkg_venta AS

    -- ============================================================
    -- TIPOS DE DATOS
    -- ============================================================

    -- Tipo para recibir o enviar múltiples IDs (entradas o reservas)
    TYPE t_lista_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;


    -- ============================================================
    -- PROCEDIMIENTOS
    -- ============================================================

    /*
     * ETAPA 1 - Reserva de entradas.
     *
     * Recibe una lista de IDs de entradas (p_ids_entradas) y el ID del evento
     * (p_id_evento). Para cada entrada ejecuta la siguiente secuencia:
     *
     *   1. verificar_reserva(id_entrada):
     *        - Si la entrada está en Reserva_Entradas y el timeout >= ahora,
     *          se arroja el error -20101 (entrada reservada).
     *        - Si la entrada está en Reserva_Entradas y el timeout ya pasó,
     *          se ejecuta eliminar_reserva para liberarla.
     *   2. verificar_disponibilidad(id_entrada):
     *        - Si el estado de la entrada no es 'DISPONIBLE', se arroja el
     *          error -20102 (entrada no disponible).
     *   3. reservar_entrada(id_entrada):
     *        - Agrega la entrada a Reserva_Entradas, cambia el estado a
     *          'RESERVADA' y retorna el id_reserva_entradas.
     *
     * p_ids_reservas devuelve la lista con el ID de cada reserva generada,
     * en el mismo orden que p_ids_entradas.
     */
    PROCEDURE reservar_entradas (
        p_ids_entradas      IN  t_lista_ids,
        p_id_evento         IN  eventos.id_evento%TYPE,
        p_ids_reservas      OUT t_lista_ids
    );

    /*
     * ETAPA 2 - Compra de entradas.
     *
     * Toma la lista de IDs de reservas hechas previamente (p_ids_reservas) y
     * el flag de éxito del pago (p_venta_exitosa). Recibe el id del comprador
     * si está logueado (p_id_comprador) o su correo si es invitado
     * (p_correo_comprador).
     *
     * Para cada reserva:
     *   - Si el id_reserva no existe en Reserva_Entradas, se arroja el error
     *     -20103 (reserva no válida o expirada). El frontend podría reintentar
     *     automáticamente desde el principio al recibir este error.
     *   - Si venta_exitosa = FALSE y no ha pasado el tiempo de reserva: no
     *     pasa nada (la reserva se mantiene).
     *   - Si venta_exitosa = FALSE y ha pasado el tiempo de reserva: se
     *     ejecuta eliminar_reserva para cada entrada.
     *
     * Si venta_exitosa = TRUE:
     *   - Se cambia el estado de las entradas a 'VENDIDA'.
     *   - Se quitan de Reserva_Entradas.
     *   - Se procesan los datos del comprador:
     *        * Si se recibe un id_comprador válido, se utiliza directamente.
     *        * Si solo se recibe el correo, se busca en la tabla Compradores:
     *            - Si no existe, se guarda una nueva fila y se obtiene el
     *              nuevo id_comprador.
     *            - Si existe, se obtiene su id_comprador.
     *   - Se guarda la venta en Ventas_Entradas con timestamp, id_comprador y
     *     se actualiza el id_venta en cada entrada.
     *
     * p_id_venta_entrada retorna el ID de la venta generada (solo cuando
     * venta_exitosa = TRUE).
     */
    PROCEDURE comprar_entradas(
        p_ids_reservas      IN  t_lista_ids,
        p_venta_exitosa     IN  BOOLEAN,
        p_id_comprador      IN  compradores.id_comprador%TYPE DEFAULT NULL,
        p_correo_comprador  IN  compradores.correo%TYPE DEFAULT NULL,
        p_id_venta_entrada  OUT ventas_entradas.id_venta_entrada%TYPE
    );

    /*
     * Quita la entrada de Reserva_Entradas y cambia su estado a 'DISPONIBLE'.
     *
     * Se utiliza para liberar reservas expiradas (verificar_reserva) o para
     * cancelar reservas cuando la venta falla (comprar_entradas).
     */
    PROCEDURE eliminar_reserva(p_id_entrada IN entradas.id_entrada%TYPE);

    /*
     * Revisa si la entrada existe en Reserva_Entradas.
     *
     *   - Si se encuentra y el timeout >= ahora (reserva activa), se arroja
     *     el error -20101 (la entrada está reservada).
     *   - Si se encuentra y el timeout está en el pasado (reserva expirada),
     *     se ejecuta eliminar_reserva para liberar la entrada.
     *
     * Si la entrada no tiene reserva activa, no hace nada.
     */
    PROCEDURE verificar_reserva(p_id_entrada IN entradas.id_entrada%TYPE);

    /*
     * Revisa el estado de la entrada en la tabla ENTRADAS.
     *
     * Si el estado no es 'DISPONIBLE', se arroja el error -20102
     * (la entrada no está disponible).
     */
    PROCEDURE verificar_disponibilidad(p_id_entrada IN entradas.id_entrada%TYPE);

    /*
     * ETAPA 3 - Generación de servicios asociados.
     *
     * Por cada entrada de p_ids_entradas, se revisa si su tipo tiene servicios
     * asociados en la tabla puente Tipos_Entradas_Servicios.
     *
     * Si la entrada tiene servicios asociados, se genera, por cada uno de
     * ellos, una fila en Consumos_Entradas con fecha_hora_canje en NULL.
     */
    PROCEDURE generar_servicios_entradas(
        p_ids_entradas IN t_lista_ids,
        p_id_evento    IN eventos.id_evento%TYPE
    );

END pkg_venta;
/

CREATE OR REPLACE PACKAGE BODY pkg_venta AS

    -- ============================================================
    -- CONSTANTES
    -- ============================================================
    c_tiempo_reserva_min CONSTANT NUMBER := 15;


    -- ============================================================
    -- FUNCIONES
    -- ============================================================

    /*
     * Función de uso interno para reservar_entradas.
     *
     * Agrega la entrada a Reserva_Entradas (con el tiempo de reserva y el
     * evento asociados) y cambia el estado de la entrada a 'RESERVADA'.
     * Retorna el id_reserva_entradas generado.
     */
    FUNCTION reservar_entrada(
        p_id_entrada IN entradas.id_entrada%TYPE,
        p_id_evento  IN eventos.id_evento%TYPE
    ) RETURN NUMBER
    BEGIN
        -- TODO: Implementar
        RETURN 0;
    END reservar_entrada;


    -- ============================================================
    -- PROCEDIMIENTOS
    -- ============================================================

    PROCEDURE reservar_entradas (
        p_ids_entradas      IN  t_lista_ids,
        p_id_evento         IN  eventos.id_evento%TYPE,
        p_ids_reservas      OUT t_lista_ids
    ) IS
    BEGIN
        -- ETAPA 1 - Reserva de entradas.
        --
        -- Recorre p_ids_entradas y, por cada entrada:
        --   1. Llama a verificar_reserva(id_entrada):
        --        - Lanza -20101 si la reserva está activa (timeout >= ahora).
        --        - Llama a eliminar_reserva si la reserva expiró.
        --   2. Llama a verificar_disponibilidad(id_entrada):
        --        - Lanza -20102 si el estado no es 'DISPONIBLE'.
        --   3. Llama a reservar_entrada(id_entrada) para crear la reserva,
        --        cambiar el estado a 'RESERVADA' y obtener el id_reserva.
        -- Almacena cada id_reserva_entradas generado en p_ids_reservas.
        -- TODO: Implementar
        NULL;
    END reservar_entradas;


    PROCEDURE comprar_entradas(
        p_ids_reservas      IN  t_lista_ids,
        p_venta_exitosa     IN  BOOLEAN,
        p_id_comprador      IN  compradores.id_comprador%TYPE DEFAULT NULL,
        p_correo_comprador  IN  compradores.correo%TYPE DEFAULT NULL,
        p_id_venta_entrada  OUT ventas_entradas.id_venta_entrada%TYPE
    ) IS
    BEGIN
        -- ETAPA 2 - Compra de entradas.
        --
        -- Recorre p_ids_reservas y, por cada reserva:
        --   - Si el id_reserva no existe en Reserva_Entradas:
        --        lanza error -20103 (reserva no válida o expirada).
        --   - Si venta_exitosa = FALSE y no venció el tiempo de reserva:
        --        no pasa nada (se mantiene la reserva).
        --   - Si venta_exitosa = FALSE y venció el tiempo de reserva:
        --        ejecuta eliminar_reserva para liberar la entrada.
        --
        -- Si venta_exitosa = TRUE:
        --   - Cambia el estado de las entradas a 'VENDIDA'.
        --   - Las quita de Reserva_Entradas.
        --   - Procesa los datos del comprador:
        --        * Si p_id_comprador es válido, se usa directamente.
        --        * Si solo se recibe p_correo_comprador, se busca en
        --          Compradores:
        --            - Si no existe, se inserta y se obtiene el nuevo
        --              id_comprador.
        --            - Si existe, se obtiene su id_comprador.
        --   - Guarda la venta en Ventas_Entradas con timestamp,
        --     id_comprador y actualiza el id_venta en cada entrada.
        --   - Asigna p_id_venta_entrada con el id de la venta generada.
        -- TODO: Implementar
        NULL;
    END comprar_entradas;


    PROCEDURE eliminar_reserva(p_id_entrada IN entradas.id_entrada%TYPE) IS
    BEGIN
        -- Quita la entrada de Reserva_Entradas y cambia su estado a
        -- 'DISPONIBLE'. Se usa para liberar reservas expiradas o canceladas.
        -- TODO: Implementar
        NULL;
    END eliminar_reserva;


    PROCEDURE verificar_reserva(p_id_entrada IN entradas.id_entrada%TYPE) IS
    BEGIN
        -- Revisa si la entrada existe en Reserva_Entradas:
        --   - Si se encuentra y el timeout >= ahora (reserva activa):
        --        lanza error -20101 (la entrada está reservada).
        --   - Si se encuentra y el timeout está en el pasado (expirada):
        --        ejecuta eliminar_reserva para liberar la entrada.
        -- Si no tiene reserva activa, no hace nada.
        -- TODO: Implementar
        NULL;
    END verificar_reserva;


    PROCEDURE verificar_disponibilidad(p_id_entrada IN entradas.id_entrada%TYPE) IS
    BEGIN
        -- Revisa el estado de la entrada en la tabla ENTRADAS.
        -- Si el estado no es 'DISPONIBLE', lanza error -20102
        -- (la entrada no está disponible).
        -- TODO: Implementar
        NULL;
    END verificar_disponibilidad;


    PROCEDURE generar_servicios_entradas(
        p_ids_entradas IN t_lista_ids,
        p_id_evento    IN eventos.id_evento%TYPE
    ) IS
    BEGIN
        -- ETAPA 3 - Generación de servicios asociados.
        --
        -- Por cada entrada de p_ids_entradas:
        --   - Revisa si su tipo tiene servicios asociados en la tabla puente
        --     Tipos_Entradas_Servicios.
        --   - Si tiene servicios asociados, genera por cada uno una fila en
        --     Consumos_Entradas con fecha_hora_canje en NULL.
        -- TODO: Implementar
        NULL;
    END generar_servicios_entradas;

END pkg_venta;
/
