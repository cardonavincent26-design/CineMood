import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/boton_primario.dart';
import '../widgets/campo_texto.dart';

/// Pantalla 1 · Inicio de sesión (autentica contra la API y guarda el token JWT).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  void _aviso(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _iniciarSesion() async {
    if (_correo.text.trim().isEmpty || _clave.text.isEmpty) {
      _aviso('Ingresa tu correo y contraseña');
      return;
    }
    setState(() => _cargando = true);
    try {
      await context.read<AppProvider>().iniciarSesion(_correo.text.trim(), _clave.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Rutas.mood);
    } on ApiException catch (e) {
      if (mounted) _aviso(e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 90),
              const Text('CineMood',
                  style: TextStyle(
                      color: Colores.primario,
                      fontSize: 40,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Encuentra algo que vaya contigo hoy.',
                  style: TextStyle(color: Colores.textoSecundario, fontSize: 13)),
              const SizedBox(height: 56),
              CampoTexto(
                  etiqueta: 'Correo electrónico',
                  controller: _correo,
                  teclado: TextInputType.emailAddress),
              CampoTexto(etiqueta: 'Contraseña', controller: _clave, oculto: true),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colores.primario, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 8),
              BotonPrimario(
                texto: _cargando ? 'Entrando...' : 'Iniciar sesión',
                onPressed: _cargando ? null : _iniciarSesion,
              ),
              if (_cargando)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Si hace rato no se usa, el servidor puede tardar hasta un minuto en despertar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colores.textoSecundario, fontSize: 11),
                  ),
                ),
              const SizedBox(height: 10),
              BotonPrimario(
                texto: 'Crear una cuenta',
                secundario: true,
                onPressed: _cargando
                    ? null
                    : () => Navigator.pushNamed(context, Rutas.registro),
              ),
              const SizedBox(height: 60),
              const Text('Recomendaciones por estado de ánimo, gustos y tiempo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colores.textoSecundario, fontSize: 11)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
