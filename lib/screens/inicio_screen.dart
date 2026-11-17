import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recomendacion.dart';
import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/tarjeta_deslizable.dart';
import '../widgets/tarjeta_pelicula.dart';

/// Pantalla 5 · ¿Qué quieres ver hoy? Recomendaciones por mood en forma de mazo de tarjetas:
/// deslizar a la derecha guarda en Mi lista, a la izquierda descarta. La API calcula todo.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _tarjeta = GlobalKey<TarjetaDeslizableState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppProvider>();
      app.cargarDatosUsuario();
      if (app.recomendaciones.isEmpty && !app.cargandoRecomendaciones) {
        app.cargarRecomendaciones();
      }
    });
  }

  void _aviso(String? error) {
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _decidir(Recomendacion rec, bool guardar) async {
    final error = await context.read<AppProvider>().decidir(rec, guardar: guardar);
    _aviso(error);
  }

  Future<void> _deshacer() async {
    final error = await context.read<AppProvider>().deshacer();
    _aviso(error);
  }

  Widget _mensaje(String texto, {Widget? accion}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colores.textoSecundario)),
          if (accion != null) accion,
        ],
      ),
    );
  }

  Widget _mazo(AppProvider app) {
    final recs = app.recomendaciones;

    if (app.cargandoRecomendaciones && recs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Buscando recomendaciones...\n(la primera vez puede tardar hasta un minuto)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colores.textoSecundario, fontSize: 12)),
          ],
        ),
      );
    }
    if (app.errorRecomendaciones != null) {
      return _mensaje(
        app.errorRecomendaciones!,
        accion: TextButton(
          onPressed: () => context.read<AppProvider>().cargarRecomendaciones(),
          child: const Text('Reintentar'),
        ),
      );
    }
    if (recs.isEmpty) {
      return _mensaje(
        'Ya revisaste todo lo recomendado para este mood.\nCambia tu mood o tus preferencias para ver más.',
        accion: TextButton(
          onPressed: () => context.read<AppProvider>().cargarRecomendaciones(),
          child: const Text('Buscar de nuevo'),
        ),
      );
    }

    final actual = recs.first;
    final siguiente = recs.length > 1 ? recs[1] : null;

    return Stack(
      children: [
        if (siguiente != null)
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.scale(
                scale: 0.94,
                child: Opacity(
                  opacity: 0.7,
                  child: TarjetaPelicula(recomendacion: siguiente, onTap: () {}),
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: TarjetaDeslizable(
            key: _tarjeta,
            id: actual.contenido.id,
            onGuardar: () => _decidir(actual, true),
            onDescartar: () => _decidir(actual, false),
            child: TarjetaPelicula(
              recomendacion: actual,
              onTap: () =>
                  Navigator.pushNamed(context, Rutas.detalle, arguments: actual.contenido),
            ),
          ),
        ),
      ],
    );
  }

  Widget _boton(IconData icono, Color color, double tamano, VoidCallback? onPressed,
      String ayuda) {
    return Tooltip(
      message: ayuda,
      child: Material(
        color: Colores.superficie,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.all(tamano * 0.4),
            child: Icon(icono,
                size: tamano, color: onPressed == null ? Colores.textoSecundario : color),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final hayMazo = app.recomendaciones.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Qué quieres ver hoy?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Rutas.mood, arguments: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colores.superficie,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tu mood: ${app.estadoAnimo.etiqueta} ${app.estadoAnimo.emoji}',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 12, color: Colores.textoSecundario),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _mazo(app)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _boton(Icons.close, Colors.redAccent, 28,
                  hayMazo ? () => _tarjeta.currentState?.salir(derecha: false) : null,
                  'Descartar'),
              const SizedBox(width: 18),
              _boton(Icons.undo, Colores.textoSecundario, 20,
                  app.puedeDeshacer ? _deshacer : null, 'Deshacer'),
              const SizedBox(width: 18),
              _boton(Icons.favorite, Colors.greenAccent, 28,
                  hayMazo ? () => _tarjeta.currentState?.salir(derecha: true) : null,
                  'Guardar en Mi lista'),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Desliza a la derecha para guardar · a la izquierda para descartar',
                style: TextStyle(color: Colores.textoSecundario, fontSize: 11)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
