---

description: "Lista de tareas de la feature 003 — el nadador consume su plan"
---

# Tasks: El nadador consume su plan

**Input**: documentos de diseño de `specs/003-consumo-del-nadador/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/](contracts/)

**Tests**: **sí, y no son opcionales.** El principio III de la constitución es «NO
NEGOCIABLE» para las reglas que llegan al nadador, y las puertas de calidad exigen
`flutter test` en verde y las pruebas de reglas en el emulador antes de cerrar la feature.

**Organization**: las tareas se agrupan por historia de usuario para que cada una se pueda
implementar y probar por separado.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: se puede hacer en paralelo (archivos distintos, sin dependencias pendientes)
- **[Story]**: a qué historia pertenece (US1, US2, US3, US4)

---

## Phase 1: Setup

**Purpose**: dejar el terreno listo. Nada de esto se ve en la app.

- [X] T001 Elegir la dependencia de persistencia local comparando al menos tres opciones que funcionen **en web y en móvil**, y registrar la decisión con sus alternativas rechazadas en `specs/003-consumo-del-nadador/research.md` como D7. Criterio: que no arrastre un esquema que mantener ni migraciones que escribir (principio VII)
- [X] T002 Añadir la dependencia elegida a `pubspec.yaml` y comprobar que `flutter build web --release` sigue compilando
- [X] T003 [P] Crear las carpetas nuevas con un archivo `library;` de marcador: `lib/dominio/sincronizacion/`, `lib/datos/local/`, `lib/datos/red/`, `lib/ui/nadador/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: lo que toda historia necesita. Sin esto no empieza ninguna.

**⚠️ CRITICAL**: ninguna historia puede empezar hasta que esta fase esté completa.

- [X] T004 Activar la persistencia de lectura de Firestore en `lib/datos/firestore/configuracion.dart`. Hoy está en `persistenceEnabled: false` para los emuladores; debe quedar activada también ahí, porque si no el escenario C1 del quickstart no se puede verificar en local (decisión D1)
- [X] T005 [P] Escribir en `test/datos/persistencia_lectura_test.dart` la prueba de que la configuración declara la persistencia activada, para que nadie la desactive sin que falle algo
- [ ] T006 Implementar la selección de perfil activo de nadador en `lib/ui/nadador/perfil_activo.dart`, eligiendo entre los perfiles que `RepositorioNadadores` ya guarda desde la feature 001. **Sin autenticación**: es la decisión D4, y las cuentas son la feature 004
  - **Estuvo marcada como hecha sin estarlo.** Se destapó al pedir el despliegue
    para T071. `EstadoNadador.abrirComo` es el único método que entrega un plan
    al nadador, y **no se llama desde ningún sitio de `lib/`**: en la app que
    corre, la pestaña del nadador dice siempre «todavía no tienes un plan
    asignado». Las pruebas pasan porque le inyectan el plan directamente; lo que
    falta es el camino por el que llega en la app real.
  - **Qué falta exactamente:** el selector de perfil, y el camino por el que un
    plan publicado llega al nadador. Hoy tampoco hay forma de aprobar ni publicar
    desde la app: `PantallaPlan` no está en la navegación, así que el ciclo
    `borrador → aprobado → publicado` no se puede recorrer a mano.
  - **No se arregla a medias.** Cablear el perfil sin que exista un plan
    publicado que entregarle dejaría la misma pantalla vacía con más código
    detrás.
- [X] T007 Añadir a `lib/dominio/repositorios/repositorios.dart` las interfaces `RepositorioRegistros` y `BandejaDeSalida` con las firmas de `data-model.md`. **Ninguna firma menciona tipos de Firestore**
- [X] T008 Añadir la colección `registros` a `firebase/firestore.rules`, **denegando por omisión** y permitiendo solo el rol de entrenador, como el resto de colecciones. La regla por nadador es de la feature 004 (desviación declarada en `plan.md`)
- [X] T009 Añadir a `firebase/test/reglas.test.js` los casos negativos de la colección nueva: sin rol no se lee y no se escribe. **Casos negativos, no solo el feliz** (principio III)
- [X] T010 [P] Crear `lib/datos/local/almacen_local.dart` con la interfaz de guardado en el dispositivo y su implementación sobre la dependencia elegida en T001
- [X] T011 [P] Escribir en `test/datos/almacen_local_test.dart` las pruebas de que lo guardado sobrevive a una reapertura del almacén

