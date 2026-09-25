import 'package:flutter/material.dart';
import 'package:natacion_app/datos/recursos/biblioteca_empaquetada.dart';
import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/ui/editor/estado_editor.dart';
import 'package:natacion_app/ui/editor/pantalla_editor.dart';
import 'package:provider/provider.dart';

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

/// Carga la Biblioteca Oficial antes de abrir el editor.
///
/// Sin biblioteca no se puede comprobar la regla de no invención, así que el
/// editor no se muestra hasta tenerla.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late final Future<Biblioteca> _biblioteca = CargadorBiblioteca().cargar();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Biblioteca>(
      future: _biblioteca,
      builder: (context, instantanea) {
        if (instantanea.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Planificación de natación')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo cargar la Biblioteca Oficial de ejercicios.\n'
                  'Sin ella no se puede comprobar la regla de no invención.\n\n'
                  '${instantanea.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (!instantanea.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ChangeNotifierProvider(
          create: (_) => EstadoEditor(biblioteca: instantanea.data!),
          child: const PantallaEditor(),
        );
      },
    );
  }
}
