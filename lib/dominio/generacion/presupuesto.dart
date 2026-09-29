/// Reparto descendente del microciclo: volumen, zonas, técnica y estilos.
///
/// Decisión D1 de `research.md`. El cumplimiento sale del reparto, no de
/// comprobar al final y volver a intentarlo.
library;

import 'package:natacion_app/dominio/generacion/peticion.dart';
import 'package:natacion_app/dominio/generacion/reparto.dart';
import 'package:natacion_app/dominio/metodologia/categorias.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/dominio/metodologia/zonas.dart';

class Presupuesto {
  const Presupuesto({
    required this.volumenTotal,
    required this.volumenPorSesion,
    required this.unidad,
    required this.sesiones,
    required this.metrosPorZona,
    required this.metrosTecnicos,
    required this.metrosPorEstilo,
    required this.metrosPorSesion,
  });

  final int volumenTotal;
  final int volumenPorSesion;

  /// Longitud de piscina: la unidad de reparto.
  final int unidad;

  final int sesiones;

  final Map<Zona, int> metrosPorZona;
  final int metrosTecnicos;
  final Map<Estilo, int> metrosPorEstilo;
  final List<int> metrosPorSesion;

  double get porcentajeTecnico =>
      volumenTotal == 0 ? 0 : (metrosTecnicos * 100) / volumenTotal;

  double porcentajeDe(Zona zona) => volumenTotal == 0
      ? 0
      : ((metrosPorZona[zona] ?? 0) * 100) / volumenTotal;

  double porcentajeDeEstilo(Estilo estilo) => volumenTotal == 0
      ? 0
      : ((metrosPorEstilo[estilo] ?? 0) * 100) / volumenTotal;

  /// Metros de una zona que corresponden a una sesión concreta.
  ///
  /// Se reparten con la misma regla de resto mayor, para que la suma por
  /// sesión sea exactamente el total de la zona.
  Map<Zona, int> zonasDeSesion(int indiceSesion) {
    final porSesion = <Zona, int>{};

    for (final zona in ordenDeZonas) {
      final metros = metrosPorZona[zona] ?? 0;
      if (metros == 0) {
        porSesion[zona] = 0;
        continue;
      }

      final unidades = aUnidades(metros, unidad);
      final repartido = repartirPorRestoMayor(
        unidades: unidades,
        porcentajes: {
          for (var i = 0; i < sesiones; i++) 'sesion$i': (100 / sesiones).floor(),
        },
        orden: [for (var i = 0; i < sesiones; i++) 'sesion$i'],
      );
      porSesion[zona] = aMetros(repartido['sesion$indiceSesion'] ?? 0, unidad);
    }

    return porSesion;
  }
}

