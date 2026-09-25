# Especificación de Feature: Editor de Planes con Auditoría Metodológica

**Feature Branch**: `001-editor-planes-auditoria`

**Created**: 2026-09-25

**Status**: Draft

**Input**: Primera rebanada vertical del producto. El entrenador construye planes de
entrenamiento dentro de la app, y la app los valida contra su metodología
(`docs/metodologia/PROMPT_MAESTRO_V3.4.md` y la Biblioteca Oficial de ejercicios) antes de
permitirle aprobarlos. Incluye cuentas y roles al mínimo, con consentimiento verificable
del acudiente cuando el nadador es menor de edad.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Construir una sesión validada (Priority: P1)

El entrenador crea una sesión para una categoría y un estilo objetivo. Escribe las series
con su notación habitual (`4x100 AL / 2'`, `200 PULL PL`, `8x50 (1L 1Estilo 1>4)`),
eligiendo ejercicios de la Biblioteca Oficial. Mientras escribe, la app va sumando los
metros de cada parte (inicial, central, final), muestra el porcentaje de trabajo técnico y
le avisa cuando algo se sale de su propia metodología: un ejercicio que no existe en la
biblioteca, un volumen fuera del rango de la categoría, o una sesión sin objetivo técnico.

**Why this priority**: Es la unidad mínima de trabajo del entrenador y la que hoy le
consume más tiempo en Excel con verificación aritmética manual. Una sesión validada, por sí
sola, ya sustituye parte de su flujo actual.

**Independent Test**: Se puede probar por completo creando una sesión desde cero para una
categoría conocida y comprobando que los totales, el porcentaje técnico y los avisos
coinciden con lo que arroja la revisión manual del entrenador.

**Acceptance Scenarios**:

1. **Given** una sesión nueva de categoría Precompetitivo (rango 1800-2200 m), **When** el
   entrenador escribe series que suman 2.000 m distribuidos 40/50/10 entre las tres partes,
   **Then** la app muestra el total, la distribución por parte y ningún aviso de volumen.
2. **Given** una sesión en construcción, **When** el entrenador escribe un ejercicio que no
   está en la Biblioteca Oficial, **Then** la app lo marca como no reconocido, no lo acepta
   como ejercicio válido y ofrece registrarlo como propuesta pendiente de aprobación,
   fuera del plan.
3. **Given** una sesión de categoría Precompetitivo, **When** las series suman 2.600 m,
   **Then** la app avisa que el volumen excede el rango de la categoría e indica la
   diferencia exacta.
4. **Given** un ejercicio cuyo nombre se repite entre estilos (`FLECHA`, `ROLIDO`),
   **When** el entrenador lo selecciona, **Then** la app exige indicar el estilo y lo
   guarda con esa desambiguación (`FLECHA (Espalda)`).
5. **Given** una sesión sin objetivo técnico o sin objetivo fisiológico declarado,
   **When** el entrenador intenta darla por terminada, **Then** la app señala el dato
   faltante y no la considera completa.

---

### User Story 2 - Auditar el plan completo (Priority: P2)

El entrenador agrupa sesiones en microciclos y los microciclos en un plan con fase ATR
declarada. La app calcula la distribución real de zonas de intensidad (A1, A2, A3, AT, Máx,
Velocidad), el porcentaje de trabajo técnico y la distribución de estilos del plan
completo, y los compara contra los valores que la metodología prescribe para esa fase.

**Why this priority**: Los errores de distribución no se ven mirando una sesión aislada:
solo aparecen al sumar el microciclo o la fase. Es la verificación que hoy no existe en
ninguna parte del flujo del entrenador.

**Independent Test**: Se puede probar cargando las sesiones de un microciclo histórico ya
existente y comprobando que los porcentajes calculados por la app coinciden con los del
documento original.

**Acceptance Scenarios**:

1. **Given** un plan en fase de Acumulación, **When** sus sesiones suman 45% de A1 en lugar
   del 60% prescrito, **Then** la app muestra la desviación por zona, con el valor real,
   el prescrito y la diferencia.
2. **Given** un plan con estilo objetivo Libre, **When** el volumen de nado se reparte 60%
   Libre y 40% Espalda, **Then** la app señala que la distribución se aparta del 80-85% /
   15-20% prescrito para ese estilo objetivo.
3. **Given** un plan en fase de Acumulación con 50% de trabajo técnico prescrito, **When**
   los ejercicios técnicos representan el 32% del volumen total, **Then** la app lo reporta
   como incumplimiento del porcentaje técnico de la fase.
