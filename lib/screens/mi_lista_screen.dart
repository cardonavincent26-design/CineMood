import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/contenido_card.dart';

/// Pantalla 8 · Mi lista (guardado para ver después).
class MiListaScreen extends StatelessWidget {
  const MiListaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final lista = app.miLista;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mi lista',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Guardado para ver después',
              style: TextStyle(color: Colores.textoSecundario, fontSize: 12)),
          const SizedBox(height: 14),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text('Aún no has guardado nada.\nAgrega contenido desde su detalle.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colores.textoSecundario)))
                : ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (_, i) => Dismissible(
                      key: ValueKey(lista[i].id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Colores.primario,
                        child: const Icon(Icons.delete_outline),
                      ),
                      onDismissed: (_) =>
                          context.read<AppProvider>().alternarEnLista(lista[i]),
                      child: ContenidoCard(
                        contenido: lista[i],
                        onTap: () => Navigator.pushNamed(context, Rutas.detalle,
                            arguments: lista[i]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
