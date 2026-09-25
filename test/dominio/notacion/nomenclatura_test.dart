import 'package:flutter_test/flutter_test.dart';
import 'package:natacion_app/dominio/entidades/parte.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/dominio/notacion/analizador.dart';
import 'package:natacion_app/dominio/notacion/glosario.dart';

import 'ayuda_pruebas.dart';

/// Nomenclatura de estilos (sección 8 del documento normativo).
///
/// Cuando se nada el estilo completo sin ejercicio técnico se escribe
/// únicamente `Nado Libre`, `Nado Espalda`, `Nado Pecho`, `Nado Mariposa` o
/// `Nado CI`. Las formas como "Libre técnico" están prohibidas: para enfatizar
/// una corrección se usa un ejercicio de la Biblioteca antes del nado completo.
void main() {
  late Analizador analizador;

  setUpAll(() {
    analizador = crearAnalizador();
  });

  group('formas de nado prohibidas', () {
    const prohibidas = [
      'Libre técnico',
      'Pecho asistido',
      'Mariposa técnica',
      'Espalda técnica',
      'Libre corregido',
      'Pecho corregido',
    ];

    for (final forma in prohibidas) {
      test('"$forma" se rechaza', () {
        final resultado = analizador.analizar('200 $forma');

        expect(
          resultado.pendientes.any(
            (p) => p.motivo == MotivoPendiente.nomenclaturaProhibida,
          ),
          isTrue,
          reason: 'Debería marcarse como nomenclatura prohibida',
        );
      });
    }

    test('el aviso explica qué hacer en su lugar', () {
      final resultado = analizador.analizar('200 Libre técnico');
      final pendiente = resultado.pendientes.firstWhere(
        (p) => p.motivo == MotivoPendiente.nomenclaturaProhibida,
      );

      expect(pendiente.detalle, contains('Biblioteca'));
    });

    test('la detección no distingue mayúsculas', () {
      final resultado = analizador.analizar('200 LIBRE TÉCNICO');
      expect(
        resultado.pendientes.any(
          (p) => p.motivo == MotivoPendiente.nomenclaturaProhibida,
        ),
        isTrue,
      );
    });
  });

  group('nombres de nado permitidos', () {
    test('los cinco nombres válidos son los de la sección 8', () {
      expect(Estilo.libre.nombreDeNado, 'Nado Libre');
      expect(Estilo.espalda.nombreDeNado, 'Nado Espalda');
      expect(Estilo.pecho.nombreDeNado, 'Nado Pecho');
      expect(Estilo.mariposa.nombreDeNado, 'Nado Mariposa');
      expect(Estilo.combinado.nombreDeNado, 'Nado CI');
    });

    test('"Nado Libre" no produce ningún pendiente', () {
      final resultado = analizador.analizar('400 Nado Libre');
      expect(resultado.pendientes, isEmpty);
      expect(resultado.metros, 400);
    });
  });

  group('etiquetas de bloque técnico', () {
    test('TEC L es válida como etiqueta de bloque', () {
      final resultado = analizador.analizar('200 TEC L');

      expect(resultado.pendientes, isEmpty);
      expect(resultado.series.first.bloqueTecnico, Estilo.libre);
      expect(resultado.series.first.esTecnica, isTrue);
    });

    test('las cinco etiquetas del glosario se reconocen', () {
      for (final etiqueta in Glosario.etiquetasTecnicas.keys) {
        final resultado = analizador.analizar('200 $etiqueta');
        expect(
          resultado.pendientes,
          isEmpty,
          reason: '$etiqueta debería reconocerse',
        );
      }
    });

    test('TEC sin estilo no es una etiqueta válida', () {
      final resultado = analizador.analizar('200 TEC');

      expect(resultado.pendientes, isNotEmpty);
      expect(
        resultado.pendientes.first.detalle,
        contains('TEC L'),
        reason: 'El aviso debe recordar las formas válidas',
      );
    });
  });
}