**Checkpoint**: la base está lista. Las historias pueden empezar.

---

## Phase 3: User Story 1 — El nadador ve lo que le toca hoy (P1) 🎯 MVP

**Goal**: el nadador abre la app a pie de piscina, sin señal, y ve su sesión del día
completa.

**Independent Test**: asignar un plan publicado a un perfil de prueba, abrir la app con el
dispositivo en modo avión y comprobar que la sesión del día aparece completa y legible
(escenario C1 de `quickstart.md`).

### Tests for User Story 1

> Escribir estas pruebas **primero** y comprobar que fallan antes de implementar.

- [X] T012 [P] [US1] Escribir en `test/dominio/calculo/sesion_del_dia_test.dart` las pruebas de qué sesión corresponde a una fecha: la de hoy si la hay, la siguiente si no, y nada si el plan terminó
- [X] T013 [P] [US1] Escribir en `test/datos/planes_del_nadador_test.dart` la prueba de que solo se devuelven planes en estado `publicado` asignados al nadador, y de que un `borrador` o un `aprobado` **no aparecen** (FR-001)
- [X] T014 [P] [US1] Escribir en `test/ui/nadador/sesion_del_dia_test.dart` el recorrido de lectura **sin conexión**, con el repositorio simulando que la red no responde

### Implementation for User Story 1

- [X] T015 [US1] Implementar en `lib/dominio/calculo/sesion_del_dia.dart` la selección de la sesión que corresponde a una fecha, devolviendo también cuál es la siguiente y cuándo, para que no haya pantalla vacía (FR-002)
- [X] T016 [US1] Ampliar `lib/datos/firestore/repositorios_firestore.dart` con la consulta de planes publicados asignados a un nadador (FR-001)
- [X] T017 [US1] Implementar `lib/ui/nadador/pantalla_sesion_del_dia.dart`: objetivo técnico, objetivo fisiológico y las tres partes con sus series (FR-003)
- [X] T018 [US1] Mostrar las series **con la notación del entrenador y los nombres exactos de la Biblioteca**, sin abreviar, reescribir ni corregir (FR-004). Reutilizar el renderizador de la feature 002, no escribir otro
- [X] T019 [US1] Añadir la vista del plan completo en `lib/ui/nadador/pantalla_mi_plan.dart`, para cuando el nadador quiere ver más allá de hoy
- [X] T020 [US1] Mostrar **cuándo se sincronizó por última vez**, para que el nadador sepa si lo que lee está al día. Sale de la decisión D1 y la especificación no lo pedía: la lectura sin conexión solo cubre lo ya descargado
- [X] T021 [US1] Manejar los casos límite de pantalla: sin plan asignado, plan sin sesiones, y sesión sin series. **Ninguno debe dar error**, los tres dicen lo que pasa
- [X] T022 [US1] Añadir la navegación del nadador a `lib/main.dart`, separada de la del entrenador

**Checkpoint**: el nadador ve su plan sin señal. **Es el MVP**: entregado solo, el plan deja de vivir en una hoja del entrenador.

---

## Phase 4: User Story 2 — El nadador responde y el entrenador lo lee (P1)

**Goal**: el nadador marca la sesión, anota su RPE y sus observaciones, y el entrenador lo
lee junto al plan que lo originó.

**Independent Test**: con un perfil de prueba, marcar una sesión y anotar RPE y
observaciones, y comprobar que el entrenador las ve asociadas a esa sesión concreta
(escenarios C3 y C5 de `quickstart.md`).

**Nota de alcance**: en esta historia el registro se guarda **en local**. Que viaje al
servidor es la historia 3. Así cada una se prueba sola y el camino de escritura no se
construye dos veces.

### Tests for User Story 2

