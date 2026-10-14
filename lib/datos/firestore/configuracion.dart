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

class ConfiguracionDatos {
  const ConfiguracionDatos({required this.usarEmuladores});

  final bool usarEmuladores;

  /// Inicializa Firebase y, si procede, redirige a los emuladores.
  ///
  /// Devuelve `null` si la inicialización falla: la app debe poder arrancar y
  /// explicarlo, no caerse.
  Future<FirebaseFirestore?> conectar() async {
    try {
      await Firebase.initializeApp(
        options: usarEmuladores
            ? const FirebaseOptions(
                apiKey: 'emulador-local',
                appId: 'emulador-local',
                messagingSenderId: 'emulador-local',
                projectId: proyectoLocal,
              )
            : null,
      );

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
    } on FirebaseException {
      return null;
    } on Exception {
      return null;
    }
  }
}
