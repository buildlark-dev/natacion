/// Selección de ejercicios de la Biblioteca Oficial.
///
/// Dos caminos, según haya diagnóstico o no (FR-021, FR-022):
///
/// - **Con diagnóstico**: se eligen ejercicios cuyo «error que corrige»
///   corresponda a los errores observados.
/// - **Sin diagnóstico**: se sigue la progresión técnica de la sección 15, sin
///   inventar errores que nadie observó.
///
/// En ambos casos el recorrido es **estable**: dado el mismo conjunto de
/// entrada, el mismo ejercicio. La rotación entre sesiones se hace por
/// posición, nunca por azar.
///
/// Cuando un error diagnosticado no tiene ejercicio que lo corrija, se reporta
/// el vacío y **no se sustituye** por otro (FR-023). Elegir un ejercicio
/// aproximado sería inventar por otra vía.
library;

import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/dominio/biblioteca/ejercicio.dart';
import 'package:natacion_app/dominio/generacion/resultado.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';

/// Progresión técnica de la sección 15, en orden.
///
/// Se usa cuando no hay diagnóstico: son los términos que se buscan, en este
/// orden, dentro del campo de error que corrige.
const List<String> progresionTecnica = [
  'patada',
  'posición corporal',
  'control corporal',
  'respiración',
  'tracción',
  'brazada',
  'recobro',
  'deslizamiento',
];

/// Lo que devuelve el selector.
class SeleccionEjercicios {
  const SeleccionEjercicios({
    required this.ejercicios,
    this.vacios = const <VacioDeBiblioteca>[],
  });

  final List<Ejercicio> ejercicios;
  final List<VacioDeBiblioteca> vacios;

  bool get estaVacia => ejercicios.isEmpty;
}

class SelectorEjercicios {
  const SelectorEjercicios(this.biblioteca);

  final Biblioteca biblioteca;

  /// Elige ejercicios para un estilo, atendiendo al diagnóstico si lo hay.
  ///
  /// [cuantos] es el número de ejercicios distintos que se quieren.
  SeleccionEjercicios elegir({
    required Estilo estilo,
    required List<String> diagnostico,
    required int cuantos,
    int desplazamiento = 0,
  }) {
    if (diagnostico.isEmpty) {
      return SeleccionEjercicios(
        ejercicios: _porProgresion(estilo, cuantos, desplazamiento),
      );
    }
    return _porDiagnostico(estilo, diagnostico, cuantos, desplazamiento);
  }

  /// Ejercicios del estilo que corrigen alguno de los errores observados.
  SeleccionEjercicios _porDiagnostico(
    Estilo estilo,
    List<String> diagnostico,
    int cuantos,
    int desplazamiento,
  ) {
    final elegidos = <Ejercicio>[];
    final vacios = <VacioDeBiblioteca>[];

    for (final error in diagnostico) {
      final candidatos = _queCorrigen(estilo, error);

      if (candidatos.isEmpty) {
        vacios.add(
          VacioDeBiblioteca(errorDiagnosticado: error, estilo: estilo),
        );
        continue;
      }

      for (final candidato in candidatos) {
        if (!elegidos.contains(candidato)) elegidos.add(candidato);
      }
    }

    if (elegidos.isEmpty) {
      // Con diagnóstico pero sin ejercicios que lo cubran, se recurre a la
      // progresión estándar para que la sesión tenga trabajo técnico. El
      // vacío ya queda reportado.
      return SeleccionEjercicios(
        ejercicios: _porProgresion(estilo, cuantos, desplazamiento),
        vacios: vacios,
      );
    }

    return SeleccionEjercicios(
      ejercicios: _tomarRotando(elegidos, cuantos, desplazamiento),
      vacios: vacios,
    );
  }

  /// Ejercicios del estilo en el orden de la progresión de la sección 15.
  List<Ejercicio> _porProgresion(
    Estilo estilo,
    int cuantos,
    int desplazamiento,
  ) {
    final ordenados = <Ejercicio>[];

    for (final etapa in progresionTecnica) {
      for (final ejercicio in _queCorrigen(estilo, etapa)) {
        if (!ordenados.contains(ejercicio)) ordenados.add(ejercicio);
      }
    }

    // Los que no encajan en ninguna etapa van al final, en el orden de la
    // Biblioteca, para que el recorrido siga siendo estable y completo.
    for (final ejercicio in _delEstilo(estilo)) {
      if (!ordenados.contains(ejercicio)) ordenados.add(ejercicio);
    }

    return _tomarRotando(ordenados, cuantos, desplazamiento);
  }

  /// Ejercicios del estilo cuyo error corregido menciona [termino].
  ///
  /// La correspondencia es por término normalizado sobre el texto en prosa de
  /// la Biblioteca. **Es el punto más débil de la feature**: ese campo está
  /// escrito en lenguaje libre y el emparejamiento puede fallar en los dos
  /// sentidos. Por eso un error sin coincidencia se reporta como vacío en
  /// lugar de resolverse con un ejercicio aproximado.
  List<Ejercicio> _queCorrigen(Estilo estilo, String termino) {
    final buscado = _normalizar(termino);
    if (buscado.isEmpty) return const [];

    return _delEstilo(estilo)
        .where((e) => _normalizar(e.errorQueCorrige).contains(buscado))
        .toList();
  }

  /// Ejercicios del estilo, más los generales, en el orden de la Biblioteca.
  List<Ejercicio> _delEstilo(Estilo estilo) => biblioteca.todos
      .where((e) => e.estilo == estilo || e.estilo == Estilo.general)
      .toList();

  /// Toma [cuantos] elementos empezando en [desplazamiento], dando la vuelta.
  ///
  /// Es lo que hace que dos sesiones de la misma semana no repitan los mismos
  /// ejercicios, sin usar azar.
  List<Ejercicio> _tomarRotando(
    List<Ejercicio> origen,
    int cuantos,
    int desplazamiento,
  ) {
    if (origen.isEmpty || cuantos <= 0) return const [];

    return [
      for (var i = 0; i < cuantos && i < origen.length; i++)
        origen[(desplazamiento + i) % origen.length],
    ];
  }

  static String _normalizar(String texto) => texto
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .trim();
}
