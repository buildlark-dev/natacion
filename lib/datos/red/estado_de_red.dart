/// Si hay red, para saber cuándo reintentar.
///
/// Implementa `EstadoDeRed` del dominio, que la bandeja de salida usa sin saber
/// cómo se detecta nada (principio II).
///
/// **La detección es deliberadamente tonta**: se intenta una escritura y se ve
/// si llega. No se consulta ningún servicio de conectividad del sistema, porque
/// «el teléfono dice que hay wifi» y «el servidor responde» son cosas distintas,
/// y a pie de piscina la segunda es la que importa. Una piscina con wifi que no
/// sale a internet es el caso normal, no el raro.
library;

import 'dart:async';

import 'package:natacion_app/dominio/repositorios/repositorios.dart';

class RedPorSondeo implements EstadoDeRed {
  RedPorSondeo({
    required this.sondear,
    this.intervalo = const Duration(seconds: 30),
  });

  /// Cómo se comprueba. Se inyecta para poder simular la red en las pruebas.
  final Future<bool> Function() sondear;
  final Duration intervalo;

  final StreamController<bool> _cambios = StreamController<bool>.broadcast();
  Timer? _temporizador;
  bool? _ultimoConocido;

  @override
  Future<bool> hayConexion() async {
    try {
      final hay = await sondear();
      _anotar(hay);
      return hay;
    } on Exception {
      _anotar(false);
      return false;
    }
  }

  @override
  Stream<bool> get cambios {
    _empezarAVigilar();
    return _cambios.stream;
  }

  /// Emite **solo cuando cambia**, no en cada sondeo: la bandeja reacciona a
  /// que la red vuelva, no a que siga ahí.
  void _anotar(bool hay) {
    if (_ultimoConocido == hay) return;
    _ultimoConocido = hay;
    if (!_cambios.isClosed) _cambios.add(hay);
  }

  void _empezarAVigilar() {
    _temporizador ??= Timer.periodic(intervalo, (_) => hayConexion());
  }

  /// Deja de vigilar. La interfaz del dominio no lo declara porque apagar un
  /// temporizador es un detalle de esta implementación.
  Future<void> cerrar() async {
    _temporizador?.cancel();
    _temporizador = null;
    await _cambios.close();
  }
}
