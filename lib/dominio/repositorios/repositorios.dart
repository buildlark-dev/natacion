/// Interfaces que el dominio declara y la capa de datos implementa.
///
/// Contrato: `specs/001-editor-planes-auditoria/contracts/almacenamiento.md`.
///
/// **Ninguna firma menciona tipos de Firestore.** Los errores se expresan como
/// resultados del dominio, no como excepciones de la librería de datos.
library;

import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/dominio/entidades/plan.dart';
import 'package:natacion_app/dominio/entidades/nadador.dart';
import 'package:natacion_app/dominio/entidades/sesion.dart';
import 'package:natacion_app/dominio/metodologia/categorias.dart';

/// Fallo al acceder a los datos, expresado en términos del dominio.
class FalloDeDatos implements Exception {
  const FalloDeDatos(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

abstract class RepositorioPlanes {
  Future<Plan?> obtener(String id);

  Future<List<Plan>> listar({Categoria? categoria, EstadoPlan? estado});

  /// Guarda un borrador. Devuelve el identificador asignado.
  Future<String> guardarBorrador(Plan plan);

  /// Guarda un plan ya aprobado, con su instantánea de auditoría.
  Future<void> guardarAprobado(Plan plan, Map<String, dynamic> auditoria);

  /// Crea una versión nueva en borrador desde un plan aprobado (FR-025).
  Future<Plan> crearVersionDesde(String idAprobado);

  /// Exporta el plan completo en un formato legible sin la app (FR-031).
  Future<Map<String, dynamic>> exportar(String id);
}

abstract class RepositorioSesiones {
  Future<List<Sesion>> obtenerDePlan(String planId);

  Future<String> guardar(String planId, Sesion sesion);

  Future<void> eliminar(String planId, String sesionId);
}

abstract class RepositorioNadadores {
  Future<Nadador?> obtener(String id);

  Future<List<Nadador>> listar();

  Future<String> guardar(Nadador nadador);

  Future<void> eliminar(String id);

  Future<Map<String, dynamic>> exportar(String id);
}

abstract class RepositorioBiblioteca {
  Future<Biblioteca> cargar();
}
