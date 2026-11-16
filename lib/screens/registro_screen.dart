import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/boton_primario.dart';
import '../widgets/campo_texto.dart';

/// Pantalla 2 · Crear cuenta (se registra en la API y entra directamente).
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombre = TextEditingController();
  final _edad = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _edad.dispose();
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  void _aviso(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _registrar() async {
    final edad = int.tryParse(_edad.text.trim());
    if (_nombre.text.trim().isEmpty ||
        edad == null ||
        edad < 1 ||
        edad > 120 ||
        !_correo.text.contains('@') ||
        _clave.text.length < 8) {
      _aviso('Completa todos los campos (contraseña de mínimo 8 caracteres)');
      return;
    }
    setState(() => _cargando = true);
    try {
      await context
          .read<AppProvider>()
          .registrar(_nombre.text.trim(), edad, _correo.text.trim(), _clave.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Rutas.gustos, (_) => false);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              const Center(
                child: Text('Crear cuenta',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Comienza a personalizar tus recomendaciones.',
                    style: TextStyle(color: Colores.textoSecundario, fontSize: 12)),
              ),
              const SizedBox(height: 40),
              CampoTexto(etiqueta: 'Nombre', controller: _nombre),
              CampoTexto(
                  etiqueta: 'Edad', controller: _edad, teclado: TextInputType.number),
              CampoTexto(
                  etiqueta: 'Correo electrónico',
                  controller: _correo,
                  teclado: TextInputType.emailAddress),
              CampoTexto(
                  etiqueta: 'Contraseña (mínimo 8 caracteres)',
                  controller: _clave,
                  oculto: true),
              const SizedBox(height: 16),
              BotonPrimario(
                texto: _cargando ? 'Creando cuenta...' : 'Registrarme',
                onPressed: _cargando ? null : _registrar,
              ),
              if (_cargando)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Si hace rato no se usa, el servidor puede tardar hasta un minuto en despertar.',
                    style: TextStyle(color: Colores.textoSecundario, fontSize: 11),
                  ),
                ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(color: Colores.textoSecundario, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
