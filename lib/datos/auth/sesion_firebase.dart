/// Identidad contra Firebase Authentication.
///
/// **Este es el único archivo del proyecto que puede importar
/// `firebase_auth`**, y la prueba de frontera de `test/dominio/arquitectura_test.dart`
/// lo comprueba. El resto de la app —dominio e interfaz— habla de [Cuenta] y de
/// [Rol], que son tipos del dominio.
///
/// No es purismo: es que cambiar de proveedor de identidad tiene que ser un
/// archivo, no una búsqueda por todo el repositorio.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:natacion_app/datos/local/almacen_local.dart';
import 'package:natacion_app/dominio/cuentas/cuenta.dart';
import 'package:natacion_app/dominio/repositorios/repositorios.dart';

/// Cómo se lee el rol dentro del token.
///
/// Tiene que coincidir con lo que leen las reglas de acceso:
/// `request.auth.token.rol`. Si cambia aquí, cambia en `firestore.rules` el
/// mismo día, y las pruebas de reglas se enteran.
const String claveDelRol = 'rol';

/// Dónde vive el vínculo entre la cuenta y el perfil de nadador.
///
/// El rol viaja en el token porque las reglas lo consultan en cada
/// comprobación y ahí no cuesta nada. El perfil asociado es un dato que cambia
/// y que no tiene por qué viajar en cada petición, así que vive en un
/// documento (decisión D2).
const String coleccionUsuarios = 'usuarios';

class SesionFirebase implements Identidad {
  SesionFirebase({
    required this.auth,
    required this.firestore,
    this.almacenLocal,
  });

  final fb.FirebaseAuth auth;
  final FirebaseFirestore firestore;

  /// Lo que hay que vaciar al cerrar sesión. Puede faltar en pruebas.
  final AlmacenLocal? almacenLocal;

  @override
  Future<Cuenta?> actual() => _cuentaDe(auth.currentUser);

  @override
  Stream<Cuenta?> get cambios =>
      auth.idTokenChanges().asyncMap(_cuentaDe);

  @override
  Future<void> cerrarSesion() async {
    // El orden importa y no es casual.
    //
    // Primero se vacía lo que hay en el dispositivo, mientras todavía se sabe
    // de quién era. Después se cierra la sesión. Al revés, quedaría un rastro
    // sin dueño: datos de alguien que ya no se puede identificar para
    // borrarlos, que es la peor versión posible de este problema.
    await almacenLocal?.vaciar();

    // La caché de Firestore sobrevive al cierre de sesión si no se limpia, y
    // el siguiente que entre en este teléfono podría leer de ella. El grupo
    // son hermanos que comparten dispositivo (garantía A7).
    try {
      await firestore.terminate();
      await firestore.clearPersistence();
    } catch (_) {
      // Si la caché no se puede limpiar —web sin almacenamiento, o una
      // instancia ya terminada— no se deja a medias el cierre de sesión. Lo
      // local ya se vació, que es lo que esta app escribe.
    }

    await auth.signOut();
  }

  /// Traduce un usuario de Firebase a una cuenta del dominio.
  ///
  /// Devuelve `null` cuando no hay sesión **y también cuando el token no trae
  /// un rol que se entienda**. Un token sin rol reconocible no se resuelve al
  /// rol menos peligroso: se trata como si no hubiera sesión, porque actuar
  /// con un permiso supuesto es justo como se cuela un acceso.
  Future<Cuenta?> _cuentaDe(fb.User? usuario) async {
    if (usuario == null) return null;

    final token = await usuario.getIdTokenResult();
    final rol = Rol.porClave(token.claims?[claveDelRol] as String?);
    if (rol == null) return null;

    return Cuenta(
      id: usuario.uid,
      rol: rol,
      nadadorId: rol == Rol.entrenador ? null : await _nadadorIdDe(usuario.uid),
    );
  }

  Future<String?> _nadadorIdDe(String uid) async {
    try {
      final documento =
          await firestore.collection(coleccionUsuarios).doc(uid).get();
      return documento.data()?['nadadorId'] as String?;
    } on FirebaseException {
      // Sin red y sin caché, la cuenta entra sin perfil asociado en lugar de
      // no entrar. Es un estado que la app ya sabe mostrar, y bloquear el
      // acceso por no poder leer un vínculo sería dejar a un nadador sin su
      // entrenamiento por un problema de red.
      return null;
    }
  }
}
