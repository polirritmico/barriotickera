"""
CRUD de PACIENTES - Clínica Ketekura
Consume el package PL/SQL PKG_PACIENTE desde Python.

Requisitos:
    pip install oracledb

Conexión (variables de entorno opcionales):
    DB_USER, DB_PASSWORD, DB_DSN
    DB_WALLET_DIR, DB_WALLET_PASSWORD   (solo Oracle Cloud con wallet)

Uso:
    python crud_paciente.py          -> menú interactivo
    python crud_paciente.py --demo   -> ejecuta un ciclo CRUD completo automático
"""

import os
import sys
from dataclasses import dataclass
from datetime import date, datetime
from typing import Optional

import oracledb

# ----------------------------------------------------------------------
# CONFIGURACIÓN DE CONEXIÓN
# ----------------------------------------------------------------------
DB_USER = os.getenv("DB_USER", "BDY1103_C4")
DB_PASSWORD = os.getenv("DB_PASSWORD", "BDY1103.clase_c4")
# Oracle XE local: "localhost:1521/XEPDB1"
# Oracle Cloud:    alias del tnsnames.ora del wallet, ej. "midb_high"
DB_DSN = os.getenv("DB_DSN", "localhost:1521/XEPDB1")
WALLET_DIR = os.getenv("DB_WALLET_DIR")
WALLET_PASSWORD = os.getenv("DB_WALLET_PASSWORD")


def conectar() -> oracledb.Connection:
    params = {"user": DB_USER, "password": DB_PASSWORD, "dsn": DB_DSN}
    if WALLET_DIR:
        params.update(config_dir=WALLET_DIR,
                      wallet_location=WALLET_DIR,
                      wallet_password=WALLET_PASSWORD)
    return oracledb.connect(**params)


# ----------------------------------------------------------------------
# MODELO Y EXCEPCIÓN DE NEGOCIO
# ----------------------------------------------------------------------
@dataclass
class Paciente:
    run: int
    dv: str
    pnombre: str
    snombre: str
    apaterno: str
    amaterno: str
    fecha_nacimiento: date
    telefono: Optional[int] = None
    sal_id: Optional[int] = None


class PacienteError(Exception):
    """Error de negocio lanzado por PKG_PACIENTE (ORA-20001 .. ORA-20999)."""

    def __init__(self, codigo: int, mensaje: str):
        super().__init__(mensaje)
        self.codigo = codigo
        self.mensaje = mensaje

    def __str__(self):
        return f"[{self.codigo}] {self.mensaje}"


def _error_negocio(exc: oracledb.DatabaseError) -> Optional[PacienteError]:
    """Si el error viene de RAISE_APPLICATION_ERROR, lo convierte en PacienteError."""
    error, = exc.args
    if 20000 <= error.code <= 20999:
        primera_linea = error.message.split("\n")[0]        # "ORA-20001: texto"
        texto = primera_linea.split(": ", 1)[-1]
        return PacienteError(-error.code, texto)
    return None


# ----------------------------------------------------------------------
# DAO: cada método llama a un procedimiento/función del package
# ----------------------------------------------------------------------
class PacienteDAO:

    def __init__(self, conn: oracledb.Connection):
        self.conn = conn

    # --- helpers internos ---------------------------------------------
    def _ejecutar(self, procedimiento: str, parametros: list) -> None:
        """Ejecuta un procedimiento DML y controla la transacción."""
        try:
            with self.conn.cursor() as cur:
                cur.callproc(procedimiento, parametros)
            self.conn.commit()
        except oracledb.DatabaseError as exc:
            self.conn.rollback()
            negocio = _error_negocio(exc)
            if negocio:
                raise negocio from exc
            raise

    def _consultar(self, procedimiento: str, parametros: list) -> list[dict]:
        """Ejecuta un procedimiento que retorna un SYS_REFCURSOR (último parámetro)."""
        with self.conn.cursor() as cur, self.conn.cursor() as ref_cursor:
            try:
                cur.callproc(procedimiento, parametros + [ref_cursor])
            except oracledb.DatabaseError as exc:
                negocio = _error_negocio(exc)
                if negocio:
                    raise negocio from exc
                raise
            columnas = [col[0].lower() for col in ref_cursor.description]
            return [dict(zip(columnas, fila)) for fila in ref_cursor]

    # --- utilidades ---------------------------------------------------
    def calcular_dv(self, run: int) -> str:
        with self.conn.cursor() as cur:
            return cur.callfunc("pkg_paciente.fn_calcular_dv", str, [run])

    def existe(self, run: int) -> bool:
        with self.conn.cursor() as cur:
            return cur.callfunc("pkg_paciente.fn_existe", int, [run]) > 0

    # --- CRUD ---------------------------------------------------------
    def crear(self, p: Paciente) -> None:
        self._ejecutar("pkg_paciente.sp_insertar", [
            p.run, p.dv, p.pnombre, p.snombre, p.apaterno, p.amaterno,
            p.fecha_nacimiento, p.telefono, p.sal_id
        ])

    def obtener(self, run: int) -> dict:
        return self._consultar("pkg_paciente.sp_obtener", [run])[0]

    def listar(self, filtro: Optional[str] = None) -> list[dict]:
        return self._consultar("pkg_paciente.sp_listar", [filtro])

    def actualizar(self, p: Paciente) -> None:
        self._ejecutar("pkg_paciente.sp_actualizar", [
            p.run, p.pnombre, p.snombre, p.apaterno, p.amaterno,
            p.fecha_nacimiento, p.telefono, p.sal_id
        ])

    def eliminar(self, run: int) -> None:
        self._ejecutar("pkg_paciente.sp_eliminar", [run])


