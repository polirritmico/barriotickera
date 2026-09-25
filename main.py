#!/usr/bin/env python

from src.database import Database
from src.database_config import DatabaseConfig


def main():
    print("=== BarrioTickera ===")
    db_config = DatabaseConfig()
    database = Database(db_config)
    database.connect()


if __name__ == "__main__":
    main()
