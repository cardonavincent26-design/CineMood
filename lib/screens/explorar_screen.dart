import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contenido.dart';
import '../models/estado_animo.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/contenido_card.dart';

/// Pantalla 6 · Explorar (búsqueda + filtros). La búsqueda y los filtros se hacen en la API.
/// Si el título no está en nuestra base, se puede buscar en TMDB (la API lo guarda).
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

  List<Contenido> _resultados = [];
  bool _cargando = false;
  String? _error;
  Timer? _espera;
  int _version = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().cargarGeneros();
      _buscar();
    });
  }

  @override
  void dispose() {
    _espera?.cancel();
    super.dispose();
  }

  Future<void> _consultar(Future<List<Contenido>> Function() pedir) async {
    final mia = ++_version;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final r = await pedir();
      if (!mounted || mia != _version) return;
      setState(() {
        _resultados = r;
        _cargando = false;
      });
    } on ApiException catch (e) {
      if (!mounted || mia != _version) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  Future<void> _buscar() {
    final api = context.read<AppProvider>().api;
    final q = _busqueda.trim();
    return _consultar(() => api.contenidos(
          q: q.isEmpty ? null : q,
          tipo: _tipo,
          genero: _genero,
          duracionMax: _duracionMax,
          animo: _animo,
        ));
  }

  Future<void> _buscarEnTmdb() {
    final api = context.read<AppProvider>().api;
    return _consultar(() => api.buscarEnTmdb(_busqueda.trim(), _tipo));
  }

  void _alEscribir(String texto) {
    setState(() => _busqueda = texto);
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 500), _buscar);
  }

  void _cambiarFiltro(VoidCallback cambio) {
    setState(cambio);
    _buscar();
  }

  @override
  Widget build(BuildContext context) {
    final generos = context.watch<AppProvider>().generos;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Explorar',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          TextField(
            onChanged: _alEscribir,
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
                  opciones: {for (final g in generos) g: g},
                  onChanged: (v) => _cambiarFiltro(() => _genero = v),
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
                  onChanged: (v) => _cambiarFiltro(() => _duracionMax = v),
                ),
                _Filtro<TipoContenido>(
                  etiqueta: 'Tipo',
                  valor: _tipo,
                  opciones: {for (final t in TipoContenido.values) t.etiqueta: t},
                  onChanged: (v) => _cambiarFiltro(() => _tipo = v),
                ),
                _Filtro<EstadoAnimo>(
                  etiqueta: 'Estado de ánimo',
                  valor: _animo,
                  opciones: {for (final e in EstadoAnimo.values) e.etiqueta: e},
                  onChanged: (v) => _cambiarFiltro(() => _animo = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Resultados (${_resultados.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              if (_busqueda.trim().length >= 2)
                TextButton(
                  onPressed: _cargando ? null : _buscarEnTmdb,
                  child: const Text('Buscar en TMDB', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colores.textoSecundario)),
                            TextButton(onPressed: _buscar, child: const Text('Reintentar')),
                          ],
                        ),
                      )
                    : _resultados.isEmpty
                        ? const Center(
                            child: Text(
                                'Sin resultados.\nPrueba con "Buscar en TMDB" si no lo encuentras.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colores.textoSecundario)))
                        : ListView.builder(
                            itemCount: _resultados.length,
                            itemBuilder: (_, i) => ContenidoCard(
                              contenido: _resultados[i],
                              onTap: () => Navigator.pushNamed(context, Rutas.detalle,
                                  arguments: _resultados[i]),
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
    final textoActivo =
        activo ? opciones.entries.firstWhere((e) => e.value == valor).key : etiqueta;

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
                  fontSize: 12, color: activo ? Colors.white : Colores.textoSecundario)),
        ),
      ),
    );
  }
}

class _Opcion<T> {
  final T? valor;
  const _Opcion(this.valor);
}