4. **Given** un plan de categoría Iniciación o Tecnificación, **When** el entrenador intenta
   asignarle una fase ATR, **Then** la app lo impide e indica que esas categorías no usan
   ATR.
5. **Given** un microciclo cuyas sesiones semanales no coinciden con la frecuencia de la
   categoría, **When** el entrenador revisa el plan, **Then** la app señala la discrepancia
   entre sesiones programadas y sesiones esperadas.

---

### User Story 3 - Aprobar con auditoría visible (Priority: P3)

Antes de aprobar un plan, el entrenador ve la tabla de auditoría completa, con cada
criterio marcado como cumple o no cumple y su observación. Los incumplimientos que tocan
reglas no negociables impiden la aprobación. Los que la metodología admite justificar —como
un descenso de volumen por afinación— exigen que el entrenador escriba la justificación,
que queda guardada junto al plan.

**Why this priority**: Es la garantía de que ningún plan defectuoso llega a un nadador, y
convierte la auditoría de la metodología en algo que el sistema hace, no en algo que el
entrenador recuerda hacer.

**Independent Test**: Se puede probar intentando aprobar planes con distintos defectos
sembrados a propósito y comprobando cuáles bloquean, cuáles piden justificación y cuáles
pasan limpios.

**Acceptance Scenarios**:

1. **Given** un plan que contiene un ejercicio ajeno a la Biblioteca Oficial, **When** el
   entrenador intenta aprobarlo, **Then** la app lo impide y nombra el ejercicio y la
   sesión donde aparece.
2. **Given** un plan en fase de Realización cuyo volumen por sesión baja del rango de la
   categoría, **When** el entrenador intenta aprobarlo, **Then** la app pide una
   justificación escrita de afinación y, una vez escrita, permite aprobar y conserva el
   texto junto al plan.
3. **Given** un plan que cumple los once criterios de auditoría, **When** el entrenador lo
   aprueba, **Then** el plan pasa a estado aprobado, queda registrada la fecha y la versión
   de metodología vigente, y el contenido del plan queda bloqueado contra edición.
4. **Given** un plan aprobado, **When** el entrenador necesita cambiarlo, **Then** la app
   crea una nueva versión en estado borrador y conserva la aprobada intacta.
5. **Given** cualquier plan, **When** el entrenador consulta la auditoría, **Then** ve los
   once criterios de la metodología, cada uno con su resultado y su observación.

---

### User Story 4 - Cuentas, roles y consentimiento (Priority: P4)

Existen dos tipos de usuario: entrenador y nadador. El entrenador registra a sus nadadores
con los datos mínimos necesarios para planificar (categoría, edad, estilo objetivo, marcas
conocidas). Cuando el nadador es menor de edad, la app exige el consentimiento verificable
de su padre, madre o acudiente antes de almacenar sus datos.

**Why this priority**: Sin nadadores registrados no hay a quién asignar un plan, y sin
consentimiento no se pueden guardar datos de menores. Va después del núcleo porque el
editor puede construirse y probarse contra perfiles de prueba.

**Independent Test**: Se puede probar registrando un nadador mayor y uno menor, y
comprobando que el menor no queda almacenado mientras no exista consentimiento registrado.

**Acceptance Scenarios**:

1. **Given** un nadador menor de 18 años, **When** el entrenador intenta guardar su perfil
   sin consentimiento del acudiente, **Then** la app no almacena los datos y explica qué
   falta.
2. **Given** un consentimiento otorgado, **When** queda registrado, **Then** guarda quién
   lo otorga, su relación con el menor y la fecha.
3. **Given** un usuario con rol de nadador, **When** intenta acceder a los datos o a los
   planes de otro nadador, **Then** la app lo deniega.
4. **Given** un usuario con rol de nadador, **When** intenta aprobar o editar un plan,
   **Then** la app lo deniega: solo el entrenador aprueba.
5. **Given** un nadador registrado, **When** solicita sus datos, **Then** el entrenador
   puede exportarlos en un formato legible y puede eliminarlos a petición.

---

### Edge Cases

- **Notación desconocida**: el entrenador escribe una abreviatura que no está en el
  glosario ni en la biblioteca. La app pregunta en lugar de suponer, y una vez aclarada la
  incorpora al glosario con su fecha.
