-- CONFIGURACION DE PAGINA APEX: NO EJECUTAR EN SQL WORKSHOP.
-- Pagina 5 > Processing > Process form Entrada.
-- Type: Form - Automatic Row Processing (DML). Form Region: Entrada.
-- Target Type: PL/SQL Code. Pegar BEGIN...END; en PL/SQL Code.
-- Mantener Close Dialog despues de este proceso. Sin COMMIT manual.
-- C crea, U actualiza, D elimina SOLO la entrada seleccionada al enviar el formulario.
-- Guardar el codigo no ejecuta las operaciones.
-- El usuario confirmo crear, editar y eliminar una entrada de prueba desde APEX.
-- La bitacora mostro CREAR, ACTUALIZAR y BORRAR. Configuracion: README_CRUD.md.
-- El paquete original no administra TIMESTAMP_CANJE: ese item debe ser solo de consulta.

BEGIN
    CASE :APEX$ROW_STATUS
        WHEN 'C' THEN
            pkg_entrada.crear_entrada(
                p_ubicacion         => :P5_UBICACION,
                p_qr                => :P5_QR,
                p_id_tipo_entrada   => :P5_ID_TIPO_ENTRADA,
                p_id_evento         => :P5_ID_EVENTO,
                p_id_venta_entrada  => :P5_ID_VENTA_ENTRADA,
                p_id_estado_entrada => :P5_ID_ESTADO_ENTRADA,
                p_id_entrada        => :P5_ID_ENTRADA
            );
        WHEN 'U' THEN
            pkg_entrada.actualizar_entrada(
                p_id_entrada        => :P5_ID_ENTRADA,
                p_ubicacion         => :P5_UBICACION,
                p_qr                => :P5_QR,
                p_id_tipo_entrada   => :P5_ID_TIPO_ENTRADA,
                p_id_evento         => :P5_ID_EVENTO,
                p_id_venta_entrada  => :P5_ID_VENTA_ENTRADA,
                p_id_estado_entrada => :P5_ID_ESTADO_ENTRADA
            );
        WHEN 'D' THEN
            pkg_entrada.eliminar_entrada(
                p_id_entrada => :P5_ID_ENTRADA
            );
        ELSE
            RAISE_APPLICATION_ERROR(-20020, 'Operacion de formulario no reconocida.');
    END CASE;
END;
