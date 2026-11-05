/*
# Códigos de error pkg_entrada:

-20101: Error de venta: La entrada está reservada
-20102: Error de venta: La entrada no está disponible
-20103: Error de compra: La reserva no es valida o ya expiró
-20999: Error inesperado

# Procedimientos:

-
*/

-- Aplicar el script en el contenedor y esquema usado por la aplicación
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = TICKETERA_APP;

CREATE OR REPLACE PACKAGE pkg_venta AS

    FUNCTION verificar_disponibilidad(
        p_entrada_id NUMBER
    ) RETURN BOOLEAN;

/*
Flujo de venta de una entrada. Se divide en reservar_entrada, comprar_entrada y
generar servicios entradas.

Códigos de error:

-20101: Error de venta: La entrada está reservada
-20102: Error de venta: La entrada no está disponible
-20103: Error de compra: La reserva no es valida o ya expiró
-20999: Error inesperado

Funciones utilizadas:

función eliminar_reserva(id_entrada):
    - quita la entrada de Reserva_Entradas
    - cambia el estado de la entrada a disponible

función reservar_entrada(id_entrada):
    - agrega la entrada a Reserva_Entradas
    - cambia el estado de la entrada a reservada
    - retorna el id_reserva_entradas

procedimiento lógica de negocio:

1. Verificar_reserva(id_entrada); Se revisa si la entrada está en la tabla Reserva_Entradas.
    - Si se encuentra y el timeout >= ahora, se arroja el error 20101
    - Si se encuentra y el timeout está en el pasado se ejecuta eliminar_reserva
2. Verificar_disponibilidad(id_entrada);
    - Se revisa el estado de la entrada. Si no es disponible se arroja el error 20102
3. Se ejecuta reservar_entrada(id_entrada) y se retorna el id de la reserva

Tras la reserva se espera el resultado de la venta.

comprar_entrada(id_reserva, venta_exitosa):
    - Si id_reserva no existe en Reserva_Entradas:
        - Se arroja error -20103 (en el front se podría reintentar
          automáticamente desde el principio si se recibe este error)
    - Si venta_exitosa es false y no ha pasado el tiempo de reserva no pasa nada
    - Si venta_exitosa es false y ha pasado el tiempo de reserva se ejecuta
      eliminar_reserva.
    - venta_exitosa es true:
       - Se cambia el estado a vendida
       - Se quita de la reserva
       - Se revisa si existen datos del comprador.
          - Si no existen, se guarda una nueva fila en tabla Compradores
          - Si existe se obtiene su id_comprador
          - Se guarda la venta en Ventas_Entradas con timestamp, id_comprador e id_entrada

Tras la venta de la entrada se generan los servicios asociados a la entrada
(si es que tiene)

generar_servicios_entrada(id_entrada, id_tipo_entrada, id_evento):
    - Se revisa si el tipo de entrada tiene servicios asociados en la tabla puente
      Tipos_Entradas_Servicios.
       - Si tiene servicios asociados se genera, por cada uno, una fila en
         Consumos_Entradas con fecha_hora_canje en null.
*/

    PROCEDURE reservar_entrada(
        p_id_entrada        IN  entradas.id_entrada%TYPE,
        p_id_estado_entrada IN  entradas.id_estado_entrada%TYPE,
        p_id_evento         IN  entradas.id_evento%TYPE
    );

    PROCEDURE liberar_reserva_entrada (
        p_id_entrada        IN  entradas.id_entrada%TYPE
    );

    PROCEDURE comprar_entrada(
        p_id_entrada        IN  entradas.id_entrada%TYPE,
        p_id_comprador      IN  compradores.id_comprador%TYPE,
        p_venta_exitosa     IN  BOOLEAN,

        p_id_estado_entrada IN  entradas.id_estado_entrada%TYPE,
        p_id_evento         IN  entradas.id_evento%TYPE,
        p_id_venta_entrada  OUT entradas.id_venta_entrada%TYPE
    );

END pkg_venta;
/

CREATE OR REPLACE PACKAGE BODY pkg_venta AS

END pkg_venta;
/
