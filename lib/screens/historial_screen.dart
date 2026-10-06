import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/contenido_card.dart';

/// Pantalla 9 · Historial (lo que has visto recientemente).
class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historial = context.watch<AppProvider>().historial;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lo que has visto recientemente',
                style: TextStyle(color: Colores.textoSecundario, fontSize: 12)),
            const SizedBox(height: 10),
            Expanded(
              child: historial.isEmpty
                  ? const Center(
                      child: Text('Todavía no hay nada en tu historial.',
                          style: TextStyle(color: Colores.textoSecundario)))
                  : ListView.builder(
                      itemCount: historial.length,
                      itemBuilder: (_, i) => ContenidoCard(
                        contenido: historial[i],
                        subtitulo: 'Visto recientemente',
                        onTap: () => Navigator.pushNamed(context, Rutas.detalle,
                            arguments: historial[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
