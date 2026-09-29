/// Zonas de intensidad fisiológica.
///
/// Fuente normativa: sección 9 de `docs/metodologia/PROMPT_MAESTRO_V3.4.md`,
/// alineada al sistema de Swimming Canada (2024).
///
/// Las bandas de porcentaje de frecuencia cardíaca máxima son **contiguas y sin
/// solapamiento**: el límite superior de una zona es el inferior de la
/// siguiente, y el intervalo se interpreta como `[minimo, maximo)`. Esto es lo
/// que garantiza que ninguna serie pueda contabilizarse en dos zonas.
library;

/// Banda de intensidad, medida en porcentaje de frecuencia cardíaca máxima.
class BandaFrecuencia {
  const BandaFrecuencia(this.minimo, this.maximo);

  /// Límite inferior, incluido.
  final int minimo;

  /// Límite superior, excluido. `null` en la zona más alta, que no tiene techo.
  final int? maximo;

  bool contiene(int porcentaje) {
    if (porcentaje < minimo) return false;
    return maximo == null || porcentaje < maximo!;
  }
}

/// Las seis zonas de la sección 9.
enum Zona {
  a1(
    abreviatura: 'A1',
    descripcion: 'Aeróbico regenerativo / técnico',
    banda: BandaFrecuencia(60, 70),
    rpeMinimo: 1,
    rpeMaximo: 2,
  ),
  a2(
    abreviatura: 'A2',
    descripcion: 'Aeróbico extensivo',
    banda: BandaFrecuencia(70, 80),
    rpeMinimo: 2,
    rpeMaximo: 4,
  ),
  a3(
    abreviatura: 'A3',
    descripcion: 'Aeróbico intensivo',
    banda: BandaFrecuencia(80, 85),
    rpeMinimo: 4,
    rpeMaximo: 5,
  ),
  at(
    abreviatura: 'AT',
    descripcion: 'Umbral anaeróbico',
    banda: BandaFrecuencia(85, 92),
    rpeMinimo: 5,
    rpeMaximo: 6,
  ),
  maximo(
    abreviatura: 'Máx',
    descripcion: 'VO2 máx / resistencia intensiva',
    banda: BandaFrecuencia(92, null),
    rpeMinimo: 7,
    rpeMaximo: 10,
  ),
  velocidad(
    abreviatura: 'Velocidad',
    descripcion: 'Velocidad pura, alta intensidad y explosiva',
    banda: null,
    rpeMinimo: 10,
    rpeMaximo: 10,
  );

  const Zona({
    required this.abreviatura,
    required this.descripcion,
    required this.banda,
    required this.rpeMinimo,
    required this.rpeMaximo,
  });

  final String abreviatura;
  final String descripcion;

  /// `null` en Velocidad: se controla por ritmo, no por frecuencia cardíaca.
  final BandaFrecuencia? banda;

  final int rpeMinimo;
  final int rpeMaximo;

  bool get seControlaPorRitmo => banda == null;

  /// Reconoce una zona escrita por el entrenador. Distingue `Máx` con y sin
  /// tilde, y admite `MAX`, porque en los documentos aparece de varias formas.
  static Zona? porAbreviatura(String texto) {
    final buscado = texto.trim().toLowerCase().replaceAll('á', 'a');
    for (final zona in Zona.values) {
      if (zona.abreviatura.toLowerCase().replaceAll('á', 'a') == buscado) {
        return zona;
      }
    }
    if (buscado == 'vel') return Zona.velocidad;
    return null;
  }
}
