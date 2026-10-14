# Especificación de feature: Cuentas, roles y consentimiento verificable

**Feature Branch**: `004-accounts-and-consent`

**Created**: 2026-10-14

**Status**: Draft

**Input**: Cuentas, roles y consentimiento verificable del acudiente. El entrenador y el
nadador entran con su propia cuenta; cada uno ve solo lo suyo. Para un nadador menor de
edad no se almacena nada hasta que su acudiente otorga consentimiento verificable, y ese
consentimiento es puerta de publicación. Los planes dejan de vivir en memoria y persisten.
Es la feature que desbloquea el despliegue y el uso con nadadores reales del grupo de
Iniciación Avanzada, niños de 7 a 10 años.

---

## Por qué existe esta feature

Las tres features anteriores construyeron un producto que **nadie puede usar todavía**.

El entrenador genera un microciclo, lo audita, lo aprueba y lo entrega. El nadador lo lee a
pie de piscina sin señal, marca la sesión, anota su RPE y su respuesta vuelve. El ciclo de
la metodología está cerrado. Y sin embargo:

- **No hay cuentas.** El perfil activo se elige de una lista local. Cualquiera que abra la
  app es cualquiera.
- **No hay nada guardado.** Los planes viven en memoria mientras la app está abierta. Se
  cierra, y el trabajo del entrenador desaparece.
- **No hay consentimiento.** El principio V lo dice sin rodeos: «el consentimiento es
  requisito de publicación, no una feature opcional posterior».

El grupo de Iniciación Avanzada son **niños de 7 a 10 años**. En Colombia sus datos están
bajo la Ley 1581 de 2012, y el entrenador responde por ellos ante las familias y ante la
ley. Esta feature es la que convierte un prototipo correcto en algo que se puede desplegar
sin incumplir.

No agrega ninguna capacidad deportiva nueva. Agrega la condición para que las que ya
existen lleguen a alguien.

### Dónde está la puerta, exactamente

La decisión que ordena toda la feature: **lo que el consentimiento bloquea no es usar la
app, es que los datos personales del nadador lleguen al entrenador.**

Nadie queda fuera. El nadador entra, lee lo que tenga y anota lo que quiera. Lo que escribe
se queda en su dispositivo —en la bandeja de salida que la feature 003 ya construyó— sin
enviarse. Cuando el consentimiento llega, sale. Si nunca llega, nunca salió, y el entrenador
nunca almacenó lo que no debía.

Esto cumple el principio V y a la vez no deja a nadie bloqueado. No hacía falta elegir.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sin consentimiento, los datos del menor no salen del dispositivo (Priority: P1)

El entrenador inscribe a un niño de su grupo. Hasta que su acudiente consiente, nada de lo
que ese niño escriba llega al entrenador ni se almacena fuera de su teléfono. El niño
mientras tanto puede usar la app.

**Why this priority**: es la puerta de publicación del principio V y la razón por la que
esta feature va antes del despliegue. Entregada sola, cambia el estado legal del producto.

**Independent Test**: se inscribe a un menor sin consentimiento, se anota una sesión desde
su cuenta y se comprueba que el entrenador no la recibe y que no quedó almacenada fuera del
dispositivo; se registra el consentimiento y se comprueba que a partir de ahí sí llega.

**Acceptance Scenarios**:

1. **Given** un nadador menor sin consentimiento vigente, **When** anota una sesión,
   **Then** el registro queda en su dispositivo como pendiente y **no** se envía.
2. **Given** ese mismo nadador, **When** usa la app, **Then** no encuentra ningún bloqueo:
   la falta de consentimiento no le impide entrar ni anotar.
3. **Given** un consentimiento que se otorga después, **When** queda registrado, **Then** lo
   que estaba pendiente se envía, sin que el nadador tenga que repetir nada.
4. **Given** un nadador menor sin consentimiento, **When** el entrenador intenta publicarle
   un plan, **Then** no puede, y se le dice exactamente qué falta.
5. **Given** un nadador que declara ser mayor de edad, **When** se inscribe, **Then**
   consiente por sí mismo y no se le pide acudiente.
