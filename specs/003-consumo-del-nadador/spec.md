# Especificación de feature: El nadador consume su plan

**Feature Branch**: `003-swimmer-plan-consumption`

**Created**: 2026-10-13

**Status**: Draft

**Input**: El nadador entra a la app, ve su plan y la sesión que le toca, la marca como realizada, anota su RPE y sus observaciones, y todo eso funciona a pie de piscina sin conexión.

---

## Por qué existe esta feature

El entrenador ya puede generar un microciclo, revisarlo y aprobarlo. Pero el nadador
**no tiene por dónde entrar**: el entregable sigue siendo del entrenador, no suyo.

La constitución lo dice desde su primera línea —«el plan entregado es **interactivo**: vive
dentro de la aplicación, el nadador actúa sobre él y su respuesta vuelve al entrenador. No
es un documento que se lee y se cierra»— y el principio VIII exige cerrar el ciclo
diagnóstico → modelar → programar → **controlar** → reajustar. Hoy el producto implementa la
programación y no implementa el control.

Sin la respuesta del nadador, un plan es una hipótesis que nadie comprueba.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - El nadador ve lo que le toca hoy (Priority: P1)

El nadador abre la app a pie de piscina y ve, sin más pasos, la sesión que le corresponde:
sus objetivos, sus tres partes y sus series tal como el entrenador las escribió. Si no hay
señal —que es lo normal en una piscina— lo ve igual.

**Why this priority**: es el mínimo que convierte el plan en algo del nadador. Sin esto, las
otras dos historias no tienen dónde ocurrir. Entregada sola ya cambia el producto: el plan
deja de vivir en una hoja del entrenador.

**Independent Test**: se asigna un plan publicado a un perfil de prueba, se abre la app con
el dispositivo en modo avión y se comprueba que la sesión del día aparece completa y
legible.

**Acceptance Scenarios**:

1. **Given** un plan publicado y asignado al nadador, **When** abre la app, **Then** ve la
   sesión que corresponde a la fecha de hoy, con su objetivo técnico, su objetivo
   fisiológico y las series de las tres partes.
2. **Given** el dispositivo sin conexión, **When** el nadador consulta su plan, su sesión
   del día o su progreso, **Then** lo ve completo, sin ningún mensaje de error y sin
   esperar a la red.
3. **Given** que hoy no hay sesión programada, **When** abre la app, **Then** ve cuál es la
   siguiente y cuándo, en lugar de una pantalla vacía.
4. **Given** un plan en estado `borrador` o `aprobado` pero no `publicado`, **When** el
   nadador abre la app, **Then** ese plan no aparece.
5. **Given** una serie escrita por el entrenador, **When** el nadador la lee, **Then** la ve
   con la notación del entrenador y los nombres exactos de la Biblioteca, sin reescribir ni
   abreviar.

---

### User Story 2 - El nadador responde y el entrenador lo lee (Priority: P1)

Al terminar, el nadador marca la sesión como realizada, anota su RPE percibido y escribe lo
que quiera: que le costó, que le dolió el hombro, que la tercera serie la hizo corta. El
entrenador ve esa respuesta junto al plan que la originó.

**Why this priority**: es el principio VIII, y es la razón de ser de la feature. «Un registro
que nadie lee no es control.» Es P1 junto con la historia 1 porque entregar solo la lectura
dejaría el ciclo abierto otra vez.

**Independent Test**: con un perfil de prueba se marca una sesión, se anota RPE y
observaciones, y se comprueba que el entrenador las ve asociadas a esa sesión concreta y no
mezcladas con lo que él programó.

**Acceptance Scenarios**:

1. **Given** una sesión publicada, **When** el nadador la marca como realizada, **Then**
   queda registrada con su fecha y hora, y el plan aprobado **no se modifica**.
2. **Given** una sesión, **When** el nadador anota un RPE, **Then** solo se aceptan valores
   enteros de 0 a 10 de la escala de Borg.
3. **Given** una sesión realizada con observaciones, **When** el entrenador la consulta,
   **Then** ve el texto del nadador junto a esa sesión, y distingue a simple vista qué
   programó él y qué respondió el nadador.
4. **Given** un nadador que no anota nada, **When** usa la app, **Then** sigue viendo su
   plan con normalidad: registrar la carga interna **no es obligatorio**.
5. **Given** un nadador que quiere reportar dolor o molestia, **When** lo registra, **Then**
   queda marcado **aparte** del resto de observaciones y llega al entrenador señalado como
   tal, sin que la app proponga ninguna conducta.
