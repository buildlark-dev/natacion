# Fase 0 — Decisiones técnicas

**Feature**: cuentas, roles y consentimiento verificable
**Plan**: [plan.md](plan.md) · **Especificación**: [spec.md](spec.md)

Seis decisiones. La primera ordena las otras cinco.

---

## D1 — La puerta de consentimiento vive en las reglas de Firestore

**Decisión**: la condición «este nadador tiene consentimiento vigente» la comprueban las
**reglas de acceso del servidor**. El cliente la comprueba también, pero solo para no enviar
lo que va a rebotar y para explicárselo al nadador.

**Por qué**: una puerta que solo comprueba el cliente no es una puerta. Cualquiera con la app
modificada, o con el SDK de Firestore y las credenciales del proyecto, escribe lo que quiera.
El principio V no admite esa interpretación: si los datos de un menor sin consentimiento
pueden llegar al servidor, llegaron.

**Cómo**: las reglas de `registros/{id}` hacen `get()` del documento de consentimiento del
nadador y exigen `vigente == true`. Eso cuesta **una lectura facturada por escritura**.

**Alternativas descartadas**:

- **Desnormalizar `consentimientoVigente` en el documento del nadador**, para ahorrar el
  `get()`. Descartada: el ahorro es irrelevante a esta escala —decenas de nadadores— y
  duplicar el estado de la puerta en dos sitios crea la posibilidad de que discrepen. La
  puerta debe tener un solo sitio donde consultarse.
- **Comprobar solo en el cliente**: ver arriba.

**Consecuencia**: esta decisión es la que obliga a todo lo demás. Las reglas necesitan saber
el rol, el rol necesita ser infalsificable, y eso exige un servidor.

---

## D2 — El rol viaja en un custom claim, no en un documento

**Decisión**: el rol (`entrenador` | `nadador`) se guarda como **custom claim** del token de
Firebase Authentication. Las reglas lo leen con `request.auth.token.rol`.

**Por qué**: es lo que `firebase/firestore.rules` ya asume desde la feature 001, donde
`esEntrenador()` quedó escrita como marcador:

```javascript
function esEntrenador() {
  return request.auth != null
      && request.auth.token.get('rol', '') == 'entrenador';
}
```

Un claim lo firma el Admin SDK y el cliente no puede alterarlo. Leerlo en una regla no cuesta
nada: ya viene dentro del token.

**Alternativas descartadas**:

- **Un documento `usuarios/{uid}` con el rol**, leído con `get()` en cada regla. Descartada
  por dos razones: cuesta una lectura por comprobación en **todas** las reglas, no solo en las
  de registros; y para que no sea falsificable tendría que escribirlo igualmente el servidor,
  con lo que no ahorra el servidor, que era el único argumento a su favor.

**Lo que hay que resolver**: el primer entrenador. Nadie puede concederse el claim a sí mismo,
así que el rol `entrenador` se asigna por una operación administrativa explícita y **no** por
registro. Toda cuenta nueva nace con rol `nadador`. Queda como tarea con su prueba.

---

## D3 — El servidor son Cloud Functions en TypeScript

**Decisión**: **Cloud Functions de 2ª generación en TypeScript**, en `firebase/functions/`.

La constitución dejó esta elección pendiente:

> «Lógica de servidor […]: Cloud Functions en TypeScript, o Cloud Run con un servidor Dart
> `shelf` detrás de un *rewrite* de Hosting si se prefiere mantener todo en Dart. **La ruta
> elegida se documenta en el `plan.md` de la primera feature que la necesite.**»

Es esta feature. Queda elegida aquí.

**Por qué TypeScript y no Dart**:

1. **El Admin SDK.** Firmar custom claims y poner fechas de servidor es exactamente lo que
   hace el Admin SDK, que es de primera clase en Node y de tercera en Dart. Esto no es
   preferencia de lenguaje: es dónde está la pieza que necesitamos.
2. **El proyecto ya mantiene Node.** `firebase/package.json` existe desde la 001 para las
   pruebas de reglas, y `firebase-tools` ya está fijado en el CI. No se abre una cadena de
   herramientas nueva; se usa la que ya hay.
3. **Disparadores de Auth.** Asignar el rol por omisión al crearse una cuenta es un
   disparador que Cloud Run no tiene.

**Lo que se descarta y por qué**: **Cloud Run con Dart `shelf`** mantendría un solo lenguaje,
que es un argumento real para una persona sola. Se descarta porque obligaría a reimplementar
a mano lo que el Admin SDK ya hace, y porque añadir un servicio que desplegar, versionar y
vigilar es más superficie que una función.

