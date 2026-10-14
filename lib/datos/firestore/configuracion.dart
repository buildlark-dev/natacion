/// Conexión a Firestore.
///
/// Mientras se desarrolla en local, la app apunta a los **emuladores**, nunca a
/// un proyecto real. La bandera `USAR_EMULADORES` es falsa por omisión, de modo
/// que un arranque descuidado no escriba en la nube.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Identificador ficticio. Los emuladores lo aceptan sin que exista nada en la
/// nube, y así no hay riesgo de tocar un proyecto real por descuido.
const String proyectoLocal = 'demo-natacion';

const String hostEmulador = 'localhost';
const int puertoFirestore = 8080;

/// Cómo se arranca Firebase. Se inyecta para poder comprobar en pruebas que un
/// arranque fallido deja la app en pie; en producción es siempre la de verdad.
typedef IniciarFirebase = Future<FirebaseApp> Function({
  String? name,
  FirebaseOptions? options,
});

class ConfiguracionDatos {
  const ConfiguracionDatos({
    required this.usarEmuladores,
    this.iniciar = Firebase.initializeApp,
  });

  final bool usarEmuladores;

  final IniciarFirebase iniciar;

  /// Opciones con las que se arranca Firebase.
  ///
  /// Contra emuladores, un proyecto ficticio. Sin emuladores, ninguna: la
  /// configuración la pone la plataforma, y si no la hay, no hay proyecto al
  /// que conectarse y [conectar] devuelve `null`.
  FirebaseOptions? get opciones => usarEmuladores
      ? const FirebaseOptions(
          apiKey: 'emulador-local',
          appId: 'emulador-local',
          messagingSenderId: 'emulador-local',
          projectId: proyectoLocal,
        )
      : null;

  /// Inicializa Firebase y, si procede, redirige a los emuladores.
  ///
  /// Devuelve `null` si la inicialización falla: la app debe poder arrancar y
  /// explicarlo, no caerse.
  Future<FirebaseFirestore?> conectar() async {
    try {
      await iniciar(options: opciones);

      final firestore = FirebaseFirestore.instance;

      if (usarEmuladores) {
        firestore.useFirestoreEmulator(hostEmulador, puertoFirestore);
      }

      // La persistencia va activada **también contra los emuladores**, y no es
      // un descuido: el escenario C1 del quickstart —abrir la app en modo avión
      // y ver la sesión del día— no se puede verificar en local si la caché
      // está desactivada. Verificar sin conexión con la caché apagada sería
      // verificar otra cosa.
      //
      // Decisión D1 de `specs/003-consumo-del-nadador/research.md`: la lectura
      // se apoya en la caché de Firestore; la escritura, en una bandeja de
      // salida propia.
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      return firestore;
    } catch (_) {
      // Se atrapa cualquier fallo, no solo las excepciones. En web, arrancar
      // sin opciones revienta con un `AssertionError`, que es un `Error` y no
      // una `Exception`: atrapar solo excepciones dejaba caer la app entera en
      // el arranque documentado `flutter run -d chrome`.
      //
      // Aquí no hay nada que distinguir: con Firestore o sin él, lo único que
      // cambia es que no hay destino remoto. Quedarse sin conexión no es un
      // error de programa, es el martes a pie de piscina.
      return null;
    }
  }
}
