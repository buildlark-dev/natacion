/// Reparto de un total entre varias partes según porcentajes prescritos.
///
/// Contrato: `specs/002-generador-microciclos/contracts/generacion.md`.
///
/// **Es el cimiento de la generación.** Si no cierra exacto o no es
/// determinista, todas las distribuciones que se apoyen en él arrastrarán el
/// error sin que se note en pantalla.
///
/// Dos decisiones lo gobiernan:
///
/// - El reparto opera en **unidades de longitud de piscina**, no en metros
///   sueltos, para que toda distancia generada sea nadable.
/// - Las unidades sobrantes se asignan por el **método del resto mayor**, con
///   desempate por un orden fijo. Sin ese desempate no habría determinismo: dos
///   claves con el mismo resto podrían recibir el sobrante en orden distinto
///   según cómo itere el código.
library;

import 'package:natacion_app/dominio/metodologia/zonas.dart';

/// Orden de desempate de las zonas, el de la sección 9 de la metodología.
const List<Zona> ordenDeZonas = [
  Zona.a1,
  Zona.a2,
  Zona.a3,
  Zona.at,
  Zona.maximo,
  Zona.velocidad,
];

/// Reparte [unidades] entre las claves de [porcentajes] por el método del
/// resto mayor.
///
/// [orden] fija el desempate: cuando dos claves tienen el mismo resto
/// fraccionario, recibe antes la que aparece primero.
///
/// Garantías:
/// - la suma de lo repartido es exactamente [unidades];
/// - ninguna clave recibe una cantidad negativa;
/// - el resultado no depende del orden de iteración del mapa de entrada.
Map<String, int> repartirPorRestoMayor({
  required int unidades,
  required Map<String, int> porcentajes,
  required List<String> orden,
}) {
  final asignado = <String, int>{};
  final restos = <String, double>{};

  for (final clave in orden) {
    final cuota = unidades * (porcentajes[clave] ?? 0) / 100.0;
    final entero = cuota.floor();
    asignado[clave] = entero;
    restos[clave] = cuota - entero;
  }

  final yaAsignadas = asignado.values.fold(0, (a, b) => a + b);
  var sobrantes = unidades - yaAsignadas;

  // Se recorre por resto descendente; a igual resto, por el orden declarado.
  final porResto = List<String>.from(orden)
    ..sort((a, b) {
      final comparacion = restos[b]!.compareTo(restos[a]!);
      if (comparacion != 0) return comparacion;
      return orden.indexOf(a).compareTo(orden.indexOf(b));
    });

  var i = 0;
  while (sobrantes > 0 && porResto.isNotEmpty) {
    final clave = porResto[i % porResto.length];
    asignado[clave] = asignado[clave]! + 1;
    sobrantes--;
    i++;
  }

  return asignado;
}

/// Reparte unidades entre zonas de intensidad, con el orden de desempate de la
/// metodología.
Map<Zona, int> repartirZonas({
  required int unidades,
  required Map<Zona, int> porcentajes,
}) {
  final porNombre = <String, int>{
    for (final zona in ordenDeZonas) zona.name: porcentajes[zona] ?? 0,
  };

  final repartido = repartirPorRestoMayor(
    unidades: unidades,
    porcentajes: porNombre,
    orden: ordenDeZonas.map((z) => z.name).toList(),
  );

  return <Zona, int>{
    for (final zona in ordenDeZonas) zona: repartido[zona.name] ?? 0,
  };
}

/// Convierte unidades de piscina a metros.
int aMetros(int unidades, int longitudPiscina) => unidades * longitudPiscina;

/// Convierte metros a unidades de piscina.
///
/// Lanza [ArgumentError] si los metros no son múltiplo de la longitud: dejarlo
/// pasar produciría distancias que no se pueden nadar.
int aUnidades(int metros, int longitudPiscina) {
  if (metros % longitudPiscina != 0) {
    throw ArgumentError(
      '$metros m no es múltiplo de $longitudPiscina m: no se puede repartir '
      'en unidades de piscina',
    );
  }
  return metros ~/ longitudPiscina;
}

/// Lleva unos metros al múltiplo de la longitud de piscina más cercano.
///
/// A mitad de camino redondea hacia arriba, de forma estable.
int cuantizar(int metros, int longitudPiscina) {
  final unidades = (metros / longitudPiscina).round();
  return unidades * longitudPiscina;
}
