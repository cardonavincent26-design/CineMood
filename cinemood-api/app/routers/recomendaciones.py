"""GET /recomendaciones y GET /compatibilidad/{id}: la compatibilidad se calcula aquí, no en la app."""
from typing import Literal, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import text

from ..database import get_db
from ..deps import usuario_actual
from ..recomendador import calcular_compatibilidad
from ..schemas import RecomendacionOut

router = APIRouter(tags=["Recomendaciones"], dependencies=[Depends(usuario_actual)])

# Los códigos son los de la tabla estados_animo (iguales al enum de Flutter)
EstadoAnimo = Literal[
    "feliz", "tranquilo", "emocionado", "nostalgico",
    "enojado", "triste", "curioso", "conMiedo",
]
Tiempo = Literal["menos30", "de30a60", "de60a120", "mas120"]

SUBCONSULTA_ANIMO = "(SELECT id FROM estados_animo WHERE codigo = :animo)"


def _validar_generos(db, generos: list[str]) -> None:
    """Validar contra la base de datos: así un admin puede agregar géneros sin tocar el código."""
    if not generos:
        return
    validos = {f.nombre for f in db.execute(text("SELECT nombre FROM generos"))}
    invalidos = [g for g in generos if g not in validos]
    if invalidos:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_ENTITY,
            f"Género(s) no válido(s): {invalidos}. Géneros disponibles: {sorted(validos)}",
        )


@router.get("/recomendaciones", response_model=list[RecomendacionOut])
def recomendar(
    animo: EstadoAnimo = Query(..., description="Estado de ánimo actual"),
    tipo: Literal["pelicula", "serie"] = "pelicula",
    tiempo: Optional[Tiempo] = Query(None, description="Tiempo disponible"),
    generos: list[str] = Query([], description="Géneros de interés (repite el parámetro)"),
    limite: int = Query(20, ge=1, le=100),
    db=Depends(get_db),
):
    _validar_generos(db, generos)
    filas = db.execute(
        text(
            f"""
            SELECT c.id, c.titulo, c.tipo, g.nombre AS genero, c.anio,
                   c.duracion_min, c.valoracion, c.sinopsis, c.imagen_url,
                   a.afinidad
            FROM contenidos c
            JOIN generos g ON g.id = c.genero_id
            LEFT JOIN afinidad_animo a
                   ON a.contenido_id = c.id AND a.estado_animo_id = {SUBCONSULTA_ANIMO}
            WHERE c.tipo = :tipo
            """
        ),
        {"animo": animo, "tipo": tipo},
    ).all()

    resultado = []
    for f in filas:
        item = dict(f._mapping)
        afinidad = item.pop("afinidad")
        item["compatibilidad"] = calcular_compatibilidad(
            afinidad, item["genero"], item["duracion_min"], item["valoracion"], generos, tiempo
        )
        resultado.append(item)

    resultado.sort(key=lambda r: r["compatibilidad"], reverse=True)
    return resultado[:limite]


@router.get("/compatibilidad/{contenido_id}")
def compatibilidad(
    contenido_id: int,
    animo: EstadoAnimo = Query(...),
    tiempo: Optional[Tiempo] = None,
    generos: list[str] = Query([]),
    db=Depends(get_db),
):
    """Compatibilidad de UN contenido con el ánimo y las preferencias del usuario."""
    _validar_generos(db, generos)
    f = db.execute(
        text(
            f"""
            SELECT g.nombre AS genero, c.duracion_min, c.valoracion, a.afinidad
            FROM contenidos c
            JOIN generos g ON g.id = c.genero_id
            LEFT JOIN afinidad_animo a
                   ON a.contenido_id = c.id AND a.estado_animo_id = {SUBCONSULTA_ANIMO}
            WHERE c.id = :id
            """
        ),
        {"animo": animo, "id": contenido_id},
    ).first()
    if f is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Ese contenido no existe")
    return {
        "compatibilidad": calcular_compatibilidad(
            f.afinidad, f.genero, f.duracion_min, f.valoracion, generos, tiempo
        )
    }
