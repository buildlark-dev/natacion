/// Quién está usando la app.
///
/// Es lo que permite decir «lo tuyo» y «lo ajeno». Sin una cuenta, ninguna
/// regla de acceso significa nada: comparar contra un identificador que
/// cualquiera puede declarar da una falsa sensación de protección, que es
/// exactamente la desviación que la feature 003 declaró y esta cierra.
///
/// Contrato: `specs/004-cuentas-y-consentimiento/contracts/cuentas_y_roles.md`.
library;

/// Lo que alguien puede hacer en la app.
///
/// Es una enumeración cerrada y **no un `String`** a propósito: los permisos se
/// deciden sobre un tipo cerrado, y así añadir un rol obliga a revisar todos
/// los sitios donde se decide en lugar de dejar que uno se olvide.
enum Rol {
  entrenador('entrenador'),
  nadador('nadador');

  const Rol(this.clave);

  /// Cómo viaja dentro del token y cómo lo leen las reglas de acceso.
  ///
  /// Las reglas hacen `request.auth.token.rol == 'entrenador'`. Si esta cadena
  /// cambia, hay que cambiarla en `firebase/firestore.rules` el mismo día.
  final String clave;

  /// Resuelve el rol que viene en el token.
  ///
  /// Devuelve `null` ante cualquier valor desconocido —incluido el ausente—
  /// en lugar de suponer el menos peligroso. Quien reciba `null` tiene que
  /// decidir explícitamente qué hacer, y la decisión queda a la vista.
  static Rol? porClave(String? clave) {
    for (final rol in Rol.values) {
      if (rol.clave == clave) return rol;
    }
    return null;
  }
}

/// Una identidad con sesión iniciada.
class Cuenta {
  Cuenta({
    required this.id,
    required this.rol,
    this.nadadorId,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Una cuenta sin identificador no es '
          'una cuenta: es contra esto que las reglas comparan request.auth.uid');
    }
    if (rol == Rol.entrenador && nadadorId != null) {
      throw ArgumentError.value(
        nadadorId,
        'nadadorId',
        'El entrenador no es un nadador de su propia comunidad. Si alguna vez '
            'quiere entrenarse a sí mismo, es una segunda cuenta, no un campo',
      );
    }
  }

  /// El identificador de la cuenta. Es contra este valor que las reglas de
  /// acceso comparan `request.auth.uid`.
  final String id;

  final Rol rol;

  /// A qué perfil de nadador corresponde.
  ///
  /// Nulo mientras ningún entrenador la haya asociado a un perfil. Una cuenta
  /// así **puede entrar y usar la app**; lo que no tiene todavía es plan ni
  /// registros. No es un estado de error: es el día en que alguien se registra
  /// antes de que su entrenador lo inscriba.
  final String? nadadorId;

  bool get esEntrenador => rol == Rol.entrenador;

  bool get esNadador => rol == Rol.nadador;

  /// Verdadero cuando la cuenta todavía no está asociada a ningún perfil.
  bool get sinPerfilAsociado => nadadorId == null;

  Cuenta copiarCon({String? nadadorId}) => Cuenta(
        id: id,
        rol: rol,
        nadadorId: nadadorId ?? this.nadadorId,
      );

  @override
  bool operator ==(Object other) =>
      other is Cuenta &&
      other.id == id &&
      other.rol == rol &&
      other.nadadorId == nadadorId;

  @override
  int get hashCode => Object.hash(id, rol, nadadorId);

  @override
  String toString() => 'Cuenta($id, ${rol.clave}, nadador: $nadadorId)';
}
