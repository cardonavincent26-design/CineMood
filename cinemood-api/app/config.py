"""Configuración leída de variables de entorno (en Render: sección Environment)."""
import os

from dotenv import load_dotenv

load_dotenv()


def _requerida(nombre: str) -> str:
    valor = os.getenv(nombre)
    if not valor:
        raise RuntimeError(f"Falta la variable de entorno {nombre}. Revisa tu archivo .env")
    return valor


DATABASE_URL = _requerida("DATABASE_URL")
JWT_SECRET = _requerida("JWT_SECRET")
JWT_ALGORITMO = "HS256"
JWT_EXPIRA_MINUTOS = int(os.getenv("JWT_EXPIRA_MINUTOS", "120"))
CORS_ORIGINS = [o.strip() for o in os.getenv("CORS_ORIGINS", "").split(",") if o.strip()]