6. **Given** un consentimiento revocado, **When** ocurre, **Then** los datos de ese nadador
   dejan de fluir hacia el entrenador desde ese momento.

---

### User Story 2 - El acudiente confirma, y queda constancia de que fue él (Priority: P1)

El entrenador toma de su matrícula el contacto del acudiente y le pide el consentimiento. El
acudiente recibe un enlace propio, lee qué se va a tratar y para qué, declara quién es y
confirma. Queda registrado con fecha, alcance y la versión del texto que leyó.

**Why this priority**: sin esto, la historia 1 no tiene puerta que abrir. Es lo que convierte
«pedimos permiso» en algo que se puede demostrar.

**Independent Test**: se envía una solicitud, se confirma desde el enlace y se comprueba que
el registro resultante responde a quién, cuándo, sobre quién y para qué, sin interpretar
nada.

**Acceptance Scenarios**:

1. **Given** una solicitud de consentimiento, **When** se prepara, **Then** el contacto del
   acudiente lo aporta **el entrenador**, no el nadador ni el menor.
2. **Given** un enlace de confirmación, **When** se usa una vez, **Then** deja de servir; y
   si no se usa, vence.
3. **Given** quien confirma, **When** lo hace, **Then** declara su nombre, su documento y en
   qué calidad lo hace, y declara ser el representante legal del menor.
4. **Given** una confirmación, **When** se registra, **Then** la fecha la pone el servidor y
   no el dispositivo de quien confirmó.
5. **Given** un consentimiento registrado, **When** se consulta, **Then** consta bajo qué
   versión del texto informativo se otorgó.
6. **Given** un consentimiento recién registrado, **When** se completa, **Then** se avisa al
   mismo canal del acudiente de que quedó registrado, de modo que una suplantación sea
   descubrible por el propio acudiente.
7. **Given** un menor al que se le va a tratar sus datos, **When** se recaba el
   consentimiento, **Then** consta que **el menor fue oído**, como exige la norma para datos
   de niñas, niños y adolescentes.
8. **Given** un consentimiento vigente, **When** el acudiente quiere retirarlo, **Then**
   puede hacerlo desde el mismo canal, sin pedírselo al entrenador.

---

### User Story 3 - Cada quien entra a lo suyo (Priority: P1)

El entrenador entra con su cuenta y ve su comunidad. El nadador entra con la suya y ve su
plan, su sesión y su progreso. Ninguno ve lo del otro, y ningún nadador ve lo de otro.

**Why this priority**: el consentimiento sin control de acceso no protege nada. Prometer que
los datos de un menor están resguardados y dejar que cualquiera los lea sería peor que no
prometerlo.

**Independent Test**: con dos cuentas de nadador y una de entrenador se comprueba, desde
cada una, qué se ve y qué no, incluidos los intentos de acceso directo a lo ajeno.

**Acceptance Scenarios**:

1. **Given** un nadador con sesión iniciada, **When** consulta la app, **Then** ve
   únicamente sus propios planes, registros y progreso.
2. **Given** un nadador, **When** intenta leer o escribir los registros de otro, **Then** se
   le deniega, y la denegación está probada con su caso negativo.
3. **Given** el entrenador, **When** consulta su comunidad, **Then** ve a los nadadores que
   le pertenecen y los registros que ellos le enviaron.
4. **Given** un nadador, **When** intenta aprobar o publicar un plan, **Then** no puede:
   mover un plan a `aprobado` es del entrenador y de nadie más (principio IV).
5. **Given** una persona sin sesión iniciada, **When** abre la app, **Then** no obtiene
   datos de ningún nadador.
6. **Given** un nadador cuyo plan fue despublicado, **When** abre la app, **Then** deja de
   verlo, sin que eso borre los registros que ya había enviado.

---

### User Story 4 - El trabajo del entrenador deja de perderse (Priority: P1)

El entrenador genera un microciclo, lo aprueba y cierra la app. Al volver, su plan sigue
ahí, con su estado, su versión de metodología y sus nadadores asignados.

