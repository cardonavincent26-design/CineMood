import '../data/catalogo_data.dart';
import '../models/contenido.dart';
import '../models/estado_animo.dart';
import '../models/preferencias.dart';
import '../models/recomendacion.dart';

/// Servicio que calcula la compatibilidad entre el usuario y cada contenido.
/// Hoy trabaja con datos locales; luego se reemplaza por llamadas a la API.
///
/// Pesos (el estado de ánimo es el criterio más importante):
///   estado de ánimo 50 % · género 20 % · tiempo 15 % · valoración 15 %
class RecomendacionService {
  static const double _pesoAnimo = 0.50;
  static const double _pesoGenero = 0.20;
  static const double _pesoTiempo = 0.15;
  static const double _pesoValoracion = 0.15;

  List<Contenido> obtenerCatalogo() => catalogoInicial;

  int calcularCompatibilidad(
    Contenido c,
    EstadoAnimo animo,
    Preferencias prefs,
  ) {
    final afinidadAnimo = c.afinidadAnimo[animo.name] ?? 0.1;

    final afinidadGenero =
        prefs.generos.isEmpty ? 0.5 : (prefs.generos.contains(c.genero) ? 1.0 : 0.0);

    final afinidadTiempo = prefs.tiempo == null
        ? 0.5
        : (prefs.tiempo!.contiene(c.duracionMin) ? 1.0 : 0.0);

    final afinidadValoracion = c.valoracion / 5.0;

    final total = afinidadAnimo * _pesoAnimo +
        afinidadGenero * _pesoGenero +
        afinidadTiempo * _pesoTiempo +
        afinidadValoracion * _pesoValoracion;

    return (total * 100).round().clamp(0, 99);
  }

  /// Recomendaciones ordenadas de mayor a menor compatibilidad.
  List<Recomendacion> recomendar(EstadoAnimo animo, Preferencias prefs) {
    final lista = obtenerCatalogo()
        .where((c) => c.tipo == prefs.tipo)
        .map((c) => Recomendacion(
              contenido: c,
              compatibilidad: calcularCompatibilidad(c, animo, prefs),
            ))
        .toList()
      ..sort((a, b) => b.compatibilidad.compareTo(a.compatibilidad));
    return lista;
  }
}
