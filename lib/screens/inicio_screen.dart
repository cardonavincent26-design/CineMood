import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/recomendacion_card.dart';

/// Pantalla 5 · ¿Qué quieres ver hoy? (recomendaciones por mood).
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _desplazamiento = 0; // permite pedir "otra recomendación" (RF-010)

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final todas = app.recomendaciones;
    final n = todas.length;
    final visibles = n == 0
        ? todas
        : [for (var i = 0; i < n && i < 5; i++) todas[(i + _desplazamiento) % n]];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Qué quieres ver hoy?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Rutas.mood, arguments: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colores.superficie,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tu mood: ${app.estadoAnimo.etiqueta} ${app.estadoAnimo.emoji}',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 12, color: Colores.textoSecundario),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recomendado para ti',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(
                tooltip: 'Otra recomendación',
                onPressed: () => setState(() => _desplazamiento++),
                icon: const Icon(Icons.refresh, color: Colores.primario),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visibles.isEmpty
                ? const Center(
                    child: Text('No hay contenido para tus preferencias.',
                        style: TextStyle(color: Colores.textoSecundario)))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: visibles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => RecomendacionCard(
                      recomendacion: visibles[i],
                      onTap: () => Navigator.pushNamed(context, Rutas.detalle,
                          arguments: visibles[i].contenido),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          const Text('Porque coincide con tus gustos y tu estado de ánimo.',
              style: TextStyle(color: Colores.textoSecundario, fontSize: 11)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
