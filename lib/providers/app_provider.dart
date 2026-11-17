import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contenido.dart';
import '../models/estado_animo.dart';
import '../models/preferencias.dart';
import '../models/recomendacion.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../utils/navegador.dart';
import '../utils/rutas.dart';

/// Una decisión tomada al deslizar una tarjeta (para poder deshacerla).
class _Decision {
  final Recomendacion recomendacion;
  final bool guardado;
  const _Decision(this.recomendacion, this.guardado);
}

/// Estado compartido por varias pantallas: sesión, preferencias, mood y recomendaciones.
/// Los datos (catálogo, compatibilidad, Mi lista, historial, valoraciones) viven en la API.
class AppProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  Usuario? usuario;
  Preferencias preferencias = const Preferencias();
  EstadoAnimo estadoAnimo = EstadoAnimo.feliz;

  List<String> generos = [];

  /// El "mazo" de tarjetas: la primera es la que se ve arriba.
  List<Recomendacion> recomendaciones = [];
  bool cargandoRecomendaciones = false;
  String? errorRecomendaciones;
  int _versionRecomendaciones = 0;
  final Map<int, int> _compatibilidades = {};

  final List<_Decision> _pila = []; // decisiones del swipe, para deshacer
  final Set<int> _decididos = {}; // ids ya deslizados en esta sesión

  final List<Contenido> _miLista = [];
  final List<Contenido> _historial = [];
  bool _datosCargados = false;

  static const _claveToken = 'token';
  static const _claveUsuario = 'usuario';

  AppProvider() {
    api.alSesionVencida = _sesionVencida;
  }

  bool get haIniciadoSesion => usuario != null;
  bool get puedeDeshacer => _pila.isNotEmpty;
  List<Contenido> get miLista => List.unmodifiable(_miLista);
  List<Contenido> get historial => List.unmodifiable(_historial);

  // ---- Sesión (JWT guardado en el celular) ----
  /// Al abrir la app: si hay un token guardado y no ha vencido, entra sin pedir login.
  Future<void> restaurarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_claveToken);
    final datos = prefs.getString(_claveUsuario);
    if (token == null || datos == null || _tokenVencido(token)) {
      await prefs.remove(_claveToken);
      await prefs.remove(_claveUsuario);
      return;
    }
    api.token = token;
    usuario = Usuario.fromJson(jsonDecode(datos) as Map<String, dynamic>);
  }

  bool _tokenVencido(String token) {
    try {
      final carga = utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1])));
      final exp = (jsonDecode(carga) as Map<String, dynamic>)['exp'] as int;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp;
    } catch (_) {
      return true;
    }
  }

  Future<void> iniciarSesion(String correo, String contrasena) async {
    final token = await api.iniciarSesion(correo, contrasena);
    api.token = token;
    usuario = await api.perfil();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveToken, token);
    await prefs.setString(_claveUsuario, jsonEncode(usuario!.toJson()));
    notifyListeners();
  }

  Future<void> registrar(String nombre, int edad, String correo, String contrasena) async {
    await api.registrar(nombre, edad, correo, contrasena);
    await iniciarSesion(correo, contrasena);
  }

  Future<void> cerrarSesion() async {
    api.token = null;
    usuario = null;
    recomendaciones = [];
    errorRecomendaciones = null;
    _compatibilidades.clear();
    _pila.clear();
    _decididos.clear();
    _miLista.clear();
    _historial.clear();
    _datosCargados = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveToken);
    await prefs.remove(_claveUsuario);
    notifyListeners();
  }

  /// La API respondió 401: el token venció. Se cierra la sesión y se vuelve al login.
  void _sesionVencida() {
    if (usuario == null) return;
    cerrarSesion();
    navegadorKey.currentState?.pushNamedAndRemoveUntil(Rutas.login, (_) => false);
  }

  // ---- Catálogos y datos del usuario ----
  Future<void> cargarGeneros() async {
    if (generos.isNotEmpty) return;
    try {
      generos = await api.generos();
      notifyListeners();
    } on ApiException {
      // Se reintenta la próxima vez que una pantalla los pida.
    }
  }

  /// Carga Mi lista e historial desde la API (una sola vez por sesión).
  Future<void> cargarDatosUsuario() async {
    if (usuario == null || _datosCargados) return;
    _datosCargados = true;
    try {
      final resultados = await Future.wait([api.miLista(), api.historial()]);
      _miLista
        ..clear()
        ..addAll(resultados[0]);
      _historial
        ..clear()
        ..addAll(resultados[1]);
      notifyListeners();
    } on ApiException {
      _datosCargados = false; // se reintenta la próxima vez
    }
  }

  // ---- Recomendaciones (las calcula la API) ----
  Future<void> cargarRecomendaciones() async {
    if (usuario == null) return;
    final mia = ++_versionRecomendaciones;
    cargandoRecomendaciones = true;
    errorRecomendaciones = null;
    notifyListeners();
    try {
      final r = await api.recomendaciones(estadoAnimo, preferencias);
      if (mia != _versionRecomendaciones) return; // llegó una petición más nueva
      recomendaciones = r.where((x) => !_decididos.contains(x.contenido.id)).toList();
    } on ApiException catch (e) {
      if (mia != _versionRecomendaciones) return;
      recomendaciones = [];
      errorRecomendaciones = e.mensaje;
    }
    cargandoRecomendaciones = false;
    notifyListeners();
  }

  /// Compatibilidad de un contenido con el mood y las preferencias actuales.
  Future<int> compatibilidadDe(Contenido c) async {
    final enCache = _compatibilidades[c.id];
    if (enCache != null) return enCache;
    for (final r in recomendaciones) {
      if (r.contenido.id == c.id) return r.compatibilidad;
    }
    final valor = await api.compatibilidad(c.id, estadoAnimo, preferencias);
    _compatibilidades[c.id] = valor;
    return valor;
  }

  // ---- Swipe: derecha = guardar, izquierda = descartar ----
  /// Devuelve un mensaje de error (si no se pudo guardar) o null si todo salió bien.
  Future<String?> decidir(Recomendacion rec, {required bool guardar}) async {
    final decision = _Decision(rec, guardar);
    final id = rec.contenido.id;
    recomendaciones = recomendaciones.where((r) => r.contenido.id != id).toList();
    _decididos.add(id);
    _pila.add(decision);
    if (guardar && !estaEnLista(rec.contenido)) _miLista.insert(0, rec.contenido);
    notifyListeners();

    try {
      if (guardar) await api.agregarALista(id);
      // Izquierda = "ahora no": se oculta con este mood por 7 días, luego puede volver.
      await api.valorar(id, guardar ? 'interesa' : 'ahora_no', animo: estadoAnimo.name);
    } on ApiException catch (e) {
      // No se pudo guardar: la tarjeta vuelve al mazo.
      _pila.remove(decision);
      _decididos.remove(id);
      if (guardar) _miLista.removeWhere((x) => x.id == id);
      recomendaciones = [rec, ...recomendaciones];
      notifyListeners();
      return e.mensaje;
    }

    // Se está acabando el mazo: se piden más (la API ya no devuelve las decididas).
    if (recomendaciones.length < 4 && !cargandoRecomendaciones) cargarRecomendaciones();
    return null;
  }

  Future<String?> deshacer() async {
    if (_pila.isEmpty) return null;
    final d = _pila.removeLast();
    final id = d.recomendacion.contenido.id;
    _decididos.remove(id);
    recomendaciones = [d.recomendacion, ...recomendaciones.where((r) => r.contenido.id != id)];
    if (d.guardado) _miLista.removeWhere((x) => x.id == id);
    notifyListeners();
    try {
      await api.quitarValoracion(id);
      if (d.guardado) await api.quitarDeLista(id);
    } on ApiException catch (e) {
      return e.mensaje;
    }
    return null;
  }

  /// "No me interesa nunca": se oculta de las recomendaciones para siempre.
  Future<String?> noMeInteresaNunca(Contenido c) async {
    try {
      await api.valorar(c.id, 'no_interesa', animo: estadoAnimo.name);
    } on ApiException catch (e) {
      return e.mensaje;
    }
    recomendaciones = recomendaciones.where((r) => r.contenido.id != c.id).toList();
    _decididos.add(c.id);
    notifyListeners();
    return null;
  }

  // ---- Preferencias y mood ----
  void guardarPreferencias(Preferencias nuevas) {
    preferencias = nuevas;
    _compatibilidades.clear();
    notifyListeners();
    cargarRecomendaciones();
  }

  void cambiarEstadoAnimo(EstadoAnimo animo) {
    estadoAnimo = animo;
    _compatibilidades.clear();
    // Con otro mood, lo descartado antes con "ahora no" puede volver a salir.
    _decididos.clear();
    _pila.clear();
    notifyListeners();
    cargarRecomendaciones();
  }

  // ---- Mi lista e historial (guardados en la API) ----
  bool estaEnLista(Contenido c) => _miLista.any((x) => x.id == c.id);

  /// Agrega o quita de Mi lista. Devuelve un mensaje de error o null.
  Future<String?> alternarEnLista(Contenido c) async {
    final estaba = estaEnLista(c);
    if (estaba) {
      _miLista.removeWhere((x) => x.id == c.id);
    } else {
      _miLista.insert(0, c);
    }
    notifyListeners();
    try {
      if (estaba) {
        await api.quitarDeLista(c.id);
      } else {
        await api.agregarALista(c.id);
      }
      return null;
    } on ApiException catch (e) {
      if (estaba) {
        _miLista.insert(0, c);
      } else {
        _miLista.removeWhere((x) => x.id == c.id);
      }
      notifyListeners();
      return e.mensaje;
    }
  }

  Future<String?> marcarComoVisto(Contenido c) async {
    _historial.removeWhere((x) => x.id == c.id);
    _historial.insert(0, c);
    notifyListeners();
    try {
      await api.registrarVisto(c.id);
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    }
  }
}
