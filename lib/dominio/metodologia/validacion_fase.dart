/// Validaciones propias de la categoría: admisibilidad de la fase ATR y la
/// regla de alternancia de Tecnificación.
///
/// Fuentes normativas: secciones 11 y 12 de
/// `docs/metodologia/PROMPT_MAESTRO_V3.4.md`.
library;

import 'package:natacion_app/dominio/entidades/plan.dart';
import 'package:natacion_app/dominio/entidades/sesion.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';

/// Resultado de una validación de categoría.
class ValidacionCategoria {
  const ValidacionCategoria({required this.valida, required this.motivo});

  final bool valida;
  final String motivo;

  static const ValidacionCategoria correcta =
      ValidacionCategoria(valida: true, motivo: '');
}

class ValidacionFase {
  const ValidacionFase();

  /// Iniciación y Tecnificación no usan el modelo ATR (sección 11).
  ValidacionCategoria admiteFase(Plan plan) {
    if (plan.faseAtr == null) return ValidacionCategoria.correcta;

    if (!plan.categoria.usaAtr) {
      return ValidacionCategoria(
        valida: false,
        motivo: '${plan.categoria.nombre} no usa el modelo ATR: no se le puede '
            'asignar la fase ${plan.faseAtr!.nombre} (sección 11)',
      );
    }

    return ValidacionCategoria.correcta;
  }
}

/// Regla obligatoria de Tecnificación en programas de dos meses:
/// sesión 1 de Pecho, sesión 2 de Mariposa, todas las semanas (sección 11).
class ReglaAlternanciaTecnificacion {
  const ReglaAlternanciaTecnificacion();

  /// Estilos que deben alternarse, en orden dentro de cada microciclo.
  static const List<Estilo> secuencia = [Estilo.pecho, Estilo.mariposa];

  ValidacionCategoria comprobar(Plan plan) {
    if (!plan.categoria.tieneAlternanciaObligatoria) {
      return ValidacionCategoria.correcta;
    }

    final incumplimientos = <String>[];

    for (final microciclo in plan.microciclos) {
      final sesiones = plan.sesionesDe(microciclo.id);

      for (var i = 0; i < sesiones.length && i < secuencia.length; i++) {
        final esperado = secuencia[i];
        final dominante = _estiloDominante(sesiones[i]);

        if (dominante != esperado) {
          incumplimientos.add(
            '${microciclo.nombre}, sesión ${i + 1}: se esperaba '
            '${esperado.nombre} y predomina '
            '${dominante?.nombre ?? 'ningún estilo declarado'}',
          );
        }
      }

      if (sesiones.length < secuencia.length) {
        incumplimientos.add(
          '${microciclo.nombre}: tiene ${sesiones.length} sesiones y la regla '
          'necesita ${secuencia.length}',
        );
      }
    }

    if (incumplimientos.isEmpty) {
      return ValidacionCategoria.correcta;
    }

    return ValidacionCategoria(
      valida: false,
      motivo: 'Regla de alternancia de Tecnificación incumplida: '
          '${incumplimientos.join('; ')}',
    );
  }

  /// Estilo con más metros en la sesión. `null` si no hay estilo declarado.
  Estilo? _estiloDominante(Sesion sesion) {
    final metrosPorEstilo = <Estilo, int>{};

    for (final serie in sesion.todasLasSeries) {
      final estilo = serie.estilo;
      if (estilo == null) continue;
      metrosPorEstilo[estilo] = (metrosPorEstilo[estilo] ?? 0) + serie.metros;
    }

    if (metrosPorEstilo.isEmpty) return null;

    Estilo? dominante;
    var maximo = 0;
    metrosPorEstilo.forEach((estilo, metros) {
      if (metros > maximo) {
        maximo = metros;
        dominante = estilo;
      }
    });

    return dominante;
  }
}
