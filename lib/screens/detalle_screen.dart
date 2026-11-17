import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contenido.dart';
import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/formatos.dart';
import '../widgets/boton_primario.dart';
import '../widgets/compatibilidad_gauge.dart';
import '../widgets/poster.dart';

/// Pantalla 7 · Detalle. El póster se desplaza más lento que el contenido (parallax) y la
/// compatibilidad, calculada por la API, se muestra en un medidor animado.
class DetalleScreen extends StatefulWidget {
  final Contenido contenido;
  const DetalleScreen({super.key, required this.contenido});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  late final Future<int> _compatibilidad;

  @override
  void initState() {
    super.initState();
    _compatibilidad = context.read<AppProvider>().compatibilidadDe(widget.contenido);
  }

  void _aviso(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _verAhora() async {
    final error = await context.read<AppProvider>().marcarComoVisto(widget.contenido);
    if (mounted) {
      _aviso(error ?? 'Agregado a tu historial (CineMood no reproduce contenido)');
    }
  }

  Future<void> _alternarLista() async {
    final error = await context.read<AppProvider>().alternarEnLista(widget.contenido);
    if (error != null && mounted) _aviso(error);
  }

  @override
  Widget build(BuildContext context) {
    final contenido = widget.contenido;
    final app = context.watch<AppProvider>();
    final enLista = app.estaEnLista(contenido);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 460,
            backgroundColor: Colores.fondo,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.black45,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax, // el póster se mueve más lento
              titlePadding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 16),
              title: Text(
                contenido.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Poster(
                    url: contenido.imagenGrande,
                    respaldo: contenido.imagenUrl,
                    radio: 0,
                    tamanoIcono: 72,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colores.fondo],
                        stops: [0.55, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${contenido.genero} · ${contenido.anio} · ${formatearDuracion(contenido.duracionMin)} · ${formatearValoracion(contenido.valoracion)}',
                    style: const TextStyle(color: Colores.textoSecundario, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<int>(
                    future: _compatibilidad,
                    builder: (context, snap) {
                      return Row(
                        children: [
                          CompatibilidadGauge(valor: snap.data),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Compatibilidad contigo',
                                    style: TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  snap.hasError
                                      ? 'No se pudo calcular ahora.'
                                      : 'Según tu mood: ${app.estadoAnimo.etiqueta} ${app.estadoAnimo.emoji} y tus preferencias.',
                                  style: const TextStyle(
                                      color: Colores.textoSecundario,
                                      fontSize: 12,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Sinopsis',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(contenido.sinopsis,
                      style: const TextStyle(color: Colores.textoSecundario, height: 1.4)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: BotonPrimario(texto: 'Ver ahora', onPressed: _verAhora),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: BotonPrimario(
                          texto: enLista ? '✓ En mi lista' : '+ Mi lista',
                          secundario: true,
                          onPressed: _alternarLista,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('Datos e imágenes: TMDB',
                      style: TextStyle(color: Colores.textoSecundario, fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
