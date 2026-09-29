// Verificación del reparto del generador de microciclos.
//
// Comprueba que para toda combinación de categoría, fase y longitud de piscina el
// reparto cierra exacto, el volumen cae dentro del rango de la categoría y ninguna
// zona se desvía más de la tolerancia de ±3 puntos porcentuales.
//
// Se usó para de-riesgar el diseño antes de escribir el plan (decisión D1 de
// research.md). Las pruebas del dominio cubren lo mismo sobre el código real.
//
// Uso:  dart run tool/verificar_reparto.dart

import 'dart:io';

class Cat {
  const Cat(this.nombre, this.min, this.max, this.sesiones, this.atr);
  final String nombre; final int min, max, sesiones; final bool atr;
}

const cats = [
  Cat('Iniciacion', 500, 800, 2, false),
  Cat('Tecnificacion', 800, 1000, 2, false),
  Cat('Precompetitivo', 1800, 2200, 3, true),
  Cat('Competitivo', 4000, 5000, 5, true),
  Cat('AltoRendimiento', 5000, 6000, 10, true),
];

const zonas = ['A1', 'A2', 'A3', 'AT', 'Max', 'Vel'];

const fases = {
  'Acumulacion':    {'A1': 60, 'A2': 25, 'A3': 10, 'AT': 5,  'Max': 0,  'Vel': 0,  'tec': 50},
  'Transformacion': {'A1': 30, 'A2': 35, 'A3': 15, 'AT': 15, 'Max': 5,  'Vel': 0,  'tec': 30},
  'Realizacion':    {'A1': 25, 'A2': 25, 'A3': 15, 'AT': 10, 'Max': 15, 'Vel': 10, 'tec': 20},
};

/// Reparto por resto mayor sobre unidades enteras. Empates por orden fijo.
Map<String, int> repartir(int unidades, Map<String, int> pct, List<String> orden) {
  final base = <String, int>{};
  final resto = <String, double>{};
  var asignadas = 0;
  for (final k in orden) {
    final exacto = unidades * (pct[k] ?? 0) / 100.0;
    base[k] = exacto.floor();
    resto[k] = exacto - exacto.floor();
    asignadas += base[k]!;
  }
  var sobran = unidades - asignadas;
  final porResto = orden.toList()
    ..sort((a, b) {
      final c = resto[b]!.compareTo(resto[a]!);
      return c != 0 ? c : orden.indexOf(a).compareTo(orden.indexOf(b));
    });
  var i = 0;
  while (sobran > 0) {
    base[porResto[i % porResto.length]] = base[porResto[i % porResto.length]]! + 1;
    sobran--; i++;
  }
  return base;
}

void main() {
  var fallos = 0;
  for (final cat in cats) {
    // Volumen por sesion: punto medio del rango, cuantizado.
    for (final piscina in [25, 50]) {
      final q = piscina;
      final medio = ((cat.min + cat.max) / 2).round();
      final porSesion = (medio / q).round() * q;
      final total = porSesion * cat.sesiones;
      final unidades = total ~/ q;

      final listaFases = cat.atr ? fases.keys.toList() : ['(sin ATR)'];
      for (final fase in listaFases) {
        if (!cat.atr) {
          final ok = porSesion >= cat.min && porSesion <= cat.max;
          stdout.writeln('${cat.nombre} p$piscina: $porSesion m/ses x${cat.sesiones} = $total m  '
              '${ok ? "OK" : "FUERA DE RANGO"}');
          if (!ok) fallos++;
          continue;
        }
        final pct = fases[fase]!;
        final rep = repartir(unidades, pct, zonas);
        final suma = rep.values.fold(0, (a, b) => a + b);
        final desv = <String>[];
        for (final z in zonas) {
          final real = suma == 0 ? 0.0 : rep[z]! * 100 / suma;
          final d = real - (pct[z] ?? 0);
          if (d.abs() > 3) desv.add('$z ${d.toStringAsFixed(2)}');
        }
        final okVol = porSesion >= cat.min && porSesion <= cat.max;
        final okSuma = suma == unidades;
        if (desv.isNotEmpty || !okVol || !okSuma) fallos++;
        stdout.writeln('${cat.nombre} p$piscina $fase: $porSesion m/ses, total $total m, '
            '${unidades}u  vol=${okVol ? "ok" : "FUERA"} suma=${okSuma ? "ok" : "MAL"} '
            '${desv.isEmpty ? "dentro de tolerancia" : "DESVIA: ${desv.join(", ")}"}');
      }
    }
  }
  stdout.writeln('\nFALLOS: $fallos');
}
