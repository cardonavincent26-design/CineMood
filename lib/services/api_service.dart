import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/contenido.dart';
import '../models/estado_animo.dart';
import '../models/preferencias.dart';
import '../models/recomendacion.dart';
import '../models/usuario.dart';

/// Error legible para mostrar al usuario (red, servidor o validación).
class ApiException implements Exception {
  final String mensaje;
  final int? codigo;
  const ApiException(this.mensaje, [this.codigo]);

  @override
  String toString() => mensaje;
}

/// Único lugar de la app que habla con la API. La app no calcula nada importante:
/// la compatibilidad, los filtros y la búsqueda se resuelven en el servidor.
class ApiService {
  String? token;

  /// Se ejecuta si la API responde 401 teniendo un token guardado (sesión vencida).
  void Function()? alSesionVencida;

  Map<String, String> get _cabeceras => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> _enviar(
    String metodo,
    String ruta, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? cuerpo,
  }) async {
    final uri = Uri.parse(apiBaseUrl).replace(
      path: ruta,
      queryParameters: (params == null || params.isEmpty) ? null : params,
    );

    http.Response r;
    try {
      if (metodo == 'GET') {
        r = await http.get(uri, headers: _cabeceras).timeout(apiTimeout);
      } else {
        r = await http
            .post(uri, headers: _cabeceras, body: jsonEncode(cuerpo))
            .timeout(apiTimeout);
      }
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder. Intenta de nuevo.');
    } catch (_) {
      throw const ApiException('No se pudo conectar. Revisa tu conexión a internet.');
    }

    final texto = utf8.decode(r.bodyBytes); // utf8 explícito para no dañar tildes
    final datos = texto.isEmpty ? null : jsonDecode(texto);
    if (r.statusCode >= 200 && r.statusCode < 300) return datos;

    if (r.statusCode == 401 && token != null) alSesionVencida?.call();
    throw ApiException(_mensajeDeError(datos, r.statusCode), r.statusCode);
  }

  String _mensajeDeError(dynamic datos, int codigo) {
    if (datos is Map && datos['detail'] is String) return datos['detail'] as String;
    if (codigo == 422) return 'Revisa los datos ingresados.';
    if (codigo >= 500) return 'Error del servidor. Intenta más tarde.';
    return 'Error inesperado ($codigo).';
  }

  // ---- Autenticación ----
  Future<void> registrar(String nombre, int edad, String correo, String contrasena) =>
      _enviar('POST', '/auth/registro', cuerpo: {
        'nombre': nombre,
        'edad': edad,
        'correo': correo,
        'contrasena': contrasena,
      });

  /// Devuelve el token JWT.
  Future<String> iniciarSesion(String correo, String contrasena) async {
    final d = await _enviar('POST', '/auth/login',
        cuerpo: {'correo': correo, 'contrasena': contrasena});
    return d['access_token'] as String;
  }

  Future<Usuario> perfil() async =>
      Usuario.fromJson(await _enviar('GET', '/auth/me') as Map<String, dynamic>);

  // ---- Catálogo ----
  Future<List<String>> generos() async =>
      List<String>.from(await _enviar('GET', '/generos') as List);

  Future<List<Contenido>> contenidos({
    String? q,
    TipoContenido? tipo,
    String? genero,
    int? duracionMax,
    EstadoAnimo? animo,
    int limite = 50,
  }) async {
    final d = await _enviar('GET', '/contenidos', params: {
      if (q != null) 'q': q,
      if (tipo != null) 'tipo': tipo.name,
      if (genero != null) 'genero': genero,
      if (duracionMax != null) 'duracion_max': '$duracionMax',
      if (animo != null) 'animo': animo.name,
      'limite': '$limite',
    });
    return [for (final j in d as List) Contenido.fromJson(j as Map<String, dynamic>)];
  }

  /// Busca en TMDB un título que quizá no esté en nuestra base; la API lo guarda.
  Future<List<Contenido>> buscarEnTmdb(String q, TipoContenido? tipo) async {
    final d = await _enviar('GET', '/tmdb/buscar', params: {
      'q': q,
      if (tipo != null) 'tipo': tipo.name,
    });
    return [for (final j in d as List) Contenido.fromJson(j as Map<String, dynamic>)];
  }

  // ---- Recomendaciones (la compatibilidad la calcula la API) ----
  Map<String, dynamic> _paramsRecomendacion(EstadoAnimo animo, Preferencias p) => {
        'animo': animo.name,
        if (p.tiempo != null) 'tiempo': p.tiempo!.name,
        if (p.generos.isNotEmpty) 'generos': p.generos.toList(),
      };

  Future<List<Recomendacion>> recomendaciones(EstadoAnimo animo, Preferencias p,
      {int limite = 30}) async {
    final d = await _enviar('GET', '/recomendaciones', params: {
      ..._paramsRecomendacion(animo, p),
      'tipo': p.tipo.name,
      'limite': '$limite',
    });
    return [for (final j in d as List) Recomendacion.fromJson(j as Map<String, dynamic>)];
  }

  Future<int> compatibilidad(int contenidoId, EstadoAnimo animo, Preferencias p) async {
    final d = await _enviar('GET', '/compatibilidad/$contenidoId',
        params: _paramsRecomendacion(animo, p));
    return d['compatibilidad'] as int;
  }
}
