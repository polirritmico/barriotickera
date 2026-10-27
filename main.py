#!/usr/bin/env python

import sys

from fastapi import FastAPI

import src.api.v1.controllers.app_builder as app_builder
import src.logs as logs
from src.app import App
from src.config import get_settings
from src.database import Database
from src.database_config import DatabaseConfig
from src.entrada_dao import EntradaDAO
from src.modo_demo import ModoDemo


def main() -> None:
    modo_demo = "--demo" in sys.argv
    print(f"=== BarrioTickera{"-DEMO" if modo_demo else ""} ===")

    db_config = DatabaseConfig()
    database = Database(db_config)

    if not database.connect():
        sys.exit(1)

    with database.conexion:
        db_version = database.conexion.version
        print(f"Conectado a OracleDB {db_version} como {db_config.service_name}")

        dao = EntradaDAO(database.conexion)
        try:
            if modo_demo:
                ModoDemo(dao).run()
            else:
                App(dao).menu()
        except KeyboardInterrupt:
            print("\nOperación cancelada por el usuario.")


if __name__ == "__main__":
    main()
