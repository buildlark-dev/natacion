---
description: "Lista de tareas de la feature 001 — Editor de planes con auditoría metodológica"
---

# Tasks: Editor de Planes con Auditoría Metodológica

**Input**: Documentos de diseño en `/specs/001-editor-planes-auditoria/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: OBLIGATORIOS. El principio III de la constitución los declara no negociables, y
la spec exige una prueba por criterio de auditoría que demuestre que detecta su violación.
Las pruebas se escriben ANTES de la implementación y deben fallar primero.

**Organization**: agrupadas por historia de usuario, para que cada una se pueda implementar,
probar y dar por terminada por separado.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: se puede hacer en paralelo (archivos distintos, sin dependencias pendientes)
- **[Story]**: a qué historia de usuario pertenece (US1, US2, US3, US4)

## Path Conventions

Proyecto Flutter único. `lib/dominio/` es Dart puro sin Flutter ni Firebase; `lib/datos/`
implementa el acceso a datos; `lib/ui/` es la interfaz. `firebase/` contiene configuración
de emuladores y pruebas de reglas en Node.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: dejar el proyecto listo para trabajar, con el prototipo actual retirado.

- [X] T001 Añadir dependencias `provider`, `firebase_core` y `cloud_firestore` a `pubspec.yaml`, y declarar `assets/biblioteca/` en la sección `flutter: assets:`
- [X] T002 Crear el árbol de carpetas de `lib/dominio/{entidades,notacion,biblioteca,calculo,auditoria,metodologia,repositorios}`, `lib/datos/{firestore,recursos}`, `lib/ui/{editor,planes,nadadores}` y `test/{dominio,datos,ui}` según la estructura de `plan.md`
- [X] T003 Reemplazar el prototipo de `lib/main.dart` (clase `MiApp`, `Nadador` con `tiempo100m` y `generarPlanIA` simulado) por un arranque mínimo que monte la app y lea la bandera `USAR_EMULADORES`
- [X] T004 [P] Crear `firebase/firebase.json` con el emulador de Firestore configurado para el proyecto ficticio `demo-natacion`, y `firebase/firestore.indexes.json` vacío
- [X] T005 [P] Crear `firebase/package.json` con `@firebase/rules-unit-testing` y un script `test`, y `firebase/.gitignore` para `node_modules`
- [X] T006 [P] Endurecer `analysis_options.yaml` para que las advertencias del analizador no pasen desapercibidas, conforme al principio VII

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: las reglas de la metodología, las entidades y el acceso a datos que todas las
historias necesitan.

**⚠️ CRÍTICO**: ninguna historia de usuario puede empezar antes de terminar esta fase.

- [X] T007 Crear `docs/metodologia/metodologia.json` declarando `version: "3.4"`, fecha y huella SHA-256 de `PROMPT_MAESTRO_V3.4.md` y de `Biblioteca de ejercicios.docx`, según la decisión D4 de `research.md`
- [X] T008 Escribir un script de extracción de la sección 19 de `docs/metodologia/PROMPT_MAESTRO_V3.4.md` que genere `assets/biblioteca/ejercicios.json` con los campos `nombre`, `estilo`, `descripcion`, `errorQueCorrige` y `requiereDesambiguacion`
- [X] T009 Revisar a mano el resultado de T008 con el entrenador: confirmar el conteo de ejercicios por estilo y marcar los nombres que se repiten entre estilos (`FLECHA`, `ROLIDO`, `ROLIDO CON 1 BRAZO`) con `requiereDesambiguacion: true`. **Un ejercicio mal transcrito es una regla mal aplicada**
- [X] T010 [P] Implementar las constantes de categoría en `lib/dominio/metodologia/categorias.dart`: Iniciación 500–800 m / 2 sesiones / sin ATR; Tecnificación 800–1000 m / 2 / sin ATR; Precompetitivo 1800–2200 m / 3 / con ATR; Competitivo 4000–5000 m / 5 / con ATR; Alto Rendimiento 5000–6000 m / 10 / con ATR
- [X] T011 [P] Implementar las seis zonas en `lib/dominio/metodologia/zonas.dart` con bandas contiguas y sin solapamiento: A1 60–70%, A2 70–80%, A3 80–85%, AT 85–92%, Máx 92%+, Velocidad (controlada por ritmo, no por frecuencia cardíaca)
- [X] T012 [P] Implementar las distribuciones de fase ATR en `lib/dominio/metodologia/fases_atr.dart`: Acumulación A1 60 / A2 25 / A3 10 / AT 5, técnico 50%; Transformación A1 30 / A2 35 / A3 15 / AT 15 / Máx 5, técnico 30%; Realización A1 25 / A2 25 / A3 15 / AT 10 / Máx 15 / Velocidad 10, técnico 20%
- [X] T013 [P] Implementar en `lib/dominio/metodologia/estilos.dart` el reparto por estilo objetivo: Libre 80–85% Libre y 15–20% Espalda; Pecho 50% Pecho y 50% Libre/Espalda; Mariposa 50% Mariposa y 50% Libre/Espalda; y el reparto de sesión inicial 40% / central 50% (pre-set 10% + principal 40%) / final 10%
- [X] T014 Escribir la prueba de frontera del dominio en `test/dominio/arquitectura_test.dart`: recorre `lib/dominio/` y falla si algún archivo importa `package:flutter/`, `package:cloud_firestore/` o `package:firebase_core/` (principio II, decisión D9)
- [X] T015 [P] Escribir pruebas de las constantes en `test/dominio/metodologia/` que verifiquen los invariantes: cada fila de fase ATR suma exactamente 100%, las bandas de zona son contiguas y no se solapan, y las categorías sin ATR están marcadas como tales
- [X] T016 Crear las entidades del dominio en `lib/dominio/entidades/`: `Plan`, `Microciclo`, `Sesion`, `Parte`, `Serie`, `Nadador`, `Ejercicio`, `FragmentoPendiente`, `Justificacion`, según los campos y reglas de `data-model.md`. Los derivados (metros, porcentajes, distribuciones) se calculan, **nunca se almacenan como campo**
- [X] T017 Declarar las interfaces de repositorio en `lib/dominio/repositorios/`: `RepositorioPlanes`, `RepositorioSesiones`, `RepositorioNadadores` y `RepositorioBiblioteca`, con las firmas de `contracts/almacenamiento.md`. Ninguna firma puede mencionar tipos de Firestore
- [X] T018 [P] Implementar `lib/datos/recursos/biblioteca_empaquetada.dart`, que carga `assets/biblioteca/ejercicios.json` y satisface `RepositorioBiblioteca` con búsqueda por coincidencia exacta de (`nombre`, `estilo`)
- [X] T019 [P] Implementar repositorios en memoria en `test/dominio/dobles/` para poder probar el dominio sin Firestore
- [X] T020 Implementar los conversores documento a entidad en `lib/datos/firestore/` para plan (con microciclos embebidos) y sesión (en subcolección `sesiones`), según la estructura de `contracts/almacenamiento.md`
- [X] T021 Escribir `firebase/firestore.rules` con postura de **denegar por defecto**: ninguna colección legible ni escribible sin concesión explícita, y prohibida toda escritura sobre un plan en estado `aprobado` o `publicado`. Sin reglas permisivas provisionales
- [X] T022 Escribir las pruebas de reglas en `firebase/test/reglas.test.js` con los seis casos de `contracts/almacenamiento.md`, incluidos los negativos: cliente sin autenticar no lee ni escribe `planes` ni `nadadores`, y no se puede escribir sobre un plan aprobado o publicado
- [X] T023 Conectar la app a los emuladores en `lib/datos/firestore/configuracion.dart` cuando `USAR_EMULADORES` esté activa, de modo que nunca apunte por accidente a un proyecto real

**Checkpoint**: las reglas de la metodología están codificadas y probadas, las entidades existen, el acceso a datos funciona contra emuladores y la frontera del dominio está vigilada.

---

## Phase 3: User Story 1 - Construir una sesión validada (Priority: P1) 🎯 MVP

**Goal**: el entrenador escribe sus series con su notación, ve al instante cómo se
interpretan, corrige lo que esté mal, y la app calcula metros y porcentaje técnico
avisándole cuando algo se sale de su metodología.

**Independent Test**: crear una sesión desde cero para una categoría conocida y comprobar
que los totales, el porcentaje técnico y los avisos coinciden con la revisión manual.

### Tests for User Story 1 ⚠️

> Escribir primero y comprobar que FALLAN antes de implementar.

- [X] T024 [P] [US1] Construir el corpus de notación en `test/dominio/notacion/corpus.dart` con las series reales de la sección 14 del documento normativo, cada una con su resultado estructurado esperado: `200 N`, `4x100 AL SNK PN / 2'`, `8x50 (1L 1Estilo 1>4)`, `200 PULL PL (75N=25 Prog)`, `400 AL (75 Estilo − 25 UW)`, `200 AL (25m Pn E FLECHA + 75 N)`, `200 PU/Pp E (50 c/brazo)`, `300 REC Pp TEC L`
- [X] T025 [P] [US1] Escribir la prueba de anclaje en `test/dominio/notacion/anclaje_seccion14_test.dart`: el ejemplo completo del miércoles 14 debe dar inicial 1.800 m, central 1.500 m, final 300 m y total **3.600 m**
- [X] T026 [P] [US1] Escribir pruebas del tokenizador en `test/dominio/notacion/tokenizador_test.dart` para implementos y modificadores (`AL`, `PL`, `Pp`, `PULL`, `PN`, `SNK`, `PARAC`, `CAUCHO`, `Hyp n`, `UW`, `REC`, `^`, `1<4`, `1>4`, `+5''`, `-5''`)
- [X] T027 [P] [US1] Escribir pruebas de recuperación de errores en `test/dominio/notacion/pendientes_test.dart`: el analizador nunca lanza excepción, y devuelve fragmentos pendientes con posición exacta y motivo correcto (`termino_desconocido`, `estructura_no_reconocida`, `ejercicio_fuera_de_biblioteca`, `ambiguo`, `nomenclatura_prohibida`)
- [X] T028 [P] [US1] Escribir pruebas de la regla de no invención en `test/dominio/biblioteca/no_invencion_test.dart`: un nombre ausente de la Biblioteca produce fragmento pendiente y **no se sugiere ningún nombre parecido**
- [X] T029 [P] [US1] Escribir pruebas de desambiguación en `test/dominio/biblioteca/desambiguacion_test.dart`: `FLECHA` sin estilo queda `ambiguo`; con estilo se guarda como `FLECHA (Espalda)`
- [X] T030 [P] [US1] Escribir pruebas de nomenclatura prohibida en `test/dominio/notacion/nomenclatura_test.dart`: se rechazan "Libre técnico", "Pecho asistido", "Mariposa técnica", "Espalda técnica", "Libre corregido" y "Pecho corregido"; solo se aceptan `Nado Libre`, `Nado Espalda`, `Nado Pecho`, `Nado Mariposa` y `Nado CI`; `TEC L` y variantes valen solo como etiqueta de bloque
- [X] T031 [P] [US1] Escribir pruebas de cálculo en `test/dominio/calculo/metros_test.dart`: metros de serie = repeticiones × distancia; metros de parte = suma de sus series; metros de sesión = suma de sus tres partes; porcentaje técnico = metros con ejercicio de biblioteca sobre metros totales
- [X] T032 [P] [US1] Escribir pruebas de reparto de partes y volumen en `test/dominio/calculo/reparto_test.dart`: desviación respecto a 40/50/10, y validación contra el rango de la categoría con casos en el límite exacto (1800 y 2200 para Precompetitivo)
- [X] T033 [P] [US1] Escribir pruebas de precedencia de la corrección manual en `test/dominio/notacion/correccion_manual_test.dart`: un campo corregido a mano queda con `origen: corregido a mano` y **una reinterpretación posterior no lo sobrescribe**
- [X] T034 [P] [US1] Escribir pruebas de completitud de sesión en `test/dominio/entidades/sesion_completa_test.dart`: sin objetivo técnico, sin objetivo fisiológico, o con fragmentos pendientes, la sesión no se da por completa

