from typing import Literal

from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configuration settings for the BarrioTickera API and Oracle Database."""

    app_name: str = "Ticketera API"
    env: Literal["development", "testing", "production"] = "development"
    debug: bool = False
    version: str = "1.0.0"
    api_v1_prefix: str = "/api/v1"

    db_user: str = "TICKETERA_APP"
    db_password: SecretStr = SecretStr("PasswordSeguro")
    db_host: str = "localhost"
    db_port: int = 1521
    db_service: str = "FREEPDB1"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    @property
    def dsn(self) -> str:
        """Constructs the Data Source Name for Oracle DB."""
        return f"{self.db_host}:{self.db_port}/{self.db_service}"
