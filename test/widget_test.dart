import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natacion_app/main.dart';

void main() {
  testWidgets('la app arranca y muestra su título', (tester) async {
    await tester.pumpWidget(const AppNatacion());

    expect(find.text('Planificación de natación'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('sin la bandera de emuladores no anuncia conexión a datos',
      (tester) async {
    await tester.pumpWidget(const AppNatacion());

    // `usarEmuladores` es falsa por omisión, de modo que un arranque
    // descuidado nunca escriba en un proyecto real.
    expect(find.text('Sin conexión a datos'), findsOneWidget);
  });
}