**Why this priority**: sin esto no hay producto que desplegar. Hoy los planes viven en
memoria: generar un microciclo completo y perderlo al recargar convierte el trabajo del
entrenador en algo que no se le puede confiar a la app.

**Independent Test**: se genera y aprueba un plan, se cierra la app por completo, se vuelve
a entrar y se comprueba que está igual —estado, versión y asignaciones incluidos—.

**Acceptance Scenarios**:

1. **Given** un plan generado y aprobado, **When** el entrenador cierra la app y vuelve,
   **Then** el plan sigue ahí con su estado, su versión de metodología sellada y sus
   nadadores asignados.
2. **Given** un plan aprobado y guardado, **When** se consulta tiempo después, **Then** su
   contenido es idéntico: guardar y recuperar no altera un solo byte de lo que firmó.
3. **Given** un plan en estado `borrador`, **When** se guarda, **Then** sigue siendo
   borrador al volver: persistir no es aprobar.
4. **Given** el entrenador sin conexión, **When** consulta un plan que ya tenía, **Then** lo
   ve, porque la lectura de lo propio nunca requiere red.
5. **Given** los registros que un nadador envió, **When** los consulta más tarde, **Then**
   siguen asociados al plan y a la versión que los originó.

---

### User Story 5 - El acudiente ve, se lleva y borra lo de su hijo (Priority: P2)

El acudiente puede saber qué guarda la app sobre su hijo, llevárselo en un archivo legible y
pedir que se elimine.

**Why this priority**: son derechos de la Ley 1581, no funcionalidades negociables. Es P2
porque el principio V se cumple en lo sustancial con la puerta y las reglas de acceso; esta
historia hace ejercitables los derechos que aquélla reconoce.

**Independent Test**: desde la posición del acudiente se consulta lo almacenado, se exporta
y se solicita la eliminación, comprobando que lo exportado es legible y que lo eliminado
deja de estar.

**Acceptance Scenarios**:

1. **Given** un nadador con datos almacenados, **When** su acudiente pide saber qué hay,
   **Then** obtiene una respuesta comprensible, no un volcado técnico.
2. **Given** una solicitud de exportación, **When** se atiende, **Then** el archivo contiene
   los datos del nadador en un formato legible fuera de la app.
3. **Given** una solicitud de eliminación, **When** se atiende, **Then** los datos
   personales del nadador dejan de estar, sin que el sistema haya tenido que rediseñarse
   para permitirlo.
4. **Given** un nadador cuyos datos se eliminaron, **When** el entrenador consulta sus
   planes, **Then** su trabajo profesional sigue existiendo sin los datos personales de ese
   nadador.

---

### User Story 6 - El entrenador trabaja antes de tener el grupo completo (Priority: P3)

El entrenador prepara microciclos para su temporada aunque todavía no haya recogido todos
los consentimientos. Lo que no puede es entregárselos a un nadador que no ha consentido.

**Why this priority**: no bloquea el despliegue, pero sin ella la puerta de publicación se
convertiría en una puerta de trabajo, y el entrenador no podría planificar hasta tener la
última firma.

**Independent Test**: se genera y aprueba un plan sin ningún nadador con consentimiento, y
se comprueba que el trabajo se guarda y que la entrega es lo único bloqueado.

**Acceptance Scenarios**:

1. **Given** ningún nadador con consentimiento vigente, **When** el entrenador genera,
   audita y aprueba un plan, **Then** puede hacerlo y su trabajo se guarda.
2. **Given** ese plan aprobado, **When** intenta publicárselo a un nadador sin
   consentimiento, **Then** no se le permite y se le dice qué falta.

---

### Edge Cases

- **Un nadador declara ser mayor y no lo es**, o al revés. La declaración es el título bajo
  el que se actúa, y queda registrada con su fecha: lo que el sistema puede garantizar es
  que consta quién declaró qué y cuándo, no que la declaración sea cierta.
- **Un nadador menor cumple la mayoría de edad** mientras usa la app. El consentimiento del
  acudiente deja de ser el título que ampara el tratamiento y corresponde recabar el suyo.