# ----------------------------------------------------------------------
# FUNCIONES DE PRESENTACIÓN / ENTRADA
# ----------------------------------------------------------------------
def fmt_fecha(valor) -> str:
    return valor.strftime("%d-%m-%Y") if valor else ""


def mostrar_listado(filas: list[dict]) -> None:
    if not filas:
        print("  (sin resultados)")
        return
    print(f"  {'RUN':>12}  {'NOMBRE':<35} {'EDAD':>4}  {'TELÉFONO':>10}  SALUD")
    print("  " + "-" * 90)
    for f in filas:
        run = f"{f['pac_run']}-{f['dv_run']}"
        print(f"  {run:>12}  {f['nombre']:<35} {f['edad']:>4}  "
              f"{f['telefono'] or '':>10}  {f['sistema_salud'] or ''}")
    print(f"  Total: {len(filas)} paciente(s)")


def mostrar_paciente(d: dict) -> None:
    print(f"""
  RUN              : {d['pac_run']}-{d['dv_run']}
  Nombre           : {d['pnombre']} {d['snombre']} {d['apaterno']} {d['amaterno']}
  Fecha nacimiento : {fmt_fecha(d['fecha_nacimiento'])}  ({d['edad']} años)
  Teléfono         : {d['telefono'] or '-'}
  Salud            : {d['sal_id'] or '-'} {d['sistema_salud'] or ''} ({d['tipo_salud'] or '-'})""")


def pedir(texto: str, actual=None, obligatorio: bool = True) -> Optional[str]:
    """Pide un texto. Si hay valor actual, Enter lo conserva."""
    sufijo = f" [{actual}]" if actual not in (None, "") else ""
    while True:
        valor = input(f"  {texto}{sufijo}: ").strip()
        if valor:
            return valor
        if actual not in (None, ""):
            return str(actual)
        if not obligatorio:
            return None
        print("    Campo obligatorio.")


def pedir_int(texto: str, actual=None, obligatorio: bool = True) -> Optional[int]:
    while True:
        valor = pedir(texto, actual, obligatorio)
        if valor is None:
            return None
        if valor.isdigit():
            return int(valor)
        print("    Debe ingresar un número entero.")


def pedir_fecha(texto: str, actual: Optional[date] = None) -> date:
    while True:
        valor = pedir(f"{texto} (dd-mm-aaaa)", fmt_fecha(actual) or None)
        try:
            return datetime.strptime(valor, "%d-%m-%Y").date()
        except ValueError:
            print("    Formato inválido, use dd-mm-aaaa.")


# ----------------------------------------------------------------------
# OPCIONES DEL MENÚ
# ----------------------------------------------------------------------
def op_listar(dao: PacienteDAO) -> None:
    filtro = pedir("Filtro por nombre/apellido (Enter = todos)", obligatorio=False)
    mostrar_listado(dao.listar(filtro))


def op_buscar(dao: PacienteDAO) -> None:
    mostrar_paciente(dao.obtener(pedir_int("RUN (sin DV)")))


def op_crear(dao: PacienteDAO) -> None:
    run = pedir_int("RUN (sin DV)")
    dv_sugerido = dao.calcular_dv(run)
    p = Paciente(
        run=run,
        dv=pedir("DV", dv_sugerido).upper(),
        pnombre=pedir("Primer nombre"),
        snombre=pedir("Segundo nombre"),
        apaterno=pedir("Apellido paterno"),
        amaterno=pedir("Apellido materno"),
        fecha_nacimiento=pedir_fecha("Fecha de nacimiento"),
        telefono=pedir_int("Teléfono (9 dígitos, opcional)", obligatorio=False),
        sal_id=pedir_int("Código sistema de salud (ej. 10, 50, 110; opcional)",
                         obligatorio=False),
    )
    dao.crear(p)
    print("  ✔ Paciente creado.")


