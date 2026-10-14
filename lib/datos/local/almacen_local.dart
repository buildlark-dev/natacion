/// Almacenamiento en el dispositivo.
///
/// Decisión D7 de `specs/003-consumo-del-nadador/research.md`: se guarda sobre
/// `shared_preferences`, un documento JSON por clave. Es lo más pequeño que
/// funciona en web y en móvil sin arrastrar un esquema ni migraciones.
///
/// **Es lo que sostiene la promesa de la feature.** Si esto no persiste de
/// verdad entre reaperturas, el nadador pierde lo que escribió sin conexión, y
/// FR-019 dice que eso no puede pasar.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lo que el dominio necesita de un almacén, sin saber qué hay debajo.
///
/// Se declara aquí y no en `lib/dominio/` porque es una capacidad de
/// infraestructura, no una regla de entrenamiento. El dominio depende de
/// `RepositorioRegistros` y `BandejaDeSalida`, que sí son suyas.
abstract class AlmacenLocal {
  /// Documentos de una colección, por clave.
  Future<Map<String, Map<String, dynamic>>> leerTodo(String coleccion);

  Future<Map<String, dynamic>?> leer(String coleccion, String clave);

  Future<void> escribir(
    String coleccion,
    String clave,
    Map<String, dynamic> documento,
  );

  Future<void> borrar(String coleccion, String clave);

  /// Borra una colección entera. Es lo que hace posible el derecho al borrado
  /// del principio V sin rediseñar nada.
  Future<void> borrarColeccion(String coleccion);
}

/// Fallo al escribir en el dispositivo.
///
/// **Este sí se reporta** (garantía S8 del contrato de sincronización): un
/// fallo de red deja el registro pendiente y se reintenta, pero un fallo de
/// escritura local significa que el dato se perdería, y eso el nadador tiene
/// que saberlo.
class FalloDeAlmacenLocal implements Exception {
  const FalloDeAlmacenLocal(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

class AlmacenPreferencias implements AlmacenLocal {
  AlmacenPreferencias({SharedPreferences? preferencias})
      : _inyectadas = preferencias;

  final SharedPreferences? _inyectadas;
  SharedPreferences? _cache;

  Future<SharedPreferences> get _prefs async {
    final inyectadas = _inyectadas;
    if (inyectadas != null) return inyectadas;

    final enCache = _cache;
    if (enCache != null) return enCache;

    try {
      final abiertas = await SharedPreferences.getInstance();
      _cache = abiertas;
      return abiertas;
    } on Exception catch (e) {
      throw FalloDeAlmacenLocal('No se pudo abrir el almacén local: $e');
    }
  }

  /// Clave compuesta. El prefijo evita chocar con lo que guarde otra parte de
  /// la app en las mismas preferencias.
  String _clave(String coleccion, String clave) =>
      'natacion_app/$coleccion/$clave';

  String _prefijo(String coleccion) => 'natacion_app/$coleccion/';

  @override
  Future<Map<String, Map<String, dynamic>>> leerTodo(String coleccion) async {
    final prefs = await _prefs;
    final prefijo = _prefijo(coleccion);
    final resultado = <String, Map<String, dynamic>>{};

    for (final clave in prefs.getKeys()) {
      if (!clave.startsWith(prefijo)) continue;

      final crudo = prefs.getString(clave);
      if (crudo == null) continue;

      final documento = _decodificar(crudo);
      // Un documento corrupto se omite, no tumba la lectura entera: perder uno
      // es malo, perderlos todos es peor.
      if (documento == null) continue;

      resultado[clave.substring(prefijo.length)] = documento;
    }

    return resultado;
  }

  @override
  Future<Map<String, dynamic>?> leer(String coleccion, String clave) async {
    final prefs = await _prefs;
    final crudo = prefs.getString(_clave(coleccion, clave));
    if (crudo == null) return null;
    return _decodificar(crudo);
  }

  @override
  Future<void> escribir(
    String coleccion,
    String clave,
    Map<String, dynamic> documento,
  ) async {
    final prefs = await _prefs;

    final bool escrito;
    try {
      escrito = await prefs.setString(
        _clave(coleccion, clave),
        jsonEncode(documento),
      );
    } on Exception catch (e) {
      throw FalloDeAlmacenLocal('No se pudo guardar en el dispositivo: $e');
    }

    if (!escrito) {
      throw const FalloDeAlmacenLocal(
        'El dispositivo rechazó la escritura. El progreso no quedó guardado.',
      );
    }
  }

  @override
  Future<void> borrar(String coleccion, String clave) async {
    final prefs = await _prefs;
    await prefs.remove(_clave(coleccion, clave));
  }

  @override
  Future<void> borrarColeccion(String coleccion) async {
    final prefs = await _prefs;
    final prefijo = _prefijo(coleccion);
    final claves = prefs.getKeys().where((k) => k.startsWith(prefijo)).toList();
    for (final clave in claves) {
      await prefs.remove(clave);
    }
  }

  Map<String, dynamic>? _decodificar(String crudo) {
    try {
      final decodificado = jsonDecode(crudo);
      return decodificado is Map<String, dynamic> ? decodificado : null;
    } on FormatException {
      return null;
    }
  }
}
