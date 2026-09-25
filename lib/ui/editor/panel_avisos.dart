/// Panel de avisos del editor.
///
/// Muestra lo que impide dar la sesión por completa: fragmentos que la app no
/// supo interpretar, volumen fuera del rango de la categoría y datos
/// obligatorios que faltan. Los avisos nombran siempre el dato concreto y la
/// diferencia exacta; nunca sugieren un ejercicio de reemplazo.
library;

import 'package:flutter/material.dart';
import 'package:natacion_app/dominio/entidades/parte.dart';
import 'package:natacion_app/ui/editor/estado_editor.dart';

class PanelAvisos extends StatelessWidget {
  const PanelAvisos({super.key, required this.estado});

  final EstadoEditor estado;

  @override
  Widget build(BuildContext context) {
    final pendientes = estado.pendientes;
    final volumen = estado.volumen;
    final faltas = estado.sesion.faltas;
    final esquema = Theme.of(context).colorScheme;

    final completa = estado.sesion.estaCompleta;

    return Card(
      color: completa
          ? esquema.secondaryContainer
          : esquema.errorContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(completa ? Icons.check_circle : Icons.info_outline),
                const SizedBox(width: 8),
                Text(
                  completa ? 'Sesión completa' : 'Sesión incompleta',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),

            // Volumen frente a la categoría.
            _Linea(
              icono: volumen.dentroDelRango
                  ? Icons.check
                  : Icons.report_problem_outlined,
              texto: volumen.descripcion,
              esProblema: !volumen.dentroDelRango,
            ),

            // Reparto entre partes.
            for (final desviacion in estado.calculo.repartoDePartes)
              if (estado.sesion.metros > 0 &&
                  desviacion.diferencia.abs() > 10)
                _Linea(
                  icono: Icons.percent,
                  texto: '${desviacion.tipo.nombre}: '
                      '${desviacion.porcentajeReal.toStringAsFixed(0)}% '
                      'frente al ${desviacion.porcentajePrescrito}% prescrito',
                  esProblema: true,
                ),

            // Metros sin zona asignada.
            if (estado.calculo.metrosSinZona > 0)
              _Linea(
                icono: Icons.help_outline,
                texto: '${estado.calculo.metrosSinZona} m sin zona asignada. '
                    'La zona la asigna el entrenador, la app no la supone.',
                esProblema: true,
              ),

            // Fragmentos pendientes.
            if (pendientes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Sin interpretar (${pendientes.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final pendiente in pendientes)
                _Linea(
                  icono: _iconoDe(pendiente.motivo),
                  texto: '"${pendiente.texto}" — '
                      '${pendiente.motivo.descripcion}'
                      '${pendiente.detalle.isEmpty ? '' : '. ${pendiente.detalle}'}',
                  esProblema: true,
                ),
            ],

            // Datos obligatorios que faltan.
            for (final falta in faltas)
              if (falta.campo != 'pendientes')
                _Linea(
                  icono: Icons.edit_note,
                  texto: falta.descripcion,
                  esProblema: true,
                ),

            // Notación en desuso y otros avisos que no bloquean.
            for (final aviso in estado.avisos)
              _Linea(icono: Icons.info_outline, texto: aviso, esProblema: false),
          ],
        ),
      ),
    );
  }

  static IconData _iconoDe(MotivoPendiente motivo) {
    switch (motivo) {
      case MotivoPendiente.ejercicioFueraDeBiblioteca:
        return Icons.block;
      case MotivoPendiente.ambiguo:
        return Icons.help_outline;
      case MotivoPendiente.nomenclaturaProhibida:
        return Icons.do_not_disturb_on_outlined;
      case MotivoPendiente.terminoDesconocido:
      case MotivoPendiente.estructuraNoReconocida:
        return Icons.question_mark;
    }
  }
}

class _Linea extends StatelessWidget {
  const _Linea({
    required this.icono,
    required this.texto,
    required this.esProblema,
  });

  final IconData icono;
  final String texto;
  final bool esProblema;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontWeight: esProblema ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
