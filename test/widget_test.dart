import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:natacion_app/main.dart';
import 'package:natacion_app/ui/editor/pantalla_editor.dart';

void main() {
  // rootBundle cachea la carga del recurso entre pruebas del mismo archivo. Si
  // una prueba termina con la carga a medias, las siguientes heredan ese
  // estado y nunca ven el editor.
  setUp(rootBundle.clear);

  /// Abre la app en una superficie de escritorio y espera a que la Biblioteca
  /// Oficial termine de cargar.
  ///
  /// No se usa `pumpAndSettle`: el indicador de carga anima sin fin y nunca
  /// llegaría a estabilizarse.
  Future<void> abrirEditor(WidgetTester tester) async {
    await tester.pumpWidget(const AppNatacion());

    // La carga del recurso es asíncrona de verdad, así que hay que dejar
    // correr el reloj real hasta que el editor aparezca.
    for (var intento = 0; intento < 20; intento++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  testWidgets('mientras carga la biblioteca muestra el indicador',
      (tester) async {
    await tester.pumpWidget(const AppNatacion());

    // Sin biblioteca no se puede comprobar la regla de no invención, así que
    // el editor no se muestra hasta tenerla.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('cargada la biblioteca, abre el editor', (tester) async {
    await abrirEditor(tester);

    expect(find.byType(PantallaEditor), findsOneWidget);
    expect(find.text('Editor de sesión'), findsOneWidget);
  });

  testWidgets('el editor muestra las tres partes de la sesión',
      (tester) async {
    await abrirEditor(tester);

    expect(find.text('Inicial'), findsWidgets);
    expect(find.text('Central'), findsWidgets);
    expect(find.text('Final'), findsWidgets);
  });

  testWidgets('una sesión recién abierta se declara incompleta',
      (tester) async {
    await abrirEditor(tester);

    // En pantalla estrecha el panel de avisos queda bajo las tres partes.
    await tester.dragUntilVisible(
      find.text('Sesión incompleta'),
      find.byType(ListView),
      const Offset(0, -300),
    );

    expect(find.text('Sesión incompleta'), findsOneWidget);
  });

  testWidgets('al escribir una serie se calculan los metros', (tester) async {
    await abrirEditor(tester);

    await tester.enterText(find.byType(TextField).last, '4x100 AL / 2\'');
    await tester.pump();

    // El total aparece en la barra superior.
    expect(find.textContaining('400 m'), findsWidgets);
  });
}
