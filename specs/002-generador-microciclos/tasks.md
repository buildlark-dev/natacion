---
description: "Lista de tareas de la feature 002 — Generador determinista de microciclos"
---

# Tasks: Generador Determinista de Microciclos

**Input**: Documentos de diseño en `/specs/002-generador-microciclos/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: OBLIGATORIOS. El principio III de la constitución los declara no negociables, y su
versión 1.1.0 añade una exigencia concreta para esta feature: todo plan generado debe tener
pruebas que demuestren que **cumple la auditoría por construcción, no por casualidad**.

**Organization**: agrupadas por historia de usuario, para que cada una se pueda implementar,
probar y dar por terminada por separado.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: se puede hacer en paralelo (archivos distintos, sin dependencias pendientes)
- **[Story]**: a qué historia de usuario pertenece (US1, US2, US3, US4)

## Path Conventions

Se añade `lib/dominio/generacion/` y `lib/ui/generacion/`. El resto del árbol ya existe. El
dominio es Dart puro: la prueba de frontera vigente lo vigila sin cambios.

---

## Phase 1: Setup

**Purpose**: abrir el hueco de la feature. No hay dependencias nuevas que instalar.

- [X] T001 Crear las carpetas `lib/dominio/generacion/`, `lib/ui/generacion/` y `test/dominio/generacion/`
- [X] T002 [P] Confirmar que `flutter analyze` y `flutter test` siguen limpios antes de empezar, para que cualquier fallo posterior sea atribuible a esta feature

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: el reparto, la petición y la trazabilidad del origen, que todas las historias
necesitan.

**⚠️ CRÍTICO**: ninguna historia puede empezar antes de terminar esta fase.

### Origen del plan

- [X] T003 Escribir pruebas del origen del plan en `test/dominio/entidades/origen_plan_test.dart`: el valor es `manual` o `automatico`, se fija al crear y **no cambia nunca, ni al editar ni al aprobar** (FR-026, invariante 14 de `data-model.md`)
- [X] T004 Añadir el campo `origen` a `lib/dominio/entidades/plan.dart` con los valores `manual` y `automatico`, por omisión `manual`, y hacer que `copiarCon` NO permita cambiarlo
- [X] T005 Propagar `origen` en `lib/datos/serializacion.dart` y comprobar en `test/datos/serializacion_test.dart` que sobrevive a la ida y vuelta y a la exportación
- [X] T006 Hacer que `crearVersionDesde` en `lib/dominio/entidades/ciclo_vida_plan.dart` conserve el `origen` del plan anterior: una versión nueva de un plan generado sigue siendo de origen automático

### Reparto por resto mayor

- [X] T007 [P] Escribir pruebas del reparto en `test/dominio/generacion/reparto_test.dart`: la suma de lo repartido es **exactamente** el total (invariante 1), toda cantidad es **múltiplo de la unidad** (invariante 2), y el resultado **no depende del orden de iteración** (invariante 7)
- [X] T008 [P] Escribir pruebas de desempate en `test/dominio/generacion/reparto_empates_test.dart`: cuando dos zonas tienen el mismo resto fraccionario, el sobrante se asigna según el orden fijo A1, A2, A3, AT, Máx, Velocidad, y el resultado es siempre el mismo
- [X] T009 Implementar el reparto en `lib/dominio/generacion/reparto.dart`: método del resto mayor sobre unidades de longitud de piscina, con desempate por orden fijo, según `contracts/generacion.md`

### Petición e impedimentos

- [X] T010 [P] Escribir pruebas de la petición en `test/dominio/generacion/peticion_test.dart` cubriendo los campos obligatorios de `data-model.md`: `categoria`, `estiloObjetivo`, `pruebaObjetivo` (texto no vacío), `faseAtr` (obligatoria si la categoría usa ATR y **prohibida si no**), `componenteAcentuado` (texto no vacío), `diasDisponibles`, `longitudPiscina` (25 o 50) y `duracionSesionMinutos` (entero positivo)
- [X] T011 Implementar `PeticionGeneracion` en `lib/dominio/generacion/peticion.dart` con los campos obligatorios y opcionales de `data-model.md`, y el descuento de `fechasSinServicio` sobre `diasDisponibles`
- [X] T012 [P] Implementar `Impedimento` en `lib/dominio/generacion/impedimento.dart` con los seis tipos de `contracts/generacion.md`: `datoFaltante`, `faseNoAdmisible`, `frecuenciaImposible`, `duracionInsuficiente`, `componenteIncoherente` y `repartoImposible`, cada uno con su explicación con números concretos
- [X] T013 [P] Implementar `Supuesto` y `VacioDeBiblioteca` en `lib/dominio/generacion/resultado.dart`, junto al tipo `ResultadoGeneracion` como unión de `MicrocicloGenerado` y `GeneracionImposible` que **nunca son las dos cosas a la vez**

### Estimación de ritmos

- [X] T014 [P] Implementar la referencia de ritmo medio por categoría en `lib/dominio/generacion/ritmos.dart`, **en un solo lugar y revisable**, documentando que es un supuesto nuestro y no una regla del entrenador (decisión D8 de `research.md`)
- [X] T015 [P] Escribir pruebas en `test/dominio/generacion/ritmos_test.dart`: 2.000 m no caben en 20 minutos y sí en 90, con la referencia declarada

**Checkpoint**: el reparto cierra y es determinista, la petición se valida, el origen del plan es trazable.

---

## Phase 3: User Story 1 - Generar la semana (Priority: P1) 🎯 MVP

**Goal**: el entrenador declara sus datos y obtiene el microciclo completo, con el volumen, la
distribución, el porcentaje técnico y el reparto de estilos ya cuadrados.

**Independent Test**: generar una semana para una categoría conocida y comprobar que los
totales y las distribuciones salen dentro de lo que la metodología prescribe, sin tocar nada.

### Tests for User Story 1 ⚠️

> Escribir primero y comprobar que FALLAN antes de implementar.

- [X] T016 [P] [US1] Escribir la prueba de las treinta combinaciones en `test/dominio/generacion/presupuesto_test.dart`: para cada categoría, cada fase que admita y cada longitud de piscina (25 y 50), el volumen por sesión cae dentro del rango, el reparto cierra exacto y **ninguna zona se desvía más que la tolerancia**
- [X] T017 [P] [US1] Escribir la prueba de anclaje en `test/dominio/generacion/anclaje_precompetitivo_test.dart`: Precompetitivo en Acumulación da **2.000 m por sesión, tres sesiones, 6.000 m de microciclo**, con A1 3.600 · A2 1.500 · A3 600 · AT 300
- [X] T018 [P] [US1] Escribir pruebas del presupuesto técnico en `test/dominio/generacion/tecnica_test.dart`: el porcentaje técnico del microciclo coincide con el prescrito para la fase dentro de la tolerancia, y **nunca queda por debajo** (nivel 4 de la escala de precedencia)
- [X] T019 [P] [US1] Escribir pruebas del reparto de estilos en `test/dominio/generacion/estilos_test.dart`: con estilo objetivo Libre, el reparto cae en 80-85% Libre y 15-20% Espalda; con Pecho y Mariposa, mitad y mitad
- [X] T020 [P] [US1] Escribir pruebas de la estructura de sesión en `test/dominio/generacion/compositor_test.dart`: cada sesión generada tiene tres partes repartidas 40/50/10, la central con su pre-set del 10%, y **las zonas se ubican donde el contrato las admite** (inicial solo A1; principal A2, A3, AT, Máx, Velocidad)
- [X] T021 [P] [US1] Escribir pruebas de precedencia en `test/dominio/generacion/precedencia_test.dart`: cuando las restricciones chocan, ceden de abajo hacia arriba según la tabla de `contracts/generacion.md`, y **nunca ceden** la no invención, la estructura de sesión, el volumen de la categoría ni el porcentaje técnico
- [X] T022 [P] [US1] Escribir pruebas de determinismo en `test/dominio/generacion/determinismo_test.dart`: la misma petición produce planes idénticos serie por serie (FR-024), y **cambiar solo el componente acentuado produce un plan distinto**
- [X] T023 [P] [US1] Escribir pruebas de selección de ejercicios en `test/dominio/generacion/seleccion_test.dart`: con diagnóstico se eligen ejercicios cuyo error corregido corresponde; sin diagnóstico se sigue la progresión de la sección 15 **sin inventar errores**; un error sin ejercicio en la Biblioteca se reporta como `VacioDeBiblioteca` y **no se sustituye** por otro
- [X] T024 [P] [US1] Escribir pruebas de la regla de Tecnificación en `test/dominio/generacion/tecnificacion_test.dart`: en esa categoría la primera sesión es de Pecho y la segunda de Mariposa, y no se le asigna fase ATR
- [X] T025 [P] [US1] Escribir pruebas del renderizador en `test/dominio/notacion/renderizador_test.dart` con los ejemplos de `contracts/renderizado.md`, incluidos los casos que ya dieron problemas: ejercicio ambiguo con su estilo, nombre con `+`, etiqueta de bloque técnico y nado completo
- [X] T026 [P] [US1] Escribir la prueba del **viaje redondo** en `test/dominio/notacion/viaje_redondo_test.dart`: generar, renderizar, releer con el analizador, y comprobar que metros, zonas, ejercicios, implementos y modificadores coinciden, con diferencia de **0 m** y sin fragmentos pendientes
- [X] T027 [P] [US1] Escribir la prueba de cumplimiento por construcción en `test/dominio/generacion/cumple_auditoria_test.dart`: todo microciclo generado pasa los once criterios **sin ningún bloqueante en rojo**, para las treinta combinaciones. Es la exigencia que la constitución 1.1.0 añadió al principio III
- [X] T028 [P] [US1] Escribir pruebas de sesiones dobles en `test/dominio/generacion/sesiones_dobles_test.dart`: Alto Rendimiento reparte diez sesiones entre los días disponibles y **marca como tal la segunda sesión del día**
- [X] T029 [P] [US1] Escribir pruebas de cuantización en `test/dominio/generacion/cuantizacion_test.dart`: toda distancia generada es múltiplo de la longitud de piscina declarada (FR-019)

### Implementation for User Story 1

- [X] T030 [US1] Implementar el presupuesto en `lib/dominio/generacion/presupuesto.dart`: volumen por sesión como punto medio del rango cuantizado, volumen del microciclo, reparto por zonas, presupuesto técnico y reparto de estilos, usando el reparto de T009
- [X] T031 [US1] Implementar el reparto entre sesiones en `lib/dominio/generacion/presupuesto.dart`, de modo que la suma por sesión sea exactamente el volumen del microciclo (invariante 6)
- [X] T032 [US1] Implementar el compositor de sesión en `lib/dominio/generacion/compositor_sesion.dart`: tres partes 40/50/10 con el pre-set del 10%, y ubicación de zonas según la tabla de `contracts/generacion.md`
- [X] T033 [US1] Implementar la escala de precedencia en `lib/dominio/generacion/precedencia.dart`: qué cede y en qué orden, devolviendo `repartoImposible` cuando tras ceder los niveles 5 y 6 dentro de la tolerancia el reparto sigue sin cerrar
- [X] T034 [US1] Implementar el selector de ejercicios en `lib/dominio/generacion/selector_ejercicios.dart`: correspondencia por términos normalizados contra el campo de error que corrige, progresión de la sección 15 cuando no hay diagnóstico, recorrido **estable** y rotación por posición sin azar
- [X] T035 [US1] Implementar la generación de objetivos y del nombre del microciclo en `lib/dominio/generacion/generador.dart`, derivando el nombre del componente acentuado declarado para que pase el criterio C09 (FR-009, invariante 12)
- [X] T036 [US1] Implementar el RPE previsto por sesión en `lib/dominio/generacion/generador.dart`, coherente con la zona dominante de la sesión según la tabla de la sección 9
- [X] T037 [US1] Implementar el renderizador en `lib/dominio/notacion/renderizador.dart` con el orden fijo de elementos de `contracts/renderizado.md`, usando el signo `×` y **sin abreviar, embellecer ni corregir** nada
- [X] T038 [US1] Orquestar todo en `lib/dominio/generacion/generador.dart`: recibe la petición, devuelve `MicrocicloGenerado` con el plan en estado `borrador` y `origen: automatico`, más sus supuestos, vacíos de biblioteca y avisos
- [X] T039 [US1] Construir el formulario de petición en `lib/ui/generacion/pantalla_peticion.dart` con los campos del protocolo de inicio, incluidos diagnóstico técnico, fechas sin servicio y lesiones
- [X] T040 [US1] Mostrar el aviso de lesiones en `lib/ui/generacion/pantalla_peticion.dart` dejando explícito que **se registran pero no modifican el plan**, y por qué
- [X] T041 [US1] Conectar el botón de generar con el editor: el microciclo generado se abre en `lib/ui/editor/` con sus sesiones ya escritas en notación

**Checkpoint**: el entrenador obtiene una semana cuadrada. Validar con los escenarios G1, G2, G3, G4, G5, G8, G9, G10 y G13 de `quickstart.md`.

---

## Phase 4: User Story 2 - Revisar y ajustar (Priority: P2)

**Goal**: el microciclo generado se edita en el editor que ya existe, y la auditoría se
recalcula al instante.

**Independent Test**: generar una semana, editar una serie y comprobar que los totales y los
criterios reflejan el cambio.

### Tests for User Story 2 ⚠️

- [X] T042 [P] [US2] Escribir pruebas de recálculo en `test/ui/edicion_generado_test.dart`: al cambiar una distancia de una sesión generada, se recalculan los metros de la parte, de la sesión y del microciclo, y se vuelve a evaluar la auditoría
- [X] T043 [P] [US2] Escribir pruebas de corrección manual sobre lo generado en `test/dominio/generacion/correccion_generado_test.dart`: una serie generada corregida a mano queda marcada como `corregidoAMano` y su valor prevalece
- [X] T044 [P] [US2] Escribir pruebas de conservación del origen en `test/dominio/generacion/origen_tras_editar_test.dart`: un plan generado y luego editado **sigue siendo de origen automático** (FR-026)
- [X] T045 [P] [US2] Escribir pruebas de edición que rompe el cumplimiento en `test/dominio/generacion/edicion_rompe_test.dart`: la auditoría lo señala con la diferencia exacta y **no se lo impide al entrenador**: él decide

### Implementation for User Story 2

- [X] T046 [US2] Poblar el estado del editor desde un plan generado en `lib/ui/editor/estado_editor.dart`, cargando el texto renderizado de cada parte y sus series estructuradas
- [X] T047 [US2] Mostrar en el editor que la sesión proviene de una generación automática, en `lib/ui/editor/cabecera_sesion.dart`, de forma que el entrenador sepa qué está revisando
- [X] T048 [US2] Permitir navegar entre las sesiones del microciclo generado en `lib/ui/editor/pantalla_editor.dart`, sin perder los cambios sin guardar de la sesión que se abandona
- [X] T049 [US2] Persistir el microciclo generado y editado con su `origen` intacto, a través de `RepositorioPlanes` y `RepositorioSesiones`

**Checkpoint**: lo generado es material de trabajo, no algo que se acepta o se descarta entero. Validar con G11.

---

## Phase 5: User Story 3 - Entender por qué no se puede generar (Priority: P3)

**Goal**: cuando los datos no alcanzan o se contradicen, la app explica qué falta o por qué es
imposible, y no genera nada.

**Independent Test**: pedir generaciones imposibles a propósito y comprobar que ninguna produce
un plan ni deja nada guardado.

### Tests for User Story 3 ⚠️

- [X] T050 [P] [US3] Escribir pruebas de datos faltantes en `test/dominio/generacion/impedimentos_test.dart`: sin categoría, sin estilo objetivo o sin componente acentuado, el resultado es `GeneracionImposible` con `datoFaltante` nombrando el campo
- [X] T051 [P] [US3] Escribir pruebas de acumulación en `test/dominio/generacion/impedimentos_acumulados_test.dart`: cuando faltan varios datos se devuelven **todos los impedimentos a la vez**, no de uno en uno
- [X] T052 [P] [US3] Escribir pruebas de contradicción de frecuencia en `test/dominio/generacion/frecuencia_test.dart`: Precompetitivo, que pide tres sesiones semanales, con solo dos días disponibles produce `frecuenciaImposible` explicando la contradicción
- [X] T053 [P] [US3] Escribir pruebas de fase no admisible en `test/dominio/generacion/fase_no_admisible_test.dart`: Iniciación o Tecnificación con fase ATR declarada produce `faseNoAdmisible`
- [X] T054 [P] [US3] Escribir pruebas de duración insuficiente en `test/dominio/generacion/duracion_test.dart`: Precompetitivo con sesión de 20 minutos produce `duracionInsuficiente`
- [X] T055 [P] [US3] Escribir pruebas de que nada queda a medias en `test/dominio/generacion/sin_residuo_test.dart`: tras un resultado imposible **no queda ningún plan guardado** (invariante 15)
- [X] T056 [P] [US3] Escribir pruebas de supuestos marcados en `test/dominio/generacion/supuestos_test.dart`: cuando un supuesto es inevitable, queda dentro del plan generado y es visible (FR-007)

### Implementation for User Story 3

- [X] T057 [US3] Implementar la validación previa en `lib/dominio/generacion/validacion_peticion.dart` con las cinco comprobaciones del contrato **en su orden**, acumulando todos los impedimentos antes de devolver
- [X] T058 [US3] Hacer que el generador valide **antes de repartir** en `lib/dominio/generacion/generador.dart`, de modo que ningún plan a medias llegue a existir
- [X] T059 [US3] Construir el panel de impedimentos en `lib/ui/generacion/panel_impedimentos.dart`: cada uno con su explicación en términos que el entrenador reconozca, y los números concretos de la contradicción
- [X] T060 [US3] Mostrar los supuestos y los vacíos de biblioteca del plan generado en `lib/ui/editor/panel_avisos.dart`, distinguiéndolos de los avisos de auditoría

**Checkpoint**: la app no entrega nunca un plan que incumple. Validar con G6 y G7.

---

## Phase 6: User Story 4 - Aprobar lo generado (Priority: P4)

**Goal**: el plan generado pasa por la misma puerta que uno escrito a mano, sin criterios
relajados.

**Independent Test**: intentar aprobar un plan generado con un defecto sembrado y comprobar que
la puerta se comporta igual que con un plan manual.

### Tests for User Story 4 ⚠️

- [X] T061 [P] [US4] Escribir pruebas del estado inicial en `test/dominio/generacion/estado_inicial_test.dart`: un microciclo recién generado está en `borrador` y con `origen: automatico` (invariante 14)
- [X] T062 [P] [US4] Escribir pruebas de aprobación en `test/dominio/generacion/aprobacion_generado_test.dart`: un plan generado limpio se aprueba, queda con la versión de metodología y la fecha estampadas, y **conserva la marca de origen automático**
- [X] T063 [P] [US4] Escribir pruebas de bloqueo en `test/dominio/generacion/bloqueo_generado_test.dart`: un plan generado y editado hasta romper un criterio bloqueante **no se puede aprobar**, igual que uno manual
- [X] T064 [P] [US4] Escribir pruebas de que no hay criterios relajados en `test/dominio/generacion/sin_excepciones_test.dart`: la auditoría de un plan generado evalúa los **once** criterios con la misma severidad que la de un plan manual

### Implementation for User Story 4

- [X] T065 [US4] Conectar el flujo de aprobación existente con los planes generados en `lib/ui/planes/pantalla_plan.dart`, sin ninguna rama especial para el origen automático
- [X] T066 [US4] Mostrar el origen del plan en la cabecera de `lib/ui/planes/pantalla_plan.dart`, para que al aprobar el entrenador sepa si firma algo generado
- [X] T067 [US4] Guardar la instantánea de auditoría al aprobar un plan generado, igual que con uno manual, en `lib/datos/firestore/repositorios_firestore.dart`

**Checkpoint**: las cuatro historias funcionan. El entrenador pasa de datos a plan aprobado sin transcribir nada.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T068 Ejecutar el escenario **G14 de `quickstart.md`** (criterio SC-009): generar con la categoría y fase de un microciclo real del entrenador y comparar **rangos, no contenido** — volumen por sesión, distribución de zonas y porcentaje técnico deben caer en sus mismos márgenes
- [ ] T069 Si G14 queda fuera de los márgenes del entrenador, determinar si el error está en el generador o en la **calibración de la tolerancia**, que sigue pendiente desde la feature 001, y registrar el hallazgo antes de tocar código
- [~] T070 Probar la correspondencia entre errores diagnosticados reales del entrenador y el campo de error que corrige de la Biblioteca, y registrar los casos en que falla en cualquiera de los dos sentidos: no encontrar un ejercicio que servía, o elegir uno que no ataca el error
  - **Probado.** 40 frases reales del entrenador, 4 estilos. Solo 2 coinciden. Registro
    completo en [`docs/metodologia/correspondencia_diagnostico.md`](../../docs/metodologia/correspondencia_diagnostico.md),
    reproducible con `dart run tool/probar_diagnostico.dart`.
  - **Causa acotada:** no faltan ejercicios, falla el método de búsqueda. La misma
    idea escrita «Rolido insuficiente/excesivo» coincide y escrita «Rolido de
    cadera/hombro insuficiente» no.
  - **Pendiente del entrenador:** confirmar la tabla del §4 (40 filas), resolver las
    cuatro contradicciones del §1 —dos ejercicios corrigen lo contrario de lo
    diagnosticado— y decidir sobre los cinco vacíos del §2.
  - **Pendiente de implementar** tras su confirmación: índice de términos declarados
    por ejercicio, en lugar de búsqueda literal sobre la prosa de la ficha.
- [X] T071 [P] Recorrer los escenarios G1 a G13 de `quickstart.md` y registrar el resultado de cada uno
- [X] T072 Medir el tiempo de generación del caso mayor (Alto Rendimiento, diez sesiones, 55.000 m) y comprobar que queda por debajo de 200 ms
- [X] T073 Verificar que `flutter analyze` termina sin errores ni advertencias nuevas, y que la prueba de frontera del dominio sigue pasando: `lib/dominio/generacion/` no puede importar Flutter ni Firebase
- [X] T074 [P] Actualizar `README.md` con el generador: qué datos pide, qué devuelve, y que funciona sin conexión

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Fase 1)**: sin dependencias
- **Foundational (Fase 2)**: depende de Setup y **bloquea todas las historias**
- **US1 (Fase 3)**: depende de Foundational. Es el MVP
- **US2 (Fase 4)**: depende de US1, porque edita lo que US1 genera
- **US3 (Fase 5)**: depende de Foundational. Se puede hacer **en paralelo a US1**, aunque el generador necesita la validación de T057 para no intentar repartir con datos malos
- **US4 (Fase 6)**: depende de US1. Reutiliza la maquinaria de aprobación que ya existe
- **Polish (Fase 7)**: T068 a T070 necesitan US1 terminada

### Dependencia crítica dentro de Foundational

T007 y T008 (pruebas del reparto) → T009 (reparto) → T030 (presupuesto) → todo lo demás.
**El reparto es el cimiento**: si el resto mayor no cierra exacto o no es determinista, todas
las distribuciones que se apoyen en él arrastrarán el error.

### Within Each User Story

- Las pruebas se escriben primero y deben fallar antes de implementar
- Dentro de US1: presupuesto (T030, T031) → compositor (T032) → precedencia (T033) → selector
  (T034) → generador (T035, T036, T038) → renderizador (T037) → interfaz (T039 a T041)
- T037 (renderizador) se puede adelantar en paralelo al resto de US1: solo depende de las
  entidades, que ya existen

### Parallel Opportunities

- T007, T008, T010, T012, T013, T014, T015 en Foundational
- **Las catorce pruebas de US1 (T016 a T029) son archivos distintos y se pueden escribir todas
  a la vez**
- Las pruebas de US2 (T042 a T045), de US3 (T050 a T056) y de US4 (T061 a T064), cada grupo en
  paralelo
- US3 completa se puede adelantar en paralelo a US1 si conviene cambiar de tema

---

## Parallel Example: User Story 1

```bash
# Las catorce pruebas de US1 se pueden escribir a la vez, son archivos distintos:
T016 treinta combinaciones     test/dominio/generacion/presupuesto_test.dart
T017 anclaje Precompetitivo    test/dominio/generacion/anclaje_precompetitivo_test.dart
T018 presupuesto tecnico       test/dominio/generacion/tecnica_test.dart
T019 reparto de estilos        test/dominio/generacion/estilos_test.dart
T020 estructura de sesion      test/dominio/generacion/compositor_test.dart
T021 precedencia               test/dominio/generacion/precedencia_test.dart
T022 determinismo              test/dominio/generacion/determinismo_test.dart
T023 seleccion de ejercicios   test/dominio/generacion/seleccion_test.dart
T024 regla de Tecnificacion    test/dominio/generacion/tecnificacion_test.dart
T025 renderizador              test/dominio/notacion/renderizador_test.dart
T026 viaje redondo             test/dominio/notacion/viaje_redondo_test.dart
T027 cumple por construccion   test/dominio/generacion/cumple_auditoria_test.dart
T028 sesiones dobles           test/dominio/generacion/sesiones_dobles_test.dart
T029 cuantizacion              test/dominio/generacion/cuantizacion_test.dart
```

---

## Implementation Strategy

### MVP primero (solo US1)

1. Fase 1: Setup
2. Fase 2: Foundational — el reparto es el cimiento
3. Fase 3: US1
4. **PARAR Y VALIDAR**: escenarios G1 a G5 de `quickstart.md`. Si el anclaje de Precompetitivo
   no da 2.000 m por sesión y 6.000 de microciclo, no seguir: el reparto está mal y el error
   contaminará todas las distribuciones
5. En este punto el entrenador ya obtiene una semana cuadrada a partir de sus datos, que es lo
   que pidió al decir que la autoría manual no le ahorraba tiempo

### Entrega incremental

1. Setup + Foundational → el reparto cierra y es determinista
2. + US1 → la semana se genera cuadrada (**MVP**)
3. + US3 → la app nunca entrega un plan que incumple
4. + US2 → lo generado es material de trabajo, editable
5. + US4 → de datos a plan aprobado sin transcribir
6. Polish → contra un microciclo real del entrenador

### Si el trabajo se desborda

La línea de corte declarada en el checklist de la spec: entregar **US1 y US3** —generar, o
explicar por qué no se puede— y dejar US2 y US4 para después, ya que ambas reutilizan
maquinaria que existe y funciona.

---

## Notes

- 74 tareas. 38 son de pruebas, el 51%, más que en la feature 001: aquí el riesgo está
  concentrado en la aritmética del reparto, que no se ve en pantalla
- Sin dependencias nuevas. El único cambio en código existente es el `origen` del plan
- Las tareas [P] tocan archivos distintos y no tienen dependencias pendientes
- Verificar que cada prueba falla antes de implementar lo que la hace pasar
- T068, T069 y T070 requieren **criterio del entrenador**, no son mecánicas

---

## Estado de cierre (2026-09-29)

**72 de 74 tareas completadas.** 607 pruebas de Flutter en verde, 15 de reglas de
acceso, `flutter analyze` limpio y build web correcto.

Las dos restantes dependen del entrenador:

- **T069 — No aplicó.** G14 cuadró: lo generado cae dentro de los márgenes del
  microciclo real del 04-08 de agosto. El generado propone 2.000 m por sesión
  frente a sus 1.900 (5,3% de diferencia), con técnica al 50% y Libre por encima
  del 75%, que es lo que su hoja declara.
- **T070 — Pendiente del entrenador.** Probar la correspondencia entre sus
  errores diagnosticados reales y el campo «error que corrige» de la Biblioteca.
  Sigue siendo el punto más débil de la feature: ese campo está en prosa libre.

### Tres defectos reales encontrados durante la implementación

1. **El analizador de la feature 001 partía series por la mitad.** El patrón que
   detecta series numeradas (`1)`, `2)`) casaba también con el `1)` de `(A1)`
   cuando le seguía un salto de línea. Los metros seguían cuadrando —por eso
   ninguna prueba de la 001 lo detectó— pero la zona se perdía en silencio.
   Corregido con prueba de regresión.

2. **El reparto de estilos se hacía por sesión y era imposible de cumplir.** El
   82% de tres sesiones no es un número entero de sesiones, así que salía el
   100% del estilo objetivo. Ahora el complementario se reparte **dentro** de
   cada sesión, como en las sesiones reales del entrenador.

3. **El plan perdía metros en el caso de diez sesiones.** El reparto por sesión y
   el reparto por zona se calculaban por separado y podían discrepar: el
   compositor pedía llenar bloques por un volumen y solo tenía zonas por otro.
   Ahora las zonas de cada sesión derivan de su propio volumen.

### Dos contratos corregidos

- **Ubicación de zonas por parte**: era una imposición imposible. En
  Transformación la fase prescribe A1 al 30% mientras inicial más final suman el
  50%. Ahora es una **preferencia**: cada bloque declara su orden de zonas y se
  llena con lo que haya. La estructura 40/50/10 y la distribución total nunca
  ceden; solo flexiona en qué bloque cae cada zona, que la sección 14 no
  prescribe.
- **Criterio C06 (transferencia)**: se aplicaba a todas las categorías, pero la
  sección 13 dice «Precompetitivo en adelante». Iniciación y Tecnificación
  quedan fuera; Tecnificación tiene su propia regla de alternancia.
