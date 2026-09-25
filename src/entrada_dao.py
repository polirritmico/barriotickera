from oracledb import DB_TYPE_NUMBER, Connection, DatabaseError, DbType

from src.entrada import Entrada, EntradaResolved
from src.exceptions import EntradaError


class EntradaDAO:
    def __init__(self, conn: Connection) -> None:
        self.conn = conn

    def _execute(
        self, procedimiento: str, parametros: list[str | int | None | DbType]
    ) -> list | tuple:
        try:
            with self.conn.cursor() as cur:
                params_procesados = []
                for p in parametros:
                    if isinstance(p, (type, DbType)):
                        params_procesados.append(cur.var(p))
                    else:
                        params_procesados.append(p)

                output: list | tuple = cur.callproc(procedimiento, params_procesados)
            self.conn.commit()
            return output

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

    def listar(self, filtro: str | None = None) -> list[EntradaResolved]:
        res: list[dict] = self._query("pkg_entrada.listar_entradas", [filtro])
        return [EntradaResolved(**raw_entrada) for raw_entrada in res]

    def obtener(self, id: int) -> EntradaResolved:
        res: list[dict] = self._query("pkg_entrada.obtener_entrada", [id])
        entrada = EntradaResolved(**res[0])
        return entrada

    def crear(self, entrada: Entrada) -> list | tuple:
        output: list | tuple = self._execute(
            "pkg_entrada.crear_entrada",
            [
                entrada.ubicacion,
                entrada.qr,
                entrada.id_tipo_entrada,
                entrada.id_evento,
                entrada.id_venta_entrada,
                entrada.id_estado_entrada,
                DB_TYPE_NUMBER,  # pos 6 (0-idx)
            ],
        )
        entrada.id = output[6]
        return output

    def actualizar(self, entrada: Entrada | EntradaResolved) -> None:
        self._execute(
            "pkg_entrada.actualizar_entrada",
            [
                entrada.id,
                entrada.ubicacion,
                entrada.qr,
                entrada.id_tipo_entrada,
                entrada.id_evento,
                entrada.id_venta_entrada,
                entrada.id_estado_entrada,
            ],
        )

    def eliminar(self, id: int) -> None:
        self._execute("pkg_entrada.eliminar_entrada", [id])
