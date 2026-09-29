import 'dart:convert';
import 'dart:io';

import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/dominio/notacion/analizador.dart';

/// Biblioteca real del proyecto, cargada desde el recurso empaquetado.
///
/// Las pruebas del analizador se hacen contra la biblioteca de verdad, no
/// contra una inventada: la regla de no invención solo se puede comprobar
/// frente a la fuente normativa.
Biblioteca cargarBibliotecaReal() {
  final json = jsonDecode(
    File('assets/biblioteca/ejercicios.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return Biblioteca.desdeJson(json);
}

Analizador crearAnalizador() =>
    Analizador(biblioteca: cargarBibliotecaReal());
