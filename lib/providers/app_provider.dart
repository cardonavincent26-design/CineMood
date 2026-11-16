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

/// Estado compartido por varias pantallas: sesión, preferencias, mood y recomendaciones.
/// Los datos del catálogo y la compatibilidad vienen de la API (FastAPI).
/// Mi lista e historial siguen siendo locales por ahora (aún no hay endpoints para ellos).
class AppProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  Usuario? usuario;
  Preferencias preferencias = const Preferencias();
  EstadoAnimo estadoAnimo = EstadoAnimo.feliz;

  List<String> generos = [];
  List<Recomendacion> recomendaciones = [];
  bool cargandoRecomendaciones = false;
  String? errorRecomendaciones;
  int _versionRecomendaciones = 0;
  final Map<int, int> _compatibilidades = {};

  final List<Contenido> _miLista = [];
  final List<Contenido> _historial = [];

  static const _claveToken = 'token';
  static const _claveUsuario = 'usuario';

  AppProvider() {
    api.alSesionVencida = _sesionVencida;
  }

  bool get haIniciadoSesion => usuario != null;
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
    _miLista.clear();
    _historial.clear();
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

  // ---- Catálogos ----
  Future<void> cargarGeneros() async {
    if (generos.isNotEmpty) return;
    try {
      generos = await api.generos();
      notifyListeners();
    } on ApiException {
      // Se reintenta la próxima vez que una pantalla los pida.
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
      recomendaciones = r;
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
    notifyListeners();
    cargarRecomendaciones();
  }

  // ---- Mi lista e historial (locales por ahora) ----
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
