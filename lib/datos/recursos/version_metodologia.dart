/// Lectura de la versión de metodología vigente.
///
/// Decisión D4: `docs/metodologia/metodologia.json` declara la versión y la
/// huella de cada documento normativo. La app estampa esa versión en cada plan
/// que se aprueba (FR-026).
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

const String rutaManifiesto = 'docs/metodologia/metodologia.json';

/// Versión que se usa si el manifiesto no está disponible.
///
/// No se inventa un número: se marca explícitamente como desconocida, para que
/// un plan nunca quede sellado con una versión falsa.
const String versionDesconocida = 'desconocida';

class CargadorVersionMetodologia {
  String? _cache;

  Future<String> cargar() async {
    final enCache = _cache;
    if (enCache != null) return enCache;

    try {
      final texto = await rootBundle.loadString(rutaManifiesto);
      final json = jsonDecode(texto) as Map<String, dynamic>;
      final version = json['version'] as String?;
      _cache = version ?? versionDesconocida;
    } on Exception {
      _cache = versionDesconocida;
    }

    return _cache!;
  }
}
