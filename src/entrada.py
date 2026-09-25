from dataclasses import dataclass


@dataclass(kw_only=True)
class Entrada:
    id: int | None = None
    ubicacion: str
    qr: str
    id_tipo_entrada: int
    id_evento: int
    id_venta_entrada: int | None = None
    id_estado_entrada: int


@dataclass(frozen=True)
class EntradaResolved:
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
