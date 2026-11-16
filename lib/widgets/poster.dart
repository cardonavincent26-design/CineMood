import 'package:flutter/material.dart';

import '../utils/colores.dart';

/// Póster de un contenido (imagen de TMDB). Si no hay imagen o falla la carga,
/// muestra un ícono. Sin ancho/alto, ocupa el espacio que le dé su contenedor.
class Poster extends StatelessWidget {
  final String? url;
  final double? ancho;
  final double? alto;
  final double radio;
  final double tamanoIcono;

  const Poster({
    super.key,
    required this.url,
    this.ancho,
    this.alto,
    this.radio = 10,
    this.tamanoIcono = 30,
  });

  Widget _vacio() => Container(
        color: Colores.superficie,
        child: Center(
          child: Icon(Icons.movie_creation_outlined,
              size: tamanoIcono, color: Colores.textoSecundario),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: SizedBox(
        width: ancho,
        height: alto,
        child: url == null
            ? _vacio()
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _vacio(),
                loadingBuilder: (_, hijo, progreso) => progreso == null ? hijo : _vacio(),
              ),
      ),
    );
  }
}
