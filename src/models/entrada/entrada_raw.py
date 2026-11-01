from dataclasses import dataclass


@dataclass(kw_only=True)
class EntradaRaw:
    id: int | None = None
    ubicacion: str
    qr: str
    id_tipo_entrada: int
    id_evento: int
    id_venta_entrada: int | None = None
    id_estado_entrada: int
