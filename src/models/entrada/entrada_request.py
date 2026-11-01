from dataclasses import dataclass


@dataclass(frozen=True)
class EntradaRequest:
    ubicacion: str
    id_tipo_entrada: int
    id_evento: int
