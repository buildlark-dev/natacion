import 'package:flutter/material.dart';
import 'package:natacion_app/datos/memoria/repositorios_memoria.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:natacion_app/datos/firestore/configuracion.dart';
import 'package:natacion_app/datos/firestore/envio_registros.dart';
import 'package:natacion_app/datos/local/almacen_local.dart';
import 'package:natacion_app/datos/local/repositorios_locales.dart';
import 'package:natacion_app/datos/recursos/biblioteca_empaquetada.dart';
import 'package:natacion_app/datos/red/estado_de_red.dart';
import 'package:natacion_app/dominio/entidades/nadador.dart';
import 'package:natacion_app/dominio/entidades/plan.dart';
import 'package:natacion_app/dominio/entidades/registro_sesion.dart';
import 'package:natacion_app/dominio/sincronizacion/bandeja_salida.dart';
import 'package:natacion_app/ui/nadador/estado_nadador.dart';
import 'package:natacion_app/ui/nadador/pantalla_mi_progreso.dart';
import 'package:natacion_app/ui/nadador/perfil_activo.dart';
import 'package:natacion_app/ui/planes/pantalla_plan.dart';
import 'package:natacion_app/ui/nadador/pantalla_sesion_del_dia.dart';
import 'package:natacion_app/datos/recursos/version_metodologia.dart';
import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/dominio/biblioteca/indice_terminos.dart';
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
    required this.indiceTerminos,
    required this.red,
    required this.transporte,
  });

  final Biblioteca biblioteca;
  final String versionMetodologia;

  /// Vocabulario de diagnóstico del entrenador. Puede venir vacío: entonces
  /// los diagnósticos se reportan como vacío de Biblioteca en lugar de
  /// resolverse con un ejercicio aproximado.
  final IndiceTerminos indiceTerminos;

  /// Si hay red, para el recorrido del nadador (feature 003).
  final EstadoDeRed red;

  /// Quién lleva los registros del nadador a su destino.
  final EnvioDeRegistros transporte;
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

  /// De todo lo que se carga aquí, **solo la biblioteca puede tumbar el
  /// arranque**. Es deliberado: sin ella no se puede comprobar la regla de no
  /// invención, así que no hay app que mostrar. Todo lo demás degrada: la
  /// versión de metodología se marca como desconocida, el índice de términos
  /// queda vacío y Firestore, si no está, deja la app trabajando en local.
  /// Si algún día otro recurso empieza a propagar, el mensaje de error de
  /// abajo pasa a mentir.
  Future<RecursosIniciales> _cargar() async {
    final biblioteca = await CargadorBiblioteca().cargar();
    final version = await CargadorVersionMetodologia().cargar();
    final indice = await CargadorIndiceTerminos().cargar();
    // Firestore puede no estar: sin credenciales, sin emuladores, o sin red.
    // **La app arranca igual.** El nadador lee y escribe en local, y lo
    // pendiente espera. Caerse porque no hay conexión sería justo lo contrario
    // de lo que esta feature promete.
    final datos =
        await const ConfiguracionDatos(usarEmuladores: usarEmuladores)
            .conectar();

    return RecursosIniciales(
      biblioteca: biblioteca,
      versionMetodologia: version,
      indiceTerminos: indice,
      // La detección de red sondea de verdad en lugar de preguntarle al
      // sistema: «hay wifi» y «el servidor responde» son cosas distintas, y a
      // pie de piscina la segunda es la que importa.
      red: RedPorSondeo(sondear: () async => datos != null),
      transporte: _TransporteSiHayFirestore(datos),
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

  /// Estado del recorrido del nadador (feature 003).
  ///
  /// Se monta sobre el almacén local y la bandeja de salida: **escribir no
  /// consulta la red**, y lo que quede pendiente viaja cuando vuelva.
  late final EstadoNadador _nadador = EstadoNadador(
    sincronizador: Sincronizador(
      registros: RegistrosLocales(_almacen),
      bandeja: BandejaLocal(_almacen),
      red: widget.recursos.red,
      transporte: widget.recursos.transporte,
    ),
  );

  final AlmacenLocal _almacen = AlmacenPreferencias();

  /// Los planes de la sesión. En memoria: la persistencia en Firestore llega
  /// con la autenticación de la feature 004.
  final List<Plan> _planes = [];

  late final RegistrosLocales _registros = RegistrosLocales(_almacen);

  /// Publica y asigna: es el puente entre el entrenador y el nadador.
  void _entregar(Plan publicado) {
    setState(() {
      _planes
        ..removeWhere((p) => p.id == publicado.id)
        ..add(publicado);
    });
  }

  /// Carga el perfil elegido con su plan publicado y sus registros.
  Future<void> _abrirComoNadador(Nadador nadador) async {
    final plan = planDe(nadador, _planes);
    final registros = plan == null
        ? <RegistroDeSesion>[]
        : await _registros.obtenerDePlan(nadador.id ?? '', plan.id ?? '');

    _nadador.abrirComo(nadador, plan: plan, registros: registros);
    await _nadador.sincronizar();
  }

  /// Abre el plan que se está revisando para aprobarlo y entregarlo.
  Future<void> _revisarPlan() async {
    final plan = _editor.planRevisado;
    if (plan == null) return;

    final nadadores = await _nadadores.listar();
    if (!mounted) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaPlan(
          plan: plan,
          versionMetodologia: widget.recursos.versionMetodologia,
          nadadores: nadadores,
          alEntregar: _entregar,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _editor.dispose();
    _nadador.dispose();
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
        indiceTerminos: widget.recursos.indiceTerminos,
        alGenerar: _abrirGenerado,
      ),
      ChangeNotifierProvider<EstadoEditor>.value(
        value: _editor,
        child: PantallaEditor(alRevisarPlan: _revisarPlan),
      ),
      PantallaPerfiles(repositorio: _nadadores),
      // El recorrido del nadador va en su propia pestaña y sobre su propio
      // estado. Es la feature 003: el nadador y el entrenador son dos
      // recorridos distintos sobre el mismo dominio, y mezclarlos en las mismas
      // pantallas haría que cada cambio para uno arriesgara al otro.
      ChangeNotifierProvider<EstadoNadador>.value(
        value: _nadador,
        child: PantallaSesionDelDia(
          selector: FutureBuilder<List<Nadador>>(
            future: _nadadores.listar(),
            builder: (context, instantanea) => SelectorDePerfil(
              estado: _nadador,
              nadadores: instantanea.data ?? const [],
              planes: _planes,
              alElegir: _abrirComoNadador,
            ),
          ),
        ),
      ),
      ChangeNotifierProvider<EstadoNadador>.value(
        value: _nadador,
        child: const PantallaMiProgreso(),
      ),
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
          NavigationDestination(
            icon: Icon(Icons.pool_outlined),
            selectedIcon: Icon(Icons.pool),
            label: 'Mi sesión',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Mi progreso',
          ),
        ],
      ),
    );
  }
}

/// Envía registros si hay Firestore, y si no, falla de forma recuperable.
///
/// Un fallo aquí deja el registro **pendiente** y se reintenta (garantía G3).
/// No es una excepción que el nadador deba ver: es el caso normal a pie de
/// piscina, y el único error que sí se le muestra es el de escritura local.
class _TransporteSiHayFirestore implements EnvioDeRegistros {
  const _TransporteSiHayFirestore(this.firestore);

  final FirebaseFirestore? firestore;

  @override
  Future<DateTime> enviar(RegistroDeSesion registro) {
    final instancia = firestore;
    if (instancia == null) {
      throw const FalloDeDatos('Sin conexión con el servidor');
    }
    return EnvioAFirestore(instancia).enviar(registro);
  }
}
