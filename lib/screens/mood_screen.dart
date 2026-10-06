import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/estado_animo.dart';
import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/boton_primario.dart';

/// Pantalla 4 · ¿Cómo te sientes hoy? (el criterio más importante).
/// Si [edicion] es true, vuelve a la pantalla anterior al confirmar.
class MoodScreen extends StatefulWidget {
  final bool edicion;
  const MoodScreen({super.key, this.edicion = false});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  late EstadoAnimo _animo;

  @override
  void initState() {
    super.initState();
    _animo = context.read<AppProvider>().estadoAnimo;
  }

  void _verRecomendaciones() {
    context.read<AppProvider>().cambiarEstadoAnimo(_animo);
    if (widget.edicion) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, Rutas.principal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.edicion ? AppBar(title: const Text('Estado de ánimo')) : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: widget.edicion ? 16 : 70),
              const Text('¿Cómo te sientes hoy?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Elige tu mood para adaptar las recomendaciones.',
                  style: TextStyle(color: Colores.textoSecundario, fontSize: 12)),
              const SizedBox(height: 28),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.6,
                  children: [
                    for (final e in EstadoAnimo.values)
                      GestureDetector(
                        onTap: () => setState(() => _animo = e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _animo == e ? Colores.primario : Colores.superficie,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${e.emoji}  ${e.etiqueta}',
                              style: TextStyle(
                                color:
                                    _animo == e ? Colors.white : Colores.textoSecundario,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ),
                  ],
                ),
              ),
              BotonPrimario(
                  texto: widget.edicion ? 'Guardar mood' : 'Ver mis recomendaciones',
                  onPressed: _verRecomendaciones),
              const SizedBox(height: 10),
              const Text('Puedes cambiar tu mood cuando quieras.',
                  style: TextStyle(color: Colores.textoSecundario, fontSize: 11)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
