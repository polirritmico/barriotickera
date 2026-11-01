from dataclasses import dataclass


@dataclass(frozen=True)
class Entrada:
    id: int
    ubicacion: str
    qr: str
    id_tipo_entrada: int
    tipo_entrada: str
    id_evento: int
    evento: str
    id_venta_entrada: int | None
    id_estado_entrada: int
    estado_entrada: str

    def __str__(self) -> str:
        return f"{self._cabecera()}\n{self._str_data()}"

    def _str_data(self) -> str:
        return (
            f"  {self.id or 'N/A':>6}  "
            f"{self.ubicacion:<15} "
            f"{self.qr:<15}  "
            f"{self.id_tipo_entrada:>7} "
            f"{self.tipo_entrada:<18} "
            f"{self.id_evento:>6} "
            f"{self.evento:<32} "
            f"{self.id_venta_entrada or 'N/A':>8} "
            f"{self.id_estado_entrada:>6} "
            f"{self.estado_entrada:<15}"
        )

    @classmethod
    def _cabecera(cls) -> str:
        ret: str = (
            f"  {'ID':>6}  {'UBICACION':<15} {'QR':<15}  "
            f"{'ID_TIPO':>7} {'TIPO':<18} {'ID_EV':>6} {'EVENTO':<32} "
            f"{'ID_VENTA':>8} {'ID_EST':>6} {'ESTADO':<15}"
        )
        ret += "\n  " + "-" * 135
        return ret

    @classmethod
    def print_listado(cls, entradas: list[Entrada]) -> None:
        if not entradas:
            print("  (sin resultados)")
            return

        print(cls._cabecera())
        for entrada in entradas:
            print(entrada._str_data())
