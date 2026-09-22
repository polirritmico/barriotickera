/* =====================================================================
   CLINICA KETEKURA - PACKAGE CRUD DE PACIENTES (clientes de la clinica)
   ---------------------------------------------------------------------
   Ejecutar conectado con el usuario dueño de las tablas
   (el que ejecuta crea_pobla_tablas_bd_CLINICA_KETEKURA.sql).

   Codigos de error de negocio (los recibe Python como ORA-200xx):
     -20001  El paciente no existe
     -20002  El paciente ya existe (RUN duplicado)
     -20003  Di­gito verificador invalido
     -20004  El sistema de salud (sal_id) no existe
     -20005  Datos de entrada invalidos
     -20006  No se puede eliminar: tiene atenciones o pagos morosos

   Nota: el package NO hace COMMIT. La transacion la controla el
   programa cliente (Python), que hace commit o rollback.
   ===================================================================== */

CREATE OR REPLACE PACKAGE pkg_entrada AS

    -- Utilidad: verificación básica del formato correo. 0 ok, 1 fallo
    FUNCTION fn_revisar_formato_correo (p_correo IN VARCHAR2) RETURN NUMBER;

    -- Utilidad: 0 si existe el paciente, 1 si no
    FUNCTION fn_existe (p_id_entrada IN entrada.id_entrada%TYPE) RETURN NUMBER;

    -- C: Create TODO: Qué es sp (original sp_insertar)
    PROCEDURE sp_insertar (
        p_id IN entrada.id_entrada%TYPE,
        p_ubicacion IN entrada.ubicacion%TYPE,
        p_qr IN entrada.qr%TYPE,
        p_id_tipo_entrada IN entrada.id_tipo_entrada%TYPE,
        p_id_evento IN entrada.id_evento%TYPE,
        p_id_venta_entrada IN entrada.id_venta_entrada%TYPE,
        p_id_estado_entrada IN entrada.id_estado_entrada%TYPE,
    );

    -- R: Read (una entrada)
    PROCEDURE sp_obtener (
        p_id     IN  entrada.id%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    -- R: Read (listado, filtro opcional por nombre o apellido)
    PROCEDURE sp_listar (
        p_filtro  IN  VARCHAR2,
        p_cursor  OUT SYS_REFCURSOR
    );

    -- U: Update (la id no se modifica porque es la PK)
    PROCEDURE sp_actualizar (
        p_id IN entrada.id_entrada%TYPE,
        p_ubicacion IN entrada.ubicacion%TYPE,
        p_qr IN entrada.qr%TYPE,
        p_id_tipo_entrada IN entrada.id_tipo_entrada%TYPE,
        p_id_evento IN entrada.id_evento%TYPE,
        p_id_venta_entrada IN entrada.id_venta_entrada%TYPE,
        p_id_estado_entrada IN entrada.id_estado_entrada%TYPE,
    );

    -- D: Delete
    PROCEDURE sp_eliminar (p_id IN entrada.id_entrada%TYPE);

END pkg_entrada;
/

CREATE OR REPLACE PACKAGE BODY pkg_entrada AS

    -- Excepciones de Oracle asociadas a restricciones
    e_fk_padre_no_existe EXCEPTION;   -- ORA-02291
    e_fk_tiene_hijos     EXCEPTION;   -- ORA-02292
    PRAGMA EXCEPTION_INIT(e_fk_padre_no_existe, -2291);
    PRAGMA EXCEPTION_INIT(e_fk_tiene_hijos,     -2292);

    ------------------------------------------------------------------
    -- FUNCIONES PuBLICAS DE UTILIDAD
    ------------------------------------------------------------------
    FUNCTION fn_calcular_dv (p_run IN NUMBER) RETURN VARCHAR2 IS
        v_run   NUMBER := p_run;
        v_suma  NUMBER := 0;
        v_mult  NUMBER := 2;
        v_res   NUMBER;
    BEGIN
        WHILE v_run > 0 LOOP
            v_suma := v_suma + MOD(v_run, 10) * v_mult;
            v_run  := TRUNC(v_run / 10);
            v_mult := CASE WHEN v_mult = 7 THEN 2 ELSE v_mult + 1 END;
        END LOOP;

        v_res := 11 - MOD(v_suma, 11);

        RETURN CASE v_res
                   WHEN 11 THEN '0'
                   WHEN 10 THEN 'K'
                   ELSE TO_CHAR(v_res)
               END;
    END fn_calcular_dv;

    FUNCTION fn_existe (p_run IN paciente.pac_run%TYPE) RETURN NUMBER IS
        v_cant NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cant FROM paciente WHERE pac_run = p_run;
        RETURN v_cant;
    END fn_existe;

    ------------------------------------------------------------------
    -- PROCEDIMIENTOS PRIVADOS
    ------------------------------------------------------------------
    PROCEDURE pr_validar_existe (p_run IN paciente.pac_run%TYPE) IS
    BEGIN
        IF fn_existe(p_run) = 0 THEN
            RAISE_APPLICATION_ERROR(-20001,
                'El paciente con RUN ' || p_run || ' no existe');
        END IF;
    END pr_validar_existe;

    PROCEDURE pr_validar_datos (
        p_pnombre   IN VARCHAR2,
        p_snombre   IN VARCHAR2,
        p_apaterno  IN VARCHAR2,
        p_amaterno  IN VARCHAR2,
        p_fecha_nac IN DATE,
        p_telefono  IN NUMBER,
        p_sal_id    IN NUMBER
    ) IS
        v_cant NUMBER;
    BEGIN
        IF TRIM(p_pnombre)  IS NULL OR TRIM(p_snombre)  IS NULL OR
           TRIM(p_apaterno) IS NULL OR TRIM(p_amaterno) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20005,
                'Nombres y apellidos son obligatorios');
        END IF;

        IF p_fecha_nac IS NULL OR p_fecha_nac > SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20005,
                'La fecha de nacimiento es obligatoria y no puede ser futura');
        END IF;

        IF p_telefono IS NOT NULL AND LENGTH(TO_CHAR(p_telefono)) > 9 THEN
            RAISE_APPLICATION_ERROR(-20005,
                'El telÃ©fono no puede tener mÃ¡s de 9 dÃ­gitos');
        END IF;

        IF p_sal_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_cant FROM salud WHERE sal_id = p_sal_id;
            IF v_cant = 0 THEN
                RAISE_APPLICATION_ERROR(-20004,
                    'El sistema de salud ' || p_sal_id || ' no existe');
            END IF;
        END IF;
    END pr_validar_datos;

    ------------------------------------------------------------------
    -- CREATE
    ------------------------------------------------------------------
    PROCEDURE sp_insertar (
        p_run        IN paciente.pac_run%TYPE,
        p_dv         IN paciente.dv_run%TYPE,
        p_pnombre    IN paciente.pnombre%TYPE,
        p_snombre    IN paciente.snombre%TYPE,
        p_apaterno   IN paciente.apaterno%TYPE,
        p_amaterno   IN paciente.amaterno%TYPE,
        p_fecha_nac  IN paciente.fecha_nacimiento%TYPE,
        p_telefono   IN paciente.telefono%TYPE,
        p_sal_id     IN paciente.sal_id%TYPE
    ) IS
    BEGIN
        IF p_run IS NULL OR p_run <= 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'El RUN es obligatorio');
        END IF;

        IF UPPER(p_dv) <> fn_calcular_dv(p_run) THEN
            RAISE_APPLICATION_ERROR(-20003,
                'DV invÃ¡lido para el RUN ' || p_run ||
                ' (se esperaba ' || fn_calcular_dv(p_run) || ')');
        END IF;

        pr_validar_datos(p_pnombre, p_snombre, p_apaterno, p_amaterno,
                         p_fecha_nac, p_telefono, p_sal_id);

        INSERT INTO paciente (pac_run, dv_run, pnombre, snombre, apaterno,
                              amaterno, fecha_nacimiento, telefono, sal_id)
        VALUES (p_run, UPPER(p_dv), INITCAP(TRIM(p_pnombre)),
                INITCAP(TRIM(p_snombre)), INITCAP(TRIM(p_apaterno)),
                INITCAP(TRIM(p_amaterno)), TRUNC(p_fecha_nac),
                p_telefono, p_sal_id);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20002,
                'Ya existe un paciente con RUN ' || p_run);
        WHEN e_fk_padre_no_existe THEN
            RAISE_APPLICATION_ERROR(-20004,
                'El sistema de salud ' || p_sal_id || ' no existe');
    END sp_insertar;

    ------------------------------------------------------------------
    -- READ (uno)
    ------------------------------------------------------------------
    PROCEDURE sp_obtener (
        p_run     IN  paciente.pac_run%TYPE,
        p_cursor  OUT SYS_REFCURSOR
    ) IS
    BEGIN
        pr_validar_existe(p_run);

        OPEN p_cursor FOR
            SELECT p.pac_run, p.dv_run, p.pnombre, p.snombre,
                   p.apaterno, p.amaterno, p.fecha_nacimiento,
                   TRUNC(MONTHS_BETWEEN(SYSDATE, p.fecha_nacimiento) / 12) AS edad,
                   p.telefono, p.sal_id,
                   s.descripcion AS sistema_salud,
                   t.descripcion AS tipo_salud
              FROM paciente p
              LEFT JOIN salud      s ON s.sal_id      = p.sal_id
              LEFT JOIN tipo_salud t ON t.tipo_sal_id = s.tipo_sal_id
             WHERE p.pac_run = p_run;
    END sp_obtener;

    ------------------------------------------------------------------
    -- READ (listado)
    ------------------------------------------------------------------
    PROCEDURE sp_listar (
        p_filtro  IN  VARCHAR2,
        p_cursor  OUT SYS_REFCURSOR
    ) IS
        v_filtro VARCHAR2(200) := '%' || UPPER(TRIM(p_filtro)) || '%';
    BEGIN
        OPEN p_cursor FOR
            SELECT p.pac_run, p.dv_run,
                   p.pnombre || ' ' || p.apaterno || ' ' || p.amaterno AS nombre,
                   TRUNC(MONTHS_BETWEEN(SYSDATE, p.fecha_nacimiento) / 12) AS edad,
                   p.telefono,
                   s.descripcion AS sistema_salud
              FROM paciente p
              LEFT JOIN salud s ON s.sal_id = p.sal_id
             WHERE p_filtro IS NULL
                OR UPPER(p.pnombre || ' ' || p.snombre || ' ' ||
                         p.apaterno || ' ' || p.amaterno) LIKE v_filtro
             ORDER BY p.apaterno, p.amaterno, p.pnombre;
    END sp_listar;

    ------------------------------------------------------------------
    -- UPDATE
    ------------------------------------------------------------------
    PROCEDURE sp_actualizar (
        p_run        IN paciente.pac_run%TYPE,
        p_pnombre    IN paciente.pnombre%TYPE,
        p_snombre    IN paciente.snombre%TYPE,
        p_apaterno   IN paciente.apaterno%TYPE,
        p_amaterno   IN paciente.amaterno%TYPE,
        p_fecha_nac  IN paciente.fecha_nacimiento%TYPE,
        p_telefono   IN paciente.telefono%TYPE,
        p_sal_id     IN paciente.sal_id%TYPE
    ) IS
    BEGIN
        pr_validar_existe(p_run);
        pr_validar_datos(p_pnombre, p_snombre, p_apaterno, p_amaterno,
                         p_fecha_nac, p_telefono, p_sal_id);

        UPDATE paciente
           SET pnombre          = INITCAP(TRIM(p_pnombre)),
               snombre          = INITCAP(TRIM(p_snombre)),
               apaterno         = INITCAP(TRIM(p_apaterno)),
               amaterno         = INITCAP(TRIM(p_amaterno)),
               fecha_nacimiento = TRUNC(p_fecha_nac),
               telefono         = p_telefono,
               sal_id           = p_sal_id
         WHERE pac_run = p_run;
    EXCEPTION
        WHEN e_fk_padre_no_existe THEN
            RAISE_APPLICATION_ERROR(-20004,
                'El sistema de salud ' || p_sal_id || ' no existe');
    END sp_actualizar;

    ------------------------------------------------------------------
    -- DELETE
    ------------------------------------------------------------------
    PROCEDURE sp_eliminar (p_run IN paciente.pac_run%TYPE) IS
        v_atenciones NUMBER;
        v_morosos    NUMBER;
    BEGIN
        pr_validar_existe(p_run);

        SELECT COUNT(*) INTO v_atenciones FROM atencion     WHERE pac_run = p_run;
        SELECT COUNT(*) INTO v_morosos    FROM pago_moroso  WHERE pac_run = p_run;

        IF v_atenciones > 0 OR v_morosos > 0 THEN
            RAISE_APPLICATION_ERROR(-20006,
                'No se puede eliminar el paciente ' || p_run ||
                ': tiene ' || v_atenciones || ' atencion(es) y ' ||
                v_morosos || ' pago(s) moroso(s) registrados');
        END IF;

        DELETE FROM paciente WHERE pac_run = p_run;
    EXCEPTION
        WHEN e_fk_tiene_hijos THEN
            RAISE_APPLICATION_ERROR(-20006,
                'No se puede eliminar el paciente ' || p_run ||
                ': tiene registros asociados');
    END sp_eliminar;

END pkg_entrada;
/

-- ---------------------------------------------------------------------
-- Pruebas rapidas desde SQL Developer
-- ---------------------------------------------------------------------
SHOW ERRORS PACKAGE BODY pkg_entrada;

SELECT pkg_entrada.fn_calcular_dv(6215470) AS dv_esperado_5 FROM dual;
SELECT pkg_entrada.fn_existe(6215470)      AS existe        FROM dual;