### Implementation for User Story 1

- [X] T035 [US1] Implementar el tokenizador en `lib/dominio/notacion/tokenizador.dart`, que convierte el texto libre en tokens conservando la posición de cada uno dentro del original
- [X] T036 [US1] Implementar el analizador descendente en `lib/dominio/notacion/analizador.dart` con la firma `analizar(texto) -> { series, pendientes }`. **Nunca lanza excepción**: ante lo que no entiende devuelve resultados parciales y un fragmento pendiente con posición y motivo (contrato en `contracts/notacion.md`)
- [X] T037 [US1] Implementar el reconocimiento de estructuras en `lib/dominio/notacion/estructuras.dart`: `N x D`, `N x D / t`, distancia suelta, series con implemento, agrupaciones entre paréntesis y composiciones con `+`
- [X] T038 [US1] Implementar la resolución de ejercicios contra la Biblioteca en `lib/dominio/biblioteca/resolucion.dart`: coincidencia exacta, sin sinónimos ni correcciones automáticas, y exigencia de estilo cuando `requiereDesambiguacion` es verdadero
- [X] T039 [US1] Implementar el glosario ampliable en `lib/dominio/notacion/glosario.dart` (FR-006): un término aclarado se incorpora con su definición y su fecha, y deja de producir fragmento pendiente. Tratar `FC1` y `FC2` como notación en desuso: se ignoran informando, sin bloquear
- [X] T040 [US1] Implementar los cálculos en `lib/dominio/calculo/`: metros por serie, parte y sesión; porcentaje técnico; reparto real entre partes; y comparación contra el rango de volumen de la categoría
- [X] T041 [US1] Implementar las reglas de completitud de sesión en `lib/dominio/entidades/sesion.dart`: objetivo técnico y objetivo fisiológico obligatorios, exactamente tres partes, y ningún fragmento pendiente
- [X] T042 [US1] Implementar el estado del editor en `lib/ui/editor/estado_editor.dart` con `ChangeNotifier`, que reinterpreta y recalcula al escribir manteniendo las correcciones manuales (decisión D8)
- [X] T043 [US1] Construir la pantalla del editor en `lib/ui/editor/pantalla_editor.dart`: las tres partes como áreas de texto libre, cada serie desglosada en campos editables al lado, y los totales en vivo
- [X] T044 [US1] Añadir los campos de cabecera de sesión en `lib/ui/editor/cabecera_sesion.dart`: fecha, objetivo técnico, objetivo fisiológico, RPE previsto de 0 a 10 y variables de monitoreo de carga interna (FR-012)
- [X] T045 [US1] Mostrar los avisos en `lib/ui/editor/panel_avisos.dart`: fragmentos pendientes resaltados sobre el texto original, ejercicios fuera de biblioteca, volumen fuera de rango con la diferencia exacta, y datos obligatorios que faltan
- [X] T046 [US1] Implementar el registro de propuestas de ejercicio en `lib/dominio/biblioteca/propuestas.dart` y su pantalla en `lib/ui/editor/dialogo_propuesta.dart` (FR-004): se guarda fuera del plan, en estado `pendiente`, y **no tiene ningún efecto sobre el plan**
- [X] T047 [US1] Persistir y recuperar sesiones a través de `RepositorioSesiones`, guardando `textoOriginal`, `series`, `fragmentosPendientes` y el campo `origen` de cada serie

**Checkpoint**: el entrenador puede escribir una sesión completa, verla interpretada, corregirla y recibir avisos. Validar con los escenarios V1, V2, V3 y V4 de `quickstart.md`.

---

## Phase 4: User Story 2 - Auditar el plan completo (Priority: P2)

**Goal**: agrupar sesiones en microciclos y microciclos en un plan con fase ATR, y comparar
la distribución real de zonas, el porcentaje técnico y el reparto de estilos contra lo que
la metodología prescribe para esa fase.

**Independent Test**: cargar las sesiones de un microciclo histórico y comprobar que los
porcentajes calculados coinciden con los del documento original.

### Tests for User Story 2 ⚠️

- [X] T048 [P] [US2] Escribir pruebas de agregación en `test/dominio/calculo/agregacion_test.dart`: distribución de zonas, porcentaje técnico y reparto de estilos de un plan completo a partir de sus sesiones
- [X] T049 [P] [US2] Escribir pruebas del criterio `C03_intensidades_fase` en `test/dominio/auditoria/c03_test.dart`, con un plan que lo viola (A1 al 45% en Acumulación, donde se prescribe 60%) y otro que lo cumple. La observación debe contener valor real, prescrito y diferencia
- [X] T050 [P] [US2] Escribir pruebas de `C02_tecnica_prioritaria` y `C04_tecnica_fase` en `test/dominio/auditoria/c02_c04_test.dart`, con un plan de Acumulación al 32% técnico donde se prescribe 50%
- [X] T051 [P] [US2] Escribir pruebas de `C06_transferencia` en `test/dominio/auditoria/c06_test.dart`, con estilo objetivo Libre repartido 60/40 donde se prescribe 80–85% / 15–20%
- [X] T052 [P] [US2] Escribir pruebas de `C05_volumen_categoria` en `test/dominio/auditoria/c05_test.dart`, incluida la discrepancia entre sesiones programadas y la frecuencia semanal esperada de la categoría
- [X] T053 [P] [US2] Escribir pruebas de la prohibición de fase ATR en `test/dominio/auditoria/atr_prohibido_test.dart`: un plan de Iniciación o Tecnificación no admite fase ATR
- [X] T054 [P] [US2] Escribir pruebas de la regla de Tecnificación en `test/dominio/auditoria/tecnificacion_test.dart`: en programas de dos meses, sesión 1 de Pecho y sesión 2 de Mariposa todas las semanas; un microciclo que lo incumple se reporta
- [X] T055 [P] [US2] Escribir pruebas de `C09_modelamiento` en `test/dominio/auditoria/c09_test.dart`: un microciclo sin objetivo real, o cuyo nombre no lo refleja, falla el criterio
- [X] T056 [P] [US2] Escribir pruebas de `C10_drills_diagnostico` en `test/dominio/auditoria/c10_test.dart`: con diagnóstico registrado y ejercicios que no atacan ninguno de sus errores, falla; **sin diagnóstico, reporta la ausencia sin culpar al plan**
- [X] T057 [P] [US2] Escribir pruebas de la tolerancia en `test/dominio/auditoria/tolerancia_test.dart`: una desviación dentro de ±3 puntos porcentuales cumple, y justo fuera no cumple

### Implementation for User Story 2

- [X] T058 [US2] Implementar la agregación de un plan en `lib/dominio/calculo/agregacion_plan.dart`: distribución de zonas sobre el volumen total, porcentaje técnico y reparto de estilos, a partir de las sesiones de todos sus microciclos
- [X] T059 [US2] Implementar la tolerancia configurable en `lib/dominio/auditoria/tolerancia.dart`, con valor inicial de ±3 puntos porcentuales definido **en un solo lugar** para poder recalibrarlo
- [X] T060 [US2] Implementar los criterios justificables `C02`, `C03`, `C04`, `C05`, `C06`, `C09` y `C10` en `lib/dominio/auditoria/criterios/`, uno por archivo, cada uno devolviendo veredicto, observación con números concretos y ubicación
- [X] T061 [US2] Implementar la validación de fase ATR frente a categoría en `lib/dominio/metodologia/validacion_fase.dart`: las categorías sin ATR no la admiten
- [X] T062 [US2] Implementar la gestión de microciclos en `lib/dominio/entidades/microciclo.dart` y `lib/ui/planes/editor_microciclos.dart`, exigiendo que el nombre describa el objetivo real y no solo la posición en la fase
- [X] T063 [US2] Construir la pantalla de plan en `lib/ui/planes/pantalla_plan.dart`: cabecera con categoría, estilo y prueba objetivo, longitud de piscina, fechas y fase ATR, con sus microciclos y sesiones
- [X] T064 [US2] Construir el panel de distribución en `lib/ui/planes/panel_distribucion.dart`, mostrando por cada zona el valor real, el prescrito y la diferencia, más el porcentaje técnico y el reparto de estilos

**Checkpoint**: la auditoría agregada detecta los errores que no se ven en una sesión aislada. Validar con el escenario V8 de `quickstart.md`.

---

## Phase 5: User Story 3 - Aprobar con auditoría visible (Priority: P3)

**Goal**: la tabla de auditoría completa antes de aprobar; los criterios bloqueantes impiden
la aprobación y los justificables exigen justificación escrita, que queda guardada.

**Independent Test**: intentar aprobar planes con defectos sembrados a propósito y comprobar
cuáles bloquean, cuáles piden justificación y cuáles pasan limpios.

### Tests for User Story 3 ⚠️

- [X] T065 [P] [US3] Escribir pruebas de los criterios bloqueantes en `test/dominio/auditoria/bloqueantes_test.dart`: `C01_biblioteca`, `C07_nomenclatura`, `C08_zonas` y `C11_sin_ambiguos`, cada uno con un plan que lo viola y otro que lo cumple
- [X] T066 [P] [US3] Escribir pruebas de `C08_zonas` en `test/dominio/auditoria/c08_test.dart`: falla si una serie no tiene zona, si la zona no es una de las seis válidas, o si una serie contara en dos zonas
- [X] T067 [P] [US3] Escribir pruebas de la regla de aprobación en `test/dominio/auditoria/regla_aprobacion_test.dart`: no se aprueba con un bloqueante en rojo ni aportando justificación; no se aprueba con un justificable en rojo y justificación vacía; sí se aprueba con justificación escrita
- [X] T068 [P] [US3] Escribir pruebas de transición de estado en `test/dominio/entidades/plan_estados_test.dart`: `borrador` → `aprobado` → `publicado`; al aprobar se estampan `versionMetodologia` y `fechaAprobacion`; un plan aprobado o publicado es inmutable
- [X] T069 [P] [US3] Escribir pruebas de versionado en `test/dominio/entidades/plan_version_test.dart`: editar un plan aprobado crea un plan nuevo en `borrador` con `versionAnteriorId`, y el aprobado queda intacto
- [X] T070 [P] [US3] Escribir pruebas de que un criterio sin datos suficientes **no cumple**, en `test/dominio/auditoria/datos_faltantes_test.dart`: nunca se considera cumplido por omisión
- [X] T071 [P] [US3] Escribir pruebas de la tabla completa en `test/dominio/auditoria/tabla_once_criterios_test.dart`: la auditoría devuelve siempre los once criterios, cada uno con veredicto y observación

### Implementation for User Story 3

- [X] T072 [US3] Implementar los criterios bloqueantes `C01`, `C07`, `C08` y `C11` en `lib/dominio/auditoria/criterios/`, uno por archivo, con la severidad declarada en `contracts/auditoria.md`
- [X] T073 [US3] Implementar el ensamblado de la auditoría en `lib/dominio/auditoria/auditoria.dart`, que ejecuta los once criterios y devuelve el resultado agregado con `apruebaSinBloqueos`
- [X] T074 [US3] Implementar la regla de aprobación en `lib/dominio/auditoria/regla_aprobacion.dart`: cero bloqueantes en rojo, justificación no vacía por cada justificable en rojo, y ninguna sesión incompleta
- [X] T075 [US3] Implementar las transiciones de estado del plan en `lib/dominio/entidades/plan.dart`: `aprobar()` estampa la versión de metodología leída de `metodologia.json` y la fecha; `publicar()`; e inmutabilidad tras aprobar
- [X] T076 [US3] Implementar `crearVersionDesde(idAprobado)` en la capa de datos, que produce un plan nuevo en `borrador` con `versionAnteriorId` y conserva el aprobado sin tocar
- [X] T077 [US3] Guardar la instantánea de auditoría y las justificaciones junto al plan al aprobar, en el campo `auditoriaAlAprobar` de `contracts/almacenamiento.md`
- [X] T078 [US3] Construir la tabla de auditoría en `lib/ui/planes/tabla_auditoria.dart`: los once criterios con su veredicto, su severidad y su observación con números concretos, consultable en cualquier momento y no solo al aprobar
- [X] T079 [US3] Construir el flujo de aprobación en `lib/ui/planes/dialogo_aprobacion.dart`: los bloqueantes se muestran como impedimento nombrando el ejercicio y la sesión; los justificables piden el texto y no dejan aprobar mientras esté vacío

**Checkpoint**: ningún plan defectuoso puede aprobarse. Validar con los escenarios V5, V6 y V7 de `quickstart.md`.

---

## Phase 6: User Story 4 - Perfiles de nadador y asignación (Priority: P4)

**Goal**: registrar perfiles con los datos mínimos para planificar y asignar cada plan a uno
o varios de ellos.

**Independent Test**: crear varios perfiles, asignarles planes y comprobar que cada plan
conserva sus destinatarios y que los perfiles se pueden exportar.

### Tests for User Story 4 ⚠️

- [X] T080 [P] [US4] Escribir pruebas de completitud de perfil en `test/dominio/entidades/nadador_test.dart`: `categoria` y `estiloObjetivo` son **obligatorios** para dar el perfil por completo
- [X] T081 [P] [US4] Escribir pruebas de asignación en `test/dominio/entidades/asignacion_test.dart`: el plan conserva su lista `nadadoresIds`, y desde un perfil se pueden ver sus planes con el estado de cada uno
- [X] T082 [P] [US4] Escribir pruebas de exportación en `test/datos/exportacion_test.dart`: un plan exportado es un único JSON con el plan y sus sesiones embebidas, legible sin la app (principio V)
- [X] T083 [P] [US4] Escribir pruebas de minimización de datos en `test/datos/registros_test.dart`: ningún nombre, marca ni identificador de nadador aparece en los registros técnicos (FR-032)

### Implementation for User Story 4

- [X] T084 [US4] Implementar la entidad `Nadador` completa en `lib/dominio/entidades/nadador.dart` con `nombre` obligatorio, `fechaNacimiento` opcional, `categoria` y `estiloObjetivo` obligatorios, `pruebaObjetivo`, lista de `marcas` y `diagnosticoTecnico`
- [X] T085 [US4] Implementar `RepositorioNadadores` sobre Firestore en `lib/datos/firestore/repositorio_nadadores.dart`
- [X] T086 [US4] Construir la pantalla de perfiles en `lib/ui/nadadores/pantalla_perfiles.dart`, señalando los datos obligatorios que falten
- [X] T087 [US4] Añadir un aviso visible y permanente en `lib/ui/nadadores/aviso_consentimiento.dart`: mientras no exista el registro de consentimiento del acudiente, solo deben cargarse perfiles de prueba o del propio entrenador. **Lo exige la condición del principio V registrada en `plan.md`**
- [X] T088 [US4] Implementar la asignación de planes a nadadores en `lib/ui/planes/asignacion.dart` y la vista de planes por perfil
- [X] T089 [US4] Implementar la exportación en `lib/datos/exportacion.dart`: plan completo con sus sesiones, y perfil con sus planes, en JSON legible

**Checkpoint**: las cuatro historias funcionan. El editor produce planes auditados, aprobados y asignados a nadadores concretos.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T090 Ejecutar el escenario **V10 de `quickstart.md`**: reconstruir el `Macrociclo - Precompetitivo Agosto` y comparar metros por sesión y microciclo contra el original, con diferencia de 0 m (criterio SC-001)
- [ ] T091 Si V10 no cuadra, determinar **cuál de las dos fuentes está equivocada antes de tocar código**, y registrar el hallazgo. Es posible que el documento original tenga un error aritmético: en ese caso no se ajusta la app para reproducirlo
- [ ] T092 Recalibrar con el entrenador la tolerancia de ±3 puntos porcentuales a la luz de los resultados de V10: si sus propias planificaciones históricas fallan criterios, la tolerancia está mal puesta, no sus planes
- [X] T093 [P] Recorrer los escenarios V1 a V9 de `quickstart.md` y registrar el resultado de cada uno
- [X] T094 Verificar que `flutter analyze` termina sin errores ni advertencias nuevas, conforme al principio VII
- [ ] T095 [P] Anonimizar el plan de referencia si contiene nombres de nadadores reales, antes de incorporarlo al repositorio como material de prueba
- [X] T096 [P] Actualizar `README.md` con cómo levantar los emuladores, arrancar la app y ejecutar las tres suites de pruebas

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Fase 1)**: sin dependencias, empieza de inmediato
- **Foundational (Fase 2)**: depende de Setup y **bloquea todas las historias**
- **US1 (Fase 3)**: depende de Foundational. Es el MVP
- **US2 (Fase 4)**: depende de Foundational y de los cálculos de US1 (T040), porque la agregación suma lo que las sesiones calculan
- **US3 (Fase 5)**: depende de Foundational. Los criterios bloqueantes se apoyan en la resolución de biblioteca de US1 (T038) y la tabla completa necesita los criterios de US2 (T060)
- **US4 (Fase 6)**: depende solo de Foundational. Es la historia más independiente
- **Polish (Fase 7)**: depende de las historias que se quieran validar; T090 a T092 necesitan US1 y US2

### Dependencia crítica dentro de Foundational

T008 (extracción) → T009 (revisión manual) → T018 (carga) → todo lo que valide ejercicios.
**T009 no se puede saltar**: es el punto donde un error de transcripción se convierte en una
regla mal aplicada durante toda la vida del producto.

### Within Each User Story

- Las pruebas se escriben primero y deben fallar antes de implementar
- Dentro de US1: tokenizador (T035) → analizador (T036) → estructuras (T037) → resolución de biblioteca (T038) → cálculos (T040) → interfaz (T042 a T045)
- Dentro de US3: criterios (T072) → ensamblado (T073) → regla de aprobación (T074) → estados (T075) → interfaz (T078, T079)

### Parallel Opportunities

- T004, T005 y T006 en Setup
- T010 a T013 (constantes de metodología) son cuatro archivos independientes
- T015, T018 y T019 tras las constantes
- Todas las pruebas de una misma historia marcadas [P]: T024 a T034 en US1, T048 a T057 en US2, T065 a T071 en US3, T080 a T083 en US4
- Los criterios de auditoría son un archivo por criterio: T060 y T072 se pueden repartir
- US4 completa se puede adelantar en paralelo a US2 y US3 si conviene cambiar de tema

---

## Parallel Example: User Story 1

```bash
# Las pruebas de US1 se pueden escribir todas a la vez, son archivos distintos:
T024 corpus de notación en test/dominio/notacion/corpus.dart
T025 anclaje de 3.600 m en test/dominio/notacion/anclaje_seccion14_test.dart
T026 tokenizador en test/dominio/notacion/tokenizador_test.dart
T027 fragmentos pendientes en test/dominio/notacion/pendientes_test.dart
T028 no invención en test/dominio/biblioteca/no_invencion_test.dart
T029 desambiguación en test/dominio/biblioteca/desambiguacion_test.dart
T030 nomenclatura en test/dominio/notacion/nomenclatura_test.dart
T031 metros en test/dominio/calculo/metros_test.dart
T032 reparto y volumen en test/dominio/calculo/reparto_test.dart
T033 corrección manual en test/dominio/notacion/correccion_manual_test.dart
T034 completitud de sesión en test/dominio/entidades/sesion_completa_test.dart
```

---

## Implementation Strategy

### MVP primero (solo US1)

1. Fase 1: Setup
2. Fase 2: Foundational — crítica, bloquea todo
3. Fase 3: US1
4. **PARAR Y VALIDAR**: escenarios V1 a V4 de `quickstart.md`. Si el anclaje de 3.600 m no
   da exacto, no seguir: el problema está en el analizador y contaminará todo lo demás
5. En este punto el entrenador ya puede escribir sesiones validadas, que es más de lo que
   hoy le da su Excel

### Entrega incremental

1. Setup + Foundational → las reglas de la metodología codificadas y probadas
2. + US1 → escribir y validar sesiones (**MVP**)
3. + US2 → auditoría agregada del plan
4. + US3 → aprobación con bloqueo
5. + US4 → perfiles y asignación
6. Polish → V10 contra el plan real, que es la prueba de fuego

### Si el trabajo se desborda

La línea de corte declarada en `plan.md` y en el checklist: entregar **US1 y US2**
(construir y auditar) como primera entrega real, y dejar US3 y US4 para una feature
posterior. US1 sola ya es utilizable; US1 + US2 ya sustituye el trabajo de verificación
manual que hoy hace el entrenador.

---

## Notes

- 96 tareas. Las pruebas son el 34% de ellas, que es lo que corresponde a un producto donde
  un cálculo equivocado afecta la preparación de un deportista real
- Las tareas [P] tocan archivos distintos y no tienen dependencias pendientes
- Verificar que cada prueba falla antes de implementar lo que la hace pasar
- Commitear por tarea o por grupo lógico
- T009, T087, T091 y T092 requieren **criterio del entrenador**, no son mecánicas

---

## Estado de cierre (2026-09-25)

**92 de 96 tareas completadas.** Las cuatro restantes dependen del entrenador o
quedaron sin aplicar:

- **T009 — Revisión de la Biblioteca extraída. CONFIRMADA por el entrenador el
  2026-09-25.** La extracción dio **70 ejercicios** (Libre 23, General 18,
  Espalda 10, Pecho 10, Mariposa 9). Los **cinco** nombres ambiguos quedan
  confirmados como ejercicios distintos, cada uno con su forma de ejecución y su
  error a corregir: `FLECHA`, `ROLIDO`, `ROLIDO CON 1 BRAZO`, `3+3 PATADA
  LATERAL` y `PULGAR ROZA EL MUSLO`. La sección 7 del documento normativo se
  completó de tres a cinco en la metodología 3.4.1.

