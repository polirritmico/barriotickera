from oracledb import Connection, DatabaseError

from src.entrada import Entrada
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

    def _query(
        self, procedimiento: str, parametros: list[str | int | None]
    ) -> list[dict]:
        with self.conn.cursor() as cur, self.conn.cursor() as ref_cursor:
            try:
                cur.callproc(procedimiento, parametros + [ref_cursor])
            except DatabaseError as err:
                if EntradaError.es_error_de_negocio(err):
                    raise EntradaError(err) from err
                else:
                    raise

            cols: list = [col[0].lower() for col in ref_cursor.description]
            return [dict(zip(cols, row)) for row in ref_cursor]

    # def existe(self, id: int) -> bool:
    #     with self.conn.cursor() as cur:
    #         return cur.callfunc("pkg_entrada.fn_existe", int, [run]) > 0

    def listar(self, filtro: str | None = None) -> list[dict]:
        return self._query("pkg_entrada.sp_listar_entrada", [filtro])

    def obtener(self, id: int) -> dict:
        # TODO: Implementar
        return self._query("pkg_entrada.sp_listar_entrada", [id])[0]

    def crear(self, entrada: Entrada) -> None:
        self._execute(
            "pkg_entrada.sp_insertar_entrada",
            list(vars(entrada).values()),
        )
