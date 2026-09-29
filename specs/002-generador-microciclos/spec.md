# Especificación de Feature: Generador Determinista de Microciclos

**Feature Branch**: `002-generador-microciclos`

**Created**: 2026-09-29

**Status**: Draft

**Input**: El entrenador introduce los datos del protocolo de inicio de su metodología
(sección 5) y la app le devuelve un microciclo completo —la semana, con todas sus sesiones—
ya cuadrado contra su metodología. Él lo revisa, lo ajusta en el editor que ya existe, y lo
guarda o lo aprueba. La composición es determinista, a partir de las reglas ya codificadas:
sin modelo de lenguaje, sin conexión y sin costo por plan.

## Clarifications

### Session 2026-09-29

- Q: ¿Cómo se consigue que dos semanas consecutivas no salgan idénticas, si la generación
  es determinista? → A: El entrenador declara el **componente acentuado** de la semana, que
  es lo que su sección 4 ya le exige hacer al nombrar el microciclo por su objetivo real. El
  generador construye la semana alrededor de ese componente. Mismos datos, incluido el
  componente, dan el mismo plan; semanas distintas difieren porque el entrenador acentúa
  algo distinto. No hay azar ni semilla.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generar la semana (Priority: P1)

El entrenador abre el generador, declara la categoría, el estilo y la prueba objetivo, la
fase ATR, el componente acentuado de la semana, los días disponibles y la longitud de
piscina, y añade el diagnóstico técnico si lo tiene. Pulsa generar y obtiene el microciclo
completo: sus sesiones con objetivo técnico, objetivo fisiológico, RPE previsto y las tres
partes con sus series, todo con el volumen y la distribución ya cuadrados.

**Why this priority**: Es la razón de existir de la feature. Sustituye el trabajo que hoy
le toma horas en una hoja de cálculo, y es lo que convierte la app en una herramienta que
ahorra tiempo en lugar de una donde transcribir.

**Independent Test**: Se puede probar por completo generando una semana para una categoría
conocida y comprobando que los totales, la distribución y el porcentaje técnico salen
dentro de lo que la metodología prescribe, sin tocar nada a mano.

**Acceptance Scenarios**:

1. **Given** categoría Precompetitivo, estilo objetivo Libre, fase de Acumulación y tres
   días disponibles, **When** el entrenador genera, **Then** obtiene tres sesiones, cada una
   con volumen dentro de 1800-2200 m.
2. **Given** el mismo caso, **When** se revisa la distribución de zonas del microciclo,
   **Then** coincide con la prescrita para Acumulación dentro de la tolerancia declarada.
3. **Given** el mismo caso, **When** se revisa el trabajo técnico, **Then** representa el
   porcentaje prescrito para la fase dentro de la tolerancia.
4. **Given** estilo objetivo Libre, **When** se revisa el reparto de estilos, **Then**
   respeta el 80-85% Libre y 15-20% Espalda que prescribe la metodología.
5. **Given** cualquier microciclo generado, **When** se revisan sus series, **Then** todos
   los ejercicios pertenecen a la Biblioteca Oficial y ninguno queda ambiguo.
6. **Given** cualquier sesión generada, **When** se revisa su estructura, **Then** tiene
   objetivo técnico, objetivo fisiológico, RPE previsto y las tres partes repartidas
   40/50/10.
7. **Given** un componente acentuado declarado, **When** se revisa el nombre del
   microciclo, **Then** refleja ese componente y no solo su posición en la fase.
8. **Given** los mismos datos de entrada dos veces, **When** el entrenador genera dos
   veces, **Then** obtiene exactamente el mismo microciclo.
9. **Given** un componente acentuado distinto y el resto igual, **When** genera, **Then**
   obtiene un microciclo distinto.
10. **Given** el generador ejecutándose, **When** no hay conexión a internet, **Then**
    genera igual.

---

### User Story 2 - Revisar y ajustar lo generado (Priority: P2)

El microciclo generado se abre en el editor que ya existe. El entrenador lee las series en
su notación, cambia lo que quiera —una distancia, un ejercicio, una zona— y ve cómo la
auditoría y los totales se recalculan al instante. Guarda cuando le convence.

**Why this priority**: Un plan que no se puede tocar no sirve: el entrenador siempre sabrá
algo del nadador que la app no sabe. Sin esta historia, la generación produce algo que hay
que aceptar o descartar entero.