- **El acudiente revoca con registros ya enviados.** Lo revocado deja de tratarse hacia
  adelante; lo que el entrenador conserve como trabajo propio no puede incluir datos
  personales del nadador.
- **Dos acudientes del mismo nadador**, o uno que no es el padre ni la madre. Quién otorgó el
  consentimiento consta con su calidad.
- **El enlace de confirmación llega a quien no debía**, porque el contacto estaba mal. El
  aviso de vuelta al mismo canal es lo que lo hace descubrible; el sistema no puede
  impedirlo.
- **El mismo nadador en dos dispositivos**, o un dispositivo compartido entre hermanos.
  Cerrar sesión deja el dispositivo sin datos del anterior.
- **Un nadador pierde el acceso a su cuenta.** Recuperarlo no puede convertirse en una vía
  para que otra persona entre a los datos de un menor.
- **El entrenador desasigna a un nadador de un plan** que ya tenía en su dispositivo. Deja de
  verlo, pero sus registros ya enviados no desaparecen.
- **Registros pendientes escritos antes de iniciar sesión**, o por un perfil que luego se
  eliminó. No pueden quedar huérfanos ni enviarse al destinatario equivocado.
- **La sesión expira a pie de piscina, sin señal.** El nadador sigue leyendo su plan y
  anotando: una sesión caducada no puede dejarlo sin su entrenamiento.
- **Los perfiles de prueba de las features 001 a 003** conviven con los reales. Tiene que
  poder distinguirse qué es prueba y qué es una persona.

## Requirements *(mandatory)*

### Functional Requirements

#### Cuentas y sesión

- **FR-001**: El sistema DEBE permitir que una persona entre con una cuenta propia, y DEBE
  distinguir cuándo no hay ninguna sesión iniciada.
- **FR-002**: Crear una cuenta NO DEBE estar condicionado a la edad. Cualquier persona puede
  entrar a la app.
- **FR-003**: El sistema DEBE reconocer los roles **entrenador** y **nadador**, y DEBE
  determinar qué puede hacer cada quien a partir de su rol, no de la pantalla en que esté.
- **FR-004**: Un nadador NO DEBE poder mover un plan a `aprobado` ni a `publicado` en ninguna
  circunstancia (principio IV).
- **FR-005**: El sistema DEBE permitir cerrar sesión, y al hacerlo NO DEBE dejar en el
  dispositivo datos del nadador que la tenía abierta.
- **FR-006**: La caducidad de una sesión NO DEBE impedir al nadador leer el plan que ya tiene
  en el dispositivo ni anotar su respuesta.

#### La categoría no es la edad

- **FR-007**: La categoría de un nadador la **declara el entrenador** y el sistema NO DEBE
  derivarla ni sugerirla a partir de la edad. Un niño y un adulto pueden pertenecer a la
  misma categoría (sección 11.1 de la metodología, versión 3.6.0).
- **FR-008**: La fecha de nacimiento NO DEBE ser obligatoria para entrenar. El sistema solo
  necesita saber si el nadador es mayor de edad, y eso se resuelve con una declaración, que
  es el dato mínimo suficiente (minimización, principio V).
- **FR-009**: Cuando sí consta la fecha de nacimiento, el sistema DEBE poder advertir que un
  nadador alcanzó la mayoría de edad, porque el título que ampara el tratamiento cambia.

#### Consentimiento

- **FR-010**: Mientras un nadador menor de edad no tenga consentimiento vigente, sus datos
  personales NO DEBEN salir de su dispositivo ni almacenarse fuera de él.
- **FR-011**: La ausencia de consentimiento NO DEBE impedir al nadador usar la app, entrar,
  leer lo que tenga ni anotar su respuesta. Lo que queda retenido es el envío, no el uso.
- **FR-012**: Otorgado el consentimiento, lo que quedó retenido DEBE enviarse sin que el
  nadador tenga que repetir nada.
- **FR-013**: El sistema DEBE impedir la publicación de un plan a un nadador sin
  consentimiento vigente. El consentimiento es **puerta de publicación**.
