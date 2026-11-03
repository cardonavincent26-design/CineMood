"""Crea el primer administrador.  Uso (desde la carpeta cinemood-api):
    python -m scripts.crear_admin correo@ejemplo.com "Nombre" "contraseña-segura"
"""
import sys

from sqlalchemy import text

from app.database import engine
from app.security import hashear

if len(sys.argv) != 4:
    sys.exit(__doc__)

correo, nombre, contrasena = sys.argv[1:]
with engine.begin() as db:
    db.execute(
        text(
            "INSERT INTO usuarios (nombre, edad, correo, contrasena_hash, rol) "
            "VALUES (:nombre, 18, :correo, :hash, 'admin')"
        ),
        {"nombre": nombre, "correo": correo, "hash": hashear(contrasena)},
    )
print("Administrador creado:", correo)
