import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:cinemood/main.dart';
import 'package:cinemood/providers/app_provider.dart';
import 'package:cinemood/screens/login_screen.dart';

void main() {
  testWidgets('Sin sesión se muestra la pantalla de inicio de sesión', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const CineMoodApp(inicio: LoginScreen()),
      ),
    );

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear una cuenta'), findsOneWidget);
  });
}
