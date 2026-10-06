import 'package:flutter/material.dart';

import '../utils/colores.dart';

/// Opción seleccionable (género, tiempo, tipo, mood).
class ChipOpcion extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  const ChipOpcion({
    super.key,
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? Colores.primario : Colores.superficie,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: seleccionado ? Colors.white : Colores.textoSecundario,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
