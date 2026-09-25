#!/usr/bin/env python

from database import Database
from database_config import DatabaseConfig


def main():
    db_config = DatabaseConfig()
    database = Database(db_config)
    database.connect()


if __name__ == "__main__":
    main()
