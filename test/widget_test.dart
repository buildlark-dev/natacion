import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:natacion_app/main.dart';
import 'package:natacion_app/ui/editor/pantalla_editor.dart';
import 'package:natacion_app/ui/generacion/pantalla_peticion.dart';

void main() {
  // rootBundle cachea la carga del recurso entre pruebas del mismo archivo. Si
  // una prueba termina con la carga a medias, las siguientes heredan ese
  // estado y nunca ven la app.
  setUp(rootBundle.clear);

  /// Abre la app y espera a que la Biblioteca Oficial termine de cargar.
  ///
  /// No se usa `pumpAndSettle`: el indicador de carga anima sin fin y nunca
  /// llegaría a estabilizarse.
  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(const AppNatacion());

    for (var intento = 0; intento < 20; intento++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  /// Cambia a la pestaña del editor.
  Future<void> irAlEditor(WidgetTester tester) async {
    await tester.tap(find.text('Editor'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('mientras carga la biblioteca muestra el indicador',
      (tester) async {
    await tester.pumpWidget(const AppNatacion());

    // Sin biblioteca no se puede comprobar la regla de no invención, así que
    // nada se muestra hasta tenerla.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('cargada la biblioteca, abre el generador', (tester) async {
    await abrirApp(tester);

    expect(find.byType(PantallaPeticion), findsOneWidget);
    expect(find.text('Generar microciclo'), findsOneWidget);
  });

  testWidgets('el generador pide los datos del protocolo de inicio',
      (tester) async {
    await abrirApp(tester);

    expect(find.text('El nadador o el grupo'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Diagnóstico y limitaciones'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );

    expect(find.text('La semana'), findsOneWidget);
    expect(find.text('Diagnóstico y limitaciones'), findsOneWidget);
  });

  testWidgets('el generador avisa de que las lesiones no modifican el plan',
      (tester) async {
    await abrirApp(tester);

    await tester.dragUntilVisible(
      find.textContaining('NO modifican el plan'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );

    expect(
      find.textContaining('NO modifican el plan'),
      findsOneWidget,
      reason: 'El principio IV prohíbe simular criterio clínico',
    );
  });

  testWidgets('la app tiene las tres pestañas', (tester) async {
    await abrirApp(tester);

    expect(find.text('Generar'), findsOneWidget);
    expect(find.text('Editor'), findsOneWidget);
    expect(find.text('Nadadores'), findsOneWidget);
  });

  testWidgets('se puede pasar al editor', (tester) async {
    await abrirApp(tester);
    await irAlEditor(tester);

    expect(find.byType(PantallaEditor), findsOneWidget);
    expect(find.text('Editor de sesión'), findsOneWidget);
  });

  testWidgets('el editor muestra las tres partes de la sesión',
      (tester) async {
    await abrirApp(tester);
    await irAlEditor(tester);

    expect(find.text('Inicial'), findsWidgets);
    expect(find.text('Central'), findsWidgets);
    expect(find.text('Final'), findsWidgets);
  });

  testWidgets('una sesión recién abierta se declara incompleta',
      (tester) async {
    await abrirApp(tester);
    await irAlEditor(tester);

    await tester.dragUntilVisible(
      find.text('Sesión incompleta'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );

    expect(find.text('Sesión incompleta'), findsOneWidget);
  });

  testWidgets('al escribir una serie se calculan los metros', (tester) async {
    await abrirApp(tester);
    await irAlEditor(tester);

    await tester.enterText(find.byType(TextField).last, '4x100 AL / 2\'');
    await tester.pump();

    expect(find.textContaining('400 m'), findsWidgets);
  });
}