6. **Given** la carga externa programada y la carga interna reportada, **When** cualquiera
   de los dos las consulta, **Then** se muestran por separado y **nunca combinadas en un
   mismo indicador**.

---

### User Story 3 - A pie de piscina no hay señal (Priority: P1)

El nadador marca la sesión y escribe sus observaciones con el teléfono sin datos. La app se
lo guarda, se lo dice con claridad, y lo envía sola cuando vuelve la red.

**Why this priority**: es P1 y no P2 porque sin esto la historia 2 no funciona donde ocurre.
La señal en las piscinas es mala; una app que exige red para anotar es una app que no se usa.
La constitución lo marca como restricción, no como mejora.

**Independent Test**: en modo avión se marca una sesión y se anota una observación, se cierra
la app, se restablece la red y se comprueba que el registro llegó sin intervención.

**Acceptance Scenarios**:

1. **Given** el dispositivo sin conexión, **When** el nadador marca una sesión o anota
   observaciones, **Then** el registro se guarda en el dispositivo y la app muestra un
   estado explícito del tipo «Guardado el progreso, se enviará cuando tengas acceso a
   internet».
2. **Given** registros pendientes de envío, **When** la red vuelve, **Then** se envían sin
   que el nadador haga nada y el estado pendiente desaparece.
3. **Given** registros pendientes, **When** el nadador cierra la app o apaga el teléfono,
   **Then** al volver siguen ahí: **ningún dato escrito sin conexión se pierde en silencio**.
4. **Given** un envío que falla, **When** ocurre, **Then** el registro permanece como
   pendiente y la app lo reintenta, sin descartarlo y sin bloquear al nadador.
5. **Given** el mismo registro enviado dos veces por un reintento, **When** llega al
   destino, **Then** no se duplica.

---

### User Story 4 - El nadador se lleva una copia (Priority: P3)

El nadador descarga su plan para archivarlo o imprimirlo.

**Why this priority**: es lo último que se necesita. La constitución es explícita: «el
entregable vive en la app […] la exportación o descarga es una copia para archivo o
impresión, **no el producto**». Entregarla antes que las tres primeras invertiría esa
prioridad.

**Independent Test**: se descarga el plan de un perfil de prueba y se comprueba que el
archivo contiene las sesiones tal como la app las muestra.

**Acceptance Scenarios**:

1. **Given** un plan publicado, **When** el nadador lo descarga, **Then** obtiene un archivo
   legible con las sesiones, sus partes y sus series.
2. **Given** un plan descargado, **When** se compara con lo que la app muestra, **Then** el
   contenido coincide: la descarga es una copia, no una versión distinta.

---

### Edge Cases

- **El entrenador publica una versión nueva del plan mientras el nadador ya respondió.** Un
  plan aprobado es inmutable, así que una corrección crea otra versión. Los registros del
  nadador siguen apuntando a la sesión de la versión bajo la que entrenó, y el entrenador
  puede ver a cuál corresponden.
- **El nadador marca como realizada una sesión de otro día**, porque entrenó corrido o se
  saltó una. Debe poder hacerlo: la fecha de la sesión y la fecha del registro son cosas
  distintas.
- **Dos dispositivos del mismo nadador con registros pendientes distintos.** Ninguno debe
  perder lo escrito en el otro.
- **El reloj del dispositivo está mal.** La fecha del registro no puede depender solo del
  dispositivo sin que eso se note al reconciliar.
- **El nadador escribe una observación muy larga**, o la escribe en mayúsculas, o pega texto
  con saltos de línea. Se guarda tal cual; no es notación del entrenador y no se interpreta.
- **El plan asignado se despublica o se desasigna** mientras el nadador lo tenía descargado
  en el dispositivo.
- **El nadador no tiene ningún plan asignado.** Ve una pantalla que lo dice, no un error.
- **Una sesión sin series** —un plan a medias que llegó a publicarse— no debe romper la
  pantalla del nadador.

## Requirements *(mandatory)*

### Functional Requirements

#### Lectura del plan

- **FR-001**: El sistema DEBE mostrar al nadador únicamente los planes en estado
  `publicado` que le estén asignados. Los `borrador` y `aprobado` no son visibles para él.
- **FR-002**: El sistema DEBE mostrar la sesión que corresponde a la fecha actual y, cuando
  no haya, indicar cuál es la siguiente y cuándo.
- **FR-003**: El sistema DEBE mostrar cada sesión con su objetivo técnico, su objetivo
  fisiológico y sus tres partes con sus series.
