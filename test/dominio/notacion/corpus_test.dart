import 'package:flutter_test/flutter_test.dart';
import 'package:natacion_app/dominio/entidades/serie.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/dominio/notacion/analizador.dart';

import 'ayuda_pruebas.dart';

/// Corpus de series reales del entrenador, tomadas de la sección 14 del
/// documento normativo.
///
/// Cada caso declara el resultado estructurado esperado. Es la red que sujeta
/// al analizador: cualquier cambio que rompa una de estas lecturas rompe una
/// serie que el entrenador ya escribió en la vida real.
class CasoCorpus {
  const CasoCorpus(
    this.texto, {
    required this.metros,
    this.repeticiones,
    this.distancia,
    this.implementos = const <Implemento>[],
    this.modificadores = const <Modificador>[],
    this.tiempoSalida,
    this.estilo,
    this.conEjercicio,
  });

  final String texto;
  final int metros;
  final int? repeticiones;
  final int? distancia;
  final List<Implemento> implementos;
  final List<Modificador> modificadores;
  final Duration? tiempoSalida;
  final Estilo? estilo;
  final String? conEjercicio;
}

const corpus = <CasoCorpus>[
  CasoCorpus('200 N', metros: 200, repeticiones: 1, distancia: 200),
  CasoCorpus(
    '4x100 AL SNK PN / 2\'',
    metros: 400,
    repeticiones: 4,
    distancia: 100,
    implementos: [Implemento.aletas, Implemento.snorkel],
    modificadores: [Modificador.patada],
    tiempoSalida: Duration(minutes: 2),
  ),
  CasoCorpus(
    '8x50 (1L 1Estilo 1>4)',
    metros: 400,
    repeticiones: 8,
    distancia: 50,
  ),
  CasoCorpus(
    '200 PULL PL (75N=25 Prog)',
    metros: 200,
    repeticiones: 1,
    distancia: 200,
    implementos: [Implemento.pullBuoy, Implemento.palas],
  ),
  CasoCorpus(
    '400 AL (75 Estilo − 25 UW)',
    metros: 400,
    repeticiones: 1,
    distancia: 400,
    implementos: [Implemento.aletas],
  ),
  CasoCorpus(
    '200 AL (25m Pn E FLECHA + 75 N)',
    metros: 200,
    repeticiones: 1,
    distancia: 200,
    implementos: [Implemento.aletas],
  ),
  CasoCorpus(
    '200 PU/Pp E (50 c/brazo)',
    metros: 200,
    repeticiones: 1,
    distancia: 200,
  ),
  CasoCorpus(
    '300 REC Pp TEC L',
    metros: 300,
    repeticiones: 1,
    distancia: 300,
    implementos: [Implemento.palasPequenas],
    modificadores: [Modificador.recuperacion],
  ),
  CasoCorpus('100 E', metros: 100, distancia: 100, estilo: Estilo.espalda),
];

/// Series del documento normativo que **deben** quedar marcadas como
/// pendientes, porque el propio documento se aparta de su Biblioteca.
const corpusConDiscrepancia = <CasoCorpus>[
  CasoCorpus(
    '200 AL CAMBIO POSI',
    metros: 200,
    implementos: [Implemento.aletas],
  ),
];

