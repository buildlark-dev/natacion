/// Exportación de planes y perfiles.
///
/// Principio V de la constitución: el usuario puede exportar sus datos en un
/// formato legible. Es la garantía de portabilidad y el seguro contra la
/// dependencia de un proveedor.
///
/// El resultado debe poder leerse **sin la app**.
library;

import 'dart:convert';

import 'package:natacion_app/datos/serializacion.dart';
import 'package:natacion_app/dominio/entidades/nadador.dart';
import 'package:natacion_app/dominio/entidades/plan.dart';

const String formatoExportacion = 'natacion-app/v1';

class Exportacion {
  const Exportacion();

  /// Plan completo con sus sesiones embebidas, en un único documento.
  Map<String, dynamic> plan(Plan plan, {String? versionMetodologia}) {
    return <String, dynamic>{
      'formato': formatoExportacion,
      'exportadoEl': DateTime.now().toIso8601String(),
      'versionMetodologia': ?versionMetodologia,
      'plan': planAJson(plan, conSesiones: true),
    };
  }

  /// Perfil de nadador con los planes que le corresponden.
  Map<String, dynamic> nadador(Nadador nadador, {List<Plan> planes = const []}) {
    return <String, dynamic>{
      'formato': formatoExportacion,
      'exportadoEl': DateTime.now().toIso8601String(),
      'nadador': nadadorAJson(nadador),
      'planes': planes.map((p) => planAJson(p, conSesiones: true)).toList(),
    };
  }

  /// Texto JSON con sangrado, listo para guardar en un archivo.
  String aTexto(Map<String, dynamic> documento) =>
      const JsonEncoder.withIndent('  ').convert(documento);
}
