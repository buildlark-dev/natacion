/// Carga de la Biblioteca Oficial desde el recurso empaquetado.
///
/// Decisión D3: la biblioteca viaja con la app, no en la base de datos. Así
/// está disponible sin conexión y siempre coincide con la versión instalada,
/// que es lo que permite validar la regla de no invención en todo momento.
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/dominio/biblioteca/indice_terminos.dart';

const String rutaBiblioteca = 'assets/biblioteca/ejercicios.json';

/// Vocabulario de diagnóstico del entrenador (tarea T070).
///
/// Va en un archivo aparte a propósito: `ejercicios.json` lo **genera**
/// `tool/extraer_biblioteca.dart` desde la sección 19, así que cualquier
/// término escrito allí se perdería al regenerarlo. La sección 19 es normativa
/// y se extrae; el vocabulario es del entrenador y se declara.
const String rutaIndiceTerminos = 'assets/biblioteca/terminos_diagnostico.json';

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

class CargadorIndiceTerminos {
  IndiceTerminos? _cache;

  /// Carga el índice una sola vez y lo reutiliza.
  ///
  /// Si el recurso falta o está mal formado devuelve un índice **vacío** en
  /// lugar de fallar: la app sigue generando sin diagnóstico, y los
  /// diagnósticos se reportan como vacío de Biblioteca. Perder el vocabulario
  /// degrada la ayuda; no debe impedir planificar.
  Future<IndiceTerminos> cargar() async {
    final enCache = _cache;
    if (enCache != null) return enCache;

    IndiceTerminos indice;
    try {
      final texto = await rootBundle.loadString(rutaIndiceTerminos);
      final json = jsonDecode(texto) as Map<String, dynamic>;
      indice = IndiceTerminos.desdeJson(json);
    } on Exception {
      indice = IndiceTerminos.vacio();
    }

    _cache = indice;
    return indice;
  }
}
