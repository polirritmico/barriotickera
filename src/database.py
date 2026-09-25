import oracledb

from src.database_config import DatabaseConfig


class Database:
    def __init__(self, config: DatabaseConfig):
        self.config = config

    def connect(self) -> oracledb.Connection:
        return oracledb.connect(
            user=self.config.user,
            password=self.config.password,
            dsn=self.config.dsn,
        )
