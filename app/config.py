from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "STL Backend API"
    database_url: str
    debug: bool = False
    version: str = "1.0.0"
    cors_origins: list[str] = ["*"]
    cors_credentials: bool = True
    cors_methods: list[str] = ["GET", "POST", "PUT", "DELETE"]
    cors_headers: list[str] = ["*", "Authorization", "Content-Type"]

    class Config:
        env_file = ".env.local"

settings = Settings()