/// La sesión activa, para la interfaz.
///
/// Escucha a [Identidad] y expone la cuenta a quien la necesite. Nada más: la
/// decisión de qué puede hacer cada quien vive en
/// `lib/dominio/cuentas/permisos.dart`, y hacerla cumplir es de las reglas de
/// acceso.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:natacion_app/dominio/cuentas/cuenta.dart';
import 'package:natacion_app/dominio/repositorios/repositorios.dart';

/// En qué punto está la sesión.
///
/// `comprobando` existe a propósito y no se colapsa con `fuera`. Al abrir la
/// app hay un instante en que todavía no se sabe quién eres, y enseñar la
/// pantalla de acceso en ese instante haría parpadear a quien ya tiene sesión
/// cada vez que abre la app a pie de piscina.
enum EstadoDeSesion { comprobando, dentro, fuera }

class SesionActiva extends ChangeNotifier {
  SesionActiva({required this.identidad}) {
    _suscripcion = identidad.cambios.listen(_actualizar);
    unawaited(_primera());
  }

  final Identidad identidad;

  StreamSubscription<Cuenta?>? _suscripcion;

  EstadoDeSesion _estado = EstadoDeSesion.comprobando;
  EstadoDeSesion get estado => _estado;

  Cuenta? _cuenta;
  Cuenta? get cuenta => _cuenta;

  bool get hayCuenta => _cuenta != null;

  Future<void> _primera() async {
    try {
      _actualizar(await identidad.actual());
    } on Exception {
      // Sin red ni caché no se puede resolver quién eres. Se trata como estar
      // fuera: la app enseña la pantalla de acceso en lugar de quedarse
      // comprobando para siempre.
      _actualizar(null);
    }
  }

  void _actualizar(Cuenta? cuenta) {
    _cuenta = cuenta;
    _estado = cuenta == null ? EstadoDeSesion.fuera : EstadoDeSesion.dentro;
    notifyListeners();
  }

  Future<void> cerrarSesion() => identidad.cerrarSesion();

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}
