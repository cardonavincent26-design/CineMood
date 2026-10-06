import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/boton_primario.dart';
import '../widgets/campo_texto.dart';

/// Pantalla 2 · Crear cuenta.
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

  @override
  void dispose() {
    _nombre.dispose();
    _edad.dispose();
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  void _registrar() {
    final edad = int.tryParse(_edad.text.trim());
    if (_nombre.text.trim().isEmpty ||
        edad == null ||
        _correo.text.trim().isEmpty ||
        _clave.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Completa todos los campos (contraseña de mínimo 6 caracteres)')),
      );
      return;
    }
    context
        .read<AppProvider>()
        .registrar(_nombre.text.trim(), edad, _correo.text.trim());
    Navigator.pushReplacementNamed(context, Rutas.gustos);
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
              CampoTexto(etiqueta: 'Contraseña', controller: _clave, oculto: true),
              const SizedBox(height: 16),
              BotonPrimario(texto: 'Registrarme', onPressed: _registrar),
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
