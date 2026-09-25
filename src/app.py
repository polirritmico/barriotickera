from collections.abc import Callable

from oracledb import DatabaseError

from src.entrada import EntradaResolved
from src.entrada_dao import EntradaDAO
from src.exceptions import EntradaError

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

    opcion_salir = "0"

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

    def pedir(self, texto: str) -> str:
        while True:
            raw_text: str = input(f"  {texto}").strip()
            print()
            if raw_text:
                return raw_text
            print("    Campo obligatorio.")

    def pedir_opcional(self, texto: str) -> None | str:
        raw_text: str = input(f"  {texto}").strip()
        print()
        if raw_text:
            return raw_text
        else:
            return None

    def _print_cabecera(self) -> None:
        print(
            f"  {'ID':>6}  {'UBICACION':<15} {'QR':<15}  "
            f"{'ID_TIPO':>7} {'TIPO':<18} {'ID_EV':>6} {'EVENTO':<32} "
            f"{'ID_VENTA':>8} {'ID_EST':>6} {'ESTADO':<15}"
        )
        print("  " + "-" * 135)

    def _print_entrada(self, entrada: EntradaResolved) -> None:
        print(
            f"  {entrada.id or 'N/A':>6}  "
            f"{entrada.ubicacion:<15} "
            f"{entrada.qr:<15}  "
            f"{entrada.id_tipo_entrada:>7} "
            f"{entrada.tipo_entrada:<18} "
            f"{entrada.id_evento:>6} "
            f"{entrada.evento:<32} "
            f"{entrada.id_venta_entrada or 'N/A':>8} "
            f"{entrada.id_estado_entrada:>6} "
            f"{entrada.estado_entrada:<15}"
        )

    def print_listado(self, entradas: list[EntradaResolved]) -> None:
        if not entradas:
            print("  (sin resultados)")
            return

        self._print_cabecera()

        for entrada in entradas:
            self._print_entrada(entrada)

    def print_entrada(self, entrada: EntradaResolved) -> None:
        self._print_cabecera()
        self._print_entrada(entrada)

    def accion_listar(self) -> None:
        filtro = self.pedir_opcional("Filtro por ubicación: ")
        res: list[EntradaResolved] = self.dao.listar(filtro)
        self.print_listado(res)

    def accion_buscar(self) -> None:
        id = int(self.pedir("Id a buscar: "))
        res: EntradaResolved = self.dao.obtener(id)
        self.print_entrada(res)

    def accion_crear(self) -> None:
        print("crear")

    def accion_actualizar(self) -> None:
        print("actualizar")

    def accion_eliminar(self) -> None:
        print("eliminar")

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

                if seleccion_usuario == self.opcion_salir:
                    return

            except EntradaError as err:
                print(f"  ❌ {err}")
            except DatabaseError as err:
                print(f"  ❌ Error de base de datos: {err}")