- **FR-014**: El contacto del acudiente lo DEBE aportar el entrenador desde su matrícula. El
  nadador NO DEBE poder designar quién consiente por él.
- **FR-015**: La solicitud de consentimiento DEBE viajar como un enlace **de un solo uso y
  con vencimiento**.
- **FR-016**: Quien confirma DEBE declarar su nombre, su documento de identidad y la calidad
  en que actúa, y DEBE declarar expresamente ser el representante legal del menor.
- **FR-017**: La fecha de un consentimiento la DEBE poner el servidor, nunca el dispositivo
  de quien confirma.
- **FR-018**: El texto informativo DEBE estar versionado, y cada consentimiento DEBE constar
  bajo la versión que su otorgante leyó. Cambiar el texto NO DEBE reescribir
  retroactivamente lo que alguien aceptó.
- **FR-019**: Registrado un consentimiento, el sistema DEBE avisar al mismo canal del
  acudiente de que quedó registrado, de modo que una suplantación sea descubrible por él.
- **FR-020**: El registro de un consentimiento DEBE constar de: quién lo otorga, en qué
  calidad, sobre qué nadador, en qué fecha, qué tratamientos cubre y bajo qué versión del
  texto informativo.
- **FR-021**: DEBE constar que **el menor fue oído** antes de que su representante legal
  autorizara el tratamiento de sus datos.
- **FR-022**: El consentimiento DEBE poder revocarse desde el mismo canal por el que se
  otorgó, sin tener que pedírselo al entrenador, y la revocación DEBE registrarse con su
  fecha sin borrar que hubo consentimiento previo.
- **FR-023**: El consentimiento DEBE tener alcance **por tratamiento**. El tratamiento de
  datos de entrenamiento y la carga de video son alcances distintos, y conceder uno NO DEBE
  conceder el otro.
- **FR-024**: Un nadador que declara ser mayor de edad consiente por sí mismo y NO DEBE
  requerir acudiente.
- **FR-025**: El sistema DEBE distinguir los perfiles de prueba de las personas reales, de
  modo que un perfil de prueba nunca cuente como un nadador con consentimiento.

#### Acceso a los datos

- **FR-026**: Las reglas de acceso DEBEN denegar por omisión. El acceso se concede
  explícitamente y se prueba con sus casos negativos (principios III y V).
- **FR-027**: Un nadador DEBE poder leer y escribir únicamente sus propios registros, y leer
  únicamente los planes que le estén publicados y asignados.
- **FR-028**: El entrenador DEBE poder leer los registros de los nadadores de su comunidad, y
  NO DEBE poder leer los de nadadores que no le pertenecen.
- **FR-029**: Sin sesión iniciada NO DEBE poderse leer ni escribir dato alguno de ningún
  nadador.
- **FR-030**: Los registros y la analítica NO DEBEN contener nombres, marcas, videos ni
  identificadores del nadador (principio V).

#### Persistencia

- **FR-031**: Los planes DEBEN sobrevivir al cierre de la app, conservando su estado, su
  versión de metodología sellada, sus microciclos, sus sesiones y sus nadadores asignados.
- **FR-032**: Guardar y recuperar un plan aprobado NO DEBE alterar su contenido.
- **FR-033**: Persistir un plan NO DEBE cambiar su estado. Un borrador guardado sigue siendo
  borrador.
- **FR-034**: La lectura de lo propio —planes del entrenador, planes y registros del
  nadador— NUNCA DEBE requerir red.
- **FR-035**: Los perfiles de nadador y las asignaciones de plan DEBEN persistir junto a los
  planes, de modo que la entrega sobreviva al cierre de la app.

#### Derechos del titular

- **FR-036**: El sistema DEBE poder mostrar qué datos guarda sobre un nadador, en términos
  comprensibles para su acudiente.
- **FR-037**: El sistema DEBE permitir exportar los datos de un nadador en un formato legible
  fuera de la app.
- **FR-038**: El sistema DEBE permitir eliminar los datos personales de un nadador sin que
  ello exija rediseñar el modelo de datos.
