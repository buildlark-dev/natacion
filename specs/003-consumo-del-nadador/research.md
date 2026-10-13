# Investigación — Feature 003: el nadador consume su plan

**Fecha**: 2026-10-13
**Especificación**: [spec.md](spec.md)

Esta feature tiene una sola decisión difícil —cómo se garantiza el funcionamiento sin
conexión— y cuatro que se derivan de ella. El resto es ensamblaje sobre lo que 001 y 002
ya dejaron construido.

---

## D1. Cómo se garantiza el funcionamiento sin conexión

**La restricción no es negociable.** La constitución dice que consultar los planes propios,
la sesión del día y el progreso propio **nunca debe requerir red**, y que ningún dato
escrito sin conexión se pierde en silencio. Esto no es una mejora: es el contexto de uso.
La señal en las piscinas es mala, y una app que exige red para anotar es una app que no se
usa.

### Decisión

**Dividir el problema en dos, porque son dos problemas distintos:**

| | Mecanismo | Por qué |
|---|---|---|
| **Lectura** del plan y las sesiones | Caché de Firestore (persistencia activada) | Reimplementar una caché de lectura sería trabajo desperdiciado: Firestore ya la trae y ya sabe invalidarla |
| **Escritura** de los registros del nadador | **Bandeja de salida propia, en el dominio** | Nos hace falta control sobre tres cosas que la cola interna de Firestore no nos da |

### Por qué la escritura no se delega a Firestore

Firestore encola las escrituras sin conexión y las envía al volver la red, y
`SnapshotMetadata.hasPendingWrites` permitiría pintar el aviso. Es tentador y es casi
gratis. Se descarta por tres razones concretas:

1. **No se puede probar.** El principio III exige probar las reglas que llegan al nadador.
   Una bandeja de salida escrita por nosotros se prueba en Dart puro, con el reloj y la red
   simulados. La cola interna de Firestore no: probarla sería probar Firebase.
2. **No da control sobre la idempotencia.** FR-020 exige que un registro reenviado no se
   duplique. Con una bandeja propia el identificador del registro es determinista y el
   reenvío sobrescribe. Con la cola interna dependemos de que el reintento conserve la
   referencia del documento.
3. **El estado pendiente deja de ser un detalle de Firestore y pasa a ser dominio.**
   «Guardado el progreso, se enviará cuando tengas acceso a internet» es una regla de
   producto, no un reflejo de `hasPendingWrites`. El principio II exige que el dominio no
   sepa qué base de datos hay debajo.

### Lo que esto significa y conviene no ocultar

**La lectura sin conexión solo cubre lo que ya se descargó alguna vez.** Un nadador que
nunca abrió la app con red no tiene nada que leer, y ningún mecanismo lo arregla. La
promesa realista, y la que la feature cumple, es: **una vez obtenido el plan, consultarlo no
vuelve a necesitar red**.

De ahí sale un requisito de diseño que la especificación no pedía explícitamente: la app
debe dejar claro **cuándo se sincronizó por última vez**, para que el nadador sepa si lo
que ve está al día.

### Alternativas consideradas

- **Persistencia de Firestore para todo.** Descartada por las tres razones de arriba.
- **Base de datos local propia (`drift`, `hive`, `sqflite`).** Resolvería lectura y
  escritura con un solo mecanismo, pero añade una dependencia grande, un esquema que
  mantener y migraciones, para duplicar una caché que ya existe. El principio VII pide
  eliminar la complejidad que no se justifica.
- **Exigir una acción explícita de «descargar para usar sin conexión».** Traslada al
  nadador un problema que es nuestro. Se descarta como mecanismo, pero se conserva su
  parte útil: mostrar la fecha de última sincronización.

---

## D2. Cómo se identifica un registro para que no se duplique

**Decisión**: el identificador del registro es **determinista** y se deriva de
`(nadadorId, planId, sesionId, versionDePlan)`. Reenviar el mismo registro sobrescribe el
mismo documento.

**Razón**: hay exactamente un registro por nadador, sesión y versión de plan. Un
identificador aleatorio obligaría a deduplicar en el destino; uno determinista hace que la
duplicación sea imposible por construcción, que es como esta base de código resuelve el
resto de sus invariantes.

