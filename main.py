#!/usr/bin/env python
import os
import sys

from src.database import Database
from src.database_config import DatabaseConfig
from src.entrada_dao import EntradaDAO
from src.modo_demo import ModoDemo


def main():
    modo_demo = "--demo" in sys.argv
    print(f"=== BarrioTickera{"-DEMO" if modo_demo else ""} ===")
    db_config = DatabaseConfig()
    database = Database(db_config)
    if not database.connect():
        os.exit(1)

    with database.conexion:
        db_version = database.connection.version
        print(f"Conectado a OracleDB {db_version} como {db_config.service_name}")
        dao = EntradaDAO(database)


if __name__ == "__main__":
    main()
