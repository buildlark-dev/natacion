/// Serie: la unidad mínima de trabajo dentro de una parte de la sesión.
library;

import 'package:natacion_app/dominio/biblioteca/ejercicio.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/dominio/metodologia/zonas.dart';

/// Implementos de la sección 10 del documento normativo.
enum Implemento {
  aletas('AL', 'Aletas'),
  palas('PL', 'Palas'),
  palasPequenas('Pp', 'Palas pequeñas'),
  pullBuoy('PULL', 'Pull buoy'),
  snorkel('SNK', 'Snorkel'),
  paracaidas('PARAC', 'Paracaídas'),
  caucho('CAUCHO', 'Banda elástica');

  const Implemento(this.abreviatura, this.nombre);

  final String abreviatura;
  final String nombre;
}

/// Modificadores de ejecución de la sección 10.
enum Modificador {
  patada('PN', 'Patada'),
  brazada('BR', 'Brazada'),
  subacuatico('UW', 'Subacuático'),
  recuperacion('REC', 'Recuperación'),
  progresivo('1<4', 'Progresivo'),
  regresivo('1>4', 'Regresivo'),
  salidaDeBloque('^', 'Con salida desde el bloque'),
  partido('Partido', 'Nado fraccionado'),
  hipoxico('Hyp', 'Hipóxico');

  const Modificador(this.abreviatura, this.nombre);

  final String abreviatura;
  final String nombre;
}

/// De dónde salió el valor de un campo.
///
/// La corrección manual prevalece sobre la interpretación automática y una
/// reinterpretación posterior no puede sobrescribirla (FR-035).
enum OrigenDato { interpretado, corregidoAMano }

class Serie {
  const Serie({
    this.repeticiones = 1,
    required this.distancia,
    this.tiempoSalida,
    this.implementos = const <Implemento>[],
    this.modificadores = const <Modificador>[],
    this.ejercicio,
    this.estilo,
    this.bloqueTecnico,
    this.zona,
    this.respiracionCada,
    this.origen = OrigenDato.interpretado,
    this.camposCorregidos = const <String>{},
    this.textoOriginal = '',
  });

  final int repeticiones;
  final int distancia;
  final Duration? tiempoSalida;
  final List<Implemento> implementos;
  final List<Modificador> modificadores;

  /// Nulo cuando la serie es nado completo sin ejercicio técnico.
  final Ejercicio? ejercicio;

  final Estilo? estilo;

  /// Etiqueta de bloque tecnico (`TEC L`, `TEC E`, ...). Valida solo como
  /// etiqueta de un bloque compuesto por ejercicios de la Biblioteca, nunca
  /// como nombre de un nado completo (seccion 8).
  final Estilo? bloqueTecnico;

  /// La asigna el entrenador. El analizador no la adivina (FR-011).
  final Zona? zona;

  /// Número de brazadas entre respiraciones, de `Hyp n`.
  final int? respiracionCada;

  final OrigenDato origen;

  /// Campos que el entrenador corrigió a mano. Una reinterpretación no los
  /// toca.
  final Set<String> camposCorregidos;

  final String textoOriginal;

  /// Metros de la serie: repeticiones por distancia.
  int get metros => repeticiones * distancia;

  /// Alimenta el porcentaje de trabajo técnico: cuenta como técnica toda serie
  /// que referencia un ejercicio de la Biblioteca, no el nado completo de
  /// estilo (definición de la sección 12).
  bool get esTecnica => ejercicio != null || bloqueTecnico != null;

  Serie copiarCon({
    int? repeticiones,
    int? distancia,
    Duration? tiempoSalida,
    List<Implemento>? implementos,
    List<Modificador>? modificadores,
    Ejercicio? ejercicio,
    Estilo? estilo,
    Estilo? bloqueTecnico,
    Zona? zona,
    int? respiracionCada,
    OrigenDato? origen,
    Set<String>? camposCorregidos,
    String? textoOriginal,
  }) {
    return Serie(
      repeticiones: repeticiones ?? this.repeticiones,
      distancia: distancia ?? this.distancia,
      tiempoSalida: tiempoSalida ?? this.tiempoSalida,
      implementos: implementos ?? this.implementos,
      modificadores: modificadores ?? this.modificadores,
      ejercicio: ejercicio ?? this.ejercicio,
      estilo: estilo ?? this.estilo,
      bloqueTecnico: bloqueTecnico ?? this.bloqueTecnico,
      zona: zona ?? this.zona,
      respiracionCada: respiracionCada ?? this.respiracionCada,
      origen: origen ?? this.origen,
      camposCorregidos: camposCorregidos ?? this.camposCorregidos,
      textoOriginal: textoOriginal ?? this.textoOriginal,
    );
  }

  /// Aplica una corrección manual sobre un campo, dejándolo protegido frente a
  /// futuras reinterpretaciones.
  Serie corregir(String campo, {int? valorEntero, Zona? zona, Estilo? estilo}) {
    final protegidos = <String>{...camposCorregidos, campo};
    return copiarCon(
      repeticiones: campo == 'repeticiones' ? valorEntero : null,
      distancia: campo == 'distancia' ? valorEntero : null,
      zona: campo == 'zona' ? zona : null,
      estilo: campo == 'estilo' ? estilo : null,
      origen: OrigenDato.corregidoAMano,
      camposCorregidos: protegidos,
    );
  }

  bool estaProtegido(String campo) => camposCorregidos.contains(campo);

  @override
  String toString() =>
      '${repeticiones}x$distancia${estilo != null ? ' ${estilo!.nombre}' : ''}'
      '${ejercicio != null ? ' ${ejercicio!.nombreParaPlan}' : ''}'
      ' = $metros m';
}
