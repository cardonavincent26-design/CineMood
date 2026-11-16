import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/contenido.dart';
import 'providers/app_provider.dart';
import 'screens/creditos_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/gustos_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mood_screen.dart';
import 'screens/principal_screen.dart';
import 'screens/registro_screen.dart';
import 'utils/colores.dart';
import 'utils/navegador.dart';
import 'utils/rutas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = AppProvider();
  await app.restaurarSesion(); // lee el token guardado (no llama a la API)
  runApp(
    ChangeNotifierProvider.value(
      value: app,
      child: CineMoodApp(inicio: app.haIniciadoSesion ? const PrincipalScreen() : const LoginScreen()),
    ),
  );
}

class CineMoodApp extends StatelessWidget {
  final Widget inicio;
  const CineMoodApp({super.key, required this.inicio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineMood',
      debugShowCheckedModeBanner: false,
      navigatorKey: navegadorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colores.fondo,
        colorScheme: const ColorScheme.dark(primary: Colores.primario),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colores.fondo,
          elevation: 0,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: inicio,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Rutas.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case Rutas.registro:
            return MaterialPageRoute(builder: (_) => const RegistroScreen());
          case Rutas.gustos:
            return MaterialPageRoute(builder: (_) => const GustosScreen());
          case Rutas.mood:
            final edicion = settings.arguments == true;
            return MaterialPageRoute(builder: (_) => MoodScreen(edicion: edicion));
          case Rutas.principal:
            return MaterialPageRoute(builder: (_) => const PrincipalScreen());
          case Rutas.detalle:
            final contenido = settings.arguments as Contenido;
            return MaterialPageRoute(builder: (_) => DetalleScreen(contenido: contenido));
          case Rutas.historial:
            return MaterialPageRoute(builder: (_) => const HistorialScreen());
          case Rutas.creditos:
            return MaterialPageRoute(builder: (_) => const CreditosScreen());
        }
        return null;
      },
    );
  }
}
