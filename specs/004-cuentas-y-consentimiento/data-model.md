# Fase 1 — Modelo de datos

**Feature**: cuentas, roles y consentimiento verificable
**Decisiones**: [research.md](research.md) · **Contratos**:
[cuentas_y_roles.md](contracts/cuentas_y_roles.md) ·
[consentimiento.md](contracts/consentimiento.md)

---

## Entidades del dominio

### `Cuenta`

Quién está usando la app. Vive en `lib/dominio/cuentas/cuenta.dart`.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | `String` | El identificador de la cuenta. Es el que las reglas comparan contra `request.auth.uid` |
| `rol` | `Rol` | `entrenador` o `nadador` |
| `nadadorId` | `String?` | A qué perfil de nadador corresponde, si es un nadador |

**Invariantes**:

- Una cuenta con rol `entrenador` **nunca** tiene `nadadorId`.
- Una cuenta con rol `nadador` sin `nadadorId` puede entrar y usar la app, pero no tiene plan
  ni registros: todavía no la asoció ningún entrenador.
- El rol **no se declara desde el cliente**. Llega dentro del token (D2).

### `Rol`

Enumeración de dos valores. No es un `String` suelto a propósito: los permisos se deciden
sobre un tipo cerrado, y añadir un rol obliga a revisar dónde se decide.

`lib/dominio/cuentas/permisos.dart` responde en Dart puro a las preguntas que hoy están
repartidas por la interfaz: quién puede aprobar, quién puede publicar, quién puede leer los
registros de quién. **Las reglas de Firestore son la misma decisión escrita otra vez**, en el
sitio donde se hace cumplir. Que coincidan lo vigila la prueba de reglas, no la buena
voluntad.

### `Consentimiento`

El título que ampara el tratamiento. Vive en
`lib/dominio/consentimiento/consentimiento.dart`.

| Campo | Tipo | Notas |
|---|---|---|
| `nadadorId` | `String` | Sobre quién |
| `otorgadoPor` | `Otorgante` | Quién, con su calidad |
| `otorgadoEn` | `DateTime` | **Fecha del servidor** (D5, FR-017) |
| `alcances` | `Set<Alcance>` | Qué tratamientos cubre |
| `versionDelTexto` | `String` | Bajo qué texto informativo se otorgó (FR-018) |
| `menorFueOido` | `bool` | FR-021 |
| `revocadoEn` | `DateTime?` | Nulo mientras siga vigente |

**Invariantes**:

- `vigente` es `revocadoEn == null`. No es un campo que se escriba: se deriva, para que no
  pueda contradecir a la fecha.
- Revocar **no borra** `otorgadoEn` ni `otorgadoPor`. El registro de que hubo consentimiento
  previo es la prueba de que el tratamiento anterior estuvo amparado (FR-022).
- `alcances` nunca es un booleano único. `datosDeEntrenamiento` y `video` son alcances
  distintos y conceder uno no concede el otro (FR-023, SC-015).
- Un consentimiento con `alcances` vacío **no existe**: no se construye.

### `Otorgante`

| Campo | Tipo | Notas |
|---|---|---|
| `nombre` | `String` | Declarado |
| `documento` | `String` | Declarado |
| `calidad` | `String` | Padre, madre, acudiente, el propio nadador… texto libre |
| `esElPropioNadador` | `bool` | Verdadero cuando el nadador declaró ser mayor de edad |

**Lo que este tipo no promete**: nada de esto está verificado. Son declaraciones, y el
sistema registra **quién declaró qué y cuándo**. Está dicho en la especificación y se repite
aquí para que nadie lo lea como una identidad comprobada.

### `SolicitudDeConsentimiento`

El instrumento, distinto del consentimiento que produce.
`lib/dominio/consentimiento/solicitud.dart`.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | `String` | |
| `nadadorId` | `String` | |
| `resumenDelToken` | `String` | SHA-256 del token. **El token en claro no se guarda** (D4) |
| `canal` | `String` | Adónde se envió. Lo aporta el entrenador (FR-014) |
| `emitidaEn` | `DateTime` | Fecha del servidor |
| `venceEn` | `DateTime` | |
| `canjeadaEn` | `DateTime?` | Nulo mientras no se use |

**Invariantes**:

- `utilizable` exige las tres cosas: no canjeada, no vencida, y el token presentado coincide
  con el resumen. Las tres se comprueban **en el servidor**.
- Canjear es **idempotente en su efecto y único en su uso**: el segundo intento con el mismo
  token no produce un segundo consentimiento ni revive el primero; se rechaza.

### `PuertaDeConsentimiento`

Una interfaz del dominio con una sola pregunta, en
`lib/dominio/consentimiento/puerta.dart`:

