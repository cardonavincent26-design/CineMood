import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../utils/colores.dart';
import '../utils/formatos.dart';

/// Fila de contenido: miniatura + título + datos. Se usa en Explorar,
/// Mi lista e Historial.
class ContenidoCard extends StatelessWidget {
  final Contenido contenido;
  final String? subtitulo;
  final VoidCallback onTap;

  const ContenidoCard({
    super.key,
    required this.contenido,
    required this.onTap,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colores.superficie,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.movie_outlined, color: Colores.textoSecundario),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contenido.titulo,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo ??
                        '${contenido.genero} · ${formatearDuracion(contenido.duracionMin)} · ${formatearValoracion(contenido.valoracion)}',
                    style: const TextStyle(color: Colores.textoSecundario, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
