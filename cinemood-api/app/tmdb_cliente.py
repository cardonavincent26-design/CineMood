"""Cliente de TMDB y guardado en MySQL.

Lo usan scripts/importar_tmdb.py (catálogo base) y el endpoint GET /tmdb/buscar (búsqueda bajo demanda).
"""
import time
from typing import Callable, Optional

import requests
from sqlalchemy import text

from .tmdb_mapeo import GENEROS_NUEVOS, MIN_VOTOS, MIN_VOTOS_BUSQUEDA, minutos, preparar

API = "https://api.themoviedb.org/3"
RUTA = {"pelicula": "movie", "serie": "tv"}  # película y serie usan rutas distintas en TMDB


def crear_sesion(token: str) -> requests.Session:
    sesion = requests.Session()
    sesion.headers.update({"Authorization": f"Bearer {token}", "Accept": "application/json"})
    return sesion


def pedir(sesion: requests.Session, ruta: str, **params) -> dict:
    """GET a TMDB con reintentos si responde 429 (demasiadas peticiones)."""
    params.setdefault("language", "es-ES")
    for _ in range(5):
        r = sesion.get(API + ruta, params=params, timeout=20)
        if r.status_code == 429:
            time.sleep(int(r.headers.get("Retry-After", 2)))
            continue
        r.raise_for_status()
        return r.json()
    raise RuntimeError(f"TMDB respondió 429 demasiadas veces en {ruta}")


def con_duracion(sesion, item: dict, tipo: str, min_votos: int = MIN_VOTOS) -> Optional[dict]:
    """Convierte un item de TMDB a nuestro formato, pidiendo el detalle para la duración."""
    datos = preparar(item, tipo, min_votos)
    if datos is None:
        return None
    duracion = minutos(pedir(sesion, f"/{RUTA[tipo]}/{item['id']}"), tipo)
    if duracion is None:
        return None
    datos["duracion_min"] = duracion
    return datos


def descargar_catalogo(sesion, tipo: str, cantidad: int) -> list[dict]:
    """Los 'cantidad' títulos con más votos de TMDB que cumplan los filtros de calidad."""
    resultado: list[dict] = []
    vistos: set[int] = set()
    pagina, total = 1, 1
    while len(resultado) < cantidad and pagina <= min(total, 500):  # TMDB solo da hasta 500 páginas
        datos = pedir(sesion, f"/discover/{RUTA[tipo]}", page=pagina,
                      sort_by="vote_count.desc", **{"vote_count.gte": MIN_VOTOS})
        total = datos.get("total_pages", 1)
        for item in datos["results"]:
            if len(resultado) >= cantidad:
                break
            if item["id"] in vistos:
                continue
            vistos.add(item["id"])
            titulo = con_duracion(sesion, item, tipo)
            time.sleep(0.05)  # no saturar a TMDB
            if titulo:
                resultado.append(titulo)
        print(f"  {tipo}: página {pagina} · {len(resultado)}/{cantidad}")
        pagina += 1
    return resultado


def buscar_en_tmdb(sesion, q: str, tipo: Optional[str],
                   existe: Callable[[str, int], bool], limite: int = 8) -> list[tuple]:
    """Busca por texto. Devuelve [(tipo, tmdb_id, datos)] en orden; datos=None si ya está en nuestra base."""
    resultado = []
    for t in ([tipo] if tipo else ["pelicula", "serie"]):
        for item in pedir(sesion, f"/search/{RUTA[t]}", query=q, page=1)["results"][:limite]:
            if existe(t, item["id"]):
                resultado.append((t, item["id"], None))
                continue
            datos = con_duracion(sesion, item, t, MIN_VOTOS_BUSQUEDA)
            if datos:
                resultado.append((t, item["id"], datos))
    return resultado


# ---------------------------------------------------------------- base de datos
def asegurar_estructura(db) -> None:
    """Agrega contenidos.tmdb_id y su índice único (tipo, tmdb_id). Es seguro repetirlo."""
    tiene_columna = db.execute(text(
        "SELECT COUNT(*) FROM information_schema.COLUMNS "
        "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contenidos' AND COLUMN_NAME = 'tmdb_id'"
    )).scalar()
    if not tiene_columna:
        db.execute(text("ALTER TABLE contenidos ADD COLUMN tmdb_id INT UNSIGNED NULL"))
    indices = {f.nombre for f in db.execute(text(
        "SELECT DISTINCT INDEX_NAME AS nombre FROM information_schema.STATISTICS "
        "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contenidos'"
    ))}
    if "tmdb_id" in indices:  # índice único antiguo: chocaba entre películas y series con el mismo id
        db.execute(text("ALTER TABLE contenidos DROP INDEX tmdb_id"))
    if "uq_tipo_tmdb" not in indices:
        db.execute(text("ALTER TABLE contenidos ADD UNIQUE KEY uq_tipo_tmdb (tipo, tmdb_id)"))


def ya_existe(db, tipo: str, tmdb_id: int) -> bool:
    return db.execute(
        text("SELECT 1 FROM contenidos WHERE tipo = :t AND tmdb_id = :i"), {"t": tipo, "i": tmdb_id}
    ).first() is not None


def guardar_titulos(db, titulos: list[dict]) -> None:
    """Inserta o actualiza títulos y sus afinidades. 'db' es una conexión de SQLAlchemy."""
    if not titulos:
        return
    asegurar_estructura(db)
    for nombre in GENEROS_NUEVOS:
        db.execute(text("INSERT IGNORE INTO generos (nombre) VALUES (:n)"), {"n": nombre})
    id_genero = {f.nombre: f.id for f in db.execute(text("SELECT id, nombre FROM generos"))}
    id_animo = {f.codigo: f.id for f in db.execute(text("SELECT id, codigo FROM estados_animo"))}

    for t in titulos:
        valores = {
            "tmdb": t["tmdb_id"], "titulo": t["titulo"], "tipo": t["tipo"],
            "genero": id_genero[t["genero"]], "anio": t["anio"], "dur": t["duracion_min"],
            "val": t["valoracion"], "sin": t["sinopsis"], "img": t["imagen_url"],
        }
        cid = db.execute(
            text("SELECT id FROM contenidos WHERE tipo = :tipo AND tmdb_id = :tmdb"), valores
        ).scalar()
        if cid:
            db.execute(text(
                "UPDATE contenidos SET titulo=:titulo, genero_id=:genero, anio=:anio, "
                "duracion_min=:dur, valoracion=:val, sinopsis=:sin, imagen_url=:img WHERE id=:cid"
            ), {**valores, "cid": cid})
        else:
            cid = db.execute(text(
                "INSERT INTO contenidos (tmdb_id, titulo, tipo, genero_id, anio, duracion_min, "
                "valoracion, sinopsis, imagen_url) "
                "VALUES (:tmdb, :titulo, :tipo, :genero, :anio, :dur, :val, :sin, :img)"
            ), valores).lastrowid
        db.execute(text("DELETE FROM afinidad_animo WHERE contenido_id = :c"), {"c": cid})
        for codigo, valor in t["afinidad"].items():
            db.execute(text(
                "INSERT INTO afinidad_animo (contenido_id, estado_animo_id, afinidad) VALUES (:c, :a, :v)"
            ), {"c": cid, "a": id_animo[codigo], "v": valor})