- **Datos insuficientes para planificar**: falta la categoría, la prueba objetivo, la
  longitud de piscina o la frecuencia semanal. La app no completa el vacío con supuestos:
  señala qué falta y no permite dar el plan por terminado.
- **Supuesto inevitable**: cuando un dato menor debe asumirse para avanzar (por ejemplo, un
  formato de descanso), la app lo marca visiblemente como supuesto dentro del plan.
- **Porcentajes que no suman 100**: la distribución de zonas de una fase debe sumar
  exactamente 100%. Un redondeo que no cierra se reporta como error, no se ajusta solo.
- **Ejercicio retirado de la biblioteca**: un plan ya aprobado que lo usa conserva su
  contenido y su versión de metodología; no se reescribe retroactivamente.
- **Cambio de versión de metodología**: los planes aprobados bajo la versión anterior siguen
  siendo válidos y muestran bajo qué versión se construyeron.
- **Sesión vacía o microciclo sin sesiones**: no se puede aprobar; se reporta como
  incompleto.
- **Categoría sin ATR**: Iniciación y Tecnificación no admiten fases ATR ni sus
  distribuciones.
- **Regla de Tecnificación**: en programas de dos meses, la sesión 1 es de Pecho y la
  sesión 2 de Mariposa todas las semanas; un microciclo que lo incumpla se reporta.
- **Menor que cumple 18 años**: el perfil deja de requerir consentimiento del acudiente,
  pero el consentimiento histórico se conserva como registro.

## Requirements *(mandatory)*

### Functional Requirements

**Biblioteca Oficial y notación**

- **FR-001**: El sistema DEBE disponer de la Biblioteca Oficial de ejercicios como fuente
  consultable, con el nombre exacto, la descripción y el error o objetivo técnico que cada
  ejercicio corrige.
- **FR-002**: El sistema DEBE rechazar como ejercicio válido cualquier nombre que no esté
  en la Biblioteca Oficial, y NO DEBE ofrecer variantes, sinónimos ni correcciones
  automáticas de nombres.
- **FR-003**: El sistema DEBE exigir la desambiguación por estilo en los ejercicios cuyo
  nombre se repite entre estilos, y almacenarlos con esa forma.
- **FR-004**: El sistema DEBE permitir registrar un ejercicio no cubierto por la biblioteca
  como propuesta pendiente de aprobación, almacenada fuera del plan y sin efecto sobre él.
- **FR-005**: El sistema DEBE interpretar la notación del entrenador (implementos, patada,
  brazada, hipóxicos, recuperación, progresivos, salidas, `NxD / t`) y DEBE tratar como
  desconocido cualquier término ausente del glosario, preguntando en lugar de suponer.
- **FR-006**: El sistema DEBE permitir ampliar el glosario con términos aclarados por el
  entrenador, registrando su definición y la fecha.

**Estructura y cálculo de sesiones**

- **FR-007**: El sistema DEBE exigir que toda sesión tenga objetivo técnico, objetivo
  fisiológico y las tres partes: inicial, central y final.
- **FR-008**: El sistema DEBE calcular los metros de cada parte y el total de la sesión a
  partir de las series escritas, sin que el entrenador los sume a mano.
- **FR-009**: El sistema DEBE comparar la distribución real de las partes contra la
  prescrita (inicial 40%, central 50% con pre-set de 10%, final 10%) y reportar la
  desviación.
- **FR-010**: El sistema DEBE calcular el porcentaje de trabajo técnico de la sesión como
  metros de ejercicios de la biblioteca sobre metros totales, excluyendo el nado completo
  de estilo.
- **FR-011**: El sistema DEBE permitir asignar una zona de intensidad a cada serie, usando
  únicamente A1, A2, A3, AT, Máx y Velocidad, sin solapamiento entre bandas.
- **FR-012**: El sistema DEBE permitir registrar el RPE previsto de la sesión y las
  variables de monitoreo de carga interna.
- **FR-013**: El sistema NO DEBE aceptar como nombre de nado completo las formas prohibidas
  por la metodología (por ejemplo "Libre técnico" o "Pecho asistido"); solo admite
  `Nado Libre`, `Nado Espalda`, `Nado Pecho`, `Nado Mariposa` y `Nado CI`.

**Plan, microciclos y validación agregada**

- **FR-014**: El sistema DEBE permitir organizar sesiones en microciclos y microciclos en
  un plan, con categoría, estilo objetivo, prueba objetivo, longitud de piscina y fechas.
