/// Interfaces que el dominio declara y la capa de datos implementa.
///
/// Contrato: `specs/001-editor-planes-auditoria/contracts/almacenamiento.md`.
///
/// **Ninguna firma menciona tipos de Firestore.** Los errores se expresan como
/// resultados del dominio, no como excepciones de la librería de datos.
library;

import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/dominio/entidades/envio_pendiente.dart';
import 'package:natacion_app/dominio/entidades/plan.dart';
import 'package:natacion_app/dominio/entidades/registro_sesion.dart';
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

/// Los registros que el nadador escribe sobre sus sesiones (feature 003).
///
/// `guardar` escribe **primero en local** y encola el envío después. Ese orden
/// es la feature: si escribiera primero en el servidor, un nadador sin red
/// perdería lo escrito, que es justo lo que FR-019 prohíbe.
abstract class RepositorioRegistros {
  Future<RegistroDeSesion?> obtener(String registroId);

  Future<List<RegistroDeSesion>> obtenerDePlan(String nadadorId, String planId);

  /// Guarda en el dispositivo. **No consulta la red y no puede fallar por su
  /// causa** (garantía G1 del contrato de sincronización).
  Future<void> guardar(RegistroDeSesion registro);

  /// Exporta los registros de un nadador en formato legible (FR-024).
  Future<Map<String, dynamic>> exportar(String nadadorId);

  /// Borra todos los registros de un nadador (FR-024, principio V).
  Future<void> eliminarDe(String nadadorId);
}

/// La bandeja de salida: lo que sostiene la promesa de que nada se pierde.
///
/// Contrato completo en
/// `specs/003-consumo-del-nadador/contracts/sincronizacion.md`.
abstract class BandejaDeSalida {
  Future<void> encolar(String registroId);

  Future<List<EnvioPendiente>> pendientes();

  Future<EnvioPendiente?> estadoDe(String registroId);

  Future<void> actualizar(EnvioPendiente envio);
}

/// Si hay red, para saber cuándo reintentar.
///
/// Es una interfaz del dominio para que la bandeja no conozca el mecanismo de
/// detección (principio II).
abstract class EstadoDeRed {
  Future<bool> hayConexion();

  /// Emite cada vez que la conectividad cambia.
  Stream<bool> get cambios;
}

/// Envía un registro a su destino. Lo implementa la capa de datos.
abstract class EnvioDeRegistros {
  /// Devuelve la hora del servidor al aceptar el registro.
  ///
  /// Lanza si no se pudo enviar: la bandeja lo traduce a un reintento.
  Future<DateTime> enviar(RegistroDeSesion registro);
}
