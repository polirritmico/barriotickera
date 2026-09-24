   /*
   Códigos de error pkg_entradas:
   -20001: QR duplicado
   -20002: QR obligatorio
   -20003: Referencia inexistente / FK inválida
   -20004: Entrada no encontrada
   -20999: Error inesperado

   Procedimientos:
   - crear_entrada
   - actualizar_entrada
   - listar_entradas (filtro opcional; NULL = todas)
   */

CREATE OR REPLACE PACKAGE pkg_entradas AS



    PROCEDURE crear_entrada (
        p_ubicacion         IN  entradas.ubicacion%TYPE,
        p_qr                IN  entradas.qr%TYPE,
        p_id_tipo_entrada   IN  entradas.id_tipo_entrada%TYPE,
        p_id_evento         IN  entradas.id_evento%TYPE,
        p_id_venta_entrada  IN  entradas.id_venta_entrada%TYPE,
        p_id_estado_entrada IN  entradas.id_estado_entrada%TYPE,
        p_id_entrada        OUT entradas.id_entrada%TYPE
    );

    PROCEDURE actualizar_entrada (
        p_id_entrada        IN entradas.id_entrada%TYPE,
        p_ubicacion         IN entradas.ubicacion%TYPE,
        p_qr                IN entradas.qr%TYPE,
        p_id_tipo_entrada   IN entradas.id_tipo_entrada%TYPE,
        p_id_evento         IN entradas.id_evento%TYPE,
        p_id_venta_entrada  IN entradas.id_venta_entrada%TYPE,
        p_id_estado_entrada IN entradas.id_estado_entrada%TYPE
    );

    -- R: listado (filtro opcional por ubicacion o QR)
    PROCEDURE listar_entradas (
        p_filtro IN  VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    );

END pkg_entradas;
/

CREATE OR REPLACE PACKAGE BODY pkg_entradas AS

    e_fk_no_encontrada EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_fk_no_encontrada, -2291);

    PROCEDURE crear_entrada (
           p_ubicacion         IN  entradas.ubicacion%TYPE,
           p_qr                IN  entradas.qr%TYPE,
           p_id_tipo_entrada   IN  entradas.id_tipo_entrada%TYPE,
           p_id_evento         IN  entradas.id_evento%TYPE,
           p_id_venta_entrada  IN  entradas.id_venta_entrada%TYPE,
           p_id_estado_entrada IN  entradas.id_estado_entrada%TYPE,
           p_id_entrada        OUT entradas.id_entrada%TYPE
       ) AS
       BEGIN
            IF TRIM(p_qr) IS NULL THEN
                RAISE_APPLICATION_ERROR(
                    -20002,
                    'El QR es obligatorio'
                );
            END IF;

           INSERT INTO entradas (
               ubicacion,
               qr,
               id_tipo_entrada,
               id_evento,
               id_venta_entrada,
               id_estado_entrada
           ) VALUES (
               p_ubicacion,
               p_qr,
               p_id_tipo_entrada,
               p_id_evento,
               p_id_venta_entrada,
               p_id_estado_entrada
           )
           RETURNING id_entrada INTO p_id_entrada;

       EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RAISE_APPLICATION_ERROR(
                   -20001,
                   'Ya existe una entrada con ese código QR.'
               );


            WHEN e_fk_no_encontrada THEN
                RAISE_APPLICATION_ERROR(
                    -20003,
                    'Alguna referencia indicada no existe'
                );

            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20999 AND -20000 THEN
                    RAISE;
                ELSE
                    RAISE_APPLICATION_ERROR(
                        -20999,
                        'Error al crear la entrada: ' || SQLERRM
                    );
                END IF;

       END crear_entrada;
    
    PROCEDURE actualizar_entrada(
        p_id_entrada        IN entradas.id_entrada%TYPE,
        p_ubicacion         IN  entradas.ubicacion%TYPE,
        p_qr                IN  entradas.qr%TYPE,
        p_id_tipo_entrada   IN  entradas.id_tipo_entrada%TYPE,
        p_id_evento         IN  entradas.id_evento%TYPE,
        p_id_venta_entrada  IN  entradas.id_venta_entrada%TYPE,
        p_id_estado_entrada IN  entradas.id_estado_entrada%TYPE
    ) AS
    BEGIN

        IF TRIM(p_qr) IS NULL THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'El QR es obligatorio'
            );
        END IF;

        UPDATE entradas
        SET ubicacion               = p_ubicacion,
            qr                      = p_qr,     
            id_tipo_entrada         = p_id_tipo_entrada,
            id_evento               = p_id_evento,
            id_venta_entrada        = p_id_venta_entrada,
            id_estado_entrada       = p_id_estado_entrada
        WHERE id_entrada = p_id_entrada;

        IF SQL%ROWCOUNT = 0 THEN
           RAISE_APPLICATION_ERROR(
                -20004,
                'NO EXISTE UNA ENTRADA CON EL ID INDICADO'
            );
        END IF;
    EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RAISE_APPLICATION_ERROR(
                   -20001,
                   'Ya existe una entrada con ese código QR.'
               );


            WHEN e_fk_no_encontrada THEN
                RAISE_APPLICATION_ERROR(
                    -20003,
                    'Alguna referencia indicada no existe'
                );

            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20999 AND -20000 THEN
                    RAISE;
                ELSE
                    RAISE_APPLICATION_ERROR(
                        -20999,
                        'Error al actualizar la entrada: ' || SQLERRM
                    );
                END IF;
    END actualizar_entrada;

    PROCEDURE listar_entradas (
        p_filtro IN  VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    ) AS
        v_filtro VARCHAR2(200) := '%' || UPPER(TRIM(p_filtro)) || '%';
    BEGIN
        OPEN p_cursor FOR
            SELECT e.id_entrada,
                   e.ubicacion,
                   e.qr,
                   e.id_tipo_entrada,
                   t.nombre AS tipo_entrada,
                   e.id_evento,
                   ev.nombre AS evento,
                   e.id_venta_entrada,
                   e.id_estado_entrada,
                   s.nombre AS estado_entrada
              FROM entradas e
              JOIN tipos_entradas   t  ON t.id_tipo_entrada   = e.id_tipo_entrada
              JOIN eventos          ev ON ev.id_evento        = e.id_evento
              JOIN estados_entradas s  ON s.id_estado_entrada = e.id_estado_entrada
             WHERE p_filtro IS NULL
                OR UPPER(e.ubicacion) LIKE v_filtro
                OR UPPER(e.qr)        LIKE v_filtro
             ORDER BY e.id_entrada;
    END listar_entradas;

END pkg_entradas;
/

