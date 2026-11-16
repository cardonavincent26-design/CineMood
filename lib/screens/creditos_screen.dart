import 'package:flutter/material.dart';

import '../utils/colores.dart';

/// Créditos y atribución. TMDB exige mostrar su logo y este aviso en la app.
class CreditosScreen extends StatelessWidget {
  const CreditosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créditos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CineMood',
                style: TextStyle(
                    color: Colores.primario, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Proyecto de Desarrollo de Software.\n'
              'Fabian Arroyo Alvarado · Zaid Daniel De Avila · Vincent Cardona Castro',
              style: TextStyle(color: Colores.textoSecundario, height: 1.5, fontSize: 12),
            ),
            const SizedBox(height: 32),
            const Text('Fuente de datos',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            // TODO: agregar aquí el logo oficial de TMDB (themoviedb.org/about/logos-attribution):
            // guárdalo en assets/tmdb_logo.png, declara la carpeta en pubspec.yaml y muéstralo con
            // Image.asset('assets/tmdb_logo.png', height: 24).
            const Text('TMDB',
                style: TextStyle(
                    color: Color(0xFF01B4E4), fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'This product uses the TMDB API but is not endorsed or certified by TMDB.',
              style: TextStyle(color: Colores.textoSecundario, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              'Los títulos, sinopsis, valoraciones y pósters provienen de The Movie Database (TMDB).',
              style: TextStyle(color: Colores.textoSecundario, height: 1.5, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
