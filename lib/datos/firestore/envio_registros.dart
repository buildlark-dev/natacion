/// Lleva un registro del nadador a Firestore.
///
/// Implementa `EnvioDeRegistros` del dominio. Es la única pieza de la
/// sincronización que sabe que debajo hay Firestore; la bandeja de salida y sus
/// ocho garantías no lo saben, y por eso se prueban en Dart puro.
///
/// **El identificador del documento es el identificador determinista del
/// registro.** Eso es lo que hace imposible duplicar al reenviar (FR-020,
/// decisión D2): dos envíos escriben el mismo documento.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:natacion_app/datos/serializacion.dart';
import 'package:natacion_app/dominio/entidades/registro_sesion.dart';
import 'package:natacion_app/dominio/repositorios/repositorios.dart';

const String coleccionRegistros = 'registros';

class EnvioAFirestore implements EnvioDeRegistros {
  const EnvioAFirestore(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Future<DateTime> enviar(RegistroDeSesion registro) async {
    final documento = firestore.collection(coleccionRegistros).doc(registro.id);

    try {
      await documento.set(<String, dynamic>{
        ...registroAJson(registro),
        // La hora del servidor, que es la que ordena y permite detectar un
        // reloj desajustado (decisión D3). La del dispositivo ya va dentro.
        'recibidoEn': FieldValue.serverTimestamp(),
      });

      final guardado = await documento.get();
      final recibido = guardado.data()?['recibidoEn'];

      // Si el servidor aún no resolvió la marca, se usa la del dispositivo: no
      // vale la pena fallar un envío que sí llegó por una marca de tiempo.
      return recibido is Timestamp ? recibido.toDate() : registro.registradoEn;
    } on FirebaseException catch (e) {
      // Se traduce a una excepción del dominio: la bandeja no conoce Firestore.
      throw FalloDeDatos('No se pudo enviar el registro: ${e.message}');
    }
  }
}
