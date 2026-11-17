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

  /// URL del póster (viene de TMDB). Puede ser null.
  final String? imagenUrl;

  /// Póster en tamaño grande (TMDB ofrece el mismo archivo en varios anchos).
  String? get imagenGrande => imagenUrl?.replaceFirst('/w500/', '/w780/');

  /// Solo lo usa el catálogo de ejemplo antiguo (data/catalogo_data.dart); la API ya no lo envía.
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
    this.imagenUrl,
    this.afinidadAnimo = const {},
  });

  factory Contenido.fromJson(Map<String, dynamic> j) => Contenido(
        id: j['id'] as int,
        titulo: j['titulo'] as String,
        tipo: TipoContenido.values.firstWhere((t) => t.name == j['tipo']),
        genero: j['genero'] as String,
        anio: j['anio'] as int,
        duracionMin: j['duracion_min'] as int,
        valoracion: (j['valoracion'] as num).toDouble(),
        sinopsis: j['sinopsis'] as String,
        imagenUrl: j['imagen_url'] as String?,
      );
}