def op_actualizar(dao: PacienteDAO) -> None:
    actual = dao.obtener(pedir_int("RUN del paciente a modificar"))
    mostrar_paciente(actual)
    print("\n  Ingrese nuevos valores (Enter conserva el actual):")
    p = Paciente(
        run=actual["pac_run"],
        dv=actual["dv_run"],
        pnombre=pedir("Primer nombre", actual["pnombre"]),
        snombre=pedir("Segundo nombre", actual["snombre"]),
        apaterno=pedir("Apellido paterno", actual["apaterno"]),
        amaterno=pedir("Apellido materno", actual["amaterno"]),
        fecha_nacimiento=pedir_fecha("Fecha de nacimiento",
                                     actual["fecha_nacimiento"]),
        telefono=pedir_int("Teléfono", actual["telefono"], obligatorio=False),
        sal_id=pedir_int("Código sistema de salud", actual["sal_id"],
                         obligatorio=False),
    )
    dao.actualizar(p)
    print("  ✔ Paciente actualizado.")


def op_eliminar(dao: PacienteDAO) -> None:
    run = pedir_int("RUN del paciente a eliminar")
    mostrar_paciente(dao.obtener(run))
    if input("\n  ¿Confirma eliminación? (s/n): ").strip().lower() == "s":
        dao.eliminar(run)
        print("  ✔ Paciente eliminado.")
    else:
        print("  Operación cancelada.")


# ----------------------------------------------------------------------
# DEMO AUTOMÁTICA: recorre todo el CRUD, incluidos los errores de negocio
# ----------------------------------------------------------------------
def demo(dao: PacienteDAO) -> None:
    RUN_DEMO = 18765432
    RUN_CON_ATENCIONES = 6215470     # paciente de la BD con atenciones

    def paso(titulo):
        print(f"\n=== {titulo} ===")

    if dao.existe(RUN_DEMO):          # limpia ejecuciones anteriores
        dao.eliminar(RUN_DEMO)

    paso("1. CREATE")
    nuevo = Paciente(RUN_DEMO, dao.calcular_dv(RUN_DEMO), "camila", "andrea",
                     "rojas", "fuentes", date(1990, 5, 14), 987654321, 50)
    dao.crear(nuevo)
    print(f"  Creado {nuevo.run}-{nuevo.dv}")

    paso("2. READ (obtener)")
    mostrar_paciente(dao.obtener(RUN_DEMO))

    paso("3. UPDATE (teléfono y sistema de salud)")
    nuevo.telefono, nuevo.sal_id = 912345678, 20
    dao.actualizar(nuevo)
    mostrar_paciente(dao.obtener(RUN_DEMO))

    paso("4. READ (listar con filtro 'rojas')")
    mostrar_listado(dao.listar("rojas"))

    paso("5. Errores de negocio controlados por el package")
    pruebas = [
        ("RUN duplicado", lambda: dao.crear(nuevo)),
        ("DV incorrecto", lambda: dao.crear(
            Paciente(11111112, "9", "a", "b", "c", "d", date(2000, 1, 1)))),
        ("Salud inexistente", lambda: dao.actualizar(
            Paciente(**{**nuevo.__dict__, "sal_id": 999}))),
        ("Eliminar paciente con atenciones",
         lambda: dao.eliminar(RUN_CON_ATENCIONES)),
    ]
    for nombre, accion in pruebas:
        try:
            accion()
            print(f"  {nombre}: (no se produjo error)")
        except PacienteError as e:
            print(f"  {nombre}: {e}")

    paso("6. DELETE")
    dao.eliminar(RUN_DEMO)
    try:
        dao.obtener(RUN_DEMO)
    except PacienteError as e:
        print(f"  Eliminado. Verificación: {e}")


# ----------------------------------------------------------------------
# PROGRAMA PRINCIPAL
# ----------------------------------------------------------------------
MENU = """
========= CLÍNICA KETEKURA - PACIENTES =========
  1. Listar pacientes
  2. Buscar paciente por RUN
  3. Crear paciente
  4. Actualizar paciente
  5. Eliminar paciente
  6. Ejecutar demo automática
  0. Salir
================================================"""


def main() -> None:
    try:
        conn = conectar()
    except oracledb.DatabaseError as exc:
        print(f"No fue posible conectar a Oracle: {exc}")
        sys.exit(1)

    with conn:
        print(f"Conectado a Oracle {conn.version} como {DB_USER}")
        dao = PacienteDAO(conn)

        if "--demo" in sys.argv:
            demo(dao)
            return

        opciones = {"1": op_listar, "2": op_buscar, "3": op_crear,
                    "4": op_actualizar, "5": op_eliminar, "6": demo}
        while True:
            print(MENU)
            opcion = input("Opción: ").strip()
            if opcion == "0":
                break
            accion = opciones.get(opcion)
            if not accion:
                print("  Opción inválida.")
                continue
            try:
                accion(dao)
            except PacienteError as e:
                print(f"  ✘ {e}")
            except oracledb.DatabaseError as e:
                print(f"  ✘ Error de base de datos: {e}")


if __name__ == "__main__":
    main()