/// Calcula el presupuesto completo de un microciclo.
///
/// El orden es el de la decisión D1: volumen, zonas, técnica, estilos y
/// finalmente el reparto entre sesiones.
Presupuesto calcularPresupuesto(PeticionGeneracion peticion) {
  final categoria = peticion.categoria;
  final unidad = peticion.longitudPiscina;
  final sesiones = categoria.sesionesPorSemana;

  // 1. Volumen por sesión: punto medio del rango, cuantizado a la piscina.
  final rango = categoria.volumenPorSesion;
  final medio = ((rango.minimo + rango.maximo) / 2).round();
  final volumenPorSesion = _dentroDelRango(cuantizar(medio, unidad), rango, unidad);

  final volumenTotal = volumenPorSesion * sesiones;
  final unidadesTotales = aUnidades(volumenTotal, unidad);

  // 2. Reparto por zonas según la fase. Sin fase ATR, todo el volumen es A1:
  //    las categorías que no usan ATR trabajan en aeróbico técnico.
  final fase = peticion.faseAtr;
  final metrosPorZona = <Zona, int>{};

  if (fase == null) {
    for (final zona in ordenDeZonas) {
      metrosPorZona[zona] = zona == Zona.a1 ? volumenTotal : 0;
    }
  } else {
    final unidadesPorZona = repartirZonas(
      unidades: unidadesTotales,
      porcentajes: fase.distribucion,
    );
    for (final entrada in unidadesPorZona.entries) {
      metrosPorZona[entrada.key] = aMetros(entrada.value, unidad);
    }
  }

  // 3. Presupuesto técnico. Sin fase ATR se usa el de Acumulación, que es el
  //    de mayor carga técnica: son categorías de perfeccionamiento.
  final porcentajeTecnico = fase?.porcentajeTecnico ?? 50;
  final metrosTecnicos = aMetros(
    (aUnidades(volumenTotal, unidad) * porcentajeTecnico / 100).round(),
    unidad,
  );

  // 4. Reparto por estilos según la priorización del estilo objetivo.
  final metrosPorEstilo =
      _repartirEstilos(peticion.estiloObjetivo, unidadesTotales, unidad);

  // 5. Reparto entre sesiones.
  final unidadesPorSesion = repartirPorRestoMayor(
    unidades: unidadesTotales,
    porcentajes: {
      for (var i = 0; i < sesiones; i++) 'sesion$i': (100 / sesiones).floor(),
    },
    orden: [for (var i = 0; i < sesiones; i++) 'sesion$i'],
  );
  final metrosPorSesion = [
    for (var i = 0; i < sesiones; i++)
      aMetros(unidadesPorSesion['sesion$i'] ?? 0, unidad),
  ];

  return Presupuesto(
    volumenTotal: volumenTotal,
    volumenPorSesion: volumenPorSesion,
    unidad: unidad,
    sesiones: sesiones,
    metrosPorZona: metrosPorZona,
    metrosTecnicos: metrosTecnicos,
    metrosPorEstilo: metrosPorEstilo,
    metrosPorSesion: metrosPorSesion,
  );
}

/// Ajusta el volumen cuantizado para que no se salga del rango de la categoría.
///
/// Cuantizar puede empujar el punto medio fuera del rango en categorías
/// estrechas; el nivel 3 de la escala de precedencia no admite eso.
int _dentroDelRango(int metros, RangoVolumen rango, int unidad) {
  if (metros < rango.minimo) return metros + unidad;
  if (metros > rango.maximo) return metros - unidad;
  return metros;
}

Map<Estilo, int> _repartirEstilos(
  Estilo objetivo,
  int unidadesTotales,
  int unidad,
) {
  final prioridad = PriorizacionEstilos.para(objetivo);

  // Sin priorización definida (CI, General), todo el volumen es del estilo
  // objetivo: no hay reparto que prescribir.
  if (prioridad == null) {
    return {objetivo: aMetros(unidadesTotales, unidad)};
  }

  // Se toma el punto medio de cada rango prescrito.
  final pctObjetivo =
      ((prioridad.rangoObjetivo.minimo + prioridad.rangoObjetivo.maximo) / 2)
          .round();

  final claves = <String>[objetivo.name, 'complementario'];
  final repartido = repartirPorRestoMayor(
    unidades: unidadesTotales,
    porcentajes: {
      objetivo.name: pctObjetivo,
      'complementario': 100 - pctObjetivo,
    },
    orden: claves,
  );

  final resultado = <Estilo, int>{
    objetivo: aMetros(repartido[objetivo.name] ?? 0, unidad),
  };

  // El volumen complementario se reparte entre los estilos que la metodología
  // señala para ese objetivo.
  final complementarios = prioridad.estilosComplementarios;
  final unidadesComplementarias = repartido['complementario'] ?? 0;
  final entreComplementarios = repartirPorRestoMayor(
    unidades: unidadesComplementarias,
    porcentajes: {
      for (final estilo in complementarios)
        estilo.name: (100 / complementarios.length).floor(),
    },
    orden: complementarios.map((e) => e.name).toList(),
  );

  for (final estilo in complementarios) {
    resultado[estilo] =
        aMetros(entreComplementarios[estilo.name] ?? 0, unidad);
  }

  return resultado;
}
