from collections.abc import Callable

from oracledb import DatabaseError

from src.entrada import Entrada, EntradaResolved
from src.entrada_dao import EntradaDAO
from src.entrada_prints import print_entrada, print_listado
from src.exceptions import EntradaError
from src.inputs_usuario import (
    pedir_numero,
    pedir_numero_opcional,
    pedir_texto,
    pedir_texto_opcional,
)

AccionMenu = Callable[[], None]


class App:
    TEXT_MENU = """
========= BarrioTickera - Entradas =========
1. Listar entradas
2. Buscar entrada por id
3. Crear entrada
4. Actualizar entrada
5. Eliminar entrada
6. Ejecutar demo automática

0. Salir
============================================"""

    ESTADO_ENTRADA_DISPONIBLE = 1
    OPCION_SALIR = "0"

    def __init__(self, dao: EntradaDAO) -> None:
        self.dao: EntradaDAO = dao
        self.opciones_menu: dict[str, AccionMenu] = {
            "1": self.accion_listar,
            "2": self.accion_buscar,
            "3": self.accion_crear,
            "4": self.accion_actualizar,
            "5": self.accion_eliminar,
            "6": self.accion_demo,
            "0": self.accion_salir,
        }

    def accion_listar(self) -> None:
        filtro = pedir_texto_opcional("-> Filtro por ubicación/qr (opcional)")
        res: list[EntradaResolved] = self.dao.listar(filtro)
        print_listado(res)

    def accion_buscar(self) -> None:
        id = int(pedir_numero("Id a buscar"))
        res: EntradaResolved = self.dao.obtener(id)
        print_entrada(res)

    def accion_crear(self) -> None:
        print("Creando una nueva entrada. Ingrese los datos requeridos.\n")
        nueva_entrada = Entrada(
            ubicacion=pedir_texto("Ubicación"),
            qr=pedir_texto("Código QR"),
            id_tipo_entrada=pedir_numero("ID tipo entrada"),
            id_evento=pedir_numero("ID evento"),
            id_venta_entrada=None,
            id_estado_entrada=self.ESTADO_ENTRADA_DISPONIBLE,
        )
        self.dao.crear(nueva_entrada)
        print(f"Nueva entrada registrada con id: {nueva_entrada.id}")

    def accion_actualizar(self) -> None:
        actual: EntradaResolved = self.dao.obtener(
            pedir_numero("Ingrese ID de la entrada")
        )
        print_entrada(actual)

        print("\nIngrese nuevos valores (<Enter> para conservar el actual): ")
        nueva_entrada = Entrada(
            id=actual.id,
            ubicacion=pedir_texto_opcional("Ubicación") or actual.ubicacion,
            qr=pedir_texto_opcional("QR") or actual.qr,
            id_tipo_entrada=pedir_numero_opcional("ID tipo entrada")
            or actual.id_tipo_entrada,
            id_evento=pedir_numero_opcional("ID evento") or actual.id_evento,
            id_venta_entrada=pedir_numero_opcional("ID venta entrada")
            or actual.id_venta_entrada,
            id_estado_entrada=pedir_numero_opcional("ID estado entrada")
            or actual.id_estado_entrada,
        )
        self.dao.actualizar(nueva_entrada)
        print("  ✔ Entrada actualizada correctamente.")

    def accion_eliminar(self) -> None:
        id = pedir_numero("ID de la entrada a eliminar")
        entrada: EntradaResolved = self.dao.obtener(id)
        print_entrada(entrada)

        msg = "\n  ¿Confirma la eliminación? (s/n): "
        if input(msg).strip().lower() == "s":
            self.dao.eliminar(id)
            print("  ✔ Entrada eliminada.")
        else:
            print("  Operación cancelada.")

    def accion_demo(self) -> None:
        print("demo")

    def accion_salir(self) -> None:
        print("Cerrando...")

    def ejecutar_seleccion(self, seleccion: str) -> None:
        seleccion_actual: AccionMenu | None = self.opciones_menu.get(seleccion, None)
        if not seleccion_actual:
            print("Selección incorrecta. Vuelva a intentarlo")
        else:
            seleccion_actual()

    def menu(self) -> None:
        while True:
            print(self.TEXT_MENU)
            seleccion_usuario: str = input("Selección: ").strip()

            try:
                self.ejecutar_seleccion(seleccion_usuario)

                if seleccion_usuario == self.OPCION_SALIR:
                    return

            except EntradaError as err:
                print(f"  ❌ {err}")
            except DatabaseError as err:
                print(f"  ❌ Error de base de datos: {err}")
