import 'package:flutter/material.dart';

/// Punto de entrada de la aplicación.
///
/// `USAR_EMULADORES` se pasa con `--dart-define=USAR_EMULADORES=true` y decide
/// si la capa de datos apunta a los emuladores locales. Por omisión es falsa,
/// de modo que un arranque descuidado nunca escriba en un proyecto real.
const bool usarEmuladores =
    bool.fromEnvironment('USAR_EMULADORES', defaultValue: false);

void main() {
  runApp(const AppNatacion());
}

class AppNatacion extends StatelessWidget {
  const AppNatacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planificación de natación',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0B6E99),
        useMaterial3: true,
      ),
      home: const PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planificación de natación')),
      body: Center(
        child: Text(
          usarEmuladores
              ? 'Conectado a emuladores locales'
              : 'Sin conexión a datos',
        ),
      ),
    );
  }
}
