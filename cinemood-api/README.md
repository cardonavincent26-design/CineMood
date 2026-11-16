# CineMood API (FastAPI + MySQL)

## Ejecutar en tu computador
```bash
python -m venv .venv
.venv\Scripts\activate          # Windows   (Linux/Mac: source .venv/bin/activate)
pip install -r requirements.txt
copy .env.example .env          # y edita DATABASE_URL y JWT_SECRET
mysql -u root -p < schema.sql   # crea la base y los datos iniciales
uvicorn app.main:app --reload
```
- API: http://localhost:8000  ·  Documentación interactiva: http://localhost:8000/docs
- Primer admin: `python -m scripts.crear_admin admin@cinemood.app "Admin" "UnaClaveSegura1"`

## Probar en Postman
1. `POST /auth/registro` — Body JSON: `{"nombre":"Ana","edad":20,"correo":"ana@mail.com","contrasena":"clave12345"}` → 201
2. `POST /auth/login` — `{"correo":"ana@mail.com","contrasena":"clave12345"}` → 200 con `access_token`
3. `GET /contenidos` — Header `Authorization: Bearer <token>` → 200. Sin token → 401.
4. `GET /contenidos/999` → 404 · registro repetido → 409

## Despliegue (como en la guía de clase)
- Render (Web Service): Build `pip install -r requirements.txt` · Start `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- Variables de entorno en Render: `DATABASE_URL`, `JWT_SECRET`, `JWT_EXPIRA_MINUTOS`, `CORS_ORIGINS`
- Aiven (MySQL): usa su cadena de conexión; normalmente exige SSL, agrega `?ssl_ca=...` o consulta su guía.

## Catálogo desde TMDB
1. Crea una cuenta en themoviedb.org, solicita una API key (uso no comercial) y copia el **API Read Access Token**.
2. Agrégalo a tu `.env`: `TMDB_TOKEN=...` (ejemplo en `.env.example`).
3. Instala lo nuevo: `pip install -r requirements.txt`
4. Prueba sin escribir nada: `python -m scripts.importar_tmdb --probar --peliculas 20 --series 10`
5. Importa el catálogo base (~1.000 títulos, tarda unos minutos):
   `python -m scripts.importar_tmdb --peliculas 700 --series 300`
   Se puede repetir: actualiza lo existente sin duplicar (hazlo al menos cada 6 meses, regla de TMDB).
   Opcional, para quitar los 10 títulos de ejemplo sin póster: `DELETE FROM contenidos WHERE tmdb_id IS NULL;`
6. **Búsqueda bajo demanda:** `GET /tmdb/buscar?q=inception` busca en TMDB cualquier título que no esté en
   la base, lo guarda (con su afinidad por género) y lo devuelve. La siguiente búsqueda ya no llama a TMDB.

TMDB no tiene estados de ánimo: la afinidad se deriva del género (tabla `AFINIDAD_GENERO` en `app/tmdb_mapeo.py`).

**Atribución obligatoria:** mostrar el logo de TMDB y el aviso "This product uses the TMDB API but is not
endorsed or certified by TMDB." en una sección "Acerca de" / "Créditos" de la app.