- **FR-015**: El sistema DEBE exigir que cada microciclo se nombre por su objetivo real y
  no solo por su posición en la fase.
- **FR-016**: El sistema DEBE validar el volumen por sesión contra el rango de la categoría
  y la frecuencia semanal contra las sesiones esperadas de esa categoría.
- **FR-017**: El sistema DEBE impedir la asignación de fases ATR a las categorías que no
  las usan.
- **FR-018**: El sistema DEBE calcular la distribución real de zonas del plan y compararla
  contra la prescrita para su fase ATR, verificando que la prescripción sume 100%.
- **FR-019**: El sistema DEBE calcular la distribución real de estilos del volumen de nado
  y compararla contra la prescrita para el estilo objetivo.
- **FR-020**: El sistema DEBE verificar la regla de Tecnificación de alternancia Pecho /
  Mariposa en los programas a los que aplica.

**Auditoría y aprobación**

- **FR-021**: El sistema DEBE producir la tabla de auditoría de la metodología con sus once
  criterios, cada uno con resultado y observación, consultable en cualquier momento.
- **FR-022**: El sistema DEBE impedir la aprobación de un plan que incumpla un criterio no
  negociable: ejercicios ajenos a la biblioteca, nomenclatura o notación inválidas, zonas
  mal asignadas, prescripción que no suma 100%, o datos obligatorios faltantes.
- **FR-023**: El sistema DEBE exigir justificación escrita del entrenador para los
  incumplimientos que la metodología admite justificar, en particular el descenso de
  volumen por afinación, y DEBE conservarla junto al plan.
- **FR-024**: El sistema DEBE manejar los estados `borrador`, `aprobado` y `publicado`, y
  solo el entrenador puede mover un plan a `aprobado`.
- **FR-025**: El sistema DEBE bloquear la edición de un plan aprobado y DEBE crear una
  nueva versión en borrador cuando se requiera modificarlo, conservando la anterior.
- **FR-026**: El sistema DEBE registrar en cada plan la versión de metodología bajo la que
  se construyó, y NO DEBE reescribir retroactivamente planes ya aprobados cuando la
  metodología cambie.

**Cuentas, datos y privacidad**

- **FR-027**: El sistema DEBE distinguir los roles entrenador y nadador, y DEBE reservar la
  creación, edición y aprobación de planes al entrenador.
- **FR-028**: El sistema DEBE impedir que un nadador acceda a los datos o a los planes de
  otro nadador.
- **FR-029**: El sistema DEBE exigir consentimiento verificable del padre, madre o
  acudiente antes de almacenar datos de un nadador menor de edad, registrando quién lo
  otorga, su relación con el menor y la fecha.
- **FR-030**: El sistema DEBE limitarse a recolectar los datos con un uso declarado en esta
  feature: identificación, categoría, edad, estilo y prueba objetivo, marcas conocidas y
  diagnóstico técnico.
- **FR-031**: El sistema DEBE permitir exportar los datos de un nadador y sus planes en un
  formato legible, y eliminarlos a petición.
- **FR-032**: El sistema NO DEBE registrar nombres, marcas ni identificadores de nadadores
  en los registros técnicos ni en la analítica.

### Key Entities

- **Usuario**: persona autenticada con un rol, entrenador o nadador. El entrenador es uno
  solo en esta etapa.
- **Nadador**: deportista con categoría, edad, estilo y prueba objetivo, marcas conocidas y
  diagnóstico técnico observado. Si es menor, referencia a su consentimiento.
- **Consentimiento**: autorización de un acudiente sobre un nadador menor, con relación y
  fecha.
- **Plan**: unidad de planificación con categoría, estilo objetivo, prueba objetivo,
  longitud de piscina, fechas, fase ATR cuando aplica, estado, versión de metodología y
  justificaciones asociadas.
- **Microciclo**: agrupación de sesiones nombrada por su objetivo real, perteneciente a un
  plan.
- **Sesión**: unidad de entrenamiento con fecha, objetivo técnico, objetivo fisiológico,
  RPE previsto y tres partes.
- **Parte de sesión**: inicial, central o final, con su conjunto de series y sus metros.
- **Serie**: tarea con distancia, repeticiones, tiempo de salida, implementos, zona de
  intensidad y, cuando corresponde, el ejercicio de la biblioteca que la compone.
- **Ejercicio de la Biblioteca**: nombre exacto, estilo, descripción y error o objetivo
  técnico que corrige.
