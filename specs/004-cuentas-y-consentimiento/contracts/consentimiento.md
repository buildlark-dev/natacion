# Contrato — consentimiento verificable

**Feature**: 004 · **Modelo**: [data-model.md](../data-model.md) ·
**Decisiones**: [research.md](../research.md)

Lo que promete este contrato y lo que no:

> El consentimiento registrado es **demostrable, no infalsificable**. Permite probar qué se
> autorizó, por quién según su propia declaración, cuándo y bajo qué texto. **No** prueba la
> identidad de quien confirmó, y **no** exime al entrenador de su responsabilidad como
> Responsable del Tratamiento bajo la Ley 1581 de 2012.

Está escrito aquí, en la especificación y en el checklist. Tres veces a propósito: es lo
primero que alguien va a dar por sentado.

---

## Las cuatro operaciones del servidor

Y ninguna más (D3).

### 1. `emitirSolicitud(nadadorId, canal, alcances)`

Llamable **solo por el entrenador**.

1. Genera un token aleatorio criptográficamente seguro.
2. Guarda la solicitud con el **resumen SHA-256** del token, el canal, la fecha del servidor y
   el vencimiento. El token en claro no se guarda en ninguna parte.
3. Entrega el enlace al `EnviadorDeAvisos`, que es un puerto: la función no sabe si detrás hay
   correo o mensajería.

### 2. `canjear(token, declaracion)`

Pública, porque la abre el acudiente, que no tiene cuenta.

1. Resume el token y busca la solicitud. Si no existe, si venció o si ya se canjeó, **rechaza
   sin decir cuál de las tres**.
2. Exige la declaración completa: nombre, documento, calidad, que es el representante legal, y
   que **el menor fue oído**.
3. Escribe el consentimiento con la **fecha del servidor**.
4. Marca la solicitud como canjeada.
5. Avisa al mismo canal de que quedó registrado.

### 3. `revocar(token | sesión del acudiente)`

Registra `revocadoEn` con fecha del servidor. No borra nada de lo anterior.

### 4. `asignarRol(uid, rol)`

Administrativa. Firma el custom claim. No es llamable desde la app.

---

## Garantías

### C1 — El nadador no designa quién consiente por él

El canal lo aporta el entrenador desde su matrícula. Ninguna ruta permite que el nadador, ni
nadie sin rol de entrenador, proponga, edite o añada el canal.

**Se comprueba**: con cuenta de nadador se intenta emitir una solicitud y se intenta cambiar
el canal de una existente. Las dos se deniegan.

**Por qué es la garantía más importante de este contrato**: es la que cierra el agujero obvio
—un niño poniendo un correo suyo— y es lo que hace que el resto de la cadena signifique algo.

### C2 — Un solo uso

Canjeado un token, deja de servir. El segundo intento no crea un segundo consentimiento ni
revive el primero.

**Se comprueba**: se canjea, se vuelve a canjear el mismo token y se verifica que se rechaza y
que hay **exactamente un** consentimiento.

### C3 — Vence

Un token no canjeado deja de servir pasado su plazo.

**Se comprueba**: con el reloj adelantado más allá del vencimiento, el canje se rechaza.

### C4 — El token en claro no está en la base de datos

Solo su resumen. Quien tenga acceso de lectura a `solicitudes` no puede fabricar un enlace
válido.

**Se comprueba**: tras emitir, se lee el documento y se verifica que el token no aparece y que
lo que hay no permite reconstruirlo.

### C5 — La fecha es del servidor

`otorgadoEn` y `revocadoEn` las escribe el servidor. El cliente no las propone y, si las
envía, se ignoran.

**Se comprueba**: se canjea con el reloj del cliente adelantado un año y se verifica que la
fecha registrada es la del servidor.

### C6 — El alcance no se concede en bloque

`datosDeEntrenamiento` y `video` son alcances distintos. Conceder uno no concede el otro.

**Se comprueba**: con un consentimiento que cubre entrenamiento y no video, se intenta
habilitar la carga de video. Se deniega (SC-015).

### C7 — Consta que el menor fue oído

El consentimiento no se registra sin esa constancia.

**Se comprueba**: se intenta canjear sin ella y se rechaza.

**Lo que esta garantía es**: la constancia de una declaración, no la verificación de un hecho.
El sistema registra que quien confirmó declaró haber oído al menor.

### C8 — Revocar no borra el pasado

`otorgadoEn` y `otorgadoPor` sobreviven a la revocación. Lo que cambia es la vigencia.

**Se comprueba**: se revoca y se verifica que el historial conserva quién otorgó y cuándo, y
que `vigente` pasa a falso.

**Por qué**: ese registro es la prueba de que el tratamiento anterior estuvo amparado. Borrarlo
al revocar destruiría justamente la evidencia que protege al entrenador.

### C9 — El acudiente se entera de lo que se registró

Tras un canje, sale un aviso al mismo canal.

**Se comprueba**: se canjea y se verifica que el enviador recibió el aviso dirigido a ese
canal.

**Lo que esta garantía logra**: no impide que un enlace mal dirigido se canjee. Lo hace
**descubrible por el acudiente**, que es lo máximo que un mecanismo digital sin verificación
documental puede ofrecer.

### C10 — El acudiente revoca sin pedir permiso

Desde el mismo canal, sin tener que pasar por el entrenador.

**Se comprueba**: se revoca sin cuenta de entrenador y se verifica que surte efecto.

---

## Garantías de la puerta

### P1 — Sin consentimiento, el servidor rechaza

La regla de `registros` deniega la escritura si el nadador no tiene consentimiento vigente,
**aunque el cliente lo intente**.

**Se comprueba**: directamente contra el emulador, saltándose la app, con la cuenta correcta
del nadador. Se deniega.

**Por qué se comprueba así y no por la interfaz**: una puerta que solo prueba a través de su
propia pantalla no está probada.

### P2 — Sin consentimiento, el nadador no queda bloqueado

Entra, lee lo que tenga y anota. Lo que escribe se queda en su bandeja.

**Se comprueba**: con un nadador sin consentimiento se recorre la app entera y se verifica que
no hay un solo punto que exija consentimiento para continuar (SC-002).

### P3 — Lo retenido sale solo

Otorgado el consentimiento, lo pendiente se envía sin que el nadador repita nada.

**Se comprueba**: se anota sin consentimiento, se otorga, y se verifica que el registro llega
con su contenido intacto y sin intervención (SC-003).

### P4 — Esperar consentimiento no es fallar

Estar sin consentimiento no incrementa `intentos` ni dispara la espera exponencial, igual que
no la dispara estar sin conexión.

**Se comprueba**: en Dart puro, con la puerta cerrada, muchos ciclos del sincronizador dejan
`intentos` en cero.

**Por qué**: si contara como fallo, un consentimiento que tarda una semana dejaría el envío
esperando cinco minutos entre intentos por una condición que no es un error.

### P5 — Sin consentimiento no se publica

Un plan no se publica a un nadador sin consentimiento vigente, y el entrenador ve qué falta.

**Se comprueba**: se intenta publicar y se deniega, en la regla y en la interfaz.

### P6 — Revocar corta el flujo

Revocado el consentimiento, los datos de ese nadador dejan de fluir desde ese momento.

**Se comprueba**: con consentimiento vigente se envía un registro; se revoca; el siguiente se
deniega.
