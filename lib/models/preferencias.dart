import 'contenido.dart';

/// Rangos de tiempo disponible, en minutos.
enum RangoTiempo {
  menos30('<30 min', 0, 30),
  de30a60('30–60', 30, 60),
  de60a120('60–120', 60, 120),
  mas120('+120', 120, 1000);

  final String etiqueta;
  final int min;
  final int max;
  const RangoTiempo(this.etiqueta, this.min, this.max);

  bool contiene(int minutos) => minutos >= min && minutos <= max;
}

class Preferencias {
  final Set<String> generos;
  final TipoContenido tipo;
  final RangoTiempo? tiempo;

  const Preferencias({
    this.generos = const {},
    this.tipo = TipoContenido.pelicula,
    this.tiempo,
  });

  Preferencias copyWith({
    Set<String>? generos,
    TipoContenido? tipo,
    RangoTiempo? tiempo,
  }) =>
      Preferencias(
        generos: generos ?? this.generos,
        tipo: tipo ?? this.tipo,
        tiempo: tiempo ?? this.tiempo,
      );
}
