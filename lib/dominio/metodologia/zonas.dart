/// Zonas de intensidad fisiológica.
///
/// Fuente normativa: sección 9 de `docs/metodologia/PROMPT_MAESTRO_V3.4.md`.
/// Fundamento y trazabilidad de cada cifra:
/// `docs/metodologia/fundamento_zonas.md`.
///
/// Cada zona lleva **dos anclajes**:
///
/// - **Banda de %FCmáx**, de Swimming Canada (Vandenbogaerde, 2024). Contigua y
///   sin solapamiento: el límite superior de una zona es el inferior de la
///   siguiente, interpretada como `[minimo, maximo)`. Orienta.
/// - **Banda de ritmo como % de velocidad crítica**, de Ginn (1993) con los
///   bordes cerrados. Clasifica y audita, porque la velocidad crítica **se
///   mide** con dos pruebas cronometradas y no depende de conocer la frecuencia
///   cardíaca máxima individual ni de medirla dentro del agua.
///
/// Siete zonas, no seis: Swimming Canada separa los esfuerzos de alta intensidad
/// (~ritmo 200, repeticiones de 25-100 m) de los explosivos (~10-20 m con
/// descanso pasivo largo), porque son sistemas energéticos distintos
/// —hidratos frente a fosfágenos—. Fusionarlas escondía esa diferencia.
library;

import 'package:natacion_app/dominio/metodologia/ritmos_competencia.dart';

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

  @override
  String toString() => maximo == null ? '$minimo%+' : '$minimo-$maximo%';
}

/// Banda de ritmo, medida en porcentaje de la velocidad crítica del nadador.
///
/// Más rápido que la velocidad crítica es más del 100%. El 100% es la frontera
/// del dominio severo: por encima, el organismo ya no mantiene el equilibrio
/// (Scott et al., 2024).
class BandaRitmo {
  const BandaRitmo(this.minimo, this.maximo, {this.interpolada = false});

  final int minimo;

  /// `null` cuando no hay techo.
  final int? maximo;

  /// Verdadero cuando el borde no está publicado y se dedujo.
  ///
  /// Ginn (1993) no tiene A3: su sistema va A1, A2, AT, MVO2, LT/LP. La banda de
  /// A3 se interpoló entre el A2 y el AT de Ginn. Queda marcado para que nadie
  /// la cite como si estuviera publicada.
  final bool interpolada;

  bool contiene(int porcentaje) {
    if (porcentaje < minimo) return false;
    return maximo == null || porcentaje < maximo!;
  }

  @override
  String toString() =>
      maximo == null ? '>$minimo% de CS' : '$minimo-$maximo% de CS';
}

/// Las tres zonas con las que mide la literatura de distribución de
/// intensidades.
///
/// Las siete zonas del entrenador son más finas que lo que la ciencia publica.
/// La literatura (Stöggl & Sperlich 2014; Pla 2019; Arroyo-Toledo 2021;
/// González-Ravé 2021) reparte en tres, separando por los dos puntos de
/// inflexión del lactato. El segundo coincide con la **velocidad crítica**, lo
/// que hace la frontera medible.
///
/// Por eso la auditoría de distribución se hace aquí y no en las siete: auditar
/// en siete exigiría cifras que nadie ha publicado.
enum ZonaTid {
  z1('Z1', 'Por debajo del primer umbral (~2 mmol·L⁻¹)'),
  z2('Z2', 'Entre los dos umbrales'),
  z3('Z3', 'Por encima del segundo umbral (~100% de velocidad crítica)');

  const ZonaTid(this.abreviatura, this.descripcion);

  final String abreviatura;
  final String descripcion;
}

