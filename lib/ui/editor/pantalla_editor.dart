/// Pantalla del editor de sesión.
///
/// A la izquierda, las tres partes como áreas de texto libre, donde el
/// entrenador escribe con su notación de siempre. A la derecha, lo que la app
/// entendió, en campos editables, más los totales en vivo y los avisos.
library;

import 'package:flutter/material.dart';
import 'package:natacion_app/dominio/entidades/serie.dart';
import 'package:natacion_app/dominio/metodologia/categorias.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/dominio/metodologia/zonas.dart';
import 'package:natacion_app/ui/editor/estado_editor.dart';
import 'package:natacion_app/ui/editor/panel_avisos.dart';
import 'package:provider/provider.dart';

class PantallaEditor extends StatelessWidget {
  const PantallaEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoEditor>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de sesión'),
        bottom: estado.revisandoGenerado
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: _SelectorSesiones(estado: estado),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${estado.sesion.metros} m · '
                '${estado.sesion.porcentajeTecnico.toStringAsFixed(0)}% técnico',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, restricciones) {
          final enColumna = restricciones.maxWidth < 900;
          final izquierda = _ColumnaEscritura(estado: estado);
          final derecha = _ColumnaInterpretacion(estado: estado);

          if (enColumna) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [izquierda, const SizedBox(height: 24), derecha],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: izquierda,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: derecha,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ColumnaEscritura extends StatelessWidget {
  const _ColumnaEscritura({required this.estado});

  final EstadoEditor estado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CabeceraSesion(estado: estado),
        const SizedBox(height: 16),
        for (final tipo in TipoParte.values) ...[
          _CampoParte(estado: estado, tipo: tipo),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _CabeceraSesion extends StatelessWidget {
  const _CabeceraSesion({required this.estado});

  final EstadoEditor estado;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<Categoria>(
              initialValue: estado.categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: [
                for (final categoria in Categoria.values)
                  DropdownMenuItem(
                    value: categoria,
                    child: Text(
                      '${categoria.nombre} · ${categoria.volumenPorSesion}',
                    ),
                  ),
              ],
              onChanged: (valor) {
                if (valor != null) estado.cambiarCategoria(valor);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Objetivo técnico',
                hintText: 'Mejoramiento técnica de Espalda',
              ),
              onChanged: estado.cambiarObjetivoTecnico,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Objetivo fisiológico',
                hintText: 'Base aeróbica',
              ),
              onChanged: estado.cambiarObjetivoFisiologico,
            ),
            const SizedBox(height: 8),
            _SelectorRpe(estado: estado),
          ],
        ),
      ),
    );
  }
}

class _SelectorRpe extends StatelessWidget {
  const _SelectorRpe({required this.estado});

  final EstadoEditor estado;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('RPE previsto (Borg 0-10):'),
        const SizedBox(width: 12),
        Expanded(
          child: Slider(
            value: (estado.sesion.rpePrevisto ?? 0).toDouble(),
            max: 10,
            divisions: 10,
            label: '${estado.sesion.rpePrevisto ?? 0}',
            onChanged: (valor) => estado.cambiarRpe(valor.round()),
          ),
        ),
      ],
    );
  }
}

class _CampoParte extends StatelessWidget {
  const _CampoParte({required this.estado, required this.tipo});

  final EstadoEditor estado;
  final TipoParte tipo;

  @override
  Widget build(BuildContext context) {
    final parte = estado.sesion.parteDe(tipo);
    final porcentaje = estado.sesion.porcentajeDe(tipo);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tipo.nombre,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${parte.metros} m · ${porcentaje.toStringAsFixed(0)}% '
                  '(prescrito ${tipo.porcentajePrescrito}%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 6,
              minLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '200 N + 4x100 AL SNK PN / 2\'',
              ),
              onChanged: (texto) => estado.escribirParte(tipo, texto),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnaInterpretacion extends StatelessWidget {
  const _ColumnaInterpretacion({required this.estado});

  final EstadoEditor estado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PanelAvisos(estado: estado),
        const SizedBox(height: 16),
        for (final tipo in TipoParte.values)
          _SeriesInterpretadas(estado: estado, tipo: tipo),
      ],
    );
  }
}

class _SeriesInterpretadas extends StatelessWidget {
  const _SeriesInterpretadas({required this.estado, required this.tipo});

  final EstadoEditor estado;
  final TipoParte tipo;

  @override
  Widget build(BuildContext context) {
    final parte = estado.sesion.parteDe(tipo);
    if (parte.series.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tipo.nombre, style: Theme.of(context).textTheme.titleSmall),
            const Divider(),
            for (var i = 0; i < parte.series.length; i++)
              _FilaSerie(
                estado: estado,
                tipo: tipo,
                indice: i,
                serie: parte.series[i],
              ),
          ],
        ),
      ),
    );
  }
}

class _FilaSerie extends StatelessWidget {
  const _FilaSerie({
    required this.estado,
    required this.tipo,
    required this.indice,
    required this.serie,
  });

  final EstadoEditor estado;
  final TipoParte tipo;
  final int indice;
  final Serie serie;

  @override
  Widget build(BuildContext context) {
    final corregida = serie.origen == OrigenDato.corregidoAMano;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '${serie.repeticiones}x${serie.distancia} m'
              '${serie.ejercicio != null ? ' · ${serie.ejercicio!.nombreParaPlan}' : ''}',
              style: TextStyle(
                fontWeight: corregida ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: DropdownButton<Zona>(
              isExpanded: true,
              value: serie.zona,
              hint: const Text('Zona'),
              items: [
                for (final zona in Zona.values)
                  DropdownMenuItem(
                    value: zona,
                    child: Text(zona.abreviatura),
                  ),
              ],
              onChanged: (zona) {
                if (zona != null) estado.asignarZona(tipo, indice, zona);
              },
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${serie.metros} m',
              textAlign: TextAlign.end,
            ),
          ),
          if (corregida)
            const Tooltip(
              message: 'Corregido a mano: prevalece sobre la interpretación',
              child: Icon(Icons.edit, size: 16),
            ),
        ],
      ),
    );
  }
}

/// Estilos declarados, usados por el panel de avisos.
extension EstiloLegible on Estilo {
  String get etiqueta => nombre;
}

/// Navegación entre las sesiones de un microciclo generado.
///
/// Aparece solo cuando el entrenador está revisando algo generado: cuando
/// escribe a mano, no hay varias sesiones entre las que moverse.
class _SelectorSesiones extends StatelessWidget {
  const _SelectorSesiones({required this.estado});

  final EstadoEditor estado;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.auto_awesome, size: 16),
          const SizedBox(width: 8),
          const Text('Generado:'),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: estado.sesionesDelPlan.length,
              itemBuilder: (context, indice) {
                final seleccionada = indice == estado.indiceAbierta;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('Sesión ${indice + 1}'),
                    selected: seleccionada,
                    onSelected: (_) => estado.abrirSesion(indice),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