**Independent Test**: Se puede probar generando una semana, editando una serie y
comprobando que los totales y los criterios de auditoría reflejan el cambio.

**Acceptance Scenarios**:

1. **Given** un microciclo generado, **When** el entrenador lo abre, **Then** cada sesión
   se muestra en el editor con sus series escritas en su notación habitual.
2. **Given** una sesión generada abierta en el editor, **When** el entrenador cambia una
   distancia, **Then** los metros de la parte, de la sesión y del microciclo se recalculan,
   y la auditoría se actualiza.
3. **Given** una serie generada, **When** el entrenador la corrige a mano, **Then** queda
   marcada como corregida y su valor prevalece.
4. **Given** un microciclo generado y editado, **When** el entrenador lo guarda, **Then**
   se conserva la marca de que su origen fue automático, junto con lo que él cambió.
5. **Given** una edición que rompe el cumplimiento, **When** el entrenador la hace,
   **Then** la auditoría lo señala con la diferencia exacta y no se lo impide: él decide.

---

### User Story 3 - Entender por qué no se puede generar (Priority: P3)

Cuando los datos no alcanzan o se contradicen, la app no entrega un plan a medias: explica
qué falta o por qué lo pedido es imposible, y no genera nada.

**Why this priority**: La regla R3 de la metodología prohíbe planificar con datos faltantes.
Un generador que rellena huecos con suposiciones produce planes que parecen válidos y no lo
son, que es peor que no generar.

**Independent Test**: Se puede probar pidiendo generaciones imposibles a propósito y
comprobando que ninguna produce un plan.

**Acceptance Scenarios**:

1. **Given** una petición sin categoría o sin estilo objetivo, **When** el entrenador
   intenta generar, **Then** la app nombra el dato que falta y no genera.
2. **Given** categoría Precompetitivo, que pide tres sesiones semanales, **When** el
   entrenador declara solo dos días disponibles, **Then** la app explica la contradicción
   entre la frecuencia de la categoría y los días disponibles, y no genera.
3. **Given** una categoría que no usa ATR, **When** el entrenador declara una fase ATR,
   **Then** la app lo impide y explica por qué.
4. **Given** un componente acentuado que la fase no admite, **When** el entrenador lo
   declara, **Then** la app lo señala en lugar de generar algo incoherente.
5. **Given** datos suficientes pero con un supuesto inevitable, **When** la app genera,
   **Then** el supuesto queda marcado visiblemente dentro del plan.
6. **Given** cualquier fallo de generación, **When** ocurre, **Then** no queda ningún plan
   a medias guardado.

---

### User Story 4 - Aprobar lo generado (Priority: P4)

El plan generado pasa por la misma puerta que uno escrito a mano: nace en borrador, muestra
la tabla de los once criterios, y solo el entrenador lo mueve a aprobado.

**Why this priority**: Es la garantía del principio IV. Va después porque la maquinaria de
aprobación ya existe: aquí solo se conecta y se comprueba que la generación no la relaja.

**Independent Test**: Se puede probar intentando aprobar un plan generado con un defecto
sembrado y comprobando que la puerta se comporta igual que con un plan manual.

**Acceptance Scenarios**:

1. **Given** un microciclo recién generado, **When** el entrenador lo consulta, **Then**
   está en estado borrador y marcado como generado automáticamente.
2. **Given** un microciclo generado, **When** el entrenador abre la auditoría, **Then** ve
   los once criterios, igual que en un plan manual.
3. **Given** un microciclo generado sin defectos, **When** el entrenador lo aprueba,
   **Then** queda aprobado con la versión de metodología y la fecha estampadas, y conserva
   la marca de su origen automático.
4. **Given** un microciclo generado y luego editado hasta romper un criterio bloqueante,
   **When** el entrenador intenta aprobarlo, **Then** no se lo permite.
5. **Given** un plan generado, **When** llega a un nadador, **Then** solo puede haber
   ocurrido después de la firma del entrenador.

---

### Edge Cases

- **Categoría de sesiones dobles**: Alto Rendimiento pide diez sesiones semanales sobre seis
  o siete días, así que algunos días llevan dos. El generador reparte y marca la segunda
  sesión del día como tal.
