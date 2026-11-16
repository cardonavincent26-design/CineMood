"""Importa el catálogo base (los títulos más votados) de TMDB a la base de datos de CineMood.

Uso (desde la carpeta cinemood-api, con el entorno virtual activo):
    python -m scripts.importar_tmdb --probar                        # solo muestra, no escribe
    python -m scripts.importar_tmdb --peliculas 700 --series 300    # importa de verdad (unos minutos)

Se puede repetir cuantas veces quieras: actualiza lo que ya existe y no duplica.
Requiere TMDB_TOKEN en el archivo .env (el "API Read Access Token" de tu cuenta de TMDB).
"""
import argparse
import os
import sys

from dotenv import load_dotenv

from app.database import engine
from app.tmdb_cliente import crear_sesion, descargar_catalogo, guardar_titulos

load_dotenv()


def main() -> None:
    ap = argparse.ArgumentParser(description="Importa catálogo base desde TMDB")
    ap.add_argument("--peliculas", type=int, default=700)
    ap.add_argument("--series", type=int, default=300)
    ap.add_argument("--probar", action="store_true", help="solo mostrar, sin tocar la base de datos")
    args = ap.parse_args()

    token = os.getenv("TMDB_TOKEN")
    if not token:
        sys.exit("Falta TMDB_TOKEN en el archivo .env")

    sesion = crear_sesion(token)
    # Se descarga todo antes de escribir: si TMDB falla a la mitad, la base queda intacta
    titulos = descargar_catalogo(sesion, "pelicula", args.peliculas)
    titulos += descargar_catalogo(sesion, "serie", args.series)
    print(f"Descargados de TMDB: {len(titulos)} títulos")
    for t in titulos[:8]:
        print(f"  {t['tipo']:8} {t['titulo']} ({t['anio']}) · {t['genero']} · {t['duracion_min']} min · {t['valoracion']}")

    if args.probar:
        print("Modo --probar: no se escribió nada en la base de datos.")
        return
    with engine.begin() as db:
        guardar_titulos(db, titulos)
    print("Listo: catálogo guardado en MySQL.")


if __name__ == "__main__":
    main()
