"""Dependencias: quién envía la petición (token) y si es administrador."""
import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import text

from .database import get_db
from .security import leer_token

esquema_bearer = HTTPBearer(auto_error=False)


def usuario_actual(
    credenciales: HTTPAuthorizationCredentials = Depends(esquema_bearer),
    db=Depends(get_db),
) -> dict:
    sin_acceso = HTTPException(
        status.HTTP_401_UNAUTHORIZED,
        "Token ausente, inválido o vencido",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if credenciales is None:
        raise sin_acceso
    try:
        datos = leer_token(credenciales.credentials)
        usuario_id = int(datos["sub"])
    except (jwt.PyJWTError, KeyError, ValueError):
        raise sin_acceso

    fila = db.execute(
        text("SELECT id, nombre, edad, correo, rol, activo FROM usuarios WHERE id = :id"),
        {"id": usuario_id},
    ).first()
    if fila is None or not fila.activo:
        raise sin_acceso
    return dict(fila._mapping)


def solo_admin(usuario: dict = Depends(usuario_actual)) -> dict:
    if usuario["rol"] != "admin":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Requiere rol de administrador")
    return usuario
