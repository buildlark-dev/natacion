/// Carga de la Biblioteca Oficial desde el recurso empaquetado.
///
/// Decisión D3: la biblioteca viaja con la app, no en la base de datos. Así
/// está disponible sin conexión y siempre coincide con la versión instalada,
/// que es lo que permite validar la regla de no invención en todo momento.
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';

const String rutaBiblioteca = 'assets/biblioteca/ejercicios.json';

class CargadorBiblioteca {
  Biblioteca? _cache;

  /// Carga la biblioteca una sola vez y la reutiliza.
  Future<Biblioteca> cargar() async {
    final enCache = _cache;
    if (enCache != null) return enCache;

    final texto = await rootBundle.loadString(rutaBiblioteca);
    final json = jsonDecode(texto) as Map<String, dynamic>;
    final biblioteca = Biblioteca.desdeJson(json);
    _cache = biblioteca;
    return biblioteca;
  }
}
