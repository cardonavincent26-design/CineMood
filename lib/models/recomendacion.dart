import 'contenido.dart';

/// Un contenido junto con su porcentaje de compatibilidad (0-100).
class Recomendacion {
  final Contenido contenido;
  final int compatibilidad;

  const Recomendacion({required this.contenido, required this.compatibilidad});
}