- **FR-004**: El sistema DEBE mostrar las series con la notación del entrenador y los
  nombres exactos de la Biblioteca Oficial, sin abreviar, reescribir ni corregir.
- **FR-005**: Consultar los planes propios, la sesión del día y el progreso propio NUNCA
  DEBE requerir red.
- **FR-005a**: El sistema DEBE mostrar al nadador su progreso como el **historial de sus
  sesiones** —cada una con su estado de realizada o no, su RPE registrado y sus
  observaciones— ordenado de la más reciente a la más antigua.
- **FR-005b**: El sistema DEBE mostrar la **adherencia**: cuántas sesiones completó de las
  programadas, por semana y en el total del plan. Es un recuento, **no una gráfica**.
- **FR-005c**: La adherencia DEBE contar sesiones, nunca mezclar el recuento con el RPE ni
  con los metros programados. La carga externa y la interna se muestran por separado
  (principio VIII), y un indicador de adherencia que incorporara intensidad las combinaría.

#### Registro de la respuesta del nadador

- **FR-006**: El nadador DEBE poder marcar una sesión como realizada, y la marca DEBE
  registrar cuándo se hizo.
- **FR-007**: El nadador DEBE poder registrar su RPE percibido en la escala de Borg 0-10.
  El sistema solo acepta enteros de 0 a 10.
- **FR-008**: El nadador DEBE poder escribir observaciones en texto libre asociadas a una
  sesión.
- **FR-009**: El nadador DEBE poder reportar dolor, lesión o malestar **en un campo
  separado** de las observaciones generales. El sistema NO DEBE proponer ninguna conducta
  ante ese reporte ni resolverlo de forma automática.
- **FR-010**: Registrar la carga interna NO DEBE ser obligatorio. Un nadador que no anota
  nada sigue usando la app con normalidad.
- **FR-011**: El registro del nadador DEBE ser una entidad **separada** del plan. Un plan
  aprobado es inmutable y NO DEBE modificarse al registrar una respuesta.
- **FR-012**: El sistema DEBE asociar cada registro a la sesión y a la versión de plan bajo
  la que el nadador entrenó.

#### Lo que ve el entrenador

- **FR-013**: El sistema DEBE mostrar al entrenador los registros del nadador **junto al
  plan que los originó**, no en una pantalla aparte y desconectada.
- **FR-014**: El sistema DEBE mostrar la **carga externa** (lo programado: metros, series,
  pausas, ritmos) y la **carga interna** (lo que el nadador respondió) por separado. NO
  DEBEN combinarse en un mismo indicador.
- **FR-015**: El sistema DEBE señalar los reportes de dolor o molestia de forma distinguible
  del resto de observaciones.

#### Funcionamiento sin conexión

- **FR-016**: El nadador DEBE poder marcar una sesión y anotar su retroalimentación sin
  conexión.
- **FR-017**: Ante un registro escrito sin conexión, el sistema DEBE mostrar un estado
  explícito que indique que quedó guardado y que se enviará cuando haya internet.
- **FR-018**: El sistema DEBE enviar los registros pendientes cuando la red vuelva, sin
  intervención del nadador.
- **FR-019**: Ningún dato escrito sin conexión DEBE perderse en silencio. Un envío fallido
  deja el registro como pendiente y se reintenta.
- **FR-020**: Un registro reenviado NO DEBE duplicarse en el destino.
- **FR-021**: Los registros pendientes DEBEN sobrevivir al cierre de la app.

#### Descarga

- **FR-022**: El nadador DEBE poder descargar su plan en un archivo legible, cuyo contenido
  coincida con lo que la app muestra.

#### Datos personales

- **FR-023**: Los registros y la analítica NO DEBEN contener nombres, marcas, videos ni
  identificadores del nadador.
- **FR-024**: El nadador DEBE poder exportar sus propios registros en un formato legible, y
  el modelo de datos DEBE permitir su eliminación sin rediseño.
- **FR-025**: El acceso a los datos de un nadador DEBE denegarse por omisión y concederse
  explícitamente, y esas reglas DEBEN probarse con sus casos negativos.
- **FR-026**: El acceso del nadador a los datos que él mismo generó NUNCA DEBE quedar detrás
  de un muro de pago. Registrar el progreso propio pertenece al nivel gratuito.

### Key Entities

- **Registro de sesión**: la respuesta del nadador a una sesión concreta. Guarda si la
  cumplió, cuándo lo registró, su RPE percibido, sus observaciones, su reporte de molestia
  si lo hubo, y a qué sesión y versión de plan corresponde. Es independiente del plan y no
  lo modifica.