- **T091 — No aplica.** Solo entraba en juego si V10 no cuadraba, y cuadró: la
  sesión S2 del 04/08 da 1.900 m exactos y la semana 5.700 m. Los dos defectos
  que V10 destapó estaban en el analizador, no en el documento del entrenador,
  y se corrigieron.

- **T092 — Medida el 2026-10-07, pendiente de una respuesta concreta.** Se midió
  contra sus dos planes reales completos —56 sesiones, 90.600 m— y el resultado
  es que **la tolerancia no es la causa**. Registro en
  [`docs/metodologia/calibracion_tolerancia.md`](../../docs/metodologia/calibracion_tolerancia.md).

  Dos hallazgos anteriores a la tolerancia:

  1. **Sus hojas no registran metros por zona.** Declaran la intensidad por
     parte y con etiquetas mixtas (`A1-A2`, `REC/A1`, `AT / RP8`, `Máx / RP8`).
     El criterio C03 compara metros por zona, así que no se puede evaluar sin
     que él declare cómo se reparten esas etiquetas (regla R3: preguntar, no
     suponer).
  2. **La zona A3 está casi ausente del macrociclo**, y eso sale igual en la
     interpretación más favorable de las etiquetas: −6,1 pp en Acumulación,
     −11,9 en Transformación, −15,0 en Realización. Ninguna tolerancia razonable
     absorbe quince puntos.

  La explicación más probable es que `RP8` comprenda A3, o A3 y AT a la vez. Si
  es así, el plan cumple de sobra sin tocar la tolerancia. **Falta su tabla de
  equivalencias entre sus etiquetas de trabajo y las seis zonas.** Con ella la
  calibración es aritmética.

  Lo que sí quedó medido:

  - Para el porcentaje técnico (C04), ±3 pp sirve: sus hojas declaran «téc ~50%»
    y Acumulación prescribe 50%.
  - Para la estructura 40/50/10, que hoy **no** es criterio: 14 de sus 56
    sesiones pasarían de ±3 pp. Si llega a serlo haría falta ±6 pp, porque su
    parte final son 200 m fijos y no el 10% de la sesión — del 9,1% en una
    sesión de 2.200 m al 15,4% en una de 1.300.
  - **Diferencia de criterio a resolver:** la distribución ATR es para él un
    objetivo de fase que alcanza variando las semanas (MC02 es solo A1 y A2). El
    generador de la 002 la hace cumplir semana a semana, así que produce semanas
    más uniformes que las suyas.

- **T095 — No aplica todavía.** El plan de referencia no se incorporó al
  repositorio; las pruebas reproducen su texto sin nombres de nadadores. Si más
  adelante se añade el archivo, habrá que anonimizarlo antes.

### Hallazgos en el documento normativo

1. **`CAMBIO POSI` frente a `CAMB POSIC`.** La sesión de ejemplo de la
   sección 14 escribe `CAMBIO POSI`, pero la sección 19 define el ejercicio
   como `CAMB POSIC`. La regla R2 exige coincidencia exacta, así que el
   analizador lo marca como fuera de biblioteca. Hay que decidir cuál de los
   dos nombres es el bueno y corregir el documento.

2. **Cinco ejercicios ambiguos, no tres** (ver T009).

### Resolución de los hallazgos (metodología 3.4.1, 2026-09-25)

El entrenador confirmó ambos hallazgos y la metodología pasó a **3.4.1**. Es una
corrección, no una revisión metodológica: no cambia ninguna regla de
entrenamiento, por eso 3.4.1 y no 3.5.

1. **`CAMBIO POSI` / `CAMB POSIC` → `CAMBIO POSIC`.** Son el mismo ejercicio.
   Unificado en las secciones 14 y 19 del documento normativo. Los dos nombres
   antiguos **no** se aceptan por compatibilidad: aceptarlos sería corregir por
   aproximación, que es lo que la regla R2 prohíbe. Hay una prueba que lo vigila.

2. **Cinco ejercicios ambiguos, no tres.** Sección 7 completada con
   `3+3 PATADA LATERAL` y `PULGAR ROZA EL MUSLO`. Hay una prueba por cada uno de
   los cinco.

Corregir esto destapó un tercer defecto del analizador: los nombres de la
Biblioteca que llevan signos que el tokenizador parte —`3+3 PATADA LATERAL`,
`CLAVADO + SUB + 6 BRAZADAS`, `BRAZA 1-2-3`— se daban por inexistentes. Ahora los
nombres se buscan primero sobre el texto crudo, del más largo al más corto y con
frontera de palabra, así que el nombre de la Biblioteca manda sobre la
puntuación.

El nombre del archivo conserva `V3.4` a propósito: la versión de referencia es la
del manifiesto, no la del nombre. Renombrarlo alteraría la trazabilidad de los
planes ya aprobados bajo la 3.4 (decisión D4).