- **Festivos y fechas sin servicio**: reducen los días disponibles. Si la reducción hace
  imposible la frecuencia de la categoría, se aplica el escenario de contradicción.
- **Sin diagnóstico técnico**: no se inventan errores. La selección de ejercicios sigue la
  progresión técnica estándar de la metodología (patada, posición corporal, control
  corporal, respiración, tracción, brazada, ejercicios específicos, nado completo).
- **Diagnóstico sin ejercicio que lo corrija**: la Biblioteca no cubre ese error. Se señala
  el vacío en lugar de elegir un ejercicio que no corresponde.
- **Lesión o limitación declarada**: se registra y se muestra al entrenador como aviso, pero
  el generador NO adapta el plan por su cuenta. La Biblioteca describe qué corrige cada
  ejercicio, no qué está contraindicado, y suponerlo sería dar consejo médico.
- **Regla de Tecnificación**: en esa categoría, la primera sesión de la semana es de Pecho y
  la segunda de Mariposa. El generador la respeta o no genera.
- **Volumen imposible en el tiempo disponible**: si los metros que la categoría exige no
  caben en la duración de sesión declarada, se reporta la contradicción.
- **Redondeo de la distribución**: repartir metros enteros entre zonas con porcentajes
  prescritos no siempre cierra exacto. El sobrante se asigna de forma declarada y estable,
  nunca al azar, y el resultado sigue dentro de la tolerancia.
- **Piscina de 50 m**: las distancias generadas deben ser múltiplos coherentes con la
  longitud de piscina declarada.
- **Cambio de versión de metodología**: un microciclo generado queda estampado con la
  versión vigente al aprobarlo, y no se regenera solo cuando la metodología cambie.

## Requirements *(mandatory)*

### Functional Requirements

**Datos de entrada**

- **FR-001**: El sistema DEBE pedir los datos del protocolo de inicio que el microciclo
  necesita: categoría, estilo objetivo, prueba objetivo, fase ATR cuando la categoría la
  usa, componente acentuado de la semana, días disponibles, duración de sesión y longitud de
  piscina.
- **FR-002**: El sistema DEBE permitir añadir el diagnóstico técnico del nadador o grupo
  como lista de errores observados, y DEBE poder generar sin él.
- **FR-003**: El sistema DEBE permitir declarar festivos o fechas sin servicio dentro de la
  semana, y descontarlos de los días disponibles.
- **FR-004**: El sistema DEBE permitir declarar lesiones o limitaciones, mostrarlas como
  aviso al entrenador, y NO DEBE modificar el plan por su cuenta a partir de ellas.
- **FR-005**: El sistema NO DEBE generar con datos obligatorios faltantes: nombra lo que
  falta y se detiene (regla R3).
- **FR-006**: El sistema DEBE detectar contradicciones entre los datos —frecuencia de la
  categoría frente a días disponibles, volumen frente a duración de sesión, fase ATR en
  categoría que no la usa, componente acentuado incompatible con la fase— y explicarlas sin
  generar.
- **FR-007**: Cuando un supuesto sea inevitable para avanzar, el sistema DEBE marcarlo
  visiblemente dentro del plan generado.

**Composición del microciclo**

- **FR-008**: El sistema DEBE generar tantas sesiones como sesiones semanales declare la
  categoría, repartidas entre los días disponibles, marcando como tal la segunda sesión de
  un mismo día cuando la frecuencia lo exija.
- **FR-009**: El sistema DEBE nombrar el microciclo por el componente acentuado declarado, y
  NO DEBE nombrarlo solo por su posición en la fase.
- **FR-010**: Cada sesión generada DEBE tener objetivo técnico, objetivo fisiológico, RPE
  previsto y las tres partes: inicial, central y final.
- **FR-011**: El volumen de cada sesión generada DEBE caer dentro del rango de metros por
  sesión de la categoría.
- **FR-012**: El reparto entre partes de cada sesión generada DEBE ajustarse al prescrito:
  inicial 40%, central 50% con su pre-set, final 10%.
- **FR-013**: La distribución de zonas de intensidad del microciclo DEBE ajustarse a la
  prescrita para su fase ATR, dentro de la tolerancia declarada.
- **FR-014**: El porcentaje de trabajo técnico del microciclo DEBE ajustarse al prescrito
  para su fase, dentro de la tolerancia declarada.
