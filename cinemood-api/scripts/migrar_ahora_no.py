"""Migración: agrega el interés 'ahora_no' y el ánimo de cada decisión a la tabla valoraciones.

Uso (desde cinemood-api, con el entorno activo; usa la base que indique DATABASE_URL):
    python -m scripts.migrar_ahora_no

Se puede repetir sin problema. Ejecútalo ANTES de subir el código nuevo del servidor.
La primera vez, además, convierte los descartes antiguos ('no_interesa') en 'ahora_no',
porque antes deslizar a la izquierda era permanente y ahora solo oculta 7 días.
"""
from sqlalchemy import text

from app.database import engine

INFO = (
    "FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() "
    "AND TABLE_NAME = 'valoraciones' AND COLUMN_NAME = '{col}'"
)


def main() -> None:
    with engine.begin() as db:
        tipo = str(db.execute(text("SELECT COLUMN_TYPE " + INFO.format(col="interes"))).scalar())
        tiene_animo = db.execute(text("SELECT COUNT(*) " + INFO.format(col="animo_id"))).scalar()

        if "ahora_no" not in tipo:
            db.execute(text(
                "ALTER TABLE valoraciones MODIFY interes ENUM('interesa','no_interesa','ahora_no') NULL"
            ))
            print("Se agregó el valor 'ahora_no' a valoraciones.interes")

        if not tiene_animo:
            db.execute(text(
                "ALTER TABLE valoraciones ADD COLUMN animo_id TINYINT UNSIGNED NULL, "
                "ADD CONSTRAINT fk_valoraciones_animo FOREIGN KEY (animo_id) REFERENCES estados_animo(id)"
            ))
            print("Se agregó la columna valoraciones.animo_id")
            convertidas = db.execute(text(
                "UPDATE valoraciones SET interes = 'ahora_no', actualizado_en = actualizado_en "
                "WHERE interes = 'no_interesa'"
            )).rowcount
            print(f"Descartes antiguos convertidos a 'ahora_no': {convertidas}")
    print("Migración lista.")


if __name__ == "__main__":
    main()