**Alternativa considerada**: identificador aleatorio más una clave de idempotencia aparte.
Es lo habitual cuando la misma entidad puede repetirse legítimamente —varios pagos iguales,
por ejemplo—. Aquí no puede: un nadador no realiza dos veces la misma sesión de la misma
versión del plan. Si algún día la respuesta pasa a ser un historial de ediciones, esta
decisión se revisa.

---

## D3. De quién es la hora

**Decisión**: el registro guarda **dos** marcas de tiempo.

- `registradoEn`: la del dispositivo, en el momento en que el nadador marca o escribe. Es
  la que ve el entrenador, porque es cuándo entrenó.
- `recibidoEn`: la del servidor, al llegar. Es la que ordena y la que permite detectar un
  reloj desajustado.

**Razón**: el caso límite del reloj mal puesto es real —un teléfono con la fecha corrida
mandaría registros al pasado o al futuro— y resolverlo con una sola marca obliga a elegir
entre perder la verdad del nadador o perder el orden. Guardar las dos cuesta un campo.

**Qué no se hace**: corregir la hora del dispositivo automáticamente. Si las dos marcas
difieren de forma absurda, se muestra; no se arregla. Es la regla R3 de la metodología
aplicada al tiempo: ante un dato que no cuadra se avisa, no se supone.

---

## D4. Quién es el nadador, si todavía no hay cuentas

**Decisión**: el perfil activo se elige **localmente**, entre los perfiles de nadador que
la feature 001 ya guarda. No hay autenticación de nadador en esta feature.

**Razón**: las cuentas, los roles y el registro de consentimiento son la feature 004, y el
principio V es explícito en que **mientras no exista ese registro la app se usa solo con
datos de prueba o del propio entrenador**. Construir media autenticación aquí sería
construirla dos veces.

**La consecuencia incómoda, dicha en voz alta**: las reglas de acceso de Firestore no
pueden distinguir a un nadador de otro sin identidad. En esta feature la colección de
registros **se escribe únicamente con el rol de entrenador** y deniega al resto, igual que
todo lo demás hoy. Las reglas por nadador se escriben en 004.

Eso **no** relaja el principio III: las reglas de la colección nueva se prueban con sus
casos negativos desde esta feature. Lo que se prueba es lo que hay — que nadie sin rol
escribe — y en 004 se añade lo que falta.

**Alternativa considerada**: adelantar un identificador de nadador a las reglas y
escribirlas como si la identidad existiera. Daría una falsa sensación de protección: una
regla que compara contra un identificador que cualquiera puede declarar no protege nada.

---

## D5. Qué formato tiene la descarga

**Decisión**: reutilizar `Exportacion` de la feature 001, añadiendo una variante para el
nadador que incluye **sus registros** junto al plan.

**Razón**: ya existe, ya produce un documento legible sin la app y ya está probada. El
principio V pide portabilidad, no un formato nuevo. Y la constitución recuerda que la
descarga «es una copia para archivo o impresión, **no el producto**»: inventarle un formato
propio invertiría esa prioridad.

**Alternativa considerada**: generar un PDF imprimible. Es lo que un nadador probablemente
quiere llevarse al borde de la piscina, pero añade una dependencia de maquetación para algo
que la constitución clasifica como secundario. Queda anotado como posible mejora, no como
alcance de esta feature.

---

## D6. Dónde vive la adherencia

**Decisión**: el cálculo de adherencia vive en el **dominio**, en Dart puro, y cuenta
**sesiones y nada más**.

**Razón**: es una regla de producto comprobable, y el principio VIII prohíbe combinar carga
externa e interna en un mismo indicador. Una adherencia que ponderara por metros o por RPE
sería exactamente ese indicador prohibido. Contar sesiones es aburrido a propósito.

**Lo que se prueba**: que el recuento no cambia al variar el RPE ni los metros (SC-011). Es
una prueba que parece trivial y no lo es: impide que alguien «mejore» el indicador más
adelante sin darse cuenta de que está rompiendo un principio.
