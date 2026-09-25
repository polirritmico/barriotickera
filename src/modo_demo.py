from src.entrada import Entrada
from src.entrada_dao import EntradaDAO


class ModoDemo:
    def __init__(self, dao: EntradaDAO) -> None:
        self.dao = dao

    def print_header(self, titulo: str) -> None:
        decoracion = "\n=== {} ==="
        print(decoracion.format(titulo))

    def run(self) -> None:
        self.print_header("1. CREATE")

        nueva_entrada = Entrada(
            ubicacion="Sector Test",
            qr="QR123456",
            id_tipo_entrada=1,
            id_evento=1,
            id_venta_entrada=1,
            id_estado_entrada=1,
        )
        self.dao.crear(nueva_entrada)
        print(f"  Creado {nueva_entrada.id}")

        self.print_header("2. READ (obtener)")