- **FR-039**: Eliminar los datos personales de un nadador NO DEBE destruir el trabajo
  profesional del entrenador, que debe poder subsistir sin ellos.
- **FR-040**: El acceso de un nadador a los datos que él mismo generó NUNCA DEBE quedar
  detrás de un muro de pago (principio VI).

### Key Entities

- **Cuenta**: la identidad con la que una persona entra. Es lo que permite decir «lo tuyo» y
  «lo ajeno», y sin ella ninguna regla de acceso significa nada.
- **Rol**: entrenador o nadador. Determina qué puede hacer cada quien, en particular quién
  aprueba y publica, que la constitución reserva al entrenador.
- **Acudiente**: quien otorga el consentimiento por un nadador menor de edad, con la calidad
  en que lo hace. Puede haber más de uno y puede no ser el padre ni la madre.
- **Solicitud de consentimiento**: el enlace de un solo uso enviado al canal que el entrenador
  aportó, con su vencimiento y su estado. Es el instrumento, distinto del consentimiento que
  produce.
- **Consentimiento**: el permiso otorgado, con su fecha de servidor, su alcance por
  tratamiento, la declaración de quien lo dio, la constancia de que el menor fue oído, la
  versión del texto informativo y su estado de vigencia o revocación. Es el título que
  ampara el tratamiento y la puerta de publicación del principio V.
- **Comunidad**: el conjunto de nadadores que pertenecen a un entrenador. Delimita qué
  registros puede leer y a quién puede publicar.
- **Plan persistido**: el plan del entrenador tal como queda guardado, con su estado, su
  versión de metodología, sus sesiones y sus asignaciones. Es el mismo plan de las features
  001 y 002; lo nuevo es que sobrevive al cierre de la app.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: **Ningún dato personal de un menor sin consentimiento vigente sale de su
  dispositivo**, comprobado anotando sesiones desde su cuenta y verificando que el
  entrenador no recibe nada y que no queda nada almacenado fuera.
- **SC-002**: Un nadador sin consentimiento **completa el recorrido de la app sin encontrar
  un solo bloqueo**: entra, lee lo que tiene y anota.
- **SC-003**: Otorgado el consentimiento, **el 100% de lo que estaba retenido llega** sin que
  el nadador repita nada.
- **SC-004**: Un plan no se publica a un nadador sin consentimiento vigente, comprobado en el
  100% de los intentos.
- **SC-005**: Un consentimiento registrado permite responder, **sin interpretar nada**, a
  cinco preguntas: quién lo otorgó, cuándo, sobre quién, para qué, y bajo qué texto.
- **SC-006**: Un enlace de confirmación usado una vez deja de servir, y uno no usado vence,
  comprobados los dos como casos negativos.
- **SC-007**: Las reglas de acceso impiden que un nadador lea o escriba datos de otro,
  comprobado con casos negativos para cada tipo de dato que la app almacena.
- **SC-008**: Sin sesión iniciada no se obtiene ningún dato de ningún nadador, comprobado con
  casos negativos.
- **SC-009**: Un plan aprobado conserva su contenido **byte a byte** al guardarse y
  recuperarse.
- **SC-010**: El entrenador cierra la app, vuelve a entrar y **recupera el 100% de sus
  planes** con su estado y sus asignaciones intactos.
- **SC-011**: Un nadador con sesión iniciada llega a su sesión del día **sin conexión**,
  igual que antes de esta feature: las cuentas no rompen el recorrido a pie de piscina.
- **SC-012**: Al cerrar sesión no queda en el dispositivo ningún dato del nadador anterior,
  comprobado inspeccionando el almacenamiento local.
- **SC-013**: Los datos de un nadador se exportan en un archivo legible y se eliminan a
  solicitud, sin modificar el modelo de datos para conseguirlo.
- **SC-014**: Eliminados los datos personales de un nadador, los planes del entrenador siguen
  siendo consultables.
- **SC-015**: Un consentimiento que no cubre video no habilita la carga de video, comprobado
  como caso negativo.
