enum TipoContenido {
  pelicula('Películas'),
  serie('Series');

  final String etiqueta;
  const TipoContenido(this.etiqueta);
}

class Contenido {
  final int id;
  final String titulo;
  final TipoContenido tipo;
  final String genero;
  final int anio;
  final int duracionMin;
  final double valoracion;
  final String sinopsis;

  /// Cuánto encaja con cada estado de ánimo (0.0 a 1.0), por nombre del enum.
  final Map<String, double> afinidadAnimo;

  const Contenido({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.genero,
    required this.anio,
    required this.duracionMin,
    required this.valoracion,
    required this.sinopsis,
    required this.afinidadAnimo,
  });
}
