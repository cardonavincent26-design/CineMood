import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contenido.dart';
import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/formatos.dart';
import '../widgets/boton_primario.dart';
import '../widgets/poster.dart';

/// Pantalla 7 · Detalle de película o serie, con póster y % de compatibilidad (calculado por la API).
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

  @override
  Widget build(BuildContext context) {
    final contenido = widget.contenido;
    final app = context.watch<AppProvider>();
    final enLista = app.estaEnLista(contenido);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Poster(
                  url: contenido.imagenUrl, ancho: 220, alto: 330, radio: 14, tamanoIcono: 54),
            ),
            const SizedBox(height: 20),
            Text(contenido.titulo,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              '${contenido.genero} · ${contenido.anio} · ${formatearDuracion(contenido.duracionMin)} · ${formatearValoracion(contenido.valoracion)}',
              style: const TextStyle(color: Colores.textoSecundario, fontSize: 12),
            ),
            const SizedBox(height: 20),
            const Text('Sinopsis',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(contenido.sinopsis,
                style: const TextStyle(color: Colores.textoSecundario, height: 1.4)),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: BotonPrimario(
                    texto: 'Ver ahora',
                    onPressed: () {
                      context.read<AppProvider>().marcarComoVisto(contenido);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Agregado a tu historial (CineMood no reproduce contenido)')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: BotonPrimario(
                    texto: enLista ? '✓ En mi lista' : '+ Mi lista',
                    secundario: true,
                    onPressed: () => context.read<AppProvider>().alternarEnLista(contenido),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            FutureBuilder<int>(
              future: _compatibilidad,
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Text('No se pudo calcular la compatibilidad.',
                      style: TextStyle(color: Colores.textoSecundario));
                }
                final compat = snap.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        compat == null
                            ? 'Calculando compatibilidad...'
                            : 'Compatibilidad contigo: $compat%',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: compat == null ? null : compat / 100,
                        minHeight: 8,
                        backgroundColor: Colores.superficie,
                        color: Colores.primario,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Datos e imágenes: TMDB',
                style: TextStyle(color: Colores.textoSecundario, fontSize: 10)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
