/// El aviso de progreso guardado.
///
/// FR-017: ante un registro escrito sin conexión se muestra un estado explícito
/// que indica que quedó guardado y que se enviará cuando haya internet.
///
/// **Lo que nunca se le muestra al nadador**: un error de red, un código de
/// estado, un contador de reintentos o un botón de «reintentar». El reintento es
/// trabajo de la app, y alguien mojado al borde de una piscina no está para
/// diagnosticar conectividad.
library;

import 'package:flutter/material.dart';
import 'package:natacion_app/dominio/sincronizacion/bandeja_salida.dart';
import 'package:natacion_app/ui/nadador/estado_nadador.dart';

class AvisoSincronizacion extends StatelessWidget {
  const AvisoSincronizacion({super.key, required this.estado});

  final EstadoNadador estado;

  @override
  Widget build(BuildContext context) {
    // Sin pendientes no ocupa pantalla: el estado de sincronización no estorba
    // cuando no hace falta.
    if (!estado.hayPendientes) return const SizedBox.shrink();

    final esquema = Theme.of(context).colorScheme;

    return Card(
      color: esquema.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, color: esquema.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                avisoProgresoGuardado,
                style: TextStyle(color: esquema.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuándo se sincronizó por última vez.
///
/// La lectura sin conexión solo cubre lo que ya se descargó alguna vez
/// (decisión D1), así que el nadador tiene derecho a saber si lo que lee está
/// al día. No es un aviso de error: es información.
class UltimaSincronizacion extends StatelessWidget {
  const UltimaSincronizacion({super.key, required this.estado});

  final EstadoNadador estado;

  @override
  Widget build(BuildContext context) {
    final cuando = estado.ultimaSincronizacion;
    final estilo = Theme.of(context).textTheme.bodySmall;

    if (cuando == null) {
      return Text('Sin sincronizar todavía', style: estilo);
    }

    final dia = '${cuando.day.toString().padLeft(2, '0')}/'
        '${cuando.month.toString().padLeft(2, '0')}';
    final hora = '${cuando.hour.toString().padLeft(2, '0')}:'
        '${cuando.minute.toString().padLeft(2, '0')}';

    return Text('Al día hasta el $dia a las $hora', style: estilo);
  }
}
