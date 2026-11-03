"""Punto de entrada de la API de CineMood.  Ejecutar:  uvicorn app.main:app --reload"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import CORS_ORIGINS
from .routers import auth, contenidos, recomendaciones

app = FastAPI(title="CineMood API", version="0.1.0")

# Permite que el panel web (Vue.js) llame a la API desde otro origen
if CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=CORS_ORIGINS,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(auth.router)
app.include_router(contenidos.router)
app.include_router(recomendaciones.router)


@app.get("/", tags=["Estado"])
def raiz():
    """Comprueba que la API está encendida (no requiere token)."""
    return {"estado": "ok", "api": "CineMood"}
