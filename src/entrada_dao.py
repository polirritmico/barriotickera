from oracledb import Connection, DatabaseError

from src.exceptions import EntradaError


class EntradaDAO:
    def __init__(self, conn: Connection):
        self.conn = conn

    def _execute(self, procedimiento: str, parametros: list[str | int]) -> None:
        try:
            with self.conn.cursor() as cur:
                cur.callproc(procedimiento, parametros)
            self.conn.commit()

        except DatabaseError as err:
            self.conn.rollback()

            if EntradaError.es_error_de_negocio(err):
                raise EntradaError(err) from err
            else:
                raise
