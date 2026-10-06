import 'package:flutter/material.dart';

import '../utils/colores.dart';

class BotonPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool secundario;

  const BotonPrimario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.secundario = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: secundario ? Colores.superficie : Colores.primario,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
