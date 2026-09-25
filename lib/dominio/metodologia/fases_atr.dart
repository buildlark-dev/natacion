/// Distribuciones del modelo ATR.
///
/// Fuente normativa: sección 12 de `docs/metodologia/PROMPT_MAESTRO_V3.4.md`.
///
/// Cada fase prescribe qué porcentaje del volumen total corresponde a cada zona
/// de intensidad. **Cada fila suma exactamente 100%**: la versión 3.4 eliminó la
/// doble contabilización que existía antes, de modo que cada intensidad se
/// cuenta donde de verdad ocurre.
///
/// El porcentaje de trabajo técnico es una medida aparte, sobre el volumen
/// total, y no entra en esa suma.
library;

import 'package:natacion_app/dominio/metodologia/zonas.dart';

enum FaseAtr {
  acumulacion(
    nombre: 'Acumulación',
    objetivos: 'Técnica, economía de nado, base aeróbica',
    distribucion: {
      Zona.a1: 60,
      Zona.a2: 25,
      Zona.a3: 10,
      Zona.at: 5,
      Zona.maximo: 0,
      Zona.velocidad: 0,
    },
    porcentajeTecnico: 50,
  ),
  transformacion(
    nombre: 'Transformación',
    objetivos: 'Umbral, ritmo competitivo, velocidad-resistencia',
    distribucion: {
      Zona.a1: 30,
      Zona.a2: 35,
      Zona.a3: 15,
      Zona.at: 15,
      Zona.maximo: 5,
      Zona.velocidad: 0,
    },
    porcentajeTecnico: 30,
  ),
  realizacion(
    nombre: 'Realización',
    objetivos: 'Velocidad, afinación, competencia',
    distribucion: {
      Zona.a1: 25,
      Zona.a2: 25,
      Zona.a3: 15,
      Zona.at: 10,
      Zona.maximo: 15,
      Zona.velocidad: 10,
    },
    porcentajeTecnico: 20,
  );

  const FaseAtr({
    required this.nombre,
    required this.objetivos,
    required this.distribucion,
    required this.porcentajeTecnico,
  });

  final String nombre;
  final String objetivos;

  /// Porcentaje del volumen total prescrito para cada zona.
  final Map<Zona, int> distribucion;

  /// Porcentaje del volumen total que debe ser trabajo técnico.
  final int porcentajeTecnico;

  /// Suma de la distribución. Debe ser 100 en todas las fases; hay una prueba
  /// que lo verifica.
  int get sumaDistribucion =>
      distribucion.values.fold(0, (total, valor) => total + valor);

  int prescritoPara(Zona zona) => distribucion[zona] ?? 0;

  static FaseAtr? porNombre(String nombre) {
    final buscado = nombre.trim().toLowerCase();
    for (final fase in FaseAtr.values) {
      if (fase.nombre.toLowerCase() == buscado) return fase;
    }
    return null;
  }
}
