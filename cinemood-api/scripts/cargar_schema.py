"""Crea las tablas de CineMood en la base que indique DATABASE_URL (pensado para Aiven).

Uso (desde la carpeta cinemood-api, con el entorno virtual activo):
    python -m scripts.cargar_schema

- No ejecuta CREATE DATABASE / USE: usa la base que ya trae la URL (en Aiven, 'defaultdb').
- No carga los 10 títulos de ejemplo: el catálogo se importa después con scripts.importar_tmdb.
- Si las tablas ya existen, se detiene con un aviso y no borra nada.
"""
import re
import sys
from pathlib import Path

from sqlalchemy import text

from app.database import engine

SALTAR = ("CREATE DATABASE", "USE ", "INSERT INTO CONTENIDOS", "INSERT INTO AFINIDAD_ANIMO")


def sentencias(sql: str) -> list[str]:
    """Divide schema.sql en sentencias (cada una termina con ';' al final de una línea)."""
    sin_comentarios = [re.sub(r"--.*$", "", linea) for linea in sql.splitlines()]
    bloques, actual = [], []
    for linea in sin_comentarios:
        actual.append(linea)
        if linea.rstrip().endswith(";"):
            bloques.append("\n".join(actual).strip())
            actual = []
    return [b for b in bloques if b]


def main() -> None:
    ruta = Path(__file__).resolve().parent.parent / "schema.sql"
    pendientes = [
        s for s in sentencias(ruta.read_text(encoding="utf-8"))
        if not s.upper().startswith(SALTAR)
    ]
    with engine.begin() as db:
        ya_hay = db.execute(text(
            "SELECT COUNT(*) FROM information_schema.TABLES "
            "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'usuarios'"
        )).scalar()
        if ya_hay:
            sys.exit("Esta base ya tiene tablas de CineMood. No se hizo nada.")
        for s in pendientes:
            db.execute(text(s))
    print(f"Listo: {len(pendientes)} sentencias ejecutadas (tablas y datos iniciales).")


if __name__ == "__main__":
    main()
