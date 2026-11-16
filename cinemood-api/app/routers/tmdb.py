"""GET /tmdb/buscar: busca en TMDB un título que quizá no esté en nuestra base, lo guarda y lo devuelve."""
from typing import Literal, Optional

import requests
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import text

from ..config import TMDB_TOKEN
from ..database import get_db
from ..deps import usuario_actual
from ..schemas import ContenidoOut
from ..tmdb_cliente import buscar_en_tmdb, crear_sesion, guardar_titulos, ya_existe
from .contenidos import SELECT_BASE

router = APIRouter(tags=["TMDB"], dependencies=[Depends(usuario_actual)])


@router.get("/tmdb/buscar", response_model=list[ContenidoOut])
def buscar(
    q: str = Query(..., min_length=2, max_length=100, description="Título a buscar"),
    tipo: Optional[Literal["pelicula", "serie"]] = None,
    db=Depends(get_db),
):
    """Los títulos nuevos se guardan en la base, así que la próxima búsqueda ya no llama a TMDB."""
    if not TMDB_TOKEN:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "La búsqueda en TMDB no está configurada")
    try:
        encontrados = buscar_en_tmdb(
            crear_sesion(TMDB_TOKEN), q, tipo, existe=lambda t, i: ya_existe(db, t, i)
        )
    except requests.RequestException:
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, "TMDB no respondió, intenta de nuevo")

    guardar_titulos(db, [datos for _, _, datos in encontrados if datos])

    salida = []
    for t, tmdb_id, _ in encontrados:
        fila = db.execute(
            text(SELECT_BASE + " WHERE c.tipo = :t AND c.tmdb_id = :i"), {"t": t, "i": tmdb_id}
        ).first()
        if fila:
            salida.append(dict(fila._mapping))
    return salida