```dart
abstract class PuertaDeConsentimiento {
  Future<bool> puedeSalir(String nadadorId);
}
```

Es lo que el `Sincronizador` consulta antes de soltar un envío (D6). Que sea una interfaz y
no una consulta a Firestore es lo que permite probar la retención entera en Dart puro, con un
doble, igual que ya se hace con el reloj y la red.

---

## Lo que cambia en entidades que ya existen

### `Nadador`

Gana un campo y **no** gana los que podría:

| Campo | Cambio | Por qué |
|---|---|---|
| `declaraSerMayorDeEdad` | **Nuevo**, `bool?` | FR-008. Es el dato mínimo suficiente para saber si hace falta acudiente. `null` significa que todavía no lo declaró, que no es lo mismo que menor |
| `fechaNacimiento` | **Sigue siendo opcional** | Minimización. Cuando sí está, permite advertir que alguien alcanzó la mayoría de edad (FR-009) |
| `categoria` | **Sin cambios** | Y eso es el requisito: FR-007 prohíbe derivarla de la edad. `Categoria` no tiene ni ha tenido ningún campo de edad, y SC-016 lo vigila con una prueba |

`esMenorEn(referencia)` ya devuelve `null` cuando no hay fecha de nacimiento, con el
comentario «no se supone la edad». Se conserva tal cual: era correcto antes de esta feature.

### `EnvioPendiente` y `EstadoDeEnvio`

**No cambian.** Es la decisión D6. Un registro retenido por falta de consentimiento es un
registro pendiente, y ya existe la forma de representarlo.

Lo único que cambia es que estar sin consentimiento, igual que estar sin conexión, **no
incrementa `intentos`** y no dispara la espera exponencial. No es un fallo.

---

## Esquema en Firestore

El esquema tiene que ser documentado y exportable, porque la constitución lo exige desde el
inicio para que migrar a una relacional siga siendo posible.

```text
planes/{planId}                         ← ya existe
  sesiones/{sesionId}                   ← ya existe
nadadores/{nadadorId}                   ← ya existe, gana declaraSerMayorDeEdad
registros/{registroId}                  ← ya existe, la regla cambia
consentimientos/{nadadorId}             ← NUEVO. Uno por nadador, el vigente
  historial/{consentimientoId}          ← NUEVO. Los anteriores, incluidos los revocados
solicitudes/{solicitudId}               ← NUEVO
usuarios/{uid}                          ← NUEVO. Vínculo cuenta ↔ nadadorId
```

**Por qué `consentimientos/{nadadorId}` y no `{consentimientoId}`**: la pregunta que la regla
hace en cada escritura es «¿este nadador tiene consentimiento vigente?». Con el identificador
del nadador como clave, es un `get()` directo; con una colección hay que consultar, y las
reglas no consultan. El historial cuelga debajo.

**Por qué `usuarios/{uid}` si el rol va en el claim**: el claim lleva el rol, que es lo que las
reglas necesitan en cada comprobación. El vínculo con el perfil de nadador es un dato más
grande y que cambia, y no tiene por qué viajar en cada token.

### Lo que no hay que migrar

Los registros de la feature 003 **ya llevan `nadadorId`**. La regla nueva compara contra él y
no hay que tocar ni un documento. Quedó prometido así en el `plan.md` de la 003 y se cumple.

---

## Reglas de acceso, en una tabla

| Colección | Entrenador | Nadador | Sin sesión |
|---|---|---|---|
| `planes` | Lee y escribe los suyos; nunca sobre un plan inmutable | Lee solo los `publicado` que le están asignados | Nada |
| `planes/*/sesiones` | Igual que el plan | Igual que el plan | Nada |
| `nadadores` | Lee y escribe los de su comunidad | Lee el suyo | Nada |
| `registros` | Lee los de su comunidad; **no** escribe | Escribe y lee **los suyos**, y solo con consentimiento vigente | Nada |
| `consentimientos` | Lee los de su comunidad | Lee el suyo | Nada |
| `consentimientos/*/historial` | Lee | Lee el suyo | Nada |
| `solicitudes` | Lee el estado | Nada | Nada |
| `usuarios` | Lee los de su comunidad | Lee el suyo | Nada |
| Todo lo demás | Denegado | Denegado | Denegado |

**Dos filas que merecen leerse dos veces.**

El entrenador **no escribe** en `registros`. Hoy sí puede, porque era la única forma de que la
colección no estuviera abierta sin identidad de nadador. Con cuentas, lo que el nadador
responde solo lo escribe el nadador: es su carga interna, no la del entrenador.

Ninguna escritura del cliente crea ni modifica `consentimientos` ni `solicitudes`. **Solo el
servidor**, porque la fecha es suya (D5) y el canje es suyo (D4).
