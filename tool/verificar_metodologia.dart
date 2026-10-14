/// Comprueba que los documentos normativos no cambiaron sin subir la versión.
///
/// `docs/metodologia/metodologia.json` declara la versión vigente y la huella
/// SHA-256 de cada documento normativo, y dice esto:
///
/// > «Si una huella deja de coincidir, un documento normativo cambió sin subir
/// > la versión.»
///
/// Esta herramienta lo convierte en algo que el sistema verifica, en lugar de
/// algo que hay que recordar. La app estampa la versión del manifiesto en cada
/// plan aprobado (FR-026): si el documento cambió y la versión no, los planes
/// quedan sellados con una versión que ya no describe lo que se les aplicó.
///
/// Uso:
///
///   dart run tool/verificar_metodologia.dart
///
/// Devuelve 0 si todo cuadra y 1 si alguna huella no coincide.
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Huella de un documento normativo.
///
/// Los documentos de texto se normalizan a saltos de línea LF **antes** de
/// resumirlos. No es un detalle de estilo: sin esto, la misma versión de la
/// metodología tiene dos huellas distintas según quién la tenga en el disco.
///
/// Git convierte los finales de línea al sacar los archivos del repositorio,
/// así que un clon en Windows y uno en Linux ven bytes distintos para el mismo
/// contenido. El CI corre en Linux y veía LF; el entrenador trabaja en Windows
/// y veía CRLF. La puerta aprobaba en un sitio y fallaba en el otro, por una
/// conversión que **no cambia ni una regla de entrenamiento**.
///
/// Lo que esta herramienta tiene que detectar es que cambió una regla. Un salto
/// de línea distinto no lo es.
///
/// Los binarios —la biblioteca en `.docx`— se resumen tal cual: ahí cualquier
/// byte distinto sí es un documento distinto, y normalizar lo corrompería.
String huellaDe(File archivo) {
  final bytes = archivo.readAsBytesSync();
  final esTexto = archivo.path.toLowerCase().endsWith('.md');
  return sha256.convert(esTexto ? sinRetornosDeCarro(bytes) : bytes).toString();
}

/// Quita los `\r` de un `\r\n`. Un `\r` suelto se conserva, porque entonces no
/// es un final de línea de Windows sino contenido.
List<int> sinRetornosDeCarro(List<int> bytes) {
  const retorno = 13; // \r
  const salto = 10; // \n

  final salida = <int>[];
  for (var i = 0; i < bytes.length; i++) {
    final esCrLf =
        bytes[i] == retorno && i + 1 < bytes.length && bytes[i + 1] == salto;
    if (!esCrLf) salida.add(bytes[i]);
  }
  return salida;
}

void main() {
  final manifiesto = File('docs/metodologia/metodologia.json');
  if (!manifiesto.existsSync()) {
    stdout.writeln(
      'No encuentro docs/metodologia/metodologia.json. '
      'Ejecuta esto desde la raíz del proyecto.',
    );
    exit(1);
  }

  final json =
      jsonDecode(manifiesto.readAsStringSync()) as Map<String, dynamic>;
  final version = json['version'] as String? ?? '(sin versión)';
  final documentos = json['documentos'] as List<dynamic>? ?? const [];

  stdout.writeln('Metodología declarada: $version');
  stdout.writeln('');

  var fallos = 0;

  for (final entrada in documentos) {
    final documento = entrada as Map<String, dynamic>;
    final ruta = documento['ruta'] as String? ?? '';
    final declarada = documento['sha256'] as String? ?? '';

    final archivo = File(ruta);
    if (!archivo.existsSync()) {
      stdout.writeln('FALTA  $ruta');
      stdout.writeln('       El manifiesto lo declara y no está en el árbol.');
      fallos++;
      continue;
    }

    final real = huellaDe(archivo);

    if (real == declarada) {
      stdout.writeln('OK     $ruta');
      continue;
    }

    stdout.writeln('CAMBIÓ $ruta');
    stdout.writeln('       declarada: $declarada');
    stdout.writeln('       real:      $real');
    fallos++;
  }

  stdout.writeln('');

  if (fallos == 0) {
    stdout.writeln(
      'Las ${documentos.length} huellas coinciden. '
      'Los planes sellados con $version describen lo que se les aplicó.',
    );
    return;
  }

  stdout.writeln(
    '$fallos documento(s) normativo(s) cambiaron sin que la versión del '
    'manifiesto cambie.',
  );
  stdout.writeln('');
  stdout.writeln('Qué hacer, y en este orden:');
  stdout.writeln('  1. Decidir si el cambio es una corrección o una revisión');
  stdout.writeln('     metodológica: 3.5.1 frente a 3.6.');
  stdout.writeln('  2. Subir "version" en el manifiesto y anotar el cambio.');
  stdout.writeln('  3. Actualizar la huella con el valor real de arriba.');
  stdout.writeln('  4. Revisar las pruebas que fijan las constantes afectadas.');
  stdout.writeln('');
  stdout.writeln(
    'No actualices solo la huella: eso oculta que una regla de entrenamiento '
    'cambió, y los planes aprobados antes quedan mal sellados.',
  );
  exit(1);
}
