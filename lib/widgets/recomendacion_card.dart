import 'package:flutter/material.dart';

import '../models/recomendacion.dart';
import '../utils/colores.dart';

/// Tarjeta vertical del carrusel "Recomendado para ti", con el % de compatibilidad.
class RecomendacionCard extends StatelessWidget {
  final Recomendacion recomendacion;
  final VoidCallback onTap;

  const RecomendacionCard({super.key, required this.recomendacion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = recomendacion.contenido;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colores.superficie,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.movie_creation_outlined,
                          size: 34, color: Colores.textoSecundario),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colores.primario,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${recomendacion.compatibilidad}%',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(c.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            Text(c.genero,
                style: const TextStyle(color: Colores.textoSecundario, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
