from oracledb import DatabaseError


class EntradaError(Exception):
    def __init__(self, error: DatabaseError) -> None:
        (err,) = error.args
        self.codigo: int = err.code
        primera_linea: str = err.message.split("\n")[0]
        self.mensaje = primera_linea.split(": ", 1)[-1]
        super().__init__(self.mensaje)

    def __str__(self) -> str:
        return f"[{self.codigo}] {self.mensaje}"

    @staticmethod
    def es_error_de_negocio(exception: DatabaseError) -> bool:
        (error,) = exception.args
        return 20_000 <= error.code <= 20_999