- [X] T023 [P] [US2] Escribir en `test/dominio/entidades/registro_sesion_test.dart` las pruebas de las invariantes: **RPE entero de 0 a 10**, fuera de rango no construye (escenario R1); **RPE ausente es válido** (R2); `realizada: false` con observaciones es válido (R3)
- [X] T024 [P] [US2] Escribir en el mismo archivo la prueba de que el identificador es **determinista**: mismo `(nadadorId, planId, sesionId, versionDePlan)` da el mismo `id` (decisión D2, FR-020)
- [X] T025 [P] [US2] Escribir en `test/dominio/entidades/plan_inmutable_test.dart` la prueba de que **registrar respuestas no cambia el plan**: serializar el plan aprobado antes y después y comparar (SC-007, escenario C4)
- [X] T026 [P] [US2] Escribir en `test/dominio/entidades/registro_sesion_test.dart` la prueba de que las observaciones se guardan **tal cual**: mayúsculas, acentos, saltos de línea y texto largo (R4)
- [X] T027 [P] [US2] Escribir en `test/ui/nadador/formulario_registro_test.dart` la prueba de que un nadador que **no anota nada** completa el recorrido sin un solo bloqueo (FR-010, escenario C7)

### Implementation for User Story 2

- [X] T028 [P] [US2] Crear `lib/dominio/entidades/registro_sesion.dart` con `RegistroDeSesion`: `id` determinista, `nadadorId`, `planId`, `sesionId`, `versionDePlan`, `realizada`, `registradoEn`, `rpePercibido` (nullable, **0 a 10**), `observaciones` y `molestia` (nullable). **Sin metros, series ni zonas**: eso es carga externa y vive en el plan
- [X] T029 [P] [US2] Crear en el mismo archivo `ReporteDeMolestia` con `descripcion` y `zonaDelCuerpo`, los dos de texto libre. **No se ofrece lista cerrada** de zonas del cuerpo
- [X] T030 [US2] Ampliar `lib/datos/serializacion.dart` con el registro y el reporte de molestia, y ampliar `test/datos/serializacion_test.dart` con su viaje de ida y vuelta
- [X] T031 [US2] Implementar `lib/datos/local/repositorio_registros_local.dart`: guardar **primero en local**, que es lo que permite que escribir nunca falle por falta de red
- [X] T032 [US2] Implementar `lib/ui/nadador/formulario_registro.dart`: marcar como realizada, deslizador de RPE 0-10 y campo de observaciones. **Solo `realizada` es obligatorio**
- [X] T033 [US2] Añadir al formulario el campo de molestia, **visiblemente separado** de las observaciones generales (FR-009). La app no sugiere nada, no clasifica gravedad y no cambia el plan (principio IV)
- [X] T034 [US2] Mostrar en la pantalla del entrenador, sobre cada sesión, lo que el nadador respondió (FR-013). **Junto al plan que lo originó**, no en otra pantalla: un registro que nadie lee no es control
- [X] T035 [US2] Separar visualmente en esa pantalla la **carga externa** (metros, series, pausas, ritmos) de la **carga interna** (realizada, RPE, observaciones). **Nunca combinadas en un mismo indicador** (FR-014, principio VIII)
- [X] T036 [US2] Señalar los reportes de molestia de forma distinguible y hacerlos localizables **sin abrir las sesiones una por una** (FR-015, SC-006, escenario C5)
- [X] T037 [US2] Registrar en cada registro la **versión de plan** bajo la que el nadador entrenó, para que un plan corregido no haga parecer que respondió a series que nunca hizo (FR-012, escenario V10)

**Checkpoint**: el ciclo de control está cerrado. El nadador responde y el entrenador lo lee.

---

## Phase 5: User Story 3 — A pie de piscina no hay señal (P1)

**Goal**: lo que el nadador escribe sin conexión se guarda, se lo decimos, y viaja solo
cuando vuelve la red.

**Independent Test**: en modo avión marcar una sesión y anotar, cerrar la app, restablecer
la red y comprobar que el registro llegó sin que nadie tocara nada (escenario C2).

**Esta es la historia que hace que la 2 funcione donde de verdad ocurre.** Contrato completo
en [contracts/sincronizacion.md](contracts/sincronizacion.md).

### Tests for User Story 3

> Las ocho garantías del contrato, en Dart puro, con red y reloj simulados. Esa es la razón
> por la que no se delegó en la cola interna de Firestore (decisión D1).

- [X] T038 [P] [US3] Escribir en `test/dominio/sincronizacion/bandeja_salida_test.dart` la garantía **S1**: guardar sin red da éxito, deja el registro en local y en estado `pendiente`
- [X] T039 [P] [US3] Escribir la garantía **S2**: vuelve la red y el pendiente se envía solo, sin intervención
- [X] T040 [P] [US3] Escribir la garantía **S3**: lo pendiente sobrevive a cerrar y reabrir (FR-021)
- [X] T041 [P] [US3] Escribir la garantía **S4**: tres fallos seguidos y luego éxito dejan **un solo documento** en destino y tres intentos contados
- [X] T042 [P] [US3] Escribir la garantía **S5**: enviar dos veces el mismo registro no duplica (FR-020, escenario C6)
- [X] T043 [P] [US3] Escribir la garantía **S6**: de tres pendientes llegan dos, y el estado resultante es dos `enviado` y uno `pendiente`, sin estados intermedios raros
- [X] T044 [P] [US3] Escribir la garantía **S7**: con red disponible el registro llega directo y el nadador **nunca ve el aviso**
- [X] T045 [P] [US3] Escribir la garantía **S8**: un fallo al escribir **en local** sí se reporta, porque ahí el dato sí se perdería
- [X] T046 [P] [US3] Escribir en el mismo archivo la prueba de que **no existe estado terminal de fallo**: un registro con cuarenta intentos sigue en `pendiente`, nunca descartado (FR-019)

### Implementation for User Story 3

- [X] T047 [P] [US3] Crear `lib/dominio/entidades/envio_pendiente.dart` con `EnvioPendiente` (`registroId`, `estado`, `intentos`, `ultimoIntento`, `ultimoError`) y `EstadoDeEnvio` con **solo tres valores**: `pendiente`, `enviando`, `enviado`. **Sin `fallido`**: sería la forma en que los datos se pierden en silencio
- [X] T048 [US3] Implementar `lib/dominio/sincronizacion/bandeja_salida.dart` en **Dart puro**, con la máquina de estados y la política de reintentos. No sabe qué hay debajo: ni Firestore, ni cómo se detecta la red, ni dónde se guarda
- [X] T049 [US3] Implementar los reintentos **espaciados de forma creciente**, nunca en bucle apretado: el teléfono es de alguien que está nadando y tiene batería limitada
- [X] T050 [US3] Implementar `lib/datos/local/bandeja_salida_local.dart`, que persiste lo pendiente sobre el almacén de T010
- [X] T051 [US3] Implementar `lib/datos/red/estado_de_red.dart` para detectar que la red vuelve, detrás de una interfaz del dominio para que la bandeja no la conozca
- [X] T052 [US3] Implementar `lib/datos/firestore/repositorio_registros.dart` como destino del envío, con el identificador determinista como id del documento
- [X] T053 [US3] Conectar los tres disparadores de envío: al guardar, al volver la red y al abrir la app
- [X] T054 [US3] Implementar `lib/ui/nadador/aviso_sincronizacion.dart` con el texto **«Guardado el progreso, se enviará cuando tengas acceso a internet»** (FR-017). Se muestra con pendientes y desaparece sin ellos
- [X] T055 [US3] Comprobar que al nadador **nunca** se le muestra un error de red, un código de estado, un contador de reintentos ni un botón de «reintentar». El reintento es trabajo de la app
- [X] T056 [US3] Guardar en cada registro las **dos** marcas de tiempo: `registradoEn` del dispositivo y `recibidoEn` del servidor (decisión D3). Si difieren de forma absurda se muestra; **no se corrige** (regla R3)

**Checkpoint**: las ocho garantías del contrato se cumplen. La feature funciona donde se usa.

---

## Phase 6: User Story 4 — El nadador se lleva una copia (P3)

**Goal**: descargar el plan para archivarlo o imprimirlo.

**Independent Test**: descargar el plan de un perfil de prueba y comprobar que el archivo se
lee sin la app y coincide con lo que la pantalla muestra (escenario V12).

**Nota de prioridad**: es lo último a propósito. La constitución dice que la descarga «es
una copia para archivo o impresión, **no el producto**».

### Tests for User Story 4

- [X] T057 [P] [US4] Escribir en `test/datos/exportacion_test.dart` la prueba de que la descarga del nadador incluye sus registros junto al plan, y de que su contenido coincide con el del plan en pantalla

### Implementation for User Story 4

- [X] T058 [US4] Ampliar `lib/datos/exportacion.dart` con la variante para el nadador: el plan con sus sesiones más los registros propios (decisión D5). **Reutilizar el formato existente**, no inventar uno nuevo
- [X] T059 [US4] Añadir la acción de descarga a la pantalla del nadador

**Checkpoint**: las cuatro historias funcionan.

---

## Phase 7: Progreso y adherencia

**Purpose**: lo que el entrenador eligió en la aclaración de la especificación: historial de
sesiones más adherencia como recuento, sin gráficas.

- [X] T060 [P] Escribir en `test/dominio/calculo/progreso_nadador_test.dart` la prueba del historial: las sesiones del plan con su registro si lo hay, **de la más reciente a la más antigua** (FR-005a)
- [X] T061 [P] Escribir la prueba de la adherencia: cuatro de seis sesiones realizadas dan «4 de 6», por semana y en el plan (FR-005b, escenario V8)
- [X] T062 [P] Escribir la prueba de que **el recuento no cambia al variar el RPE ni los metros** (SC-011). Parece trivial y no lo es: impide que alguien «mejore» el indicador más adelante sin notar que rompe el principio VIII
- [X] T063 Implementar `lib/dominio/calculo/progreso_nadador.dart` en Dart puro: historial y adherencia. **Cuenta sesiones y nada más** (decisión D6, FR-005c)
- [X] T064 Implementar `lib/ui/nadador/pantalla_mi_progreso.dart`, que **funciona sin conexión** como todo lo demás que el nadador lee (FR-005)

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T065 Comprobar que `lib/dominio/` sigue sin importar Flutter ni Firebase: `flutter test test/dominio/arquitectura_test.dart`. Las carpetas nuevas `sincronizacion/` y las entidades nuevas entran en esa frontera (principio II)
- [X] T066 [P] Comprobar que **ni los registros ni la analítica contienen** nombres, marcas, videos ni identificadores de nadador (FR-023, principio V), con una prueba que recorra lo que se escribe
- [X] T067 [P] Implementar la exportación y el borrado de los registros de un nadador (FR-024), y probar que el modelo lo permite sin rediseño
- [X] T068 [P] Comprobar que acceder a lo que el nadador generó **no queda tras ningún muro de pago** (FR-026, principio VI)
- [X] T069 Recorrer los escenarios **C1 a C7** de `quickstart.md` y registrar el resultado de cada uno. Son los que no pueden fallar
- [X] T070 Recorrer los escenarios **V8 a V12** de `quickstart.md` y registrar el resultado
- [ ] T071 **Verificación manual de C1 y C2 en un dispositivo real con el modo avión puesto.** El emulador de red no es lo mismo que una piscina, y esta puerta no se salta
- [X] T072 Comprobar que `flutter analyze` termina limpio y que `flutter build web --release` compila
- [X] T073 Comprobar que `npm --prefix firebase test` pasa, con los casos negativos nuevos
- [X] T074 [P] Actualizar `docs/DEVELOPMENT.md` con lo que el nadador puede hacer y cómo se prueba el funcionamiento sin conexión
- [X] T075 Registrar en este archivo el estado de cierre: qué se hizo, qué defectos aparecieron y qué queda pendiente del entrenador

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Fase 1)**: sin dependencias
- **Foundational (Fase 2)**: depende de Setup. **Bloquea todas las historias**
- **US1 (Fase 3)**: depende de Foundational. Es el MVP
- **US2 (Fase 4)**: depende de Foundational. Independiente de US1, aunque se vea mejor con ella
- **US3 (Fase 5)**: depende de Foundational y de US2, porque sincroniza lo que US2 escribe
- **US4 (Fase 6)**: depende de Foundational y de US1
- **Progreso (Fase 7)**: depende de US2, porque agrega los registros que US2 crea
- **Polish (Fase 8)**: depende de las historias que se quieran cerrar

### Dependencia crítica

T001 (elegir la dependencia local) → T010 (almacén) → T031 y T050 (lo que guarda registros y
bandeja). **Si el almacén local no persiste de verdad entre reaperturas, la feature no
cumple su promesa**, y las ocho garantías del contrato se apoyan en él.

### Within Each User Story

