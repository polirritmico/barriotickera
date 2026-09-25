from dataclasses import dataclass


@dataclass
class Entrada:
    id: int
    ubicacion: str
    qr: str
    id_tipo_entrada: int
    id_evento: int
    id_venta_entrada: int
    id_estado_entrada: int
    # tipo_entrada: str
    # evento: id
    # venta_entrada: str
    # estado_entrada: str
