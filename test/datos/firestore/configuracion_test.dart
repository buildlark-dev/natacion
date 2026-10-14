import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:natacion_app/datos/firestore/configuracion.dart';

/// Arrancar sin Firestore.
///
/// La app promete funcionar sin conexión: el nadador lee de la caché, escribe
/// en local y lo pendiente espera en la bandeja de salida. Esa promesa empieza
/// en el arranque. Si conectar con Firestore puede tumbar la app, no hay
/// recorrido sin conexión que valga.
///
/// Esto falló de verdad: `flutter run -d chrome` sin emuladores —el arranque
/// que documenta `docs/DEVELOPMENT.md`— dejaba una pantalla de error en lugar
/// de la app, porque `firebase_core_web` no lanza una `Exception` cuando no
/// hay opciones, lanza un `AssertionError`.
void main() {
  /// Un arranque de Firebase que nunca llega a buen puerto, y que además
  /// recuerda con qué opciones lo llamaron.
  ({IniciarFirebase iniciar, List<FirebaseOptions?> llamadas}) falla(
    Object queLanza,
  ) {
    final llamadas = <FirebaseOptions?>[];
    Future<FirebaseApp> iniciar({String? name, FirebaseOptions? options}) {
      llamadas.add(options);
      throw queLanza;
    }

    return (iniciar: iniciar, llamadas: llamadas);
  }

  group('un fallo al conectar no tumba la app', () {
    test('un AssertionError, que es el fallo real de la web', () async {
      final doble = falla(
        AssertionError('FirebaseOptions cannot be null when creating the '
            'default app.'),
      );

      final datos = await ConfiguracionDatos(
        usarEmuladores: false,
        iniciar: doble.iniciar,
      ).conectar();

      expect(
        datos,
        isNull,
        reason: 'Un AssertionError es un Error, no una Exception. Atrapar '
            'solo excepciones es lo que dejó la app en una pantalla de error',
      );
    });

    test('una FirebaseException', () async {
      final doble = falla(
        FirebaseException(plugin: 'core', message: 'no hay proyecto'),
      );

      final datos = await ConfiguracionDatos(
        usarEmuladores: false,
        iniciar: doble.iniciar,
      ).conectar();

      expect(datos, isNull);
    });

    test('una excepción cualquiera', () async {
      final doble = falla(const FormatException('configuración ilegible'));

      final datos = await ConfiguracionDatos(
        usarEmuladores: true,
        iniciar: doble.iniciar,
      ).conectar();

      expect(datos, isNull);
    });

    test('tampoco con los emuladores apagados', () async {
      // El caso de todos los días: se arranca la app y no se levantaron los
      // emuladores. No hay nada que avisar, se trabaja en local.
      final doble = falla(
        Exception('Connection refused: localhost:8080'),
      );

      final datos = await ConfiguracionDatos(
        usarEmuladores: true,
        iniciar: doble.iniciar,
      ).conectar();

      expect(datos, isNull);
    });
  });

  group('nunca se apunta a un proyecto real por descuido', () {
    test('con emuladores se arranca con el proyecto ficticio', () async {
      final doble = falla(Exception('da igual, ya se registró la llamada'));

      await ConfiguracionDatos(
        usarEmuladores: true,
        iniciar: doble.iniciar,
      ).conectar();

      expect(doble.llamadas.single?.projectId, proyectoLocal);
      expect(doble.llamadas.single?.projectId, 'demo-natacion');
    });

    test('sin emuladores no se inventan opciones', () async {
      // Sin opciones, la configuración la pone la plataforma. Si no la hay,
      // no hay proyecto al que conectarse, y eso es exactamente lo que debe
      // pasar: ningún identificador escrito a mano aquí puede acabar
      // apuntando a la nube de alguien.
      final doble = falla(Exception('sin configuración de plataforma'));

      await ConfiguracionDatos(
        usarEmuladores: false,
        iniciar: doble.iniciar,
      ).conectar();

      expect(doble.llamadas.single, isNull);
    });

    test('la bandera por omisión es falsa', () {
      const porOmision = ConfiguracionDatos(usarEmuladores: false);
      expect(porOmision.opciones, isNull);
    });
  });
}
