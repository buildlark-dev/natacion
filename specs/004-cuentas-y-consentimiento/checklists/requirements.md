# Specification Quality Checklist: Cuentas, roles y consentimiento verificable

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-10-14
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

- Items marked incomplete require spec updates before `/speckit-clarify` or `/speckit-plan`

### Las dos aclaraciones, y cómo se resolvieron

Ambas tocaban a menores y ninguna tenía una opción por omisión segura. Se consultaron al
entrenador el 2026-10-14 en lugar de suponerlas:

**FR-005 original — cómo entra a la app un niño de 7 a 10 años.** Respuesta: cualquiera
entra, sin puerta por edad. Lo único que se distingue es la **categoría**, y la categoría se
determina por habilidades y nunca por edad. Eso obligó a una revisión de la metodología
—versión **3.6.0**, sección 11.1— porque la tabla de habilidades por categoría no existía en
ningún documento del proyecto. De ahí salen FR-007 y FR-008, y SC-016 los vigila.

**FR-009 original — qué hace verificable al consentimiento.** Respuesta: confirmación digital,
con un camino propuesto y aprobado. Se convirtió en FR-014 a FR-022.

### Tres cosas que esta revisión cambió de raíz

1. **Dónde está la puerta.** Pasó de «sin consentimiento no se usa la app» a «sin
   consentimiento los datos no salen del dispositivo». Cumple el principio V igual y no deja
   a nadie bloqueado, reutilizando la bandeja de salida de la feature 003.
2. **El menor tiene que ser oído.** El Decreto 1377 de 2013 lo exige y no estaba contemplado
   en ninguna parte del proyecto. Es FR-021.
3. **Qué promete el consentimiento.** La especificación dice en sus suposiciones que es
   **demostrable, no infalsificable**, y que **no exime de responsabilidad** bajo la Ley
   1581. Escribirlo evita construir sobre una creencia falsa.

### Lo que sigue necesitando una opinión que no es la mía

Las referencias a la Ley 1581 de 2012 y al Decreto 1377 de 2013 están tomadas de buena fe y
**no son asesoría jurídica**. Antes de desplegar con nadadores reales conviene que un abogado
revise, como mínimo, el texto informativo, la declaración que firma quien confirma y la
constancia de que el menor fue oído.
