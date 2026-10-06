import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalogo_data.dart';
import '../models/contenido.dart';
import '../models/estado_animo.dart';
import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/contenido_card.dart';

/// Pantalla 6 · Explorar (búsqueda + filtros).
class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  String _busqueda = '';
  String? _genero;
  TipoContenido? _tipo;
  int? _duracionMax; // en minutos
  EstadoAnimo? _animo;

  bool _cumple(Contenido c) {
    if (_busqueda.isNotEmpty &&
        !c.titulo.toLowerCase().contains(_busqueda.toLowerCase())) {
      return false;
    }
    if (_genero != null && c.genero != _genero) return false;
    if (_tipo != null && c.tipo != _tipo) return false;
    if (_duracionMax != null && c.duracionMin > _duracionMax!) return false;
    if (_animo != null && (c.afinidadAnimo[_animo!.name] ?? 0) < 0.6) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final resultados = app.catalogo.where(_cumple).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Explorar',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => _busqueda = v),
            decoration: InputDecoration(
              hintText: 'Buscar película o serie...',
              hintStyle: const TextStyle(color: Colores.textoSecundario, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colores.textoSecundario),
              filled: true,
              fillColor: Colores.superficie,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Filtro<String>(
                  etiqueta: 'Género',
                  valor: _genero,
                  opciones: {for (final g in generosDisponibles) g: g},
                  onChanged: (v) => setState(() => _genero = v),
                ),
                _Filtro<int>(
                  etiqueta: 'Duración',
                  valor: _duracionMax,
                  opciones: const {
                    'Hasta 30 min': 30,
                    'Hasta 60 min': 60,
                    'Hasta 120 min': 120,
                    'Hasta 3 h': 180,
                  },
                  onChanged: (v) => setState(() => _duracionMax = v),
                ),
                _Filtro<TipoContenido>(
                  etiqueta: 'Tipo',
                  valor: _tipo,
                  opciones: {for (final t in TipoContenido.values) t.etiqueta: t},
                  onChanged: (v) => setState(() => _tipo = v),
                ),
                _Filtro<EstadoAnimo>(
                  etiqueta: 'Estado de ánimo',
                  valor: _animo,
                  opciones: {for (final e in EstadoAnimo.values) e.etiqueta: e},
                  onChanged: (v) => setState(() => _animo = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Resultados (${resultados.length})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Expanded(
            child: resultados.isEmpty
                ? const Center(
                    child: Text('Sin resultados',
                        style: TextStyle(color: Colores.textoSecundario)))
                : ListView.builder(
                    itemCount: resultados.length,
                    itemBuilder: (_, i) => ContenidoCard(
                      contenido: resultados[i],
                      onTap: () => Navigator.pushNamed(context, Rutas.detalle,
                          arguments: resultados[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Botón de filtro con menú desplegable. Al elegir "Todos" se quita el filtro.
class _Filtro<T> extends StatelessWidget {
  final String etiqueta;
  final T? valor;
  final Map<String, T> opciones;
  final ValueChanged<T?> onChanged;

  const _Filtro({
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activo = valor != null;
    final textoActivo = activo
        ? opciones.entries.firstWhere((e) => e.value == valor).key
        : etiqueta;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<_Opcion<T>>(
        color: Colores.superficie,
        // Se envuelve el valor porque PopupMenuButton ignora los valores null.
        onSelected: (o) => onChanged(o.valor),
        itemBuilder: (_) => [
          PopupMenuItem<_Opcion<T>>(value: _Opcion<T>(null), child: const Text('Todos')),
          for (final e in opciones.entries)
            PopupMenuItem<_Opcion<T>>(value: _Opcion<T>(e.value), child: Text(e.key)),
        ],
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: activo ? Colores.primario : Colores.superficie,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(textoActivo,
              style: TextStyle(
                  fontSize: 12,
                  color: activo ? Colors.white : Colores.textoSecundario)),
        ),
      ),
    );
  }
}

class _Opcion<T> {
  final T? valor;
  const _Opcion(this.valor);
}