- **FR-015**: El reparto de estilos del volumen de nado DEBE ajustarse al prescrito para el
  estilo objetivo.
- **FR-016**: Toda serie generada DEBE llevar su zona de intensidad asignada. El generador
  la asigna porque la deriva de la distribución que está construyendo, no la adivina.
- **FR-017**: El sistema DEBE respetar la regla de alternancia de Tecnificación —primera
  sesión de Pecho, segunda de Mariposa— en esa categoría, o no generar.
- **FR-018**: El reparto de metros entre zonas DEBE resolver el redondeo de forma declarada
  y estable, sin azar, dejando el resultado dentro de la tolerancia.
- **FR-019**: Las distancias generadas DEBEN ser coherentes con la longitud de piscina
  declarada.

**Selección de ejercicios**

- **FR-020**: El sistema NO DEBE usar ningún ejercicio ajeno a la Biblioteca Oficial, y
  DEBE indicar el estilo en los nombres que se repiten entre estilos.
- **FR-021**: Cuando exista diagnóstico técnico, el sistema DEBE elegir ejercicios cuyo
  error corregido corresponda a los errores diagnosticados.
- **FR-022**: Cuando no exista diagnóstico, el sistema DEBE seguir la progresión técnica
  estándar de la metodología y NO DEBE inventar errores.
- **FR-023**: Cuando un error diagnosticado no tenga ejercicio que lo corrija en la
  Biblioteca, el sistema DEBE señalar ese vacío en lugar de elegir otro ejercicio.

**Determinismo y trazabilidad**

- **FR-024**: Con los mismos datos de entrada el sistema DEBE producir el mismo microciclo.
  NO DEBE intervenir el azar en ninguna decisión.
- **FR-025**: El sistema DEBE generar sin conexión a internet y sin consultar ningún
  servicio externo.
- **FR-026**: Todo plan generado DEBE nacer en estado borrador y quedar marcado con que su
  origen fue automático, marca que se conserva aunque el entrenador lo edite después.
- **FR-027**: El sistema DEBE dejar el microciclo generado escrito en la notación del
  entrenador, de modo que él lo lea y lo edite en el mismo editor que usa para escribir a
  mano.
- **FR-028**: El microciclo generado, releído desde su notación, DEBE arrojar los mismos
  metros que el generador calculó.

**Revisión, auditoría y aprobación**

- **FR-029**: El sistema DEBE abrir el microciclo generado en el editor existente, con cada
  sesión editable.
- **FR-030**: Al editar una sesión generada, el sistema DEBE recalcular los totales del
  microciclo y volver a evaluar la auditoría.
- **FR-031**: Una corrección manual sobre una serie generada DEBE prevalecer y quedar
  marcada como tal.
- **FR-032**: El sistema DEBE evaluar los once criterios de auditoría sobre el plan generado
  igual que sobre uno manual, sin excepciones ni criterios relajados.
- **FR-033**: El sistema NO DEBE permitir aprobar un plan generado que incumpla un criterio
  bloqueante, ni uno justificable sin justificación escrita.
- **FR-034**: Solo el entrenador DEBE poder mover un plan generado a aprobado.
- **FR-035**: Al aprobar, el sistema DEBE estampar la versión de metodología vigente y la
  fecha, y conservar la marca de origen automático.

### Key Entities

- **Petición de generación**: el conjunto de datos de entrada —categoría, estilo y prueba
  objetivo, fase ATR, componente acentuado, días disponibles, festivos, duración de sesión,
  longitud de piscina, diagnóstico técnico, lesiones—. Es lo que hace reproducible el
  resultado: misma petición, mismo plan.
- **Componente acentuado**: el contenido dominante de la semana, declarado por el
  entrenador. Da nombre al microciclo y orienta la selección de ejercicios y el reparto de
  intensidades.
- **Resultado de generación**: o un microciclo, o la lista de impedimentos que lo hicieron
  imposible. Nunca las dos cosas, nunca un plan a medias.
- **Impedimento de generación**: dato que falta o contradicción detectada, con su
  explicación en términos que el entrenador reconozca.
- **Origen del plan**: manual o automático. Se conserva durante toda la vida del plan,
  incluso después de que el entrenador lo edite o lo apruebe.
