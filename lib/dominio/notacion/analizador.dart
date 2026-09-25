/// Analizador de la notación del entrenador.
///
/// Contrato: `specs/001-editor-planes-auditoria/contracts/notacion.md`.
///
/// **Garantía fundamental**: nunca lanza una excepción. Ante cualquier entrada
/// devuelve las series que sí pudo interpretar más la lista de fragmentos que
/// no, cada uno con su posición exacta en el texto original. Es lo que permite
/// que el entrenador siga escribiendo aunque la app no entienda una parte
/// (FR-036).
library;

import 'package:natacion_app/dominio/biblioteca/biblioteca.dart';
import 'package:natacion_app/dominio/biblioteca/ejercicio.dart';
import 'package:natacion_app/dominio/entidades/parte.dart';
import 'package:natacion_app/dominio/entidades/serie.dart';
import 'package:natacion_app/dominio/notacion/glosario.dart';
import 'package:natacion_app/dominio/notacion/tokenizador.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';

/// Lo que devuelve el analizador: series interpretadas y lo que quedó
/// pendiente.
class ResultadoAnalisis {
  const ResultadoAnalisis({
    required this.series,
    required this.pendientes,
    this.avisos = const <String>[],
  });

  final List<Serie> series;
  final List<FragmentoPendiente> pendientes;

  /// Información que no impide nada, como notación en desuso ignorada.
  final List<String> avisos;

  int get metros => series.fold(0, (total, serie) => total + serie.metros);

  bool get tienePendientes => pendientes.isNotEmpty;
}

class Analizador {
  Analizador({required this.biblioteca, Glosario? glosario})
      : glosario = glosario ?? Glosario();

  final Biblioteca biblioteca;
  final Glosario glosario;

  final Tokenizador _tokenizador = Tokenizador();

  /// Interpreta un texto de serie o de parte completa.
  ResultadoAnalisis analizar(String texto) {
    if (texto.trim().isEmpty) {
      return const ResultadoAnalisis(series: [], pendientes: []);
    }

    final series = <Serie>[];
    final pendientes = <FragmentoPendiente>[];
    final avisos = <String>[];

    // Una forma de nado prohibida invalida el fragmento entero (sección 8).
    final prohibida = Glosario.formaProhibidaEn(texto);
    if (prohibida != null) {
      final posicion = texto.toLowerCase().indexOf(prohibida);
      pendientes.add(FragmentoPendiente(
        texto: texto.substring(posicion, posicion + prohibida.length),
        posicionInicio: posicion,
        posicionFin: posicion + prohibida.length,
        motivo: MotivoPendiente.nomenclaturaProhibida,
        detalle: 'Use un ejercicio de la Biblioteca antes del nado completo',
      ));
    }

    for (final trozo in _dividirEnSeries(texto)) {
      final resultado = _analizarSerie(trozo.texto, trozo.desplazamiento);
      series.addAll(resultado.series);
      pendientes.addAll(resultado.pendientes);
      avisos.addAll(resultado.avisos);
    }

    return ResultadoAnalisis(
      series: series,
      pendientes: pendientes,
      avisos: avisos,
    );
  }

  /// Divide el texto de una parte en las series que la componen.
  ///
  /// El entrenador separa con saltos de línea, con `+` entre tareas del
  /// calentamiento, o numerando `1)`, `2)`. Se conserva el desplazamiento de
  /// cada trozo para que las posiciones de los pendientes sigan refiriéndose al
  /// texto original.
  List<_Trozo> _dividirEnSeries(String texto) {
    final trozos = <_Trozo>[];
    final patron = RegExp(r'(\n|<br>|\d+\)\s)');

    var inicio = 0;
    for (final coincidencia in patron.allMatches(texto)) {
      final fragmento = texto.substring(inicio, coincidencia.start);
      if (fragmento.trim().isNotEmpty) {
        trozos.add(_Trozo(fragmento, inicio));
      }
      inicio = coincidencia.end;
    }
    final ultimo = texto.substring(inicio);
    if (ultimo.trim().isNotEmpty) {
      trozos.add(_Trozo(ultimo, inicio));
    }

    // El `+` de nivel superior separa tareas solo si no está dentro de un
    // paréntesis. Se parte cada trozo respetando el anidamiento.
    final finales = <_Trozo>[];
    for (final trozo in trozos) {
      finales.addAll(_partirPorMasDeNivelSuperior(trozo));
    }
    return finales;
  }

