import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/colores.dart';
import '../utils/rutas.dart';
import '../widgets/boton_primario.dart';
import 'gustos_screen.dart';

/// Pantalla 10 · Mi perfil.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final u = app.usuario;
    final p = app.preferencias;
    final generos = p.generos.isEmpty ? 'Sin definir' : p.generos.join(', ');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mi perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colores.primario,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, size: 46),
            ),
          ),
          const SizedBox(height: 18),
          Text(u?.nombre ?? 'Tu nombre',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(u?.correo ?? 'tu@email.com',
              style: const TextStyle(color: Colores.textoSecundario, fontSize: 12)),
          const SizedBox(height: 22),
          const Text('Mis preferencias',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Géneros: $generos\n'
            'Tipo de contenido: ${p.tipo.etiqueta}\n'
            'Tiempo disponible: ${p.tiempo?.etiqueta ?? 'Sin definir'}\n'
            'Mood actual: ${app.estadoAnimo.etiqueta} ${app.estadoAnimo.emoji}',
            style: const TextStyle(color: Colores.textoSecundario, height: 1.6, fontSize: 12),
          ),
          const SizedBox(height: 22),
          BotonPrimario(
            texto: 'Editar preferencias',
            secundario: true,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GustosScreen(edicion: true)),
            ),
          ),
          const SizedBox(height: 10),
          BotonPrimario(
            texto: 'Cambiar estado de ánimo',
            secundario: true,
            onPressed: () => Navigator.pushNamed(context, Rutas.mood, arguments: true),
          ),
          const SizedBox(height: 10),
          BotonPrimario(
            texto: 'Ver historial',
            secundario: true,
            onPressed: () => Navigator.pushNamed(context, Rutas.historial),
          ),
          const SizedBox(height: 10),
          BotonPrimario(
            texto: 'Cerrar sesión',
            secundario: true,
            onPressed: () {
              context.read<AppProvider>().cerrarSesion();
              Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (_) => false);
            },
          ),
        ],
      ),
    );
  }
}
