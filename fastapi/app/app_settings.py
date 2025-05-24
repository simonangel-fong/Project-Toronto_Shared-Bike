from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict

ENV_FILE='../env/fastapi.env'

class Settings(BaseSettings):

    ORCLDB_HOST: str
    ORCLDB_SID: str
    ORCLDB_PORT: str
    ORCLDB_SERVICE: str
    ORCLDB_USER: str
    ORCLDB_PWD: str

    model_config = SettingsConfigDict(
        # env_file=ENV_FILE # dev: using env file
        )


@lru_cache
def get_settings():
    return Settings()
