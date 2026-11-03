"""POST /auth/registro · POST /auth/login · GET /auth/me"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import text

from ..database import get_db
from ..deps import usuario_actual
from ..schemas import LoginIn, RegistroIn, TokenOut, UsuarioOut
from ..security import crear_token, hashear, verificar

router = APIRouter(prefix="/auth", tags=["Autenticación"])


@router.post("/registro", response_model=UsuarioOut, status_code=status.HTTP_201_CREATED)
def registro(datos: RegistroIn, db=Depends(get_db)):
    existe = db.execute(
        text("SELECT 1 FROM usuarios WHERE correo = :correo"), {"correo": datos.correo}
    ).first()
    if existe:
        raise HTTPException(status.HTTP_409_CONFLICT, "Ya existe una cuenta con ese correo")

    resultado = db.execute(
        text(
            "INSERT INTO usuarios (nombre, edad, correo, contrasena_hash) "
            "VALUES (:nombre, :edad, :correo, :hash)"
        ),
        {
            "nombre": datos.nombre.strip(),
            "edad": datos.edad,
            "correo": datos.correo,
            "hash": hashear(datos.contrasena),
        },
    )
    # Fila vacía de preferencias para que luego solo se actualice
    db.execute(
        text("INSERT INTO preferencias_usuario (usuario_id) VALUES (:id)"),
        {"id": resultado.lastrowid},
    )
    return UsuarioOut(
        id=resultado.lastrowid,
        nombre=datos.nombre.strip(),
        edad=datos.edad,
        correo=datos.correo,
        rol="usuario",
    )


@router.post("/login", response_model=TokenOut)
def login(datos: LoginIn, db=Depends(get_db)):
    fila = db.execute(
        text("SELECT id, contrasena_hash, rol, activo FROM usuarios WHERE correo = :correo"),
        {"correo": datos.correo},
    ).first()
    # Mismo mensaje si falla el correo o la contraseña: no revelar cuál fue
    if fila is None or not fila.activo or not verificar(datos.contrasena, fila.contrasena_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Correo o contraseña incorrectos")
    return TokenOut(access_token=crear_token(fila.id, fila.rol))


@router.get("/me", response_model=UsuarioOut)
def me(usuario: dict = Depends(usuario_actual)):
    return usuario
