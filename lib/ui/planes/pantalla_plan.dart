/// Pantalla de plan: cabecera, microciclos, distribución y auditoría.
///
/// Es donde el entrenador ve lo que no se aprecia en una sesión aislada, y
/// desde donde aprueba.
library;

import 'package:flutter/material.dart';
import 'package:natacion_app/dominio/auditoria/auditoria.dart';
import 'package:natacion_app/dominio/entidades/ciclo_vida_plan.dart';
import 'package:natacion_app/dominio/entidades/plan.dart';
import 'package:natacion_app/dominio/metodologia/validacion_fase.dart';
import 'package:natacion_app/ui/planes/dialogo_aprobacion.dart';
import 'package:natacion_app/ui/planes/panel_distribucion.dart';
import 'package:natacion_app/ui/planes/tabla_auditoria.dart';

class PantallaPlan extends StatefulWidget {
  const PantallaPlan({
    super.key,
    required this.plan,
    required this.versionMetodologia,
  });

  final Plan plan;
  final String versionMetodologia;

  @override
  State<PantallaPlan> createState() => _PantallaPlanState();
}

class _PantallaPlanState extends State<PantallaPlan> {
  late Plan _plan = widget.plan;

  final Auditoria _auditoria = Auditoria();

  late final CicloVidaPlan _ciclo = CicloVidaPlan(
    auditoria: _auditoria,
    versionMetodologia: widget.versionMetodologia,
  );

  Future<void> _aprobar() async {
    final justificaciones = await showDialog<List<Justificacion>>(
      context: context,
      builder: (_) => DialogoAprobacion(plan: _plan, auditoria: _auditoria),
    );
    if (justificaciones == null) return;

    final conJustificaciones =
        _plan.copiarCon(justificaciones: justificaciones);
    final resultado = _ciclo.aprobar(conJustificaciones);

    if (!mounted) return;

    switch (resultado) {
      case TransicionHecha(:final plan):
        setState(() => _plan = plan);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Plan aprobado bajo la metodología '
              '${plan.versionMetodologia}. Queda bloqueado contra edición.',
            ),
          ),
        );
      case TransicionRechazada(:final impedimentos):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(impedimentos.first.toString())),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _auditoria.evaluar(_plan);
    final fase = const ValidacionFase().admiteFase(_plan);
    final alternancia =
        const ReglaAlternanciaTecnificacion().comprobar(_plan);

    return Scaffold(
      appBar: AppBar(
        title: Text(_plan.nombre),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Chip(label: Text(_plan.estado.nombre))),
          ),
        ],
      ),
      floatingActionButton: _plan.estado == EstadoPlan.borrador
          ? FloatingActionButton.extended(
              onPressed: _aprobar,
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Aprobar'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Cabecera(plan: _plan),
          if (!fase.valida) _Advertencia(texto: fase.motivo),
          if (!alternancia.valida) _Advertencia(texto: alternancia.motivo),
          const SizedBox(height: 12),
          PanelDistribucion(plan: _plan),
          const SizedBox(height: 12),
          _Microciclos(plan: _plan),
          const SizedBox(height: 12),
          TablaAuditoria(resultado: resultado),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 24,
          runSpacing: 8,
          children: [
            _Dato(etiqueta: 'Categoría', valor: plan.categoria.nombre),
            _Dato(etiqueta: 'Estilo objetivo', valor: plan.estiloObjetivo.nombre),
            if (plan.pruebaObjetivo.isNotEmpty)
              _Dato(etiqueta: 'Prueba', valor: plan.pruebaObjetivo),
            _Dato(etiqueta: 'Piscina', valor: '${plan.longitudPiscina} m'),
            if (plan.faseAtr != null)
              _Dato(etiqueta: 'Fase ATR', valor: plan.faseAtr!.nombre),
            _Dato(etiqueta: 'Sesiones', valor: '${plan.sesiones.length}'),
            if (plan.versionMetodologia != null)
              _Dato(
                etiqueta: 'Metodología',
                valor: 'v${plan.versionMetodologia}',
              ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: Theme.of(context).textTheme.labelSmall),
        Text(valor, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _Microciclos extends StatelessWidget {
  const _Microciclos({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Microciclos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            if (plan.microciclos.isEmpty)
              const Text('El plan no tiene microciclos'),
            for (final microciclo in plan.microciclos)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  microciclo.nombraElObjetivoReal
                      ? Icons.label_outline
                      : Icons.warning_amber_outlined,
                ),
                title: Text(microciclo.nombre),
                subtitle: Text(
                  microciclo.objetivo.isEmpty
                      ? 'Sin objetivo declarado'
                      : microciclo.objetivo,
                ),
                trailing: Text(
                  '${plan.sesionesDe(microciclo.id).length} sesiones',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Advertencia extends StatelessWidget {
  const _Advertencia({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Card(
      color: esquema.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.report_problem_outlined, color: esquema.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(color: esquema.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
