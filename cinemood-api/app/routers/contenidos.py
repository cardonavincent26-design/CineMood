"""GET /contenidos (con búsqueda y filtros) · GET /contenidos/{id} · GET /generos"""
from typing import Literal, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import text

from ..database import get_db
from ..deps import usuario_actual
from ..schemas import ContenidoOut

router = APIRouter(tags=["Catálogo"], dependencies=[Depends(usuario_actual)])

SELECT_BASE = """
    SELECT c.id, c.titulo, c.tipo, g.nombre AS genero, c.anio,
           c.duracion_min, c.valoracion, c.sinopsis, c.imagen_url
    FROM contenidos c
    JOIN generos g ON g.id = c.genero_id
"""


@router.get("/contenidos", response_model=list[ContenidoOut])
def listar(
    q: Optional[str] = Query(None, description="Texto a buscar en el título"),
    tipo: Optional[Literal["pelicula", "serie"]] = None,
    genero: Optional[str] = Query(None, description="Nombre del género, ej. Drama"),
    duracion_max: Optional[int] = Query(None, ge=1),
    valoracion_min: Optional[float] = Query(None, ge=0, le=5),
    limite: int = Query(50, ge=1, le=100),
    desde: int = Query(0, ge=0),
    db=Depends(get_db),
):
    condiciones, params = [], {"limite": limite, "desde": desde}
    if q:
        condiciones.append("c.titulo LIKE :q")
        params["q"] = f"%{q}%"
    if tipo:
        condiciones.append("c.tipo = :tipo")
        params["tipo"] = tipo
    if genero:
        condiciones.append("g.nombre = :genero")
        params["genero"] = genero
    if duracion_max is not None:
        condiciones.append("c.duracion_min <= :duracion_max")
        params["duracion_max"] = duracion_max
    if valoracion_min is not None:
        condiciones.append("c.valoracion >= :valoracion_min")
        params["valoracion_min"] = valoracion_min

    sql = SELECT_BASE
    if condiciones:
        sql += " WHERE " + " AND ".join(condiciones)
    sql += " ORDER BY c.valoracion DESC, c.titulo LIMIT :limite OFFSET :desde"
    filas = db.execute(text(sql), params).all()
    return [dict(f._mapping) for f in filas]


@router.get("/contenidos/{contenido_id}", response_model=ContenidoOut)
def detalle(contenido_id: int, db=Depends(get_db)):
    fila = db.execute(text(SELECT_BASE + " WHERE c.id = :id"), {"id": contenido_id}).first()
    if fila is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Ese contenido no existe")
    return dict(fila._mapping)


@router.get("/generos", response_model=list[str])
def generos(db=Depends(get_db)):
    return [f.nombre for f in db.execute(text("SELECT nombre FROM generos ORDER BY nombre"))]
