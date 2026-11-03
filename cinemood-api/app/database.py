"""Conexión a MySQL. Cada petición recibe una conexión y se confirma (commit) al terminar bien."""
from sqlalchemy import create_engine

from .config import DATABASE_URL

engine = create_engine(DATABASE_URL, pool_pre_ping=True, pool_recycle=280)


def get_db():
    # begin() hace commit si todo sale bien y rollback si se lanza una excepción
    with engine.begin() as conexion:
        yield conexion