- Las pruebas se escriben primero y deben fallar antes de implementar
- Entidades antes que repositorios, repositorios antes que pantallas
- En US3: las ocho garantías (T038-T046) antes que la bandeja (T048)

### Parallel Opportunities

- T003, T005, T010 y T011 en la fase foundational
- Las tres pruebas de US1 (T012-T014) entre sí
- Las cinco pruebas de US2 (T023-T027) entre sí
- **Las nueve pruebas de US3 (T038-T046) entre sí**: es el bloque paralelo más grande
- T028 y T029 entre sí
- Las tres pruebas de progreso (T060-T062) entre sí
- T066, T067, T068 y T074 en el cierre

---

## Parallel Example: User Story 3

```bash
# Las nueve garantías del contrato, todas en el mismo archivo de pruebas pero
# independientes entre sí:
Task: "S1 — guardar sin red da éxito y deja pendiente"
Task: "S2 — vuelve la red y se envía solo"
Task: "S3 — lo pendiente sobrevive al cierre"
Task: "S4 — tres fallos y luego éxito dejan un solo documento"
Task: "S5 — reenviar no duplica"
Task: "S6 — de tres llegan dos, estado correcto"
Task: "S7 — con red el aviso nunca aparece"
Task: "S8 — fallo al escribir en local sí se reporta"
Task: "Sin estado terminal de fallo"
```

---

## Implementation Strategy

### MVP primero (solo US1)

1. Fase 1: Setup
2. Fase 2: Foundational (**crítica, bloquea todo**)
3. Fase 3: US1
4. **Parar y validar**: escenario C1 en un dispositivo real, en modo avión
5. Es entregable: el plan deja de vivir en una hoja del entrenador

### Entrega incremental

1. Setup + Foundational → base lista
2. US1 → el nadador ve su plan sin señal → **MVP**
3. US2 → responde y el entrenador lo lee → el ciclo de control se cierra
4. US3 → funciona a pie de piscina → la feature sirve donde se usa
5. Fase 7 → progreso y adherencia
6. US4 → la copia para archivo

**Las tres primeras son P1 y conviene no separarlas en el tiempo.** US1 sola es un MVP
honesto, pero US2 sin US3 es un ciclo de control que solo funciona donde hay señal, y la
señal es justo lo que no hay.

---

## Notes

- `[P]` = archivos distintos, sin dependencias pendientes
- Comprobar que cada prueba falla antes de implementar lo que la hace pasar
- Commit por tarea o por grupo lógico, **en inglés** (constitución 1.2.0)
- **T071 no se salta.** Verificar sin conexión en un emulador no es verificarlo
- **Ningún nadador real participa en ninguna tarea de esta feature.** Perfiles de prueba o
  el entrenador como nadador, hasta que exista la feature 004: el grupo de Iniciación
  Avanzada son niños de 7 a 10 años y el consentimiento es puerta de publicación

---

## Estado de cierre (2026-10-14)

**73 de 75 tareas completadas.** Quedan dos, y están encadenadas.

- **T006 — el perfil activo no está cableado.** Estuvo marcada como hecha sin
  estarlo. Se destapó al preparar el despliegue para T071: `abrirComo` no se
  llama desde ningún sitio, así que en la app que corre el nadador nunca recibe
  un plan.
- **T071 — verificación en dispositivo real.** No se puede hacer hasta que T006
  esté resuelta y haya dónde desplegar.

### Por qué el despliegue no se hizo (2026-10-14)

El entrenador pidió desplegar en Firebase para poder verificar T071 en su
teléfono. **No se desplegó**, y conviene que la razón quede escrita porque no es
una sola:

1. **El nadador no recibe plan** (T006, arriba). Un despliegue hoy daría una
   pestaña que dice siempre «no tienes un plan asignado».
2. **Firestore denegaría todo.** `esEntrenador()` exige
   `request.auth.token.rol == 'entrenador'` y **no hay autenticación**: es la
   feature 004. No se relajó la regla, porque el propio archivo advierte que
   «una regla abierta puesta para salir del paso es exactamente lo que se queda
   puesto».
3. **No hay proyecto de Firebase real.** Falta `firebase_options.dart` y el
   bloque de *hosting* en `firebase.json`. Crearlo exige la cuenta del
   entrenador.

