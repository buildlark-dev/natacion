# Contrato: el registro del nadador

**Feature**: 003 — el nadador consume su plan
**Modelo**: [data-model.md](../data-model.md)

Lo que el nadador escribe, qué se acepta y qué llega al entrenador.

---

## Lo que se acepta

| Campo | Obligatorio | Validación |
|---|---|---|
| `realizada` | Sí | `true` o `false`. Es lo único que la app pide de verdad |
| `rpePercibido` | **No** | Si viene, entero de **0 a 10** (Borg). Fuera de rango, el registro no se construye |
| `observaciones` | No | Texto libre, se guarda **tal cual** |
| `molestia` | No | Si viene, con descripción y zona del cuerpo |

### Nada de esto es obligatorio salvo `realizada`

FR-010 y el principio VIII: «el registro de la carga interna NO DEBE ser obligatorio para
usar la app». Un nadador que solo marca la sesión y se va ha usado la app correctamente.

Lo que **no** se permite es que la app no ofrezca dónde anotarlo.

### Las observaciones no se interpretan

El analizador de notación de la feature 001 lee lo que escribe **el entrenador**. Lo que
escribe el nadador es prosa: «me costó mucho la tercera», «llegué tarde y recorté». No es
notación, no se parsea, no se corrige, no se normaliza. Se guarda y se muestra.

Mayúsculas, acentos, saltos de línea y longitud: tal cual.

---

## Lo que el entrenador ve

### Separado, siempre

| | Qué es | De dónde sale |
|---|---|---|
| **Carga externa** | Metros, series, pausas, ritmos, zonas | El plan. Lo programó él |
| **Carga interna** | Realizada, RPE, observaciones | El registro. Lo respondió el nadador |

**Nunca combinadas en un mismo indicador** (principio VIII, FR-014). No hay un número que
mezcle lo programado con lo percibido, y la adherencia cuenta sesiones precisamente para no
serlo.

### Junto al plan que lo originó

FR-013: el registro se muestra **sobre la sesión que lo produjo**, no en una bandeja
aparte. «Un registro que nadie lee no es control», y un registro que vive en otra pantalla
es un registro que nadie lee.

### La molestia, señalada

Un reporte de dolor se distingue a simple vista del resto de observaciones y es localizable
sin leer todas las sesiones (SC-006).

**La app no actúa sobre él**: no clasifica gravedad, no sugiere reposo, no esconde la sesión
siguiente, no avisa a nadie. Llega señalado y decide el entrenador (principio IV).

---

## Qué no modifica

**Un plan aprobado es inmutable.** Registrar una respuesta:

- no cambia el plan,
- no cambia la sesión,
- no cambia la auditoría,
- no cambia la versión de metodología estampada.

SC-007 lo fija: el plan conserva su contenido byte a byte después de que un nadador registre
respuestas sobre él. Hay una prueba que lo comprueba comparando el plan serializado antes y
después.

---

## Versión del plan

Cada registro apunta a la **versión bajo la que el nadador entrenó**.

Si el entrenador corrige un plan aprobado, la feature 001 crea una versión nueva: la
anterior no se reescribe. El registro sigue apuntando a la que el nadador vivió, y el
entrenador puede ver a cuál corresponde.

**Por qué importa**: sin esto, un plan corregido haría que las respuestas pasadas parecieran
referirse a series que el nadador nunca hizo.

---

## Fechas

| Campo | De quién | Para qué |
|---|---|---|
| `registradoEn` | Del dispositivo | Cuándo entrenó. Es la que ve el entrenador |
| `recibidoEn` | Del servidor | Ordenar, y detectar un reloj desajustado |

Un nadador puede marcar como realizada una sesión de otro día: entrenó corrido, o se saltó
una y la recuperó. **La fecha de la sesión y la del registro son cosas distintas** y el
sistema no las fuerza a coincidir.

Si las dos marcas difieren de forma absurda, se muestra. No se corrige (regla R3: ante un
dato que no cuadra se avisa, no se supone).

---

## Datos personales

- Los registros y la analítica **no contienen** nombres, marcas, videos ni identificadores
  del nadador (FR-023, principio V).
- El nadador puede **exportar** sus registros en formato legible y **solicitar su
  eliminación**; el modelo lo permite sin rediseño (FR-024).
- El acceso **deniega por omisión** y se prueba con casos negativos (FR-025).
- Acceder a lo que él mismo generó **nunca queda tras un muro de pago** (FR-026,
  principio VI).

---

## Escenarios de verificación

| | Escenario | Resultado esperado |
|---|---|---|
| **R1** | RPE 11, o −1 | El registro no se construye |
| **R2** | RPE ausente | Registro válido |
| **R3** | `realizada: false` con observaciones | Válido: «no pude ir» es información |
| **R4** | Observación con saltos de línea y mayúsculas | Se guarda tal cual |
| **R5** | Registrar sobre un plan aprobado | El plan serializado no cambia |
| **R6** | Molestia reportada | Localizable sin abrir todas las sesiones |
| **R7** | Plan con versión nueva | El registro antiguo sigue apuntando a la versión vieja |
| **R8** | Nadador que no anota nada | Recorrido de lectura completo, sin un solo bloqueo |
| **R9** | Exportar registros | Documento legible sin la app |
| **R10** | Lectura sin rol | Denegada |
