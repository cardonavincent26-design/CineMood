import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../utils/colores.dart';
import '../utils/formatos.dart';
import 'poster.dart';

/// Fila de contenido: póster + título + datos. Se usa en Explorar,
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
            Poster(url: contenido.imagenUrl, ancho: 52, alto: 76, radio: 8, tamanoIcono: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contenido.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
