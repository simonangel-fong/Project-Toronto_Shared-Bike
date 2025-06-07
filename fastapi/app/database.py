from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from app_settings import get_settings

settings = get_settings()

username = settings.ORCLDB_USER
password = settings.ORCLDB_PWD
host = settings.ORCLDB_HOST
port = settings.ORCLDB_PORT
service = settings.ORCLDB_SERVICE

engin = create_engine(
    f"oracle+oracledb://{username}:{password}@{host}:{port}/?service_name={service}"
)


def get_db():
    try:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")

        db = Session(bind=engin)
        yield db
    # handle sql database error
    except SQLAlchemyError as e:
        print(f"{timestamp}:  [Error]: {str(e)}")
        raise e
    # handle other error
    except Exception as e:
        print(f"{timestamp}:  [Error]: {str(e)}")
        raise e
    finally:
        # if db exist, close
        if db:
            db.close()
