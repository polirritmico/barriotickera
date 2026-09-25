import os
from dataclasses import dataclass


@dataclass(frozen=True)
class DatabaseConfig:
    user: str = os.getenv("DB_USER", "TICKETERA_APP")
    password: str = os.getenv("DB_PASSWORD", "PasswordSeguro")
    host: str = os.getenv("DB_HOST", "localhost")
    port: int = int(os.getenv("DB_PORT", "1521"))
    service_name: str = os.getenv("DB_SERVICE", "FREEPDB1")

    @property
    def dsn(self) -> str:
        """Data Source Name"""
        return f"{self.host}:{self.port}/{self.service_name}"
