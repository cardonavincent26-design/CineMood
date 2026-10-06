import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contenido.dart';
import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/formatos.dart';
import '../widgets/boton_primario.dart';

/// Pantalla 7 · Detalle de película o serie, con % de compatibilidad.
class DetalleScreen extends StatelessWidget {
  final Contenido contenido;
  const DetalleScreen({super.key, required this.contenido});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final enLista = app.estaEnLista(contenido);
    final compat = app.compatibilidadDe(contenido);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colores.superficie,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.movie_creation_outlined,
                  size: 54, color: Colores.textoSecundario),
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
                            content: Text('Agregado a tu historial (CineMood no reproduce contenido)')),
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
            Text('Compatibilidad contigo: $compat%',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: compat / 100,
                minHeight: 8,
                backgroundColor: Colores.superficie,
                color: Colores.primario,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
