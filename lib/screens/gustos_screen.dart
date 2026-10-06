import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalogo_data.dart';
import '../models/contenido.dart';
import '../models/preferencias.dart';
import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/boton_primario.dart';
import '../widgets/chip_opcion.dart';

/// Pantalla 3 · Conozcamos tus gustos (géneros, tipo de contenido, tiempo).
/// Si [edicion] es true, vuelve a la pantalla anterior al guardar.
class GustosScreen extends StatefulWidget {
  final bool edicion;
  const GustosScreen({super.key, this.edicion = false});

  @override
  State<GustosScreen> createState() => _GustosScreenState();
}

class _GustosScreenState extends State<GustosScreen> {
  late Set<String> _generos;
  late TipoContenido _tipo;
  RangoTiempo? _tiempo;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>().preferencias;
    _generos = {...p.generos};
    _tipo = p.tipo;
    _tiempo = p.tiempo;
  }

  void _continuar() {
    context.read<AppProvider>().guardarPreferencias(
          Preferencias(generos: _generos, tipo: _tipo, tiempo: _tiempo),
        );
    if (widget.edicion) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, Rutas.mood);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.edicion ? AppBar(title: const Text('Editar preferencias')) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: widget.edicion ? 16 : 70),
              const Center(
                child: Text('Conozcamos tus gustos',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Selecciona géneros, contenido y tiempo.',
                    style: TextStyle(color: Colores.textoSecundario, fontSize: 12)),
              ),
              const SizedBox(height: 28),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3.6,
                children: [
                  for (final g in generosDisponibles)
                    ChipOpcion(
                      texto: g,
                      seleccionado: _generos.contains(g),
                      onTap: () => setState(() {
                        _generos.contains(g) ? _generos.remove(g) : _generos.add(g);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Tipo de contenido', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final t in TipoContenido.values) ...[
                    Expanded(
                      child: ChipOpcion(
                        texto: t.etiqueta,
                        seleccionado: _tipo == t,
                        onTap: () => setState(() => _tipo = t),
                      ),
                    ),
                    if (t != TipoContenido.values.last) const SizedBox(width: 10),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              const Text('Disponibilidad de tiempo', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final r in RangoTiempo.values) ...[
                    Expanded(
                      child: ChipOpcion(
                        texto: r.etiqueta,
                        seleccionado: _tiempo == r,
                        onTap: () => setState(() => _tiempo = r),
                      ),
                    ),
                    if (r != RangoTiempo.values.last) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 40),
              BotonPrimario(
                  texto: widget.edicion ? 'Guardar' : 'Continuar', onPressed: _continuar),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
