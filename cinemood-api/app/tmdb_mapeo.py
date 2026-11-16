"""Traduce datos de TMDB a nuestro modelo: géneros y afinidad con el estado de ánimo.

Python puro (sin red ni base de datos) para poder probarlo fácilmente.
TMDB no sabe de estados de ánimo, así que la afinidad se DERIVA del género (ver AFINIDAD_GENERO).
Esta tabla es una decisión de diseño del proyecto: conviene documentarla en el SRS.
"""
from typing import Optional

IMAGEN_BASE = "https://image.tmdb.org/t/p/w500"
MIN_VOTOS = 200  # catálogo base: ignora títulos con muy pocas votaciones (la nota no sería confiable)
MIN_VOTOS_BUSQUEDA = 20  # búsqueda bajo demanda: se acepta algo menos conocido

# Géneros que se agregan a los 6 originales (Acción, Comedia, Drama, Terror, Romance, Ciencia ficción)
GENEROS_NUEVOS = ["Animación", "Suspenso", "Fantasía"]

# id de género de TMDB -> nuestro género (películas y series usan algunos ids distintos)
GENERO_TMDB = {
    27: "Terror",
    878: "Ciencia ficción", 10765: "Ciencia ficción",   # 10765 = Sci-Fi & Fantasy (series)
    14: "Fantasía",
    16: "Animación",
    35: "Comedia",
    10749: "Romance",
    53: "Suspenso", 9648: "Suspenso", 80: "Suspenso",    # Thriller, Misterio, Crimen
    18: "Drama", 36: "Drama",                            # Drama, Historia
    28: "Acción", 10752: "Acción", 37: "Acción",         # Acción, Bélica, Western
    10759: "Acción", 10768: "Acción",                    # Action & Adventure, War & Politics (series)
}

# Si un título tiene varios géneros, el principal es el primero de esta lista (lo específico antes que lo genérico)
PRIORIDAD = ["Terror", "Animación", "Ciencia ficción", "Fantasía", "Romance",
             "Comedia", "Acción", "Suspenso", "Drama"]

# Qué tanto encaja cada género con cada estado de ánimo (0.0 a 1.0). Códigos = tabla estados_animo.
AFINIDAD_GENERO = {
    "Acción":          {"emocionado": 0.95, "enojado": 0.90, "curioso": 0.50, "feliz": 0.50, "nostalgico": 0.30},
    "Comedia":         {"feliz": 0.95, "tranquilo": 0.80, "nostalgico": 0.60, "triste": 0.60, "curioso": 0.30},
    "Drama":           {"triste": 0.90, "nostalgico": 0.70, "enojado": 0.60, "curioso": 0.60, "tranquilo": 0.50},
    "Terror":          {"conMiedo": 0.95, "emocionado": 0.70, "curioso": 0.60, "enojado": 0.40},
    "Romance":         {"nostalgico": 0.90, "feliz": 0.80, "tranquilo": 0.70, "triste": 0.70},
    "Ciencia ficción": {"curioso": 0.95, "emocionado": 0.80, "nostalgico": 0.60, "tranquilo": 0.30},
    "Animación":       {"feliz": 0.90, "nostalgico": 0.85, "tranquilo": 0.80, "triste": 0.60, "curioso": 0.50},
    "Suspenso":        {"curioso": 0.90, "emocionado": 0.80, "conMiedo": 0.70, "enojado": 0.50},
    "Fantasía":        {"curioso": 0.85, "emocionado": 0.80, "feliz": 0.70, "nostalgico": 0.70, "tranquilo": 0.60},
}
PESO_SECUNDARIO = 0.8  # los géneros secundarios cuentan un poco menos que el principal


def generos_nuestros(genre_ids: list[int]) -> list[str]:
    """Nuestros géneros para un título, el principal primero. Vacío si ninguno aplica."""
    encontrados = []
    for gid in genre_ids:
        nombre = GENERO_TMDB.get(gid)
        if nombre and nombre not in encontrados:
            encontrados.append(nombre)
    encontrados.sort(key=PRIORIDAD.index)
    return encontrados


def afinidad(generos: list[str]) -> dict[str, float]:
    """Afinidad por estado de ánimo: el mejor valor entre sus géneros (secundarios con menos peso)."""
    resultado: dict[str, float] = {}
    for i, genero in enumerate(generos):
        peso = 1.0 if i == 0 else PESO_SECUNDARIO
        for animo, valor in AFINIDAD_GENERO[genero].items():
            resultado[animo] = max(resultado.get(animo, 0.0), round(valor * peso, 2))
    return resultado


def preparar(item: dict, tipo: str, min_votos: int = MIN_VOTOS) -> Optional[dict]:
    """Convierte un elemento de las listas de TMDB (popular, top_rated) a nuestro formato.

    Devuelve None si no sirve (sin póster, sin sinopsis, pocas votaciones o sin género útil).
    Falta 'duracion_min', que viene del detalle del título.
    """
    titulo = item.get("title") if tipo == "pelicula" else item.get("name")
    fecha = item.get("release_date") if tipo == "pelicula" else item.get("first_air_date")
    generos = generos_nuestros(item.get("genre_ids") or [])

    if (
        not titulo
        or not item.get("overview")
        or not item.get("poster_path")
        or not fecha
        or len(fecha) < 4
        or (item.get("vote_count") or 0) < min_votos
        or not generos
    ):
        return None

    return {
        "tmdb_id": item["id"],
        "titulo": titulo[:200],
        "tipo": tipo,
        "genero": generos[0],
        "anio": int(fecha[:4]),
        "valoracion": min(5.0, round((item.get("vote_average") or 0) / 2, 1)),  # TMDB usa 0-10, nosotros 0-5
        "sinopsis": item["overview"],
        "imagen_url": IMAGEN_BASE + item["poster_path"],
        "afinidad": afinidad(generos),
    }


def minutos(detalle: dict, tipo: str) -> Optional[int]:
    """Duración en minutos: de la película, o por episodio en una serie."""
    if tipo == "pelicula":
        return detalle.get("runtime") or None
    por_episodio = (detalle.get("episode_run_time") or [None])[0]
    ultimo = (detalle.get("last_episode_to_air") or {}).get("runtime")
    return por_episodio or ultimo or 45  # si TMDB no informa duración de la serie, se usa 45 min
