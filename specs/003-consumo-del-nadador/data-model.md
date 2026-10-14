# Modelo de datos — Feature 003: el nadador consume su plan

**Fecha**: 2026-10-13
**Decisiones**: [research.md](research.md)

La regla que gobierna todo este modelo: **un plan aprobado es inmutable**. Nada de lo que
el nadador escriba lo toca. Su respuesta es una entidad aparte que *apunta* al plan.

---

## `RegistroDeSesion`

La respuesta del nadador a una sesión concreta. Vive en `lib/dominio/entidades/`, en Dart
puro.

| Campo | Tipo | Regla |
|---|---|---|
| `id` | `String` | **Determinista** (D2): derivado de `nadadorId`, `planId`, `sesionId` y `versionDePlan`. Reenviar sobrescribe, no duplica |
| `nadadorId` | `String` | A quién pertenece |
| `planId` | `String` | Qué plan |
| `sesionId` | `String` | Qué sesión |
| `versionDePlan` | `String` | Bajo qué versión entrenó. Un plan corregido crea otra versión; el registro sigue apuntando a la que el nadador vivió |
| `realizada` | `bool` | Si la cumplió |
| `registradoEn` | `DateTime` | Hora del **dispositivo**. Es cuándo entrenó, y es la que ve el entrenador (D3) |
| `rpePercibido` | `int?` | Borg 0-10. **Nulo es válido**: anotar no es obligatorio (FR-010) |
| `observaciones` | `String` | Texto libre. Se guarda tal cual: no es notación del entrenador y no se interpreta |
| `molestia` | `ReporteDeMolestia?` | Separado a propósito. Ver abajo |

### Invariantes

- `rpePercibido`, si viene, es un entero de **0 a 10**. Fuera de ese rango no se construye
  el registro.
- `realizada == false` con observaciones **es válido**: «no pude ir» es información.
- El registro **no** contiene metros, series ni zonas. Eso es carga externa y vive en el
  plan. Mezclarlas en una misma entidad sería el primer paso hacia el indicador que el
  principio VIII prohíbe.

### Estados

Un registro no tiene máquina de estados propia. Lo que sí la tiene es su envío, y eso es
otra entidad (`EnvioPendiente`), a propósito: el contenido de lo que el nadador escribió y
el hecho de si llegó al servidor son cosas distintas, y acoplarlas obligaría a reescribir
el registro cada vez que cambia el estado de red.

---

## `ReporteDeMolestia`

Dolor, lesión o malestar. **Es un campo propio, no una observación más.**

| Campo | Tipo | Regla |
|---|---|---|
| `descripcion` | `String` | Lo que el nadador escribe |
| `zonaDelCuerpo` | `String` | Texto libre. No se ofrece una lista cerrada: no somos quién para acotar el vocabulario clínico de nadie |

**Por qué está separado.** El principio VIII lo exige: un reporte de dolor «se marca aparte
del resto de observaciones, llega al entrenador y NO DEBE resolverse de forma automática».
Si viviera dentro de `observaciones`, encontrarlo dependería de que alguien leyera todas las
observaciones de todas las sesiones, y SC-006 exige lo contrario.

**Lo que el sistema no hace, y es deliberado**: no clasifica la gravedad, no sugiere
reposo, no oculta la sesión siguiente, no avisa a nadie automáticamente. Llega al entrenador
señalado y decide él (principio IV).

---

## `EnvioPendiente`

La bandeja de salida. Es lo que sostiene la promesa de que nada se pierde.

| Campo | Tipo | Regla |
|---|---|---|
| `registroId` | `String` | Qué registro espera |
| `estado` | `EstadoDeEnvio` | Ver abajo |
| `intentos` | `int` | Cuántas veces se intentó |
| `ultimoIntento` | `DateTime?` | Para espaciar los reintentos |
| `ultimoError` | `String?` | Qué falló. Para diagnosticar, no para mostrarle al nadador un error de red |

### `EstadoDeEnvio`

```text
pendiente ──────► enviando ──────► enviado
    ▲                  │
    └──────────────────┘
         (falló, reintenta)
```

