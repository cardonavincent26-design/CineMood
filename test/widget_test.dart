import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:cinemood/main.dart';
import 'package:cinemood/providers/app_provider.dart';

void main() {
  testWidgets('Login lleva a la pantalla de estado de ánimo', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const CineMoodApp(),
      ),
    );

    expect(find.text('Iniciar sesión'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'a@correo.com');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('¿Cómo te sientes hoy?'), findsOneWidget);
  });
}