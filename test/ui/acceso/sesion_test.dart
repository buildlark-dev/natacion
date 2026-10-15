import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:natacion_app/dominio/cuentas/cuenta.dart';
import 'package:natacion_app/dominio/repositorios/repositorios.dart';
import 'package:natacion_app/ui/acceso/estado_sesion.dart';

/// El estado de sesión, que es lo que decide qué ve cada quien al abrir.
///
/// Se prueba contra un doble de [Identidad] y no contra Firebase: lo que hay
/// que comprobar es la decisión, no la librería.
void main() {
  group('al abrir la app', () {
    test('no se enseña la pantalla de acceso antes de saber quién eres', () {
      // Es el parpadeo que vería a diario quien ya tiene sesión. El estado
      // «comprobando» existe para eso y no se colapsa con «fuera».
      final sesion = SesionActiva(identidad: _IdentidadFalsa());

      expect(sesion.estado, EstadoDeSesion.comprobando);
      expect(sesion.hayCuenta, isFalse);
    });

    test('con sesión guardada se entra directo', () async {
      final identidad = _IdentidadFalsa(
        inicial: Cuenta(id: 'u1', rol: Rol.nadador, nadadorId: 'n1'),
      );
      final sesion = SesionActiva(identidad: identidad);

      await _unCiclo();

      expect(sesion.estado, EstadoDeSesion.dentro);
      expect(sesion.cuenta!.nadadorId, 'n1');
    });

    test('sin sesión guardada se queda fuera', () async {
      final sesion = SesionActiva(identidad: _IdentidadFalsa());
      await _unCiclo();

      expect(sesion.estado, EstadoDeSesion.fuera);
    });

    test('si no se puede resolver quién eres, se trata como estar fuera', () async {
      // Sin red y sin caché. Quedarse «comprobando» para siempre dejaría la
      // app con un indicador de carga que no termina nunca.
      final sesion = SesionActiva(identidad: _IdentidadFalsa(revienta: true));
      await _unCiclo();

      expect(sesion.estado, EstadoDeSesion.fuera);
    });
  });

  group('cerrar sesión', () {
    test('deja la sesión fuera', () async {
      final identidad = _IdentidadFalsa(
        inicial: Cuenta(id: 'u1', rol: Rol.nadador, nadadorId: 'n1'),
      );
      final sesion = SesionActiva(identidad: identidad);
      await _unCiclo();
      expect(sesion.estado, EstadoDeSesion.dentro);

      await sesion.cerrarSesion();
      await _unCiclo();

      expect(sesion.estado, EstadoDeSesion.fuera);
      expect(sesion.cuenta, isNull);
    });

    test('pide vaciar el dispositivo, no solo cerrar la sesión', () async {
      // Garantía A7. Si solo cerrara la sesión, el siguiente hermano que
      // entrase en ese teléfono encontraría lo del anterior en la caché.
      final identidad = _IdentidadFalsa(
        inicial: Cuenta(id: 'u1', rol: Rol.nadador, nadadorId: 'n1'),
      );
      final sesion = SesionActiva(identidad: identidad);
      await _unCiclo();

      await sesion.cerrarSesion();

      expect(identidad.vaciados, 1);
    });
  });

  group('cambiar de cuenta en el mismo dispositivo', () {
    test('la cuenta activa pasa a ser la nueva, sin rastro de la anterior', () async {
      final identidad = _IdentidadFalsa(
        inicial: Cuenta(id: 'u-mayor', rol: Rol.nadador, nadadorId: 'n1'),
      );
      final sesion = SesionActiva(identidad: identidad);
      await _unCiclo();

      await sesion.cerrarSesion();
      identidad.entra(Cuenta(id: 'u-menor', rol: Rol.nadador, nadadorId: 'n2'));
      await _unCiclo();

      expect(sesion.cuenta!.id, 'u-menor');
      expect(sesion.cuenta!.nadadorId, 'n2');
    });
  });

  group('el rol decide qué se ve', () {
    test('una cuenta de entrenador se reconoce como tal', () async {
      final sesion = SesionActiva(
        identidad: _IdentidadFalsa(
          inicial: Cuenta(id: 'u-e', rol: Rol.entrenador),
        ),
      );
      await _unCiclo();

      expect(sesion.cuenta!.esEntrenador, isTrue);
      expect(sesion.cuenta!.esNadador, isFalse);
    });

    test('una cuenta sin perfil asociado entra igual', () async {
      // No es un error: es el día en que alguien se registra antes de que su
      // entrenador lo inscriba. Entra, y lo que ve es que no tiene nada.
      final sesion = SesionActiva(
        identidad: _IdentidadFalsa(inicial: Cuenta(id: 'u-s', rol: Rol.nadador)),
      );
      await _unCiclo();

      expect(sesion.estado, EstadoDeSesion.dentro);
      expect(sesion.cuenta!.sinPerfilAsociado, isTrue);
    });
  });
}

/// Deja correr los futuros pendientes.
Future<void> _unCiclo() => Future<void>.delayed(Duration.zero);

class _IdentidadFalsa implements Identidad {
  _IdentidadFalsa({Cuenta? inicial, this.revienta = false})
      : _cuenta = inicial;

  Cuenta? _cuenta;
  final bool revienta;

  /// Cuántas veces se pidió vaciar el dispositivo.
  int vaciados = 0;

  final _control = StreamController<Cuenta?>.broadcast();

  void entra(Cuenta cuenta) {
    _cuenta = cuenta;
    _control.add(cuenta);
  }

  @override
  Future<Cuenta?> actual() async {
    if (revienta) throw const FalloDeAcceso('sin red y sin caché');
    return _cuenta;
  }

  @override
  Stream<Cuenta?> get cambios => _control.stream;

  @override
  Future<void> cerrarSesion() async {
    vaciados++;
    _cuenta = null;
    _control.add(null);
  }

  @override
  Future<void> entrar({required String correo, required String clave}) async {
    entra(Cuenta(id: 'u-$correo', rol: Rol.nadador));
  }

  @override
  Future<void> crearCuenta({
    required String correo,
    required String clave,
  }) async {
    entra(Cuenta(id: 'u-$correo', rol: Rol.nadador));
  }
}
