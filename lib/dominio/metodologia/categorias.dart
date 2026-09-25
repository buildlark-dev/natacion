/// Categorías de nadador y sus parámetros de control.
///
/// Fuente normativa: sección 11 de `docs/metodologia/PROMPT_MAESTRO_V3.4.md`.
/// Los rangos son metros **por sesión**; la frecuencia es sesiones por semana.
library;

/// Rango cerrado de metros admitido en una sesión.
class RangoVolumen {
  const RangoVolumen(this.minimo, this.maximo);

  final int minimo;
  final int maximo;

  /// Ambos extremos son válidos: 1800 y 2200 están dentro de 1800-2200.
  bool contiene(int metros) => metros >= minimo && metros <= maximo;

  /// Metros que sobran o faltan respecto al rango. Cero si está dentro.
  ///
  /// Negativo cuando queda por debajo del mínimo, positivo cuando excede el
  /// máximo. Sirve para que el aviso diga la diferencia exacta.
  int desviacion(int metros) {
    if (metros < minimo) return metros - minimo;
    if (metros > maximo) return metros - maximo;
    return 0;
  }

  @override
  String toString() => '$minimo-$maximo m';
}

/// Las cinco categorías de la metodología.
enum Categoria {
  iniciacion(
    nombre: 'Iniciación',
    volumenPorSesion: RangoVolumen(500, 800),
    sesionesPorSemana: 2,
    usaAtr: false,
  ),
  tecnificacion(
    nombre: 'Tecnificación',
    volumenPorSesion: RangoVolumen(800, 1000),
    sesionesPorSemana: 2,
    usaAtr: false,
  ),
  precompetitivo(
    nombre: 'Precompetitivo',
    volumenPorSesion: RangoVolumen(1800, 2200),
    sesionesPorSemana: 3,
    usaAtr: true,
  ),
  competitivo(
    nombre: 'Competitivo',
    volumenPorSesion: RangoVolumen(4000, 5000),
    sesionesPorSemana: 5,
    usaAtr: true,
  ),
  altoRendimiento(
    nombre: 'Alto Rendimiento',
    volumenPorSesion: RangoVolumen(5000, 6000),
    sesionesPorSemana: 10,
    usaAtr: true,
  );

  const Categoria({
    required this.nombre,
    required this.volumenPorSesion,
    required this.sesionesPorSemana,
    required this.usaAtr,
  });

  final String nombre;
  final RangoVolumen volumenPorSesion;
  final int sesionesPorSemana;

  /// Iniciación y Tecnificación no usan el modelo ATR (sección 11).
  final bool usaAtr;

  /// Tecnificación tiene una regla propia de alternancia de estilos en
  /// programas de dos meses: sesión 1 de Pecho, sesión 2 de Mariposa.
  bool get tieneAlternanciaObligatoria => this == Categoria.tecnificacion;

  static Categoria? porNombre(String nombre) {
    final buscado = nombre.trim().toLowerCase();
    for (final categoria in Categoria.values) {
      if (categoria.nombre.toLowerCase() == buscado) return categoria;
    }
    return null;
  }
}