**Y una parte de C2 no se puede verificar hasta la 004**: «comprueba que el
registro llegó» necesita un servidor que acepte la escritura.

Un detalle técnico que conviene no olvidar cuando llegue el momento: los
navegadores solo registran *service workers* sobre **HTTPS o localhost**. Servir
el build por la red local en `http://192.168.x.x` no sobreviviría a cerrar la app
en modo avión, así que Firebase Hosting no es un capricho: es lo que hace que el
caché sin conexión funcione de verdad.

**Decisión del entrenador**: no desplegar en estas circunstancias. T071 queda
pendiente para cuando todo esté en su punto.

| Puerta | Resultado |
|---|---|
| `flutter test` | **800 en verde** (eran 705) |
| `npm --prefix firebase test` | **21 en verde**, 0 fallos (eran 15) |
| `flutter analyze` | Sin incidencias |
| `flutter build web --release` | Compila |
| `dart run tool/verificar_metodologia.dart` | Las dos huellas coinciden |

### Escenarios del quickstart

| | Escenario | Cómo quedó |
|---|---|---|
| **C1** | La sesión del día, sin señal | ✅ Prueba de interfaz con la red caída, más los casos de sin plan y de día de descanso |
| **C2** | Anotar sin conexión, y que llegue | ✅ Prueba de interfaz: el aviso aparece, el registro queda guardado y al volver la red se envía solo |
| **C3** | El entrenador lo lee donde tiene que leerlo | ✅ `RespuestasDelNadador` lo muestra sobre la sesión, con carga externa e interna en columnas separadas |
| **C4** | El plan no se mueve | ✅ `plan_inmutable_test.dart` compara el plan serializado antes y después |
| **C5** | La molestia se ve | ✅ Se lista aparte y arriba; probado en dominio y en interfaz |
| **C6** | Reenviar no duplica | ✅ Probado en la bandeja y en las reglas de acceso |
| **C7** | Quien no anota, no se bloquea | ✅ Prueba de interfaz del recorrido completo sin registrar nada |
| **V8** | Adherencia | ✅ Incluye la prueba de que el recuento **no cambia** al variar el RPE ni los metros |
| **V9** | Las fechas no se fuerzan | ✅ La fecha de la sesión y la del registro son campos distintos |
| **V10** | Las versiones no se confunden | ✅ El registro apunta a la versión bajo la que se entrenó |
| **V11** | Las reglas deniegan | ✅ Seis casos negativos nuevos |
| **V12** | Descarga | ✅ `paraElNadador` reutiliza el formato existente |
| **T071** | **Dispositivo real, modo avión** | ⏳ **Pendiente**: necesita T006 y un despliegue |

### Dos correcciones de casillas marcadas sin trabajo detrás

Marqué T025 como hecha antes de escribir su archivo. Al recorrer los escenarios
me di cuenta y escribí `plan_inmutable_test.dart` de verdad, en lugar de dejar una
casilla marcada sin respaldo.

Y T006 estuvo marcada sin estarlo hasta que el entrenador pidió desplegar: esa no
la encontré yo, la destapó él al pedir algo que la usaba de verdad. Las dos quedan
anotadas porque una lista de tareas en la que una casilla puede estar marcada sin
trabajo detrás no sirve para nada, y porque la segunda demuestra que mi propia
revisión no bastó.

### Lo que quedó fuera a propósito

- **Cuentas, roles y consentimiento verificable**: es la feature 004, y es
  **bloqueante para el uso real**. Ningún nadador real usa esta feature hasta
  entonces: el grupo de Iniciación Avanzada son niños de 7 a 10 años.
- Las reglas de acceso **no distinguen a un nadador de otro**, por lo mismo. Es la
  desviación declarada en `plan.md`, con su contención y su fecha de caducidad.
- Carga de video, comunidad, notificaciones y cobro.
- Reajuste automático del plan a partir de lo que el nadador reporta: el
  principio IV lo prohíbe.

### Decisión tomada durante la implementación

**D7, dónde se guarda lo local.** Se eligió `shared_preferences` frente a cuatro
alternativas, con el criterio de T001: web y móvil, sin esquema ni migraciones. Su
límite —unos 5 MB de `localStorage` en web— queda escrito junto con cuándo
revisarlo, y el cambio queda contenido porque `AlmacenLocal` es una interfaz.