| Estado | Qué significa | Qué ve el nadador |
|---|---|---|
| `pendiente` | Escrito en el dispositivo, sin enviar | «Guardado el progreso, se enviará cuando tengas acceso a internet» |
| `enviando` | En curso | Lo mismo: no se le cuenta al nadador el detalle de la red |
| `enviado` | Confirmado por el servidor | Nada. El estado desaparece |

**No existe un estado `fallido` terminal.** Un envío que falla vuelve a `pendiente` y se
reintenta. Que un registro pueda quedarse en «fallido» sería exactamente la forma en que los
datos se pierden en silencio, y FR-019 lo prohíbe.

---

## `ProgresoDelNadador`

Calculado, no almacenado. Vive en `lib/dominio/calculo/`, junto a `AgregacionPlan`.

| Dato | Cómo sale |
|---|---|
| Historial de sesiones | Las sesiones del plan, cada una con su registro si lo hay, de la más reciente a la más antigua (FR-005a) |
| Adherencia de la semana | Sesiones con `realizada == true` sobre sesiones programadas de esa semana |
| Adherencia del plan | Lo mismo sobre el total del plan |

**La adherencia cuenta sesiones. Punto.** No pondera por metros, no pondera por RPE, no se
combina con nada (FR-005c, D6). Hay una prueba que lo fija: el recuento no cambia al variar
el RPE ni los metros (SC-011).

Es un indicador deliberadamente aburrido. Un indicador «mejor» que mezclara cumplimiento con
intensidad sería el indicador combinado que el principio VIII prohíbe.

---

## Relación con lo que ya existe

```text
Plan (001, inmutable al aprobarse)
 └── Sesion (001)
      ▲
      │ apunta
      │
RegistroDeSesion (003) ──► ReporteDeMolestia (003)
      ▲
      │ espera
      │
EnvioPendiente (003)

Nadador (001) ──── asignación (001) ────► Plan
```

**Nada de 003 modifica una entidad de 001.** La relación es de referencia en un solo
sentido: el registro conoce la sesión, la sesión no conoce el registro. Eso es lo que
permite que el plan aprobado conserve su contenido byte a byte (SC-007).

---

## Interfaces del dominio

Se añaden a `lib/dominio/repositorios/repositorios.dart`, con la misma regla que las
existentes: **ninguna firma menciona tipos de Firestore.**

```text
RepositorioRegistros
  obtenerDeSesion(nadadorId, planId, sesionId) -> RegistroDeSesion?
  obtenerDePlan(nadadorId, planId)             -> List<RegistroDeSesion>
  guardar(RegistroDeSesion)                    -> void      // local primero
  exportar(nadadorId)                          -> Map       // portabilidad (FR-024)
  eliminar(nadadorId)                          -> void      // borrado (FR-024)

BandejaDeSalida
  encolar(registroId)        -> void
  pendientes()               -> List<EnvioPendiente>
  marcarEnviado(registroId)  -> void
  marcarFallido(registroId, error) -> void
```

`guardar` **escribe primero en local y encola después**. Ese orden es la feature: si se
escribiera primero en el servidor, un nadador sin red perdería lo escrito, que es justo lo
que FR-019 prohíbe.

---

## Almacenamiento

| Qué | Dónde | Por qué |
|---|---|---|
| Planes y sesiones para leer sin conexión | Caché de Firestore | Ya existe y ya sabe invalidarse (D1) |
| Registros del nadador | Local primero, Firestore al sincronizar | La escritura es nuestra: necesitamos idempotencia y estado propio (D1, D2) |
| Bandeja de salida | Solo local | No tiene sentido fuera del dispositivo |

### Reglas de acceso

La colección de registros se añade a `firebase/firestore.rules` **denegando por omisión**,
como todo lo demás.

En esta feature **solo escribe el rol de entrenador**, porque no hay identidad de nadador
hasta la 004 (D4). Las reglas por nadador se escriben allí. Lo que sí se prueba desde ahora,
con sus casos negativos: que nadie sin rol lee ni escribe registros.

**Esto es una limitación conocida, no un descuido.** Está en el plan y en la especificación:
ningún nadador real usa esta feature hasta que 004 exista.
