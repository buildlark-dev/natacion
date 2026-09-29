/// Panel de distribución del plan.
///
/// Por cada zona, el valor real, el prescrito y la diferencia. Más el
/// porcentaje técnico y el reparto de estilos.
library;

import 'package:flutter/material.dart';
import 'package:natacion_app/dominio/auditoria/tolerancia.dart';
import 'package:natacion_app/dominio/calculo/agregacion_plan.dart';
import 'package:natacion_app/dominio/entidades/plan.dart';

class PanelDistribucion extends StatelessWidget {
  const PanelDistribucion({
    super.key,
    required this.plan,
    this.tolerancia = Tolerancia.predeterminada,
  });

  final Plan plan;
  final Tolerancia tolerancia;

  @override
  Widget build(BuildContext context) {
    final agregacion = AgregacionPlan(plan);
    final porZona = agregacion.repartoPorZona;
    final porEstilo = agregacion.repartoDeEstilos;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Distribución del plan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${plan.metros} m · '
                  '${plan.porcentajeTecnico.toStringAsFixed(1)}% técnico',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            if (agregacion.metrosSinZona > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${agregacion.metrosSinZona} m sin zona asignada: la '
                  'distribución no es fiable mientras queden series sin zona.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),

            if (porZona.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Zonas de intensidad frente a ${plan.faseAtr?.nombre ?? 'la fase'}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final reparto in porZona)
                _FilaReparto(reparto: reparto, tolerancia: tolerancia),
            ],

            if (porEstilo.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Estilos, con objetivo ${plan.estiloObjetivo.nombre}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final reparto in porEstilo)
                _FilaReparto(reparto: reparto, tolerancia: tolerancia),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilaReparto extends StatelessWidget {
  const _FilaReparto({required this.reparto, required this.tolerancia});

  final Reparto reparto;
  final Tolerancia tolerancia;

  @override
  Widget build(BuildContext context) {
    final dentro = tolerancia.admite(reparto.diferencia);
    final color = dentro ? null : Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(reparto.etiqueta, style: TextStyle(color: color)),
          ),
          SizedBox(
            width: 70,
            child: Text('${reparto.metros} m', textAlign: TextAlign.end),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: (reparto.porcentajeReal / 100).clamp(0.0, 1.0),
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: Text(
              '${reparto.porcentajeReal.toStringAsFixed(1)}% de '
              '${reparto.porcentajePrescrito.toStringAsFixed(0)}% '
              '(${reparto.diferencia >= 0 ? '+' : ''}'
              '${reparto.diferencia.toStringAsFixed(1)})',
              style: TextStyle(color: color, fontSize: 12),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
