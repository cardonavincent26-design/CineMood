import 'package:flutter/foundation.dart';

import '../models/contenido.dart';
import '../models/estado_animo.dart';
import '../models/preferencias.dart';
import '../models/recomendacion.dart';
import '../models/usuario.dart';
import '../services/recomendacion_service.dart';

/// Estado compartido por varias pantallas: sesión, preferencias, mood,
/// lista personal e historial.
class AppProvider extends ChangeNotifier {
  final RecomendacionService _service = RecomendacionService();

  Usuario? usuario;
  Preferencias preferencias = const Preferencias();
  EstadoAnimo estadoAnimo = EstadoAnimo.feliz;

  final List<Contenido> _miLista = [];
  final List<Contenido> _historial = [];

  bool get haIniciadoSesion => usuario != null;
  List<Contenido> get miLista => List.unmodifiable(_miLista);
  List<Contenido> get historial => List.unmodifiable(_historial);
  List<Contenido> get catalogo => _service.obtenerCatalogo();

  /// Recomendaciones según el mood y preferencias actuales.
  List<Recomendacion> get recomendaciones =>
      _service.recomendar(estadoAnimo, preferencias);

  int compatibilidadDe(Contenido c) =>
      _service.calcularCompatibilidad(c, estadoAnimo, preferencias);

  // ---- Sesión (simulada; luego se conecta a la API con JWT) ----
  void iniciarSesion(String correo) {
    usuario = Usuario(nombre: 'Usuario', edad: 18, correo: correo);
    notifyListeners();
  }

  void registrar(String nombre, int edad, String correo) {
    usuario = Usuario(nombre: nombre, edad: edad, correo: correo);
    notifyListeners();
  }

  void cerrarSesion() {
    usuario = null;
    _miLista.clear();
    _historial.clear();
    notifyListeners();
  }

  // ---- Preferencias y mood ----
  void guardarPreferencias(Preferencias nuevas) {
    preferencias = nuevas;
    notifyListeners();
  }

  void cambiarEstadoAnimo(EstadoAnimo animo) {
    estadoAnimo = animo;
    notifyListeners();
  }

  // ---- Mi lista e historial ----
  bool estaEnLista(Contenido c) => _miLista.any((x) => x.id == c.id);

  void alternarEnLista(Contenido c) {
    if (estaEnLista(c)) {
      _miLista.removeWhere((x) => x.id == c.id);
    } else {
      _miLista.add(c);
    }
    notifyListeners();
  }

  void marcarComoVisto(Contenido c) {
    _historial.removeWhere((x) => x.id == c.id);
    _historial.insert(0, c);
    notifyListeners();
  }
}
