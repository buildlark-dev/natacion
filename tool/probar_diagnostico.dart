/// Herramienta para la tarea T070: comprobar la correspondencia entre los
/// errores que el entrenador diagnostica de verdad y el campo «error que
/// corrige» de la Biblioteca Oficial.
///
/// Ese campo está escrito en prosa libre, y el selector lo busca por término
/// contenido. Es el punto más débil del generador: puede fallar en los dos
/// sentidos —no encontrar un ejercicio que servía, o traer uno que no ataca el
/// error— y solo el criterio del entrenador puede decir cuál de los dos pasó.
///
/// Uso:
///
///   dart run tool/probar_diagnostico.dart "codo caido" "poca patada"
///   dart run tool/probar_diagnostico.dart --estilo espalda "rolido insuficiente"
///   dart run tool/probar_diagnostico.dart --vocabulario
///
/// Sin argumentos, muestra la ayuda.
library;

import 'dart:convert';
import 'dart:io';

import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/dominio/generacion/selector_ejercicios.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';

void main(List<String> argumentos) {
  final biblioteca = _cargarBiblioteca();

  if (argumentos.isEmpty || argumentos.contains('--ayuda')) {
    _mostrarAyuda();
    return;
  }

  if (argumentos.contains('--vocabulario')) {
    _mostrarVocabulario(biblioteca);
    return;
  }

  final estilos = _estilosPedidos(argumentos);
  final frases = argumentos
      .where((a) => !a.startsWith('--'))
      .where((a) => !_esValorDeEstilo(argumentos, a))
      .toList();

  if (frases.isEmpty) {
    stdout.writeln('No diste ninguna frase de diagnóstico que probar.');
    stdout.writeln('');
    _mostrarAyuda();
    exitCode = 1;
    return;
  }

  final selector = SelectorEjercicios(biblioteca);
  var sinCoincidencia = 0;

  for (final frase in frases) {
    stdout.writeln('');
    stdout.writeln('─' * 72);
    stdout.writeln('DIAGNÓSTICO: «$frase»');
    stdout.writeln('─' * 72);

    for (final estilo in estilos) {
      final seleccion = selector.elegir(
        estilo: estilo,
        diagnostico: [frase],
        cuantos: 99,
      );

      if (seleccion.vacios.isNotEmpty) {
        sinCoincidencia++;
        stdout.writeln('  ${estilo.nombre.padRight(10)} SIN COINCIDENCIA');
        stdout.writeln(
          '  ${' '.padRight(10)} (el generador reportaría el vacío y no '
          'sustituiría por otro ejercicio)',
        );
        continue;
      }

      stdout.writeln(
        '  ${estilo.nombre.padRight(10)} ${seleccion.ejercicios.length} '
        'ejercicio(s):',
      );
      for (final ejercicio in seleccion.ejercicios) {
        stdout.writeln('  ${' '.padRight(10)} · ${ejercicio.nombre}');
        stdout.writeln(
          '  ${' '.padRight(10)}   corrige: ${ejercicio.errorQueCorrige}',
        );
      }
    }
  }

  stdout.writeln('');
  stdout.writeln('═' * 72);
  stdout.writeln(
    'Revisadas ${frases.length} frase(s) sobre ${estilos.length} estilo(s). '
    '$sinCoincidencia combinación(es) sin coincidencia.',
  );
  stdout.writeln('');
  stdout.writeln('Qué anotar, para cada frase:');
  stdout.writeln('  1. Si salió SIN COINCIDENCIA pero tú sí tienes un');
  stdout.writeln('     ejercicio para ese error: falta un término en el campo');
  stdout.writeln('     «error que corrige» de ese ejercicio.');
  stdout.writeln('  2. Si trajo ejercicios que NO atacan ese error: sobra un');
  stdout.writeln('     término, o la frase es demasiado genérica.');
  stdout.writeln('  3. Si trajo los correctos: esa frase queda validada.');
}

void _mostrarAyuda() {
  stdout.writeln('''
Comprueba qué ejercicios encuentra la app cuando le declaras un error técnico.

  dart run tool/probar_diagnostico.dart "codo caido" "poca patada"
  dart run tool/probar_diagnostico.dart --estilo espalda "rolido insuficiente"
  dart run tool/probar_diagnostico.dart --vocabulario

Opciones:
  --estilo <nombre>   Limita a un estilo: libre, espalda, pecho, mariposa,
                      general. Sin esta opción se prueban todos.
  --vocabulario       Lista los 70 ejercicios con su campo «error que corrige»,
                      para ver con qué palabras está escrita la Biblioteca.
  --ayuda             Muestra esto.

La búsqueda es por término contenido, sin tildes y sin distinguir mayúsculas:
la frase que escribas tiene que aparecer dentro del texto del campo. Por eso
conviene probar con frases cortas («codo caido») antes que con oraciones.''');
}

void _mostrarVocabulario(Biblioteca biblioteca) {
  stdout.writeln('VOCABULARIO DE LA BIBLIOTECA — campo «error que corrige»');
  stdout.writeln('');
  stdout.writeln(
    'Con estas palabras está escrita la Biblioteca. Una frase de diagnóstico '
    'solo\nencuentra un ejercicio si aparece contenida en su texto.',
  );

  for (final estilo in Estilo.values) {
    final delEstilo =
        biblioteca.todos.where((e) => e.estilo == estilo).toList();
    if (delEstilo.isEmpty) continue;

    stdout.writeln('');
    stdout.writeln('── ${estilo.nombre.toUpperCase()} '
        '(${delEstilo.length}) ${'─' * 40}');
    for (final ejercicio in delEstilo) {
      stdout.writeln('  ${ejercicio.nombre}');
      stdout.writeln('    ${ejercicio.errorQueCorrige}');
    }
  }

  stdout.writeln('');
  stdout.writeln('Total: ${biblioteca.cantidad} ejercicios.');
}

/// Estilos sobre los que probar: el pedido con `--estilo`, o todos.
List<Estilo> _estilosPedidos(List<String> argumentos) {
  final indice = argumentos.indexOf('--estilo');
  if (indice == -1 || indice + 1 >= argumentos.length) {
    return Estilo.values;
  }

  final pedido = argumentos[indice + 1].toLowerCase();
  final encontrado = Estilo.values.where((e) => e.name == pedido);

  if (encontrado.isEmpty) {
    stdout.writeln(
      'Estilo «$pedido» desconocido. Opciones: '
      '${Estilo.values.map((e) => e.name).join(', ')}.',
    );
    exitCode = 1;
    return const [];
  }

  return [encontrado.first];
}

/// Distingue el valor de `--estilo` de una frase de diagnóstico.
bool _esValorDeEstilo(List<String> argumentos, String candidato) {
  final indice = argumentos.indexOf('--estilo');
  return indice != -1 &&
      indice + 1 < argumentos.length &&
      argumentos[indice + 1] == candidato;
}

Biblioteca _cargarBiblioteca() {
  final archivo = File('assets/biblioteca/ejercicios.json');
  if (!archivo.existsSync()) {
    stdout.writeln(
      'No encuentro assets/biblioteca/ejercicios.json. '
      'Ejecuta esto desde la raíz del proyecto.',
    );
    exit(1);
  }

  return Biblioteca.desdeJson(
    jsonDecode(archivo.readAsStringSync()) as Map<String, dynamic>,
  );
}
