from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request

from src.database import Database
from src.database_config import DatabaseConfig
from src.entrada import Entrada, EntradaInput, EntradaResolved
from src.entrada_dao import EntradaDAO
from src.mapper import entrada_from_entrada_input


@asynccontextmanager
async def lifespan(app: FastAPI):
    # source: https://fastapi.tiangolo.com/advanced/events/#lifespan
    db_config = DatabaseConfig()
    database = Database(db_config)

    if not database.connect():
        raise RuntimeError("No se puede conectar a la base de datos")

    with database.conexion:
        print(
            f"Connectado a OracleDB {database.conexion.version} como {db_config.service_name}."
        )
        app.state.dao = EntradaDAO(database.conexion)
        yield


app: FastAPI = FastAPI(title="BarrioTickera", lifespan=lifespan)


@app.get("/health")
def check_health():
    return {"status": "BarrioTickera-API online"}


@app.get("/entradas")
def get_all_entradas(request: Request) -> list[EntradaResolved]:
    dao: EntradaDAO = request.app.state.dao
    all_entradas: list[EntradaResolved] = dao.listar()
    return all_entradas


@app.get("/entradas/{id}")
def get_entrada_by_id(id: int, request: Request) -> EntradaResolved:
    dao: EntradaDAO = request.app.state.dao
    entrada: EntradaResolved = dao.obtener(id)
    if not entrada:
        raise HTTPException(status_code=404, detail="Entrada no encontrada")
    return entrada


@app.post("/entradas")
def crear_entrada(entradaInput: EntradaInput, request: Request) -> Entrada:
    # TODO: Quizás debería retornar EntradaResolved
    dao: EntradaDAO = request.app.state.dao
    nueva_entrada: Entrada = entrada_from_entrada_input(entradaInput)
    dao.crear(nueva_entrada)
    return nueva_entrada


@app.delete("/entradas/{id}")
def delete_entrada_by_id(id: int, request: Request) -> None:
    dao: EntradaDAO = app.state.dao
    dao.eliminar(id)
