/// Lo que el nadador ve al abrir la app.
///
/// Su sesión del día, con los objetivos y las tres partes, y debajo el sitio
/// donde responder. Funciona **sin señal**: todo lo que pinta sale de lo que ya
/// está en el dispositivo (FR-005).
library;

import 'package:flutter/material.dart';
import 'package:natacion_app/dominio/calculo/sesion_del_dia.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/dominio/entidades/sesion.dart';
import 'package:natacion_app/dominio/notacion/renderizador.dart';
import 'package:natacion_app/ui/nadador/aviso_sincronizacion.dart';
import 'package:natacion_app/ui/nadador/estado_nadador.dart';
import 'package:natacion_app/ui/nadador/formulario_registro.dart';
import 'package:provider/provider.dart';

class PantallaSesionDelDia extends StatelessWidget {
  const PantallaSesionDelDia({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoNadador>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi entrenamiento'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: UltimaSincronizacion(estado: estado)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AvisoSincronizacion(estado: estado),
          const SizedBox(height: 8),
          _Hoy(estado: estado),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Hoy extends StatelessWidget {
  const _Hoy({required this.estado});

  final EstadoNadador estado;

  @override
  Widget build(BuildContext context) {
    if (estado.plan == null) {
      return const _Mensaje(
        icono: Icons.event_busy_outlined,
        titulo: 'Todavía no tienes un plan asignado',
        detalle: 'Cuando tu entrenador te asigne uno, aparecerá aquí.',
      );
    }

    return switch (estado.hoy) {
      SesionDeHoy(:final sesion) => _Sesion(sesion: sesion, estado: estado),
      SinSesionHoy(:final siguiente, :final cuando) => _Mensaje(
          icono: Icons.event_available_outlined,
          titulo: 'Hoy descansas',
          detalle: 'Tu próxima sesión es el '
              '${cuando.day.toString().padLeft(2, '0')}/'
              '${cuando.month.toString().padLeft(2, '0')}: '
              '${siguiente.objetivoTecnico}',
        ),
      SinSesionesPorDelante() => const _Mensaje(
          icono: Icons.flag_outlined,
          titulo: 'No quedan sesiones por delante',
          detalle: 'Habla con tu entrenador para el siguiente ciclo.',
        ),
    };
  }
}

class _Sesion extends StatelessWidget {
  const _Sesion({required this.sesion, required this.estado});

  final Sesion sesion;
  final EstadoNadador estado;

  @override
  Widget build(BuildContext context) {
    final registro = estado.registroDe(sesion.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sesion.objetivoTecnico,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${sesion.metros} m',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(sesion.objetivoFisiologico),
                if (registro?.realizada ?? false) ...[
                  const SizedBox(height: 8),
                  const Chip(
                    avatar: Icon(Icons.check_circle_outline, size: 18),
                    label: Text('Ya la marcaste como realizada'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final tipo in TipoParte.values) _Parte(sesion: sesion, tipo: tipo),
        const SizedBox(height: 12),
        FormularioRegistro(sesion: sesion, estado: estado),
      ],
    );
  }
}

class _Parte extends StatelessWidget {
  const _Parte({required this.sesion, required this.tipo});

  final Sesion sesion;
  final TipoParte tipo;

  @override
  Widget build(BuildContext context) {
    final parte = sesion.parteDe(tipo);
    if (parte.series.isEmpty) return const SizedBox.shrink();

    // Se reutiliza el renderizador de la feature 002: las series se muestran
    // con la notación del entrenador y los nombres exactos de la Biblioteca,
    // sin abreviar, reescribir ni corregir (FR-004).
    const renderizador = Renderizador();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tipo.nombre, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  '${parte.metros} m',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(),
            SelectableText(renderizador.series(parte.series)),
          ],
        ),
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icono, size: 40),
            const SizedBox(height: 12),
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(detalle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
