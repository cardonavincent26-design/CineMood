"""Formas de los JSON que entran y salen de la API."""
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class RegistroIn(BaseModel):
    nombre: str = Field(min_length=1, max_length=100)
    edad: int = Field(ge=1, le=120)
    correo: EmailStr
    contrasena: str = Field(min_length=8, max_length=72)  # bcrypt solo usa 72 bytes


class LoginIn(BaseModel):
    correo: EmailStr
    contrasena: str = Field(min_length=1, max_length=72)


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UsuarioOut(BaseModel):
    id: int
    nombre: str
    edad: int
    correo: str
    rol: str


class ContenidoOut(BaseModel):
    id: int
    titulo: str
    tipo: str
    genero: str
    anio: int
    duracion_min: int
    valoracion: float
    sinopsis: str
    imagen_url: Optional[str] = None
