import oracledb

from src.database_config import DatabaseConfig


class Database:
    def __init__(self, config: DatabaseConfig):
        self.config = config

    def connect(self) -> oracledb.Connection:
        pass