- **Reporte de molestia**: dolor, lesión o malestar, separado de las observaciones
  generales porque la metodología y el principio VIII exigen que llegue señalado y sin
  respuesta automática.
- **Estado de sincronización**: por cada registro, si está pendiente de envío, enviado o en
  reintento. Es lo que sostiene el mensaje que el nadador ve y la garantía de que nada se
  pierde.
- **Progreso del nadador**: la historia de sus registros a lo largo del plan, que es lo que
  convierte respuestas sueltas en algo que el entrenador puede seguir.
- **Adherencia**: cuántas sesiones completó de las programadas, por semana y en el plan. Es
  un recuento de sesiones y se mantiene deliberadamente separado de la intensidad: es el
  dato que dice si el plan se está cumpliendo, no si está siendo duro.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Con el dispositivo sin conexión, el nadador llega desde que abre la app hasta
  ver su sesión del día **sin ningún paso de red y sin mensajes de error**.
- **SC-002**: Un nadador marca la sesión y anota su RPE y una observación en **menos de 30
  segundos**, que es lo que dura la paciencia de alguien mojado al borde de la piscina.
- **SC-003**: **El 100% de los registros escritos sin conexión llegan al entrenador** una
  vez vuelve la red, en una prueba que corta la conexión, escribe, cierra la app y la
  restablece.
- **SC-004**: Ningún registro duplicado tras reintentos de envío, comprobado forzando envíos
  repetidos del mismo registro.
- **SC-005**: El entrenador, mirando una sesión, distingue **sin ambigüedad** qué programó él
  y qué respondió el nadador.
- **SC-006**: Un reporte de molestia es localizable por el entrenador **sin leer todas las
  observaciones** de todas las sesiones.
- **SC-007**: Un plan aprobado conserva su contenido **byte a byte** después de que un
  nadador registre respuestas sobre él.
- **SC-008**: Las reglas de acceso impiden que un nadador lea o escriba registros de otro,
  comprobado con casos negativos.
- **SC-009**: Un nadador que no registra nada completa el recorrido de lectura **sin
  encontrar un solo bloqueo** que le exija anotar.
- **SC-010**: El nadador ve su adherencia —sesiones completadas de las programadas, por
  semana y del plan— **sin conexión y en un solo vistazo**, sin abrir cada sesión para
  contarlas.
- **SC-011**: El recuento de adherencia **no cambia** al variar el RPE registrado ni los
  metros programados: cuenta sesiones, y nada más.

## Assumptions

- **No hay cuentas ni roles todavía.** Las cuentas, los roles y el registro de
  consentimiento verificable son la feature 004. Esta feature se desarrolla y se prueba con
  perfiles de prueba o con el entrenador como nadador, y el perfil activo se elige
  localmente. **Ningún nadador real la usa hasta que 004 exista**: el grupo de Iniciación
  Avanzada son niños de 7 a 10 años, todos menores, y el consentimiento es puerta de
  publicación (principio V).
- **La interfaz va en español**, que es lo que lee el nadador. El vocabulario de dominio en
  el código sigue en español por la misma razón que en 001 y 002: mapea con el documento
  normativo.
- **El dominio sigue en Dart puro.** Las entidades y reglas nuevas no importan Flutter ni
  Firebase, y la prueba de frontera lo vigila.
- **La asignación de planes a nadadores ya existe** desde la feature 001 y esta feature la
  consume, no la rehace.
- **La descarga reutiliza el mecanismo de exportación** que la feature 001 ya construyó, en
  lugar de introducir un formato nuevo.
- **Una sesión se identifica por su posición en el plan y su fecha prevista**, que es lo que
  permite asociar un registro aunque el nadador entrene en otro día.
- **El estado de sincronización es visible pero no interrumpe**: se muestra, no bloquea, y
  el nadador puede seguir usando la app con registros pendientes.

## Dependencies

- Feature 001: ciclo de vida del plan (`borrador` → `aprobado` → `publicado`), perfiles de
  nadador, asignación de planes y exportación.
- Feature 002: el generador, que es lo que produce los planes que el nadador consume.
- Feature 004 (**posterior, y bloqueante para el uso real**): cuentas, roles y registro de
  consentimiento verificable del acudiente.

## Out of Scope

- Cuentas, autenticación, roles y consentimiento: es la feature 004.
- Carga de video y retroalimentación en video.
- Comunidad, mensajería y notificaciones automáticas.
- Suscripciones y cobro.
- Reajuste automático del plan a partir de lo que el nadador reporta. El principio IV lo
  prohíbe: la respuesta llega al entrenador y decide él.
