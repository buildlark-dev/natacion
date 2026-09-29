// Extrae la Biblioteca Oficial de ejercicios de la sección 19 del documento
// normativo y genera `assets/biblioteca/ejercicios.json`.
//
// Decisión D3 de `specs/001-editor-planes-auditoria/research.md`: la fuente es
// el Markdown, no el .docx, porque el Markdown ya está en tablas legibles por
// máquina y es la fuente que la metodología designa como válida.
//
// Uso:  dart run tool/extraer_biblioteca.dart
//
// IMPORTANTE: el resultado DEBE revisarlo el entrenador (tarea T009). Un
// ejercicio mal transcrito es una regla mal aplicada durante toda la vida del
// producto.

import 'dart:convert';
import 'dart:io';

const rutaDocumento = 'docs/metodologia/PROMPT_MAESTRO_V3.4.md';
const rutaSalida = 'assets/biblioteca/ejercicios.json';

/// Encabezados de la sección 19 y el estilo al que corresponde cada uno.
const encabezadosDeEstilo = <String, String>{
  'libre': 'Libre',
  'crol': 'Libre',
  'espalda': 'Espalda',
  'pecho': 'Pecho',
  'mariposa': 'Mariposa',
  'general': 'General',
  'salidas': 'General',
  'virajes': 'General',
};

void main() {
  final documento = File(rutaDocumento);
  if (!documento.existsSync()) {
    stderr.writeln('No se encontró $rutaDocumento');
    exitCode = 1;
    return;
  }

  final lineas = documento.readAsLinesSync();
  final ejercicios = <Map<String, dynamic>>[];

  var dentroDeSeccion19 = false;
  var estiloActual = 'General';

  for (final linea in lineas) {
    final recortada = linea.trim();

    // La sección 19 empieza en su encabezado y llega hasta el final o hasta
    // un encabezado de nivel 2 posterior.
    if (recortada.startsWith('## 19.')) {
      dentroDeSeccion19 = true;
      continue;
    }
    if (dentroDeSeccion19 &&
        recortada.startsWith('## ') &&
        !recortada.startsWith('## 19.')) {
      break;
    }
    if (!dentroDeSeccion19) continue;

    // Los subencabezados 19.x indican el estilo del bloque.
    if (recortada.startsWith('### ')) {
      estiloActual = _estiloDeEncabezado(recortada);
      continue;
    }

    // Filas de tabla: | Nombre | Descripción | Error que corrige |
    if (!recortada.startsWith('|')) continue;

    final celdas = recortada
        .split('|')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    if (celdas.length < 2) continue;
    if (_esSeparadorDeTabla(celdas)) continue;
    if (_esEncabezadoDeTabla(celdas)) continue;

    final nombre = _limpiar(celdas[0]);
    if (nombre.isEmpty) continue;

    ejercicios.add(<String, dynamic>{
      'nombre': nombre,
      'estilo': estiloActual,
      'descripcion': _limpiar(celdas[1]),
      'errorQueCorrige': celdas.length > 2 ? _limpiar(celdas[2]) : '',
      // Se completa abajo, cuando ya se conocen todos los nombres.
      'requiereDesambiguacion': false,
    });
  }

  _marcarAmbiguos(ejercicios);

  final salida = File(rutaSalida);
  salida.parent.createSync(recursive: true);
  salida.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
      'fuente': 'Sección 19 de $rutaDocumento',
      'generado': DateTime.now().toIso8601String().split('T').first,
      'advertencia':
          'Generado automáticamente. Requiere revisión manual del entrenador '
              '(tarea T009) antes de darse por válido.',
      'ejercicios': ejercicios,
    }),
  );

  _informar(ejercicios);
}

String _estiloDeEncabezado(String encabezado) {
  final minusculas = encabezado.toLowerCase();
  for (final entrada in encabezadosDeEstilo.entries) {
    if (minusculas.contains(entrada.key)) return entrada.value;
  }
  return 'General';
}

bool _esSeparadorDeTabla(List<String> celdas) =>
    celdas.every((c) => RegExp(r'^:?-{2,}:?$').hasMatch(c));

bool _esEncabezadoDeTabla(List<String> celdas) {
  final primera = celdas.first.toLowerCase();
  return primera == 'nombre' || primera == 'ejercicio';
}

/// Quita el énfasis de Markdown y normaliza los espacios.
String _limpiar(String texto) => texto
    .replaceAll('**', '')
    .replaceAll('`', '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// El documento ya escribe el estilo dentro del nombre cuando este se repite
/// (`ROLIDO (Libre)`, `FLECHA (Espalda)`). El nombre base es lo que el
/// entrenador teclea; si ese nombre base existe en más de un estilo, usarlo sin
/// indicar el estilo es ambiguo (sección 7 de la metodología).
String _nombreBase(String nombre) {
  final coincidencia =
      RegExp(r'^(.*?)\s*\((Libre|Espalda|Pecho|Mariposa)\)\s*$').firstMatch(nombre);
  return coincidencia != null ? coincidencia.group(1)!.trim() : nombre;
}

void _marcarAmbiguos(List<Map<String, dynamic>> ejercicios) {
  final estilosPorBase = <String, Set<String>>{};
  for (final ejercicio in ejercicios) {
    final base = _nombreBase(ejercicio['nombre'] as String);
    final estilo = ejercicio['estilo'] as String;
    estilosPorBase.putIfAbsent(base, () => <String>{}).add(estilo);
  }
  for (final ejercicio in ejercicios) {
    final base = _nombreBase(ejercicio['nombre'] as String);
    ejercicio['nombreBase'] = base;
    ejercicio['requiereDesambiguacion'] =
        (estilosPorBase[base]?.length ?? 0) > 1;
  }
}

void _informar(List<Map<String, dynamic>> ejercicios) {
  final porEstilo = <String, int>{};
  for (final ejercicio in ejercicios) {
    final estilo = ejercicio['estilo'] as String;
    porEstilo[estilo] = (porEstilo[estilo] ?? 0) + 1;
  }

  stdout.writeln('Ejercicios extraídos: ${ejercicios.length}');
  final estilos = porEstilo.keys.toList()..sort();
  for (final estilo in estilos) {
    stdout.writeln('  $estilo: ${porEstilo[estilo]}');
  }

  final estilosPorBase = <String, List<String>>{};
  for (final ejercicio in ejercicios) {
    if (ejercicio['requiereDesambiguacion'] != true) continue;
    final base = ejercicio['nombreBase'] as String;
    estilosPorBase.putIfAbsent(base, () => <String>[]).add(
          ejercicio['estilo'] as String,
        );
  }

  stdout.writeln(
    '\nNombres base que exigen desambiguación: ${estilosPorBase.length}',
  );
  final bases = estilosPorBase.keys.toList()..sort();
  for (final base in bases) {
    stdout.writeln('  $base -> ${estilosPorBase[base]!.join(', ')}');
  }

  stdout.writeln('\nEscrito en $rutaSalida');
  stdout.writeln('REVISAR A MANO antes de darlo por válido (tarea T009).');
}