void main() {
  late Analizador analizador;

  setUpAll(() {
    analizador = crearAnalizador();
  });

  group('corpus de series reales', () {
    for (final caso in corpus) {
      test('"${caso.texto}" son ${caso.metros} m', () {
        final resultado = analizador.analizar(caso.texto);
        expect(
          resultado.metros,
          caso.metros,
          reason: 'Interpretado como: '
              '${resultado.series.map((s) => s.toString()).join(' | ')}',
        );
      });
    }

    test('las repeticiones y la distancia se separan bien', () {
      for (final caso in corpus) {
        if (caso.repeticiones == null) continue;
        final resultado = analizador.analizar(caso.texto);
        expect(resultado.series, isNotEmpty, reason: caso.texto);
        final serie = resultado.series.first;
        expect(serie.repeticiones, caso.repeticiones, reason: caso.texto);
        expect(serie.distancia, caso.distancia, reason: caso.texto);
      }
    });

    test('los implementos se reconocen', () {
      for (final caso in corpus) {
        if (caso.implementos.isEmpty) continue;
        final resultado = analizador.analizar(caso.texto);
        final serie = resultado.series.first;
        for (final implemento in caso.implementos) {
          expect(
            serie.implementos,
            contains(implemento),
            reason: '${caso.texto} debería llevar ${implemento.nombre}',
          );
        }
      }
    });

    test('los modificadores se reconocen', () {
      for (final caso in corpus) {
        if (caso.modificadores.isEmpty) continue;
        final resultado = analizador.analizar(caso.texto);
        final serie = resultado.series.first;
        for (final modificador in caso.modificadores) {
          expect(
            serie.modificadores,
            contains(modificador),
            reason: '${caso.texto} debería llevar ${modificador.nombre}',
          );
        }
      }
    });

    test('el tiempo de salida se lee tras la barra', () {
      final resultado = analizador.analizar('4x100 AL SNK PN / 2\'');
      expect(resultado.series.first.tiempoSalida, const Duration(minutes: 2));
    });

    test('un tiempo con minutos y segundos se lee completo', () {
      final resultado = analizador.analizar('4x100 / 1\'30"');
      expect(
        resultado.series.first.tiempoSalida,
        const Duration(minutes: 1, seconds: 30),
      );
    });

    test('el hipóxico recoge cada cuántas brazadas se respira', () {
      final resultado = analizador.analizar('4x50 Hyp 5');
      final serie = resultado.series.first;
      expect(serie.modificadores, contains(Modificador.hipoxico));
      expect(serie.respiracionCada, 5);
    });

    test('ninguna serie del corpus deja fragmentos sin interpretar', () {
      for (final caso in corpus) {
        final resultado = analizador.analizar(caso.texto);
        expect(
          resultado.pendientes,
          isEmpty,
          reason: '"${caso.texto}" dejó pendientes: '
              '${resultado.pendientes.map((p) => p.toString()).join(', ')}',
        );
      }
    });
  });

  group('discrepancia real del documento normativo', () {
    // HALLAZGO (2026-09-25): la sesión de ejemplo de la sección 14 escribe
    // "CAMBIO POSI", pero la sección 19 define el ejercicio como
    // "CAMB POSIC". La regla R2 exige coincidencia exacta, así que marcarlo
    // como fuera de biblioteca es el comportamiento correcto, no un fallo del
    // analizador.
    //
    // Pendiente de que el entrenador decida cuál de los dos nombres es el
    // bueno y corrija su documento (tarea T009).

    test('"CAMBIO POSI" se marca como fuera de la Biblioteca', () {
      final resultado = analizador.analizar('200 AL CAMBIO POSI');

      expect(resultado.metros, 200, reason: 'los metros sí se leen');
      expect(resultado.pendientes, hasLength(1));
      expect(
        resultado.pendientes.first.motivo.name,
        'ejercicioFueraDeBiblioteca',
      );
    });

    test('"CAMB POSIC", el nombre de la sección 19, sí se reconoce', () {
      final resultado = analizador.analizar('200 AL CAMB POSIC');

      expect(resultado.metros, 200);
      expect(
        resultado.pendientes,
        isEmpty,
        reason: 'El nombre exacto de la Biblioteca debe reconocerse',
      );
      expect(resultado.series.first.ejercicio, isNotNull);
      expect(resultado.series.first.esTecnica, isTrue);
    });

    test('los metros siguen contando aunque el ejercicio quede pendiente', () {
      for (final caso in corpusConDiscrepancia) {
        final resultado = analizador.analizar(caso.texto);
        expect(resultado.metros, caso.metros, reason: caso.texto);
      }
    });
  });

  group('notación en desuso', () {
    test('FC1 y FC2 se ignoran con aviso, sin bloquear', () {
      final resultado = analizador.analizar('200 N FC2');
      expect(resultado.metros, 200);
      expect(resultado.pendientes, isEmpty);
      expect(resultado.avisos, isNotEmpty);
      expect(resultado.avisos.first, contains('desuso'));
    });
  });
}
