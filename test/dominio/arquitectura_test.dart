import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Vigila el principio II de la constitución: el dominio es Dart puro.
///
/// Es fácil violarlo sin darse cuenta, con un solo `import` puesto por
/// comodidad. Esta prueba convierte la frontera en algo que el sistema verifica
/// en lugar de algo que hay que recordar.
void main() {
  group('frontera del dominio', () {
    const prohibidos = <String>[
      'package:flutter/',
      'package:flutter_test/',
      'package:cloud_firestore/',
      'package:firebase_core/',
      'package:provider/',
      'dart:ui',
    ];

    test('ningún archivo de lib/dominio importa Flutter ni Firebase', () {
      final carpeta = Directory('lib/dominio');
      expect(
        carpeta.existsSync(),
        isTrue,
        reason: 'No se encontró lib/dominio; ¿cambió la estructura?',
      );

      final infracciones = <String>[];

      for (final entrada in carpeta.listSync(recursive: true)) {
        if (entrada is! File || !entrada.path.endsWith('.dart')) continue;

        final lineas = entrada.readAsLinesSync();
        for (var i = 0; i < lineas.length; i++) {
          final linea = lineas[i].trim();
          if (!linea.startsWith('import ') && !linea.startsWith('export ')) {
            continue;
          }
          for (final prohibido in prohibidos) {
            if (linea.contains(prohibido)) {
              infracciones.add(
                '${entrada.path}:${i + 1} -> $prohibido',
              );
            }
          }
        }
      }

      expect(
        infracciones,
        isEmpty,
        reason: 'El dominio debe ser Dart puro (principio II de la '
            'constitución). Infracciones encontradas:\n'
            '${infracciones.join('\n')}',
      );
    });

    test('lib/dominio contiene archivos, la prueba no pasa por vacía', () {
      final archivos = Directory('lib/dominio')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      expect(
        archivos.length,
        greaterThan(3),
        reason: 'Si el dominio está casi vacío, esta prueba no demuestra nada.',
      );
    });
  });
}
