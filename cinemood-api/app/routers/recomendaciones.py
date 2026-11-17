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
    excluir_decididos: bool = Query(
        True, description="Oculta lo guardado, lo 'no me interesa nunca' y lo pospuesto ('ahora no') 7 días con el mismo ánimo"
    ),
    usuario: dict = Depends(usuario_actual),
    db=Depends(get_db),
):
    _validar_generos(db, generos)

    union, filtro = "", ""
    params = {"animo": animo, "tipo": tipo}
    if excluir_decididos:
        union = (
            "LEFT JOIN valoraciones v ON v.contenido_id = c.id AND v.usuario_id = :uid "
            "LEFT JOIN mi_lista ml ON ml.contenido_id = c.id AND ml.usuario_id = :uid "
        )
        # Se oculta lo que está en Mi lista, lo marcado "no me interesa nunca" y lo pospuesto
        # ("ahora no") en los últimos 7 días con este mismo ánimo. COALESCE evita que un NULL
        # (sin valoración) deje fuera al contenido.
        filtro = (
            " AND ml.contenido_id IS NULL"
            " AND NOT COALESCE(v.interes = 'no_interesa' OR (v.interes = 'ahora_no'"
            " AND v.actualizado_en >= NOW() - INTERVAL 7 DAY"
            f" AND (v.animo_id IS NULL OR v.animo_id = {SUBCONSULTA_ANIMO})), FALSE)"
        )
        params["uid"] = usuario["id"]

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
            {union}
            WHERE c.tipo = :tipo{filtro}
            """
        ),
        params,
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
