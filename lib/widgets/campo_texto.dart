import 'package:flutter/material.dart';

import '../utils/colores.dart';

class CampoTexto extends StatelessWidget {
  final String etiqueta;
  final TextEditingController? controller;
  final bool oculto;
  final TextInputType? teclado;

  const CampoTexto({
    super.key,
    required this.etiqueta,
    this.controller,
    this.oculto = false,
    this.teclado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: oculto,
        keyboardType: teclado,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: etiqueta,
          hintStyle: const TextStyle(color: Colores.textoSecundario),
          filled: true,
          fillColor: Colores.superficie,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
