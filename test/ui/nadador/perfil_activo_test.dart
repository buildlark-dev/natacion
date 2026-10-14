import 'package:flutter_test/flutter_test.dart';
import 'package:natacion_app/dominio/entidades/nadador.dart';
import 'package:natacion_app/dominio/entidades/plan.dart';
import 'package:natacion_app/dominio/metodologia/categorias.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/ui/nadador/perfil_activo.dart';

/// Tarea T006: el camino por el que un plan llega al nadador.
///
/// **Esta tarea estuvo marcada como hecha sin estarlo.** Las pruebas de la
/// feature pasaban porque inyectaban el plan directamente en el estado; lo que
/// no existía era el camino en la app real. Estas pruebas cubren justo ese
/// hueco: dado un perfil y los planes de la sesión, cuál le corresponde.
void main() {
  Plan plan({
    required String id,
    required EstadoPlan estado,
    List<String> nadadoresIds = const [],
  }) =>
      Plan(
        id: id,
        nombre: 'Microciclo $id',
        categoria: Categoria.precompetitivo,
        estiloObjetivo: Estilo.libre,
        pruebaObjetivo: '800 Libre',
        estado: estado,
        nadadoresIds: nadadoresIds,
        sesiones: const [],
      );

  const nadador = Nadador(id: 'n1', nombre: 'Perfil de prueba');
  const otro = Nadador(id: 'n2', nombre: 'Otro perfil');

  group('FR-001 — solo lo publicado es del nadador', () {
    test('un borrador asignado no le llega', () {
      final planes = [
        plan(id: 'p1', estado: EstadoPlan.borrador, nadadoresIds: ['n1']),
      ];

      expect(planDe(nadador, planes), isNull);
    });

    test('un aprobado asignado tampoco: aprobar no es entregar', () {
      final planes = [
        plan(id: 'p1', estado: EstadoPlan.aprobado, nadadoresIds: ['n1']),
      ];

      expect(
        planDe(nadador, planes),
        isNull,
        reason: 'Un plan aprobado todavía no es de nadie. Publicarlo y '
            'asignarlo es lo que lo convierte en el entrenamiento de alguien',
      );
    });

    test('un publicado y asignado sí le llega', () {
      final planes = [
        plan(id: 'p1', estado: EstadoPlan.publicado, nadadoresIds: ['n1']),
      ];

      expect(planDe(nadador, planes)?.id, 'p1');
    });
  });

  group('cada quien ve lo suyo', () {
    test('un publicado de otro nadador no le llega', () {
      final planes = [
        plan(id: 'p1', estado: EstadoPlan.publicado, nadadoresIds: ['n2']),
      ];

      expect(planDe(nadador, planes), isNull);
    });

    test('un publicado sin asignar no es de nadie', () {
      final planes = [plan(id: 'p1', estado: EstadoPlan.publicado)];

      expect(planDe(nadador, planes), isNull);
      expect(planDe(otro, planes), isNull);
    });

    test('un plan puede ser de varios a la vez', () {
      final planes = [
        plan(
          id: 'p1',
          estado: EstadoPlan.publicado,
          nadadoresIds: ['n1', 'n2'],
        ),
      ];

      expect(planDe(nadador, planes)?.id, 'p1');
      expect(planDe(otro, planes)?.id, 'p1');
    });
  });

  group('con varios planes', () {
    test('se queda con el último, que es el que está entrenando', () {
      final planes = [
        plan(id: 'viejo', estado: EstadoPlan.publicado, nadadoresIds: ['n1']),
        plan(id: 'nuevo', estado: EstadoPlan.publicado, nadadoresIds: ['n1']),
      ];

      expect(planDe(nadador, planes)?.id, 'nuevo');
    });

    test('ignora los que no están publicados aunque sean posteriores', () {
      final planes = [
        plan(id: 'publicado', estado: EstadoPlan.publicado, nadadoresIds: ['n1']),
        plan(id: 'borrador', estado: EstadoPlan.borrador, nadadoresIds: ['n1']),
      ];

      expect(planDe(nadador, planes)?.id, 'publicado');
    });
  });

  group('casos límite', () {
    test('sin planes no hay nada que entregar', () {
      expect(planDe(nadador, const []), isNull);
    });

    test('un perfil sin identificador no recibe nada, y no revienta', () {
      final planes = [
        plan(id: 'p1', estado: EstadoPlan.publicado, nadadoresIds: ['n1']),
      ];

      expect(planDe(const Nadador(nombre: 'Sin id'), planes), isNull);
    });
  });
}
