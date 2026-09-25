from collections.abc import Callable

from oracledb import DatabaseError

from src.entrada import Entrada, EntradaResolved
from src.entrada_dao import EntradaDAO
from src.entrada_prints import print_entrada, print_listado
from src.exceptions import EntradaError


class ModoDemo:
    def __init__(self, dao: EntradaDAO) -> None:
        self.dao = dao

    def print_header(self, titulo: str) -> None:
        decoracion = "\n>>> {}\n"
        print(decoracion.format(titulo))

    def run(self) -> None:
        try:
            self.demo_script()
        except EntradaError as err:
            print(f"\n  ❌ {err}")
        except DatabaseError as err:
            print(f"\n  ❌ Error de base de datos: {err}")

    def demo_script(self) -> None:
        self.print_header("1. CREATE")

        nueva_entrada = Entrada(
            ubicacion="Sector Test",
            qr="QR-123456",
            id_tipo_entrada=1,
            id_evento=1,
            id_venta_entrada=1,
            id_estado_entrada=1,
        )
        self.dao.crear(nueva_entrada)
        assert nueva_entrada.id, "Inesperado: nueva entrada no asignó id"
        print(f"  Creada una nueva entrada con id {nueva_entrada.id} (asignado por BD)")

        self.print_header("2. READ (obtener)")
        entrada_resuelta: EntradaResolved = self.dao.obtener(nueva_entrada.id)
        print_entrada(entrada_resuelta)

        self.print_header("3. UPDATE (ubicacion y estado)")
        nueva_entrada.ubicacion = "Sector VIP DEMO"
        nueva_entrada.id_estado_entrada = 2
        self.dao.actualizar(nueva_entrada)

        filtro_sector = "Sector VIP DEMO"
        self.print_header(f"4. READ (listar con filtro '{filtro_sector}')")
        resultados: list[EntradaResolved] = self.dao.listar(filtro_sector)
        print_listado(resultados)

        self.print_header("5. Errores de negocio controlados por el package")
        pruebas: list[tuple[str, Callable]] = [
            (
                "QR duplicado",
                lambda: self.dao.crear(
                    Entrada(
                        ubicacion="Sector Test",
                        qr="QR-123456",
                        id_tipo_entrada=1,
                        id_evento=1,
                        id_venta_entrada=None,
                        id_estado_entrada=1,
                    )
                ),
            ),
            (
                "QR obligatorio",
                lambda: self.dao.crear(
                    Entrada(
                        ubicacion="Sector Test",
                        qr="   ",
                        id_tipo_entrada=1,
                        id_evento=1,
                        id_venta_entrada=None,
                        id_estado_entrada=1,
                    )
                ),
            ),
            (
                "Referencia inexistente",
                lambda: self.dao.actualizar(
                    Entrada(
                        id=nueva_entrada.id,
                        ubicacion="Sector VIP",
                        qr="QR-123456",
                        id_tipo_entrada=999,
                        id_evento=1,
                        id_venta_entrada=1,
                        id_estado_entrada=2,
                    )
                ),
            ),
            ("Entrada no encontrada", lambda: self.dao.obtener(999999)),
        ]

        for nombre, accion in pruebas:
            try:
                accion()
                print(f"  {nombre}: (no se produjo error)")
            except EntradaError as err:
                print(f"  {nombre}: {err}")

            self.print_header("6. DELETE (eliminar)")
            self.dao.eliminar(nueva_entrada.id)
            try:
                self.dao.obtener(nueva_entrada.id)
            except EntradaError as err:
                print(f"  Eliminado. Verificación: {err}")
