import oracledb

from src.database_config import DatabaseConfig


class Database:
    conexion: oracledb.Connection

    def __init__(self, config: DatabaseConfig):
        self.config: DatabaseConfig = config

    def connect(self) -> oracledb.Connection | None:
        try:
            print("Conectando a la DB...")
            self.conexion = oracledb.connect(
                user=self.config.user,
                password=self.config.password,
                dsn=self.config.dsn,
            )
        except oracledb.DatabaseError as err:
            print(f"Falló conexión con la base de datos:\n{err}")
            return None

        return self.conexion
