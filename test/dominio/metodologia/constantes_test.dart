import 'package:natacion_app/dominio/metodologia/categorias.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/dominio/metodologia/fases_atr.dart';
import 'package:natacion_app/dominio/metodologia/zonas.dart';
import 'package:flutter_test/flutter_test.dart';

/// Invariantes de las constantes de la metodología.
///
/// No prueban código propio sino la transcripción de las tablas del documento
/// normativo. Una transcripción equivocada aquí se propaga a toda la auditoría.
void main() {
  group('fases ATR', () {
    test('cada fase distribuye exactamente el 100% del volumen', () {
      for (final fase in FaseAtr.values) {
        expect(
          fase.sumaDistribucion,
          100,
          reason: '${fase.nombre} suma ${fase.sumaDistribucion}%, no 100%',
        );
      }
    });

    test('Acumulación prescribe 60/25/10/5 y 50% técnico', () {
      const fase = FaseAtr.acumulacion;
      expect(fase.prescritoPara(Zona.a1), 60);
      expect(fase.prescritoPara(Zona.a2), 25);
      expect(fase.prescritoPara(Zona.a3), 10);
      expect(fase.prescritoPara(Zona.at), 5);
      expect(fase.prescritoPara(Zona.maximo), 0);
      expect(fase.prescritoPara(Zona.velocidad), 0);
      expect(fase.porcentajeTecnico, 50);
    });

    test('Transformación prescribe 30/35/15/15/5 y 30% técnico', () {
      const fase = FaseAtr.transformacion;
      expect(fase.prescritoPara(Zona.a1), 30);
      expect(fase.prescritoPara(Zona.a2), 35);
      expect(fase.prescritoPara(Zona.a3), 15);
      expect(fase.prescritoPara(Zona.at), 15);
      expect(fase.prescritoPara(Zona.maximo), 5);
      expect(fase.porcentajeTecnico, 30);
    });

    test('Realización prescribe 25/25/15/10/15/10 y 20% técnico', () {
      const fase = FaseAtr.realizacion;
      expect(fase.prescritoPara(Zona.a1), 25);
      expect(fase.prescritoPara(Zona.a2), 25);
      expect(fase.prescritoPara(Zona.a3), 15);
      expect(fase.prescritoPara(Zona.at), 10);
      expect(fase.prescritoPara(Zona.maximo), 15);
      expect(fase.prescritoPara(Zona.velocidad), 10);
      expect(fase.porcentajeTecnico, 20);
    });

    test('el trabajo técnico decrece de Acumulación a Realización', () {
      expect(
        FaseAtr.acumulacion.porcentajeTecnico,
        greaterThan(FaseAtr.transformacion.porcentajeTecnico),
      );
      expect(
        FaseAtr.transformacion.porcentajeTecnico,
        greaterThan(FaseAtr.realizacion.porcentajeTecnico),
      );
    });

    test('la técnica nunca desaparece: ninguna fase la deja en cero', () {
      for (final fase in FaseAtr.values) {
        expect(
          fase.porcentajeTecnico,
          greaterThan(0),
          reason: 'La técnica debe estar presente toda la temporada '
              '(sección 3 de la metodología)',
        );
      }
    });
  });

  group('zonas de intensidad', () {
    test('las bandas son contiguas y no se solapan', () {
      const conBanda = [Zona.a1, Zona.a2, Zona.a3, Zona.at, Zona.maximo];
      for (var i = 0; i < conBanda.length - 1; i++) {
        final actual = conBanda[i].banda!;
        final siguiente = conBanda[i + 1].banda!;
        expect(
          actual.maximo,
          siguiente.minimo,
          reason: '${conBanda[i].abreviatura} termina en ${actual.maximo} '
              'pero ${conBanda[i + 1].abreviatura} empieza en '
              '${siguiente.minimo}',
        );
      }
    });

    test('un porcentaje de frecuencia cae en una sola zona', () {
      for (final porcentaje in [60, 65, 70, 75, 80, 84, 85, 90, 92, 100]) {
        final coincidencias = Zona.values
            .where((z) => z.banda != null && z.banda!.contiene(porcentaje))
            .toList();
        expect(
          coincidencias.length,
          1,
          reason: '$porcentaje% cae en ${coincidencias.length} zonas: '
              '${coincidencias.map((z) => z.abreviatura).join(', ')}',
        );
      }
    });

    test('Velocidad se controla por ritmo, no por frecuencia cardíaca', () {
      expect(Zona.velocidad.seControlaPorRitmo, isTrue);
      expect(Zona.velocidad.banda, isNull);
    });

    test('Máx no tiene techo', () {
      expect(Zona.maximo.banda!.maximo, isNull);
      expect(Zona.maximo.banda!.contiene(100), isTrue);
    });

    test('reconoce la abreviatura escrita con y sin tilde', () {
      expect(Zona.porAbreviatura('A1'), Zona.a1);
      expect(Zona.porAbreviatura('at'), Zona.at);
      expect(Zona.porAbreviatura('Máx'), Zona.maximo);
      expect(Zona.porAbreviatura('Max'), Zona.maximo);
      expect(Zona.porAbreviatura('Vel'), Zona.velocidad);
      expect(Zona.porAbreviatura('A7'), isNull);
    });
  });

  group('categorías', () {
    test('Iniciación y Tecnificación no usan ATR', () {
      expect(Categoria.iniciacion.usaAtr, isFalse);
      expect(Categoria.tecnificacion.usaAtr, isFalse);
    });

    test('de Precompetitivo en adelante se usa ATR', () {
      expect(Categoria.precompetitivo.usaAtr, isTrue);
      expect(Categoria.competitivo.usaAtr, isTrue);
      expect(Categoria.altoRendimiento.usaAtr, isTrue);
    });

    test('los rangos de volumen son los de la sección 11', () {
      expect(Categoria.iniciacion.volumenPorSesion.minimo, 500);
      expect(Categoria.iniciacion.volumenPorSesion.maximo, 800);
      expect(Categoria.precompetitivo.volumenPorSesion.minimo, 1800);
      expect(Categoria.precompetitivo.volumenPorSesion.maximo, 2200);
      expect(Categoria.altoRendimiento.volumenPorSesion.maximo, 6000);
    });

    test('los extremos del rango son válidos', () {
      final rango = Categoria.precompetitivo.volumenPorSesion;
      expect(rango.contiene(1800), isTrue, reason: 'el mínimo está dentro');
      expect(rango.contiene(2200), isTrue, reason: 'el máximo está dentro');
      expect(rango.contiene(1799), isFalse);
      expect(rango.contiene(2201), isFalse);
    });

    test('la desviación indica cuántos metros sobran o faltan', () {
      final rango = Categoria.precompetitivo.volumenPorSesion;
      expect(rango.desviacion(2000), 0);
      expect(rango.desviacion(1400), -400, reason: 'faltan 400 m al mínimo');
      expect(rango.desviacion(2600), 400, reason: 'sobran 400 m sobre el máximo');
    });

    test('solo Tecnificación tiene alternancia obligatoria de estilos', () {
      final conAlternancia = Categoria.values
          .where((c) => c.tieneAlternanciaObligatoria)
          .toList();
      expect(conAlternancia, [Categoria.tecnificacion]);
    });

    test('la frecuencia semanal es la de la sección 11', () {
      expect(Categoria.iniciacion.sesionesPorSemana, 2);
      expect(Categoria.precompetitivo.sesionesPorSemana, 3);
      expect(Categoria.competitivo.sesionesPorSemana, 5);
      expect(Categoria.altoRendimiento.sesionesPorSemana, 10);
    });
  });

  group('priorización de estilos', () {
    test('Libre reparte 80-85% Libre y 15-20% Espalda', () {
      final prioridad = PriorizacionEstilos.para(Estilo.libre)!;
      expect(prioridad.rangoObjetivo.minimo, 80);
      expect(prioridad.rangoObjetivo.maximo, 85);
      expect(prioridad.rangoComplementario.minimo, 15);
      expect(prioridad.estilosComplementarios, [Estilo.espalda]);
    });

    test('Pecho y Mariposa reparten mitad y mitad', () {
      for (final estilo in [Estilo.pecho, Estilo.mariposa]) {
        final prioridad = PriorizacionEstilos.para(estilo)!;
        expect(prioridad.rangoObjetivo.minimo, 50);
        expect(prioridad.rangoObjetivo.maximo, 50);
        expect(prioridad.rangoComplementario.minimo, 50);
      }
    });

    test('los nombres de nado son los permitidos por la sección 8', () {
      expect(Estilo.libre.nombreDeNado, 'Nado Libre');
      expect(Estilo.espalda.nombreDeNado, 'Nado Espalda');
      expect(Estilo.combinado.nombreDeNado, 'Nado CI');
    });
  });

  group('reparto de la sesión', () {
    test('las tres partes suman el 100% del volumen', () {
      final suma = TipoParte.values
          .fold(0, (total, parte) => total + parte.porcentajePrescrito);
      expect(suma, 100);
    });

    test('la parte central se divide en pre-set 10% y principal 40%', () {
      expect(
        porcentajePreSet + porcentajeSeriePrincipal,
        TipoParte.central.porcentajePrescrito,
      );
    });
  });
}