/// Las siete zonas de la sección 9.
enum Zona {
  a1(
    abreviatura: 'A1',
    nombre: 'Aeróbico regenerativo / técnico',
    descripcion: 'Técnica y drills a muy baja intensidad; recuperación',
    banda: BandaFrecuencia(60, 70),
    ritmo: BandaRitmo(75, 80),
    rpeMinimo: 1,
    rpeMaximo: 2,
    tid: ZonaTid.z1,
  ),
  a2(
    abreviatura: 'A2',
    nombre: 'Aeróbico extensivo',
    descripcion: 'Volumen continuo, base aeróbica, cuenta de brazadas',
    banda: BandaFrecuencia(70, 80),
    ritmo: BandaRitmo(80, 86),
    rpeMinimo: 2,
    rpeMaximo: 4,
    tid: ZonaTid.z1,
  ),
  a3(
    abreviatura: 'A3',
    nombre: 'Aeróbico intensivo',
    descripcion: 'Aeróbico algo duro a duro, a frecuencia cardíaca baja',
    banda: BandaFrecuencia(80, 85),
    // Ginn no tiene A3: la banda se interpoló entre su A2 y su AT.
    ritmo: BandaRitmo(86, 90, interpolada: true),
    rpeMinimo: 4,
    rpeMaximo: 5,
    tid: ZonaTid.z2,
  ),
  at(
    abreviatura: 'AT',
    nombre: 'Umbral anaeróbico',
    descripcion: 'Máximo ritmo sostenible (~ritmo 2000); splits parejos',
    banda: BandaFrecuencia(85, 92),
    ritmo: BandaRitmo(90, 100),
    rpeMinimo: 5,
    rpeMaximo: 6,
    tid: ZonaTid.z2,
  ),
  // La abreviatura sigue siendo `Máx` a propósito: es lo que el entrenador
  // escribe en sus hojas y lo que hay guardado en los planes. Lo que cambia es
  // el nombre, porque llamarla «VO₂ máx» no es lo que dice la fuente: Swimming
  // Canada la define como ~ritmo 400 en esfuerzos de duración larga con
  // descanso medio-bajo, que es resistencia intensiva, no trabajo interválico
  // de VO₂ máx.
  resistenciaIntensiva(
    abreviatura: 'Máx',
    nombre: 'Resistencia intensiva',
    descripcion: '~ritmo 400 en esfuerzos largos con descanso medio-bajo',
    banda: BandaFrecuencia(92, null),
    ritmo: BandaRitmo(100, 110),
    rpeMinimo: 7,
    rpeMaximo: 10,
    tid: ZonaTid.z3,
  ),
  velocidad(
    abreviatura: 'Velocidad',
    nombre: 'Alta intensidad',
    descripcion: '~ritmo 200 o más rápido, en repeticiones de 25 a 100 m',
    banda: null,
    ritmo: BandaRitmo(110, null),
    rpeMinimo: 10,
    rpeMaximo: 10,
    tid: ZonaTid.z3,
  ),
  explosivo(
    abreviatura: 'Exp',
    nombre: 'Explosivo',
    descripcion: '~10 a 20 m a velocidad muy alta, con descanso pasivo largo',
    banda: null,
    // Ginn deja su nivel 6 fuera del cálculo por velocidad crítica: «this
    // intensity is not based on CS, but represents maximal velocity».
    ritmo: null,
    rpeMinimo: 10,
    rpeMaximo: 10,
    tid: ZonaTid.z3,
  );

  const Zona({
    required this.abreviatura,
    required this.nombre,
    required this.descripcion,
    required this.banda,
    required this.ritmo,
    required this.rpeMinimo,
    required this.rpeMaximo,
    required this.tid,
  });

  /// Lo que el entrenador escribe en un plan. Es también la forma guardada.
  final String abreviatura;

  final String nombre;
  final String descripcion;

  /// `null` donde no se controla por frecuencia cardíaca.
  final BandaFrecuencia? banda;

  /// `null` en Explosivo, que no se ancla a la velocidad crítica.
  final BandaRitmo? ritmo;

  final int rpeMinimo;
  final int rpeMaximo;

  /// A qué zona del modelo de tres pertenece, para auditar la distribución.
  final ZonaTid tid;

  bool get seControlaPorRitmo => banda == null;

  /// Verdadero cuando ni la frecuencia cardíaca ni la velocidad crítica la
  /// delimitan: se controla por técnica y por ritmo absoluto.
  bool get seControlaPorTecnica => banda == null && ritmo == null;

  /// Reconoce una zona escrita por el entrenador.
  ///
  /// Distingue `Máx` con y sin tilde, y admite las formas que aparecen en sus
  /// documentos. `RI` se acepta como alias del nombre nuevo de `Máx`.
  static Zona? porAbreviatura(String texto) {
    final buscado = texto.trim().toLowerCase().replaceAll('á', 'a');
    for (final zona in Zona.values) {
      if (zona.abreviatura.toLowerCase().replaceAll('á', 'a') == buscado) {
        return zona;
      }
    }
    const alias = <String, Zona>{
      'vel': Zona.velocidad,
      'ri': Zona.resistenciaIntensiva,
      'resistencia intensiva': Zona.resistenciaIntensiva,
      'explosivo': Zona.explosivo,
    };
    return alias[buscado];
  }

  /// Zonas que pertenecen a una zona del modelo de tres.
  static List<Zona> deTid(ZonaTid tid) =>
      Zona.values.where((z) => z.tid == tid).toList();

  /// Reconoce una zona, admitiendo también un **ritmo de competencia**.
  ///
  /// Un ritmo no es una zona, pero sus hojas lo escriben en la columna de
  /// intensidad (`AT / RP8`, `RP8 / Máx`, `RP8`). Para poder leerlas se traduce
  /// con la regla por defecto de `RitmoCompetencia`, que es un cálculo sobre la
  /// velocidad crítica y no una suposición.
  ///
  /// Se separa de [porAbreviatura] a propósito: quien quiera saber si el
  /// entrenador escribió una zona de verdad o un ritmo, puede distinguirlo.
  static Zona? porAbreviaturaORitmo(String texto) =>
      porAbreviatura(texto) ?? RitmoCompetencia.zonaDe(texto);
}