**El coste, dicho claro**: es un segundo lenguaje en un proyecto de una sola persona.
Principio VII. Se contiene con una regla: **el servidor hace cuatro cosas y ninguna más.**

| Entra en el servidor | No entra nunca |
|---|---|
| Asignar el claim de rol | Lógica de metodología |
| Emitir una solicitud de consentimiento | Generación de planes |
| Canjear la confirmación y registrar el consentimiento | Auditoría |
| Revocar un consentimiento | Cualquier regla del dominio |

Si alguna vez hace falta una quinta, se discute antes de escribirla.

---

## D4 — El enlace de confirmación: de un solo uso, con vencimiento y guardado en resumen

**Decisión**: la solicitud de consentimiento genera un **token aleatorio** que viaja en el
enlace. En Firestore se guarda únicamente su **resumen SHA-256**, con su vencimiento y su
estado. Canjearlo lo consume.

**Por qué el resumen y no el token**: si se guardara el token en claro, cualquiera con acceso
de lectura a esa colección podría consentir en nombre de un acudiente. Guardando el resumen,
quien tenga la base de datos no puede fabricar el enlace. Es el mismo razonamiento que se
aplica a una contraseña, y vale aquí porque el token **es** la credencial.

**Dónde aterriza el enlace**: en una ruta de la propia app web, que llama a la función de
canje. Mantiene la página en español, con el mismo tema, y en un solo código base.

**Lo que esto no resuelve, y hay que decirlo**: un token en una URL es una credencial que
viaja en un enlace. Es lo que hace cualquier recuperación de contraseña, y es aceptable con un
solo uso, vencimiento y TLS. Pero si el enlace llega al canal equivocado —porque el contacto
estaba mal escrito— quien lo reciba puede consentir. Por eso existe el aviso de vuelta de
FR-019: no impide el error, lo hace **descubrible por el acudiente**.

**Alternativa descartada**: un código corto que el acudiente teclea. Más fácil de dictar por
teléfono, y mucho más fácil de adivinar. Para datos de menores, no.

---

## D5 — La fecha la pone el servidor

**Decisión**: la fecha de un consentimiento y la de su revocación se escriben con la marca de
tiempo del servidor, dentro de la función. El cliente **no** la propone.

**Por qué**: FR-017. La fecha de un consentimiento es un dato legal. Si la pone el
dispositivo, basta cambiar el reloj del teléfono para fechar una autorización en cualquier
día. La feature 003 ya hizo la distinción análoga con `registradoEn` y `recibidoEn`: ahí el
reloj del dispositivo **sí** importa, porque es cuándo entrenó el nadador, y por eso se
conserva y se contrasta. Aquí no hay nada que conservar del reloj del dispositivo.

---

## D6 — La retención del envío no necesita nada nuevo

**Decisión**: la bandeja de salida de la feature 003 gana **una condición más** para soltar un
envío: que haya consentimiento vigente. No se añade un estado, no se añade una cola, no se
toca `EstadoDeEnvio`.

**Por qué**: el contrato de sincronización ya dice que un registro pendiente espera sin
perderse y sin bloquear al nadador, y que **no hay estado terminal de fallo**. Un registro
retenido por falta de consentimiento es exactamente un registro pendiente. Modelarlo como algo
distinto duplicaría el mecanismo que ya funciona y ya está probado.

**Cómo**: el `Sincronizador` recibe una `PuertaDeConsentimiento` inyectada, que es una
interfaz del dominio con una sola pregunta. En pruebas se sustituye por un doble, igual que el
reloj y la red. Sigue siendo Dart puro.

**El detalle que importa**: estar sin consentimiento **no cuenta como intento fallido**, igual
que estar sin conexión no cuenta. No debe disparar la espera exponencial: no es un fallo, es
una condición que todavía no se cumple.

---

## Lo que esta fase deja resuelto, y lo que no

**Resuelto**: dónde vive la puerta, cómo viaja el rol, qué servidor, cómo se emite y se canjea
la confirmación, quién pone la fecha, y cómo se retiene el envío.

**No resuelto aquí, a propósito**:

- **Por qué canal sale la solicitud.** Correo o WhatsApp es una decisión de producto y de
  coste, y el contrato la deja como un puerto: la función entrega a un `EnviadorDeAvisos` y no
  sabe qué hay detrás. Se decide al implementar, sin que nada más dependa de ello.
- **El texto informativo.** Es redacción legal, no técnica. La especificación exige que esté
  versionado y que cada consentimiento conste bajo su versión; **qué dice** lo revisa un
  abogado, como quedó anotado en el checklist.
- **La auditoría de discrepancia de categoría** que la metodología 3.6.0 ahora permite. Es
  otra feature.
