import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    ENVIROMENT = os.getenv("AEON_ENV", "development")
    SECRET_KEY = os.getenv("SECRET_KEY", "VbRkVKHw0rEBaVayLc6n1P34bIk91oN6")
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DB_URI", "postgresql://aeon:aeon@localhost/aeon"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False


class Test(Config):
    ENVIROMENT = "test"
    SQLALCHEMY_DATABASE_URI = "postgresql://aeon:aeon@postgres/test"
