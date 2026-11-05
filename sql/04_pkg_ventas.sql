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
     * Recibe una lista de IDs de entradas y el evento.
     * Retorna una lista con los IDs de las reservas generadas.
     */
    PROCEDURE reservar_entradas (
        p_ids_entradas      IN  t_lista_ids,
        p_id_evento         IN  eventos.id_evento%TYPE,
        p_ids_reservas      OUT t_lista_ids
    );

    /*
     * Toma la lista de IDs de reservas hechas previamente.
     * Recibe el flag de éxito del pago.
     * Recibe id_comprador si está logeado o correo si es invitado.
     * Retorna el id de la venta generada si fue exitosa.
     */
    PROCEDURE comprar_entradas(
        p_ids_reservas      IN  t_lista_ids,
        p_venta_exitosa     IN  BOOLEAN,
        p_id_comprador      IN  compradores.id_comprador%TYPE DEFAULT NULL,
        p_correo_comprador  IN  compradores.correo%TYPE DEFAULT NULL,
        p_id_venta_entrada  OUT ventas_entradas.id_venta_entrada%TYPE
    );

    /*
     * Quita la entrada de Reserva_Entradas y la deja 'DISPONIBLE'.
     */
    PROCEDURE eliminar_reserva(p_id_entrada IN entradas.id_entrada%TYPE);

    /*
     * Revisa Reserva_Entradas. Arroja -20101 si está activa.
     * Ejecuta eliminar_reserva si vence el tiempo de reserva.
     */
    PROCEDURE verificar_reserva(p_id_entrada IN entradas.id_entrada%TYPE);

    /*
     * Revisa estado en ENTRADAS. Arroja -20102 si no es 'DISPONIBLE'.
     */
    PROCEDURE verificar_disponibilidad(p_id_entrada IN entradas.id_entrada%TYPE);

    /*
     * Revisa la tabla puente Tipos_Entradas_Servicios y genera
     * las filas correspondientes en Consumos_Entradas.
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
     * Agrega a Reserva_Entradas y cambia estado a 'RESERVADA'.
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
        -- TODO: Implementar
        NULL;
    END comprar_entradas;


    PROCEDURE eliminar_reserva(p_id_entrada IN entradas.id_entrada%TYPE) IS
    BEGIN
        -- TODO: Implementar
        NULL;
    END eliminar_reserva;


    PROCEDURE verificar_reserva(p_id_entrada IN entradas.id_entrada%TYPE) IS
    BEGIN
        -- TODO: Implementar
        NULL;
    END verificar_reserva;


    PROCEDURE verificar_disponibilidad(p_id_entrada IN entradas.id_entrada%TYPE) IS
    BEGIN
        -- TODO: Implementar
        NULL;
    END verificar_disponibilidad;


    PROCEDURE generar_servicios_entradas(
        p_ids_entradas IN t_lista_ids,
        p_id_evento    IN eventos.id_evento%TYPE
    ) IS
    BEGIN
        -- TODO: Implementar
        NULL;
    END generar_servicios_entradas;

END pkg_venta;
/
