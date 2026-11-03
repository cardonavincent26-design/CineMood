"""Contraseñas (bcrypt) y tokens JWT."""
from datetime import datetime, timedelta, timezone

import bcrypt
import jwt

from .config import JWT_ALGORITMO, JWT_EXPIRA_MINUTOS, JWT_SECRET


def hashear(contrasena: str) -> str:
    return bcrypt.hashpw(contrasena.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verificar(contrasena: str, hash_guardado: str) -> bool:
    try:
        return bcrypt.checkpw(contrasena.encode("utf-8"), hash_guardado.encode("utf-8"))
    except ValueError:
        return False


def crear_token(usuario_id: int, rol: str) -> str:
    vence = datetime.now(timezone.utc) + timedelta(minutes=JWT_EXPIRA_MINUTOS)
    datos = {"sub": str(usuario_id), "rol": rol, "exp": vence}
    return jwt.encode(datos, JWT_SECRET, algorithm=JWT_ALGORITMO)


def leer_token(token: str) -> dict:
    """Lanza jwt.PyJWTError si el token es inválido o venció."""
    return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITMO])
