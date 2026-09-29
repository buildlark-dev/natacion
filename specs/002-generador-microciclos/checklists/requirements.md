# Specification Quality Checklist: Generador Determinista de Microciclos

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-09-29
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

Validación del 2026-09-29 sobre la primera redacción. Los dieciséis puntos pasan. Sin
marcadores de clarificación: la única ambigüedad de fondo —cómo evitar que dos semanas
consecutivas salgan idénticas siendo la generación determinista— se resolvió con la
metodología del propio entrenador, y quedó registrada en `Clarifications` y en `Assumptions`.

Observaciones para `/speckit-plan`:

1. **El corazón de la feature es un problema de reparto con restricciones.** Hay que
   distribuir un volumen entre zonas, partes y estilos respetando a la vez el rango de la
   categoría, los porcentajes de la fase, el 40/50/10 y el reparto de estilos. Esas
   restricciones pueden entrar en conflicto entre sí en casos concretos, y el plan debe
   decidir qué cede primero y dejarlo escrito. El orden que sugiere la metodología es claro:
   la técnica manda (sección 3), después la categoría, después la distribución.

2. **El redondeo necesita una regla explícita.** Repartir metros enteros entre porcentajes
   prescritos rara vez cierra exacto. FR-018 exige que la regla sea declarada y estable; el
   plan debe elegirla y probarla, no dejarla al azar del algoritmo.

3. **La generación necesita el camino inverso del analizador.** FR-027 y FR-028 obligan a
   convertir series estructuradas en notación del entrenador, que es lo contrario de lo que
   hace el analizador actual. Conviene tratarlo como una pieza con nombre propio y probar el
   viaje redondo: generar, escribir, releer, y que los metros coincidan.

4. **La selección de ejercicios depende de la calidad de la columna de errores.** FR-021 se
   apoya en el campo que declara qué corrige cada ejercicio de la Biblioteca. Esa columna se
   extrajo del documento normativo y el entrenador la confirmó, pero está escrita en prosa
   libre: emparejar un error diagnosticado con ella exige una regla de correspondencia que el
   plan debe definir y probar con casos reales.

5. **SC-009 necesita que el entrenador elija el microciclo de referencia.** La comparación
   contra un microciclo real suyo es el criterio más valioso, y hace falta que él señale cuál
   sirve de patrón para la categoría y fase que se pruebe.

6. **Tamaño.** Cuatro historias y 35 requisitos, en la misma escala que la feature 001. Si el
   plan se desborda, la línea de corte natural es entregar las historias 1 y 3 (generar, o
   explicar por qué no se puede) y dejar la 2 y la 4 (revisar y aprobar) para después, ya que
   ambas reutilizan maquinaria existente.
