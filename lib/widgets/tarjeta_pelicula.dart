import 'package:flutter/material.dart';

import '../models/recomendacion.dart';
import '../utils/colores.dart';
import '../utils/formatos.dart';
import 'poster.dart';

/// Tarjeta grande de una recomendación: póster a pantalla completa, título y % de compatibilidad.
class TarjetaPelicula extends StatelessWidget {
  final Recomendacion recomendacion;
  final VoidCallback onTap;

  const TarjetaPelicula({super.key, required this.recomendacion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = recomendacion.contenido;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Poster(url: c.imagenUrl, radio: 0, tamanoIcono: 64),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colores.primario,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${recomendacion.compatibilidad}% compatible',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Text(c.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    '${c.genero} · ${c.anio} · ${formatearDuracion(c.duracionMin)} · ${formatearValoracion(c.valoracion)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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
