import 'package:flutter/material.dart';

import '../utils/colores.dart';
import 'explorar_screen.dart';
import 'inicio_screen.dart';
import 'mi_lista_screen.dart';
import 'perfil_screen.dart';

/// Contenedor con la barra de navegación inferior:
/// Inicio · Explorar · Mi lista · Perfil.
class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _indice = 0;

  static const _pestanas = <Widget>[
    InicioScreen(),
    ExplorarScreen(),
    MiListaScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _indice, children: _pestanas)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        onTap: (i) => setState(() => _indice = i),
        backgroundColor: Colores.fondo,
        selectedItemColor: Colores.primario,
        unselectedItemColor: Colores.textoSecundario,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border), label: 'Mi lista'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