- **SC-016**: La categoría de un nadador no cambia al cambiar su edad ni su fecha de
  nacimiento, comprobado como prueba de que el sistema no la deriva.

## Assumptions

- **El consentimiento es demostrable, no infalsificable.** Ninguna confirmación digital
  prueba con certeza la identidad de quien la hace sin una verificación documental que esta
  feature no incluye. Lo que el mecanismo construye es una **cadena de evidencia**: el canal
  lo aporta el entrenador y no el menor, el enlace es de un solo uso, quien confirma declara
  bajo su responsabilidad, la fecha la pone el servidor y el acudiente recibe aviso de lo
  registrado. Eso es lo que permite demostrar diligencia.
- **El consentimiento no exime de responsabilidad.** Bajo la Ley 1581 el entrenador es el
  Responsable del Tratamiento, y ese papel no se transfiere con una autorización. Lo que el
  consentimiento aporta es la **base legal** del tratamiento y la prueba de que existió. Esta
  especificación no sustituye asesoría jurídica.
- **El menor debe ser oído.** El Decreto 1377 de 2013 exige que el tratamiento de datos de
  niñas, niños y adolescentes responda a su interés superior y que la autorización del
  representante legal se obtenga **después de que el menor ejerza su derecho a ser
  escuchado**. Por eso FR-021 existe. Conviene que un abogado lo confirme antes de desplegar.
- **Un solo entrenador.** La constitución describe «una comunidad dirigida por un
  entrenador». Varios entrenadores conviviendo son una feature posterior, y el modelo de
  datos no debe impedirla.
- **El trabajo del entrenador no es dato personal del nadador.** Un microciclo es su obra
  profesional. Por eso puede generarlo, auditarlo, aprobarlo y guardarlo antes de tener
  consentimientos; lo que la puerta bloquea es publicárselo a una persona.
- **La revocación detiene el tratamiento hacia adelante** y abre la vía de eliminación; no
  borra el hecho registrado de que hubo consentimiento previo, porque ese registro es la
  prueba de que el tratamiento anterior estuvo amparado.
- **La retención del envío reutiliza la bandeja de salida de la feature 003.** El mecanismo
  ya existe y ya garantiza que nada se pierde en silencio; lo que esta feature añade es una
  condición más para que un registro salga.
- **La interfaz va en español**, incluido el texto informativo del consentimiento. Lo leen
  acudientes colombianos.
- **El dominio sigue en Dart puro.** Cuentas, roles y consentimiento se expresan como
  entidades y reglas del dominio; la identidad concreta vive en la capa externa.
- **La carga de video no entra en esta feature**, pero su alcance de consentimiento sí se
  modela, porque el principio V exige que sea específico y separado, y descubrirlo después
  obligaría a volver a pedirlo.

## Dependencies

- **Feature 001**: ciclo de vida del plan, perfiles de nadador, asignación y exportación.
- **Feature 002**: el generador que produce los planes que ahora persisten.
- **Feature 003**: el recorrido del nadador y su bandeja de salida, que esta feature pone
  detrás de una cuenta sin romper su funcionamiento sin conexión.
- **Metodología 3.6.0**: la sección 11.1 es la que establece que la categoría se determina
  por habilidades y no por edad, de donde sale FR-007.
- **Despliegue**: esta feature es la que lo desbloquea. La verificación manual pendiente de
  la feature 003 —escenarios C1 y C2 en un dispositivo real con el modo avión puesto, tarea
  T071— se cierra cuando haya dónde desplegar.

## Out of Scope

- **Carga de video y retroalimentación en video.** Solo se modela su alcance de
  consentimiento.
- **Verificación documental de identidad** del acudiente. Queda fuera deliberadamente: ver la
  primera suposición.
- **La auditoría de discrepancia de categoría** que la metodología 3.6.0 ahora permite. Es su
  propia feature.
- **Suscripciones, pagos y muro de pago.**
- **Comunidad, mensajería y notificaciones** más allá del aviso de consentimiento registrado.
- **Varios entrenadores** en el mismo sistema.
- **Inicio de sesión con proveedores externos de identidad.**
