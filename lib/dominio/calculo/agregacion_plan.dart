/// Agregación de un plan completo: distribución de zonas, porcentaje técnico y
/// reparto de estilos sobre todas sus sesiones.
///
/// Son los errores que no se ven mirando una sesión aislada.
library;

import 'package:natacion_app/dominio/entidades/plan.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/dominio/metodologia/zonas.dart';

/// Lo real frente a lo prescrito, con la diferencia ya calculada.
class Reparto {
  const Reparto({
    required this.etiqueta,
    required this.metros,
    required this.porcentajeReal,
    required this.porcentajePrescrito,
  });

  final String etiqueta;
  final int metros;
  final double porcentajeReal;
  final double porcentajePrescrito;

  double get diferencia => porcentajeReal - porcentajePrescrito;

  String get descripcion =>
      '$etiqueta: ${porcentajeReal.toStringAsFixed(1)}% real frente a '
      '${porcentajePrescrito.toStringAsFixed(0)}% prescrito '
      '(${diferencia >= 0 ? '+' : ''}${diferencia.toStringAsFixed(1)} puntos)';
}

class AgregacionPlan {
  const AgregacionPlan(this.plan);

  final Plan plan;

  int get metros => plan.metros;

  double get porcentajeTecnico => plan.porcentajeTecnico;

  /// Metros por zona. Las series sin zona quedan bajo `null`: no se reparten
  /// por suposición.
  Map<Zona?, int> get metrosPorZona {
    final acumulado = <Zona?, int>{};
    for (final sesion in plan.sesiones) {
      for (final serie in sesion.todasLasSeries) {
        acumulado[serie.zona] = (acumulado[serie.zona] ?? 0) + serie.metros;
      }
    }
    return acumulado;
  }

  int get metrosSinZona => metrosPorZona[null] ?? 0;

  /// Porcentaje real de cada zona sobre el volumen total del plan.
  Map<Zona, double> get porcentajePorZona {
    final total = metros;
    if (total == 0) {
      return {for (final zona in Zona.values) zona: 0};
    }
    final porZona = metrosPorZona;
    return {
      for (final zona in Zona.values)
        zona: ((porZona[zona] ?? 0) * 100) / total,
    };
  }

  /// Comparación zona por zona contra la fase ATR del plan.
  ///
  /// Devuelve una lista vacía si el plan no tiene fase, porque entonces no hay
  /// distribución prescrita contra la que comparar.
  List<Reparto> get repartoPorZona {
    final fase = plan.faseAtr;
    if (fase == null) return const [];

    final reales = porcentajePorZona;
    final porZona = metrosPorZona;

    return [
      for (final zona in Zona.values)
        Reparto(
          etiqueta: zona.abreviatura,
          metros: porZona[zona] ?? 0,
          porcentajeReal: reales[zona] ?? 0,
          porcentajePrescrito: fase.prescritoPara(zona).toDouble(),
        ),
    ];
  }

  /// Metros por estilo, contando solo el volumen con estilo declarado.
  Map<Estilo?, int> get metrosPorEstilo {
    final acumulado = <Estilo?, int>{};
    for (final sesion in plan.sesiones) {
      for (final serie in sesion.todasLasSeries) {
        acumulado[serie.estilo] = (acumulado[serie.estilo] ?? 0) + serie.metros;
      }
    }
    return acumulado;
  }

  int get metrosConEstilo {
    var total = 0;
    metrosPorEstilo.forEach((estilo, metros) {
      if (estilo != null) total += metros;
    });
    return total;
  }

  /// Reparto de estilos frente a la priorización del estilo objetivo.
  ///
  /// El porcentaje se calcula sobre el volumen **con estilo declarado**, no
  /// sobre el total: incluir el volumen sin estilo falsearía el reparto.
  List<Reparto> get repartoDeEstilos {
    final prioridad = PriorizacionEstilos.para(plan.estiloObjetivo);
    if (prioridad == null) return const [];

    final base = metrosConEstilo;
    if (base == 0) return const [];

    final porEstilo = metrosPorEstilo;
    final metrosObjetivo = porEstilo[plan.estiloObjetivo] ?? 0;

    var metrosComplementarios = 0;
    for (final estilo in prioridad.estilosComplementarios) {
      metrosComplementarios += porEstilo[estilo] ?? 0;
    }

    return [
      Reparto(
        etiqueta: plan.estiloObjetivo.nombre,
        metros: metrosObjetivo,
        porcentajeReal: (metrosObjetivo * 100) / base,
        porcentajePrescrito: prioridad.rangoObjetivo.minimo.toDouble(),
      ),
      Reparto(
        etiqueta: prioridad.estilosComplementarios
            .map((e) => e.nombre)
            .join(' / '),
        metros: metrosComplementarios,
        porcentajeReal: (metrosComplementarios * 100) / base,
        porcentajePrescrito: prioridad.rangoComplementario.minimo.toDouble(),
      ),
    ];
  }

  /// Sesiones por microciclo, para comprobar la frecuencia semanal.
  Map<String, int> get sesionesPorMicrociclo {
    final conteo = <String, int>{};
    for (final microciclo in plan.microciclos) {
      conteo[microciclo.id] = plan.sesionesDe(microciclo.id).length;
    }
    return conteo;
  }
}
