import 'package:flutter/material.dart';
import 'package:natacion_app/datos/memoria/repositorios_memoria.dart';
import 'package:natacion_app/datos/recursos/biblioteca_empaquetada.dart';
import 'package:natacion_app/datos/recursos/version_metodologia.dart';
import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/dominio/repositorios/repositorios.dart';
import 'package:natacion_app/ui/editor/estado_editor.dart';
import 'package:natacion_app/dominio/generacion/resultado.dart';
import 'package:natacion_app/ui/editor/pantalla_editor.dart';
import 'package:natacion_app/ui/generacion/pantalla_peticion.dart';
import 'package:natacion_app/ui/nadadores/pantalla_perfiles.dart';
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

/// Todo lo que la app necesita cargar antes de empezar.
class RecursosIniciales {
  const RecursosIniciales({
    required this.biblioteca,
    required this.versionMetodologia,
  });

  final Biblioteca biblioteca;
  final String versionMetodologia;
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

/// Carga la Biblioteca Oficial y la versión de metodología antes de abrir la
/// app. Sin biblioteca no se puede comprobar la regla de no invención, así que
/// no se muestra nada hasta tenerla.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late final Future<RecursosIniciales> _recursos = _cargar();

  Future<RecursosIniciales> _cargar() async {
    final biblioteca = await CargadorBiblioteca().cargar();
    final version = await CargadorVersionMetodologia().cargar();
    return RecursosIniciales(
      biblioteca: biblioteca,
      versionMetodologia: version,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecursosIniciales>(
      future: _recursos,
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

        return PantallaPrincipal(recursos: instantanea.data!);
      },
    );
  }
}

/// Navegación entre el editor de sesión y los perfiles de nadador.
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key, required this.recursos});

  final RecursosIniciales recursos;

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indice = 0;

  final RepositorioNadadores _nadadores = RepositorioNadadoresMemoria();

  /// Un solo estado de editor para toda la app, para que lo generado en la
  /// primera pestaña aparezca en la segunda.
  late final EstadoEditor _editor =
      EstadoEditor(biblioteca: widget.recursos.biblioteca);

  @override
  void dispose() {
    _editor.dispose();
    super.dispose();
  }

  void _abrirGenerado(MicrocicloGenerado generado) {
    _editor.abrirGenerado(generado.plan);
    setState(() => _indice = 1);
  }

  @override
  Widget build(BuildContext context) {
    final pantallas = <Widget>[
      PantallaPeticion(
        biblioteca: widget.recursos.biblioteca,
        alGenerar: _abrirGenerado,
      ),
      ChangeNotifierProvider<EstadoEditor>.value(
        value: _editor,
        child: const PantallaEditor(),
      ),
      PantallaPerfiles(repositorio: _nadadores),
    ];

    return Scaffold(
      body: pantallas[_indice],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) => setState(() => _indice = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Generar',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Editor',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Nadadores',
          ),
        ],
      ),
    );
  }
}
