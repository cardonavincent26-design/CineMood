"""Cálculo de compatibilidad. Mismos pesos que tenía la app Flutter (recomendacion_service.dart).

   estado de ánimo 50 % · género 20 % · tiempo 15 % · valoración 15 %
Es Python puro (sin FastAPI ni base de datos) para poder probarlo fácilmente.
"""
from typing import Optional

PESO_ANIMO = 0.50
PESO_GENERO = 0.20
PESO_TIEMPO = 0.15
PESO_VALORACION = 0.15

# Rangos de tiempo disponible en minutos (mismos que RangoTiempo en Flutter)
RANGOS_TIEMPO = {
    "menos30": (0, 30),
    "de30a60": (30, 60),
    "de60a120": (60, 120),
    "mas120": (120, 1000),
}


def calcular_compatibilidad(
    afinidad_animo: Optional[float],
    genero: str,
    duracion_min: int,
    valoracion: float,
    generos_preferidos: list[str],
    tiempo: Optional[str],
) -> int:
    """Devuelve un porcentaje entero de 0 a 99."""
    a_animo = 0.1 if afinidad_animo is None else float(afinidad_animo)

    if not generos_preferidos:
        a_genero = 0.5
    else:
        a_genero = 1.0 if genero in generos_preferidos else 0.0

    if tiempo is None:
        a_tiempo = 0.5
    else:
        minimo, maximo = RANGOS_TIEMPO[tiempo]
        a_tiempo = 1.0 if minimo <= duracion_min <= maximo else 0.0

    a_valoracion = float(valoracion) / 5.0

    total = (
        a_animo * PESO_ANIMO
        + a_genero * PESO_GENERO
        + a_tiempo * PESO_TIEMPO
        + a_valoracion * PESO_VALORACION
    )
    # +0.5 y int(): redondeo "normal" (igual que .round() de Dart), no el redondeo del banquero
    return max(0, min(99, int(total * 100 + 0.5)))
