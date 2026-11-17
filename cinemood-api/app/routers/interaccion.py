"""Actividad del usuario: Mi lista, valoraciones (interés / desinterés) e historial."""
from typing import Literal, Optional

from fastapi import APIRouter, Depends, HTTPException, Response, status
from pydantic import BaseModel, Field
from sqlalchemy import text

from ..database import get_db
from ..deps import usuario_actual
from ..schemas import ContenidoOut
from .contenidos import SELECT_BASE

router = APIRouter(tags=["Mi actividad"])

SIN_CONTENIDO = dict(status_code=status.HTTP_204_NO_CONTENT, response_class=Response)


def _debe_existir(db, contenido_id: int) -> None:
    if db.execute(text("SELECT 1 FROM contenidos WHERE id = :i"), {"i": contenido_id}).first() is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Ese contenido no existe")


# ---------------------------------------------------------------- Mi lista (RF-012)
@router.get("/mi-lista", response_model=list[ContenidoOut])
def ver_lista(usuario: dict = Depends(usuario_actual), db=Depends(get_db)):
    filas = db.execute(
        text(
            SELECT_BASE
            + " JOIN mi_lista m ON m.contenido_id = c.id WHERE m.usuario_id = :u"
            " ORDER BY m.agregado_en DESC"
        ),
        {"u": usuario["id"]},
    ).all()
    return [dict(f._mapping) for f in filas]


@router.post("/mi-lista/{contenido_id}", **SIN_CONTENIDO)
def agregar_a_lista(contenido_id: int, usuario: dict = Depends(usuario_actual), db=Depends(get_db)):
    _debe_existir(db, contenido_id)
    # INSERT IGNORE: si ya estaba en la lista no hace nada (se puede repetir sin error)
    db.execute(
        text("INSERT IGNORE INTO mi_lista (usuario_id, contenido_id) VALUES (:u, :c)"),
        {"u": usuario["id"], "c": contenido_id},
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.delete("/mi-lista/{contenido_id}", **SIN_CONTENIDO)
def quitar_de_lista(contenido_id: int, usuario: dict = Depends(usuario_actual), db=Depends(get_db)):
    db.execute(
        text("DELETE FROM mi_lista WHERE usuario_id = :u AND contenido_id = :c"),
        {"u": usuario["id"], "c": contenido_id},
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# ------------------------------------------------------- Valoraciones (RF-011)
class ValoracionIn(BaseModel):
    interes: Optional[Literal["interesa", "no_interesa"]] = None
    puntaje: Optional[int] = Field(None, ge=1, le=5)


@router.put("/valoraciones/{contenido_id}", **SIN_CONTENIDO)
def valorar(
    contenido_id: int,
    datos: ValoracionIn,
    usuario: dict = Depends(usuario_actual),
    db=Depends(get_db),
):
    """Guarda si el contenido interesa o no (y/o un puntaje de 1 a 5). Se puede repetir."""
    _debe_existir(db, contenido_id)
    db.execute(
        text(
            "INSERT INTO valoraciones (usuario_id, contenido_id, puntaje, interes) "
            "VALUES (:u, :c, :p, :i) "
            "ON DUPLICATE KEY UPDATE puntaje = :p, interes = :i"
        ),
        {"u": usuario["id"], "c": contenido_id, "p": datos.puntaje, "i": datos.interes},
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.delete("/valoraciones/{contenido_id}", **SIN_CONTENIDO)
def quitar_valoracion(contenido_id: int, usuario: dict = Depends(usuario_actual), db=Depends(get_db)):
    """Deshace una valoración (por ejemplo, el botón 'deshacer' del swipe)."""
    db.execute(
        text("DELETE FROM valoraciones WHERE usuario_id = :u AND contenido_id = :c"),
        {"u": usuario["id"], "c": contenido_id},
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# ------------------------------------------------------------- Historial (RF-013)
@router.get("/historial", response_model=list[ContenidoOut])
def ver_historial(usuario: dict = Depends(usuario_actual), db=Depends(get_db)):
    filas = db.execute(
        text(
            SELECT_BASE
            + " JOIN historial h ON h.contenido_id = c.id WHERE h.usuario_id = :u"
            " ORDER BY h.visto_en DESC LIMIT 100"
        ),
        {"u": usuario["id"]},
    ).all()
    return [dict(f._mapping) for f in filas]


@router.post("/historial/{contenido_id}", **SIN_CONTENIDO)
def registrar_visto(contenido_id: int, usuario: dict = Depends(usuario_actual), db=Depends(get_db)):
    """Registra que el usuario vio el contenido; si ya estaba, solo actualiza la fecha."""
    _debe_existir(db, contenido_id)
    db.execute(
        text(
            "INSERT INTO historial (usuario_id, contenido_id) VALUES (:u, :c) "
            "ON DUPLICATE KEY UPDATE visto_en = CURRENT_TIMESTAMP"
        ),
        {"u": usuario["id"], "c": contenido_id},
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
