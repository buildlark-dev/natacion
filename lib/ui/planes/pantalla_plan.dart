/// Pantalla de plan: cabecera, microciclos, distribución y auditoría.
///
/// Es donde el entrenador ve lo que no se aprecia en una sesión aislada, y
/// desde donde aprueba.
library;

import 'package:flutter/material.dart';
import 'package:natacion_app/dominio/auditoria/auditoria.dart';
import 'package:natacion_app/dominio/entidades/ciclo_vida_plan.dart';
import 'package:natacion_app/dominio/entidades/nadador.dart';
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
    this.nadadores = const [],
    this.alEntregar,
  });

  final Plan plan;
  final String versionMetodologia;

  /// Perfiles a los que se puede asignar el plan.
  final List<Nadador> nadadores;

  /// Qué hacer con el plan publicado y asignado.
  ///
  /// Es el puente que faltaba: sin él, lo aprobado se quedaba en la pantalla
  /// del entrenador y el nadador nunca recibía nada (tarea T006).
  final void Function(Plan publicado)? alEntregar;

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

  /// Publica el plan y se lo asigna a los nadadores que el entrenador elija.
  ///
  /// Las dos cosas van juntas a propósito: un plan publicado que no es de nadie
  /// no se lo encuentra nadie, y asignar sin publicar no lo haría visible. La
  /// firma del entrenador es este paso, no el anterior.
  Future<void> _entregar() async {
    final elegidos = await showDialog<List<String>>(
      context: context,
      builder: (_) => _DialogoEntrega(
        nadadores: widget.nadadores,
        yaAsignados: _plan.nadadoresIds,
      ),
    );
    if (elegidos == null) return;

    final resultado = _ciclo.publicar(_plan.copiarCon(nadadoresIds: elegidos));

    if (!mounted) return;

    switch (resultado) {
      case TransicionHecha(:final plan):
        setState(() => _plan = plan);
        widget.alEntregar?.call(plan);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              elegidos.isEmpty
                  ? 'Plan publicado. Todavía no es de nadie: asígnalo para que '
                      'alguien lo vea.'
                  : 'Entregado a ${elegidos.length} nadador'
                      '${elegidos.length == 1 ? '' : 'es'}. Ya lo ven en su app.',
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
    final duracion = const ValidacionFase().duracionDelBloque(_plan);
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
      floatingActionButton: switch (_plan.estado) {
        EstadoPlan.borrador => FloatingActionButton.extended(
            onPressed: _aprobar,
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Aprobar'),
          ),
        // Un plan aprobado todavía no es de nadie. Publicarlo y asignarlo es lo
        // que lo convierte en el entrenamiento de alguien.
        EstadoPlan.aprobado => FloatingActionButton.extended(
            onPressed: _entregar,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Entregar al nadador'),
          ),
        EstadoPlan.publicado => null,
      },
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Cabecera(plan: _plan),
          if (!fase.valida) _Advertencia(texto: fase.motivo),
          if (!alternancia.valida) _Advertencia(texto: alternancia.motivo),
          // La duración de bloque avisa en tono neutro, no en rojo: los rangos
          // de Issurin son de otros deportes y la literatura de natación usa
          // fases más largas.
          if (!duracion.valida) _Aviso(texto: duracion.motivo),
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
            // El entrenador debe saber si lo que va a firmar lo escribió él o
            // lo compuso la app (principio IV).
            _Dato(etiqueta: 'Origen', valor: plan.origen.nombre),
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

/// Aviso en tono neutro, para lo que no es un incumplimiento.
///
/// Se distingue de `_Advertencia`, que va en rojo: un bloque más largo que el
/// rango de Issurin no es un error del plan, porque la literatura de natación
/// usa fases más largas y el macrociclo del entrenador coincide con ella.
class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Card(
      color: esquema.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: esquema.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(color: esquema.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A quién se le entrega el plan.
///
/// Permite entregar a nadie —publicar sin asignar— porque es un estado
/// legítimo: un plan publicado que todavía no es de nadie. Lo que no hace es
/// esconder esa consecuencia: el aviso lo dice.
class _DialogoEntrega extends StatefulWidget {
  const _DialogoEntrega({required this.nadadores, required this.yaAsignados});

  final List<Nadador> nadadores;
  final List<String> yaAsignados;

  @override
  State<_DialogoEntrega> createState() => _DialogoEntregaState();
}

class _DialogoEntregaState extends State<_DialogoEntrega> {
  late final Set<String> _elegidos = widget.yaAsignados.toSet();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Entregar el plan'),
      content: SizedBox(
        width: 400,
        child: widget.nadadores.isEmpty
            ? const Text(
                'Todavía no hay perfiles de nadador. Crea uno en la pestaña '
                'Nadadores y vuelve aquí.',
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Al publicarlo queda bloqueado contra edición. Quien lo '
                    'reciba lo verá en su app, también sin conexión.',
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final nadador in widget.nadadores)
                          CheckboxListTile(
                            value: _elegidos.contains(nadador.id),
                            title: Text(nadador.nombre),
                            subtitle: Text(
                              nadador.categoria?.nombre ?? 'Sin categoría',
                            ),
                            onChanged: (marcado) => setState(() {
                              final id = nadador.id;
                              if (id == null) return;
                              if (marcado ?? false) {
                                _elegidos.add(id);
                              } else {
                                _elegidos.remove(id);
                              }
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_elegidos.toList()),
          child: const Text('Publicar y entregar'),
        ),
      ],
    );
  }
}