  List<_Trozo> _partirPorMasDeNivelSuperior(_Trozo trozo) {
    final partes = <_Trozo>[];
    var profundidad = 0;
    var inicio = 0;

    for (var i = 0; i < trozo.texto.length; i++) {
      final c = trozo.texto[i];
      if (c == '(') profundidad++;
      if (c == ')') profundidad--;
      if (c == '+' && profundidad == 0) {
        final fragmento = trozo.texto.substring(inicio, i);
        if (fragmento.trim().isNotEmpty) {
          partes.add(_Trozo(fragmento, trozo.desplazamiento + inicio));
        }
        inicio = i + 1;
      }
    }
    final ultimo = trozo.texto.substring(inicio);
    if (ultimo.trim().isNotEmpty) {
      partes.add(_Trozo(ultimo, trozo.desplazamiento + inicio));
    }
    return partes.isEmpty ? [trozo] : partes;
  }

  /// Interpreta una sola serie. Nunca lanza: ante lo que no entiende devuelve
  /// un fragmento pendiente.
  ResultadoAnalisis _analizarSerie(String texto, int desplazamiento) {
    final pendientes = <FragmentoPendiente>[];
    final avisos = <String>[];

    final tokens = _tokenizador.tokenizar(texto);
    if (tokens.isEmpty) {
      return const ResultadoAnalisis(series: [], pendientes: []);
    }

    var repeticiones = 1;
    int? distancia;
    Duration? tiempoSalida;
    final implementos = <Implemento>[];
    final modificadores = <Modificador>[];
    Estilo? estilo;
    int? respiracionCada;
    final nombresCandidatos = <Token>[];

    var i = 0;

    // Cabecera: `N x D` o `D`.
    if (tokens[i].tipo == TipoToken.numero) {
      final primero = tokens[i].valorNumerico!;
      if (i + 2 < tokens.length &&
          tokens[i + 1].tipo == TipoToken.por &&
          tokens[i + 2].tipo == TipoToken.numero) {
        repeticiones = primero;
        distancia = tokens[i + 2].valorNumerico;
        i += 3;
      } else {
        distancia = primero;
        i += 1;
      }
    }

    // Resto de la serie.
    while (i < tokens.length) {
      final token = tokens[i];

      switch (token.tipo) {
        case TipoToken.barra:
          // Tiempo de salida tras `/`.
          if (i + 1 < tokens.length && tokens[i + 1].tipo == TipoToken.tiempo) {
            tiempoSalida = tokens[i + 1].duracion;
            i += 2;
            continue;
          }
          i++;
          continue;

        case TipoToken.tiempo:
          tiempoSalida ??= token.duracion;
          i++;
          continue;

        case TipoToken.palabra:
          final palabra = token.texto;

          if (glosario.estaEnDesuso(palabra)) {
            avisos.add(
              'Se ignoró "$palabra": notación en desuso (sección 10).',
            );
            i++;
            continue;
          }

          final implemento = glosario.implemento(palabra);
          if (implemento != null) {
            implementos.add(implemento);
            i++;
            continue;
          }

          final modificador = glosario.modificador(palabra);
          if (modificador != null) {
            modificadores.add(modificador);
            i++;
            continue;
          }

          // Hipóxico: `Hyp 5`.
          if (palabra.toUpperCase() == 'HYP') {
            modificadores.add(Modificador.hipoxico);
            if (i + 1 < tokens.length &&
                tokens[i + 1].tipo == TipoToken.numero) {
              respiracionCada = tokens[i + 1].valorNumerico;
              i += 2;
              continue;
            }
            i++;
            continue;
          }

          // Nado completo: `N` suelto, o `Nado Libre`.
          if (palabra.toUpperCase() == 'N' || palabra.toUpperCase() == 'NADO') {
            i++;
            continue;
          }

          final estiloLeido = glosario.estilo(palabra);
          if (estiloLeido != null) {
            estilo ??= estiloLeido;
            i++;
            continue;
          }

          // Puede ser el inicio del nombre de un ejercicio.
          nombresCandidatos.add(token);
          i++;
          continue;

        case TipoToken.numero:
        case TipoToken.abreParentesis:
        case TipoToken.cierraParentesis:
        case TipoToken.mas:
        case TipoToken.guion:
        case TipoToken.igual:
        case TipoToken.por:
        case TipoToken.separador:
          i++;
          continue;

        case TipoToken.desconocido:
          pendientes.add(FragmentoPendiente(
            texto: token.texto,
            posicionInicio: desplazamiento + token.inicio,
            posicionFin: desplazamiento + token.fin,
            motivo: MotivoPendiente.terminoDesconocido,
            detalle: 'Carácter no reconocido',
          ));
          i++;
          continue;
      }
    }

    // Resolver el nombre del ejercicio a partir de las palabras sobrantes.
    final resolucion = _resolverEjercicio(
      nombresCandidatos,
      texto,
      desplazamiento,
      estilo,
    );
    pendientes.addAll(resolucion.pendientes);

    if (distancia == null) {
      // Sin distancia no hay serie medible. Si además no hubo nada más
      // reconocible, se reporta la estructura completa como no interpretada.
      if (resolucion.ejercicio == null && implementos.isEmpty) {
        pendientes.add(FragmentoPendiente(
          texto: texto.trim(),
          posicionInicio: desplazamiento,
          posicionFin: desplazamiento + texto.length,
          motivo: MotivoPendiente.estructuraNoReconocida,
          detalle: 'No se encontró la distancia de la serie',
        ));
      }
      return ResultadoAnalisis(
        series: const [],
        pendientes: pendientes,
        avisos: avisos,
      );
    }

    final serie = Serie(
      repeticiones: repeticiones,
      distancia: distancia,
      tiempoSalida: tiempoSalida,
      implementos: implementos,
      modificadores: modificadores,
      ejercicio: resolucion.ejercicio,
      estilo: estilo ?? resolucion.ejercicio?.estilo,
      respiracionCada: respiracionCada,
      textoOriginal: texto.trim(),
    );

    return ResultadoAnalisis(
      series: [serie],
      pendientes: pendientes,
      avisos: avisos,
    );
  }