- **Zona de intensidad**: A1, A2, A3, AT, Máx o Velocidad, con su banda fisiológica y su
  uso principal.
- **Resultado de auditoría**: conjunto de criterios evaluados sobre un plan, cada uno con
  su veredicto, su observación y si es bloqueante.
- **Justificación**: texto del entrenador que habilita un incumplimiento admisible,
  asociado al criterio y al plan.
- **Propuesta de ejercicio**: sugerencia fuera de la biblioteca, pendiente de aprobación,
  sin efecto sobre ningún plan.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Al reconstruir en la app un microciclo histórico ya existente del entrenador,
  los metros totales por sesión y por microciclo coinciden exactamente con los del
  documento original, con diferencia de 0 m.
- **SC-002**: Ningún plan aprobado contiene ejercicios ajenos a la Biblioteca Oficial: cero
  excepciones sobre el total de planes aprobados.
- **SC-003**: Todo plan aprobado cumple los once criterios de auditoría o lleva
  justificación escrita del entrenador en los que la admiten: cero planes aprobados sin una
  cosa o la otra.
- **SC-004**: El entrenador construye una sesión completa de su categoría habitual en menos
  de 15 minutos, incluyendo la verificación de volumen y porcentaje técnico que hoy hace a
  mano.
- **SC-005**: Sobre un conjunto de planes con defectos sembrados a propósito, la auditoría
  detecta el 100% de los defectos que corresponden a sus once criterios.
- **SC-006**: Ningún dato de un nadador menor de edad queda almacenado sin consentimiento
  registrado: cero casos.
- **SC-007**: El entrenador exporta un plan aprobado en formato legible en menos de un
  minuto.
- **SC-008**: Un nadador no consigue acceder a los datos ni a los planes de otro nadador en
  ningún intento de las pruebas de acceso.

## Assumptions

- **Alcance de la jerarquía**: el editor cubre plan → microciclo → sesión, con la fase ATR
  declarada en el plan. La construcción del macrociclo completo con calendario de
  competencias, festivos y mesociclos encadenados queda fuera de esta feature.
- **Un solo entrenador**: el sistema asume un único entrenador responsable. La gestión de
  varios entrenadores o de permisos delegados no se contempla.
- **Digitalización de la biblioteca**: la Biblioteca Oficial debe existir como datos
  consultables dentro del producto. Su carga inicial forma parte del trabajo de esta
  feature.
- **Versión de metodología**: se asume vigente la V3.4 del documento del entrenador, y que
  el documento del repositorio declara su versión de forma verificable.
- **Auditoría bloqueante frente a justificable**: se asume que los criterios que tocan la
  regla de no invención, la nomenclatura, la notación, las zonas y los datos obligatorios
  bloquean la aprobación, mientras que el volumen fuera de rango por afinación y las
  desviaciones de distribución admiten justificación escrita. Es la interpretación de la
  jerarquía de reglas de la metodología y conviene que el entrenador la confirme.
- **Planes por nadador o por grupo**: se asume que un plan se dirige a una categoría y
  puede asignarse a uno o varios nadadores, siguiendo la forma en que el entrenador ya
  organiza sus planificaciones por grupo.
- **Importación desde Excel**: los planes históricos en hoja de cálculo no se importan
  automáticamente. Se usan como referencia de verificación, reconstruyéndolos a mano.
- **Sin conexión**: la edición de planes por parte del entrenador asume conexión. El uso a
  pie de piscina sin conexión corresponde a la consulta del nadador, que es otra feature.
- **Monetización**: esta feature no incluye cobros, suscripciones ni distinción entre nivel
  gratuito y pago. El editor es una herramienta del entrenador.
- **Volumen de uso**: se asume un entrenador y decenas de nadadores, no miles. El
  rendimiento a escala mayor no condiciona el diseño de esta feature.

## Fuera de alcance

Se excluye explícitamente de esta feature, para mantenerla como una rebanada vertical
construible:

- La consulta del plan por parte del nadador, incluida la sesión del día y el
  funcionamiento sin conexión a pie de piscina. Es la feature siguiente.
- El registro de progreso, marcas, pruebas de control y Critical Speed.
- La retroalimentación en video.
- La comunidad, el contenido educativo y las notificaciones.
- Los cobros, las suscripciones y el nivel gratuito frente al pago.
- Cualquier generación automática o asistida por IA de planes o de sesiones.
- El macrociclo completo con calendario de competencias y festivos.
- La importación automática de las planificaciones existentes en Excel.
