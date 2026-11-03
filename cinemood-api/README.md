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