  /// Intenta formar el nombre de un ejercicio con las palabras sobrantes.
  ///
  /// Prueba primero la secuencia completa y va acortando, para reconocer
  /// nombres de varias palabras como `PUNTO MUERTO` o `TOCAR AXILA`.
  _Resolucion _resolverEjercicio(
    List<Token> candidatos,
    String texto,
    int desplazamiento,
    Estilo? estilo,
  ) {
    if (candidatos.isEmpty) {
      return const _Resolucion(null, []);
    }

    for (var longitud = candidatos.length; longitud >= 1; longitud--) {
      for (var inicio = 0; inicio + longitud <= candidatos.length; inicio++) {
        final grupo = candidatos.sublist(inicio, inicio + longitud);
        final nombre = grupo.map((t) => t.texto).join(' ');

        final resultado = biblioteca.buscar(nombre, estilo: estilo);

        if (resultado is EjercicioEncontrado) {
          return _Resolucion(resultado.ejercicio, const []);
        }
        if (resultado is EjercicioAmbiguo) {
          return _Resolucion(null, [
            FragmentoPendiente(
              texto: nombre,
              posicionInicio: desplazamiento + grupo.first.inicio,
              posicionFin: desplazamiento + grupo.last.fin,
              motivo: MotivoPendiente.ambiguo,
              detalle: 'Existe en ${resultado.estilosPosibles.map((e) => e.nombre).join(', ')}. '
                  'Indique el estilo',
            ),
          ]);
        }
      }
    }

    // Ninguna combinación coincidió. Si alguna palabra suelta parece un
    // ejercicio (está en mayúsculas y no es notación conocida), se reporta.
    final sospechosas = candidatos
        .where((t) => t.texto.length > 1 && t.texto == t.texto.toUpperCase())
        .toList();

    if (sospechosas.isNotEmpty) {
      final nombre = sospechosas.map((t) => t.texto).join(' ');
      return _Resolucion(null, [
        FragmentoPendiente(
          texto: nombre,
          posicionInicio: desplazamiento + sospechosas.first.inicio,
          posicionFin: desplazamiento + sospechosas.last.fin,
          motivo: MotivoPendiente.ejercicioFueraDeBiblioteca,
          detalle: 'No está en la Biblioteca Oficial (sección 19)',
        ),
      ]);
    }

    return const _Resolucion(null, []);
  }
}

class _Trozo {
  const _Trozo(this.texto, this.desplazamiento);

  final String texto;
  final int desplazamiento;
}

class _Resolucion {
  const _Resolucion(this.ejercicio, this.pendientes);

  final Ejercicio? ejercicio;
  final List<FragmentoPendiente> pendientes;
}