- **Vacío de biblioteca**: error diagnosticado sin ejercicio que lo corrija. Se reporta, no
  se sustituye.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El entrenador obtiene un microciclo completo en menos de dos minutos desde
  que abre el formulario, frente a las horas que hoy le toma construirlo en hoja de cálculo.
- **SC-002**: El 100% de los microciclos generados pasan los once criterios de auditoría sin
  ningún criterio bloqueante en rojo, sin que el entrenador toque nada.
- **SC-003**: Con los mismos datos de entrada, dos generaciones producen planes idénticos:
  cero diferencias.
- **SC-004**: Cero ejercicios ajenos a la Biblioteca Oficial en los planes generados, y cero
  referencias ambiguas sin estilo.
- **SC-005**: El volumen de cada sesión generada cae dentro del rango de su categoría en el
  100% de los casos.
- **SC-006**: La distribución de zonas y el porcentaje técnico de cada microciclo generado
  quedan dentro de la tolerancia de su fase en el 100% de los casos.
- **SC-007**: Un microciclo generado, releído desde su notación, arroja los mismos metros
  que el generador calculó: diferencia de 0 m.
- **SC-008**: Ante datos insuficientes o contradictorios, cero planes generados. El sistema
  no produce nunca un plan que incumpla.
- **SC-009**: El microciclo generado para una categoría y fase equivalentes a un microciclo
  real del entrenador queda dentro de los mismos rangos de volumen y distribución que el
  suyo, sin necesidad de copiar su contenido.
- **SC-010**: El entrenador puede pasar de un microciclo generado a uno aprobado sin salir
  de la app y sin transcribir nada.

## Assumptions

- **El componente acentuado lo declara el entrenador.** Es lo que resuelve la tensión entre
  determinismo y variedad: el generador no inventa progresión ni introduce azar; construye
  la semana alrededor del componente que él acentúa, que es lo que su sección 4 ya le exige
  al nombrar el microciclo por su objetivo real. Semanas distintas difieren porque él
  acentúa algo distinto.
- **La fase ATR es un dato de entrada, no se deduce del calendario.** Deducirla de la fecha
  de competencia y la duración del plan corresponde al generador de macrociclos, que es otra
  feature.
- **El alcance es una semana.** Un microciclo cabe holgadamente en el límite de veinte
  sesiones a partir del cual la metodología exige construir por fases con confirmación
  intermedia, así que se genera de una vez.
- **Sin modelo de lenguaje.** Toda la composición sale de las reglas ya codificadas. La capa
  asistida por modelo es la feature 005 y se monta encima de esta, no la sustituye.
- **El generador no adapta por lesiones.** La Biblioteca declara qué error corrige cada
  ejercicio, no qué está contraindicado. Adaptar un plan a una lesión es criterio clínico y
  el principio IV prohíbe que la app lo simule: la lesión se registra y se avisa.
- **Una sola propuesta por generación.** No se ofrecen varias alternativas a elegir: se
  genera una y se edita. Ofrecer variantes multiplicaría el trabajo sin resolver nada que la
  edición no resuelva.
- **La tolerancia de distribución es la que ya existe.** Se reutiliza el valor vigente, sin
  aflojarlo para que la generación pase más fácil. Si hay que recalibrarlo, se recalibra para
  todo el sistema, no para el generador.
- **El editor existente es la superficie de revisión.** No se construye una pantalla nueva
  para leer el plan generado: se reutiliza la que ya lee y escribe notación.
- **Uso local con datos de prueba.** Sigue vigente la restricción de la constitución: sin
  registro de consentimiento del acudiente, solo perfiles de prueba o del propio entrenador.

## Fuera de alcance

- La generación asistida por modelo de lenguaje. Es la feature 005 y se monta sobre esta.
- El consumo por parte del nadador: ver su sesión, marcarla realizada y anotar
  observaciones. Es la feature 003.
- Las cuentas, los roles y el consentimiento verificable del acudiente. Es la feature 004 y
  es la puerta para publicar.
- El macrociclo completo por fases, con calendario de competencias y festivos del período.
- La derivación automática de la fase ATR a partir de la fecha de competencia.
- El progreso entre microciclos: el generador no sabe qué se hizo la semana anterior ni
  ajusta la carga en consecuencia.
- La adaptación automática por lesión o limitación.
- Los cobros y la distinción entre nivel gratuito y pago.
