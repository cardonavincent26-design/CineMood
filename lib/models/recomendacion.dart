import 'contenido.dart';

/// Un contenido junto con su porcentaje de compatibilidad (0-99), calculado por la API.
class Recomendacion {
  final Contenido contenido;
  final int compatibilidad;

  const Recomendacion({required this.contenido, required this.compatibilidad});

  factory Recomendacion.fromJson(Map<String, dynamic> j) => Recomendacion(
        contenido: Contenido.fromJson(j),
        compatibilidad: j['compatibilidad'] as int,
      );
}
