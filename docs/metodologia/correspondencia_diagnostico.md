# Correspondencia entre diagnóstico y ejercicio correctivo

Registro de la tarea **T070** de la feature 002.

El generador elige ejercicios buscando el error diagnosticado dentro del campo
«error que corrige» de la Biblioteca Oficial (sección 19). Este documento recoge
las frases con las que el entrenador diagnostica de verdad, el ejercicio que le
corresponde a cada una, y los casos en que la Biblioteca y el diagnóstico no
coinciden.

**Estado: CONFIRMADO por el entrenador el 2026-10-07 e implementado.**

La tabla del §4 está volcada en
[`assets/biblioteca/terminos_diagnostico.json`](../../assets/biblioteca/terminos_diagnostico.json),
que es el índice que consulta el generador. Las 40 correspondencias están fijadas
por pruebas: si alguien rompe una que él aprobó, falla
`test/dominio/biblioteca/indice_terminos_test.dart`.

Queda **una entrada pendiente de confirmar**, señalada en el índice como
`"origen": "heredada"`: `agarre del agua` → `VADEO`, `PUÑOS`. No está en la lista
de 40, pero ya funcionaba con la búsqueda anterior porque la ficha de `VADEO`
dice «Falta de sensibilidad y agarre del agua». Se mantuvo para no perder una
correspondencia que servía.

### Lo que cambió al implementarlo

- Se retiraron del índice, por decisión suya, tres ejercicios que corregían el
  error contrario al diagnosticado: `CHUTAR EL AGUA – DOBLAR RODILLA` (de E3 y
  E4), `TOCANDO FRENTE` (de E6) y `DELFINEO` (de M4). Siguen en la Biblioteca
  con su propio error: lo que se retiró es la correspondencia, no el ejercicio.
- `PN EN SOLDADO` salió de M8, también por decisión suya.
- Los cinco vacíos del §2 dejaron de serlo. Ninguno necesitaba un ejercicio
  nuevo: la sección 19 ya los cubría, solo faltaba que él dijera cuál.
- `2-2-2` entró en M7 y M9.

## Resultado de la comprobación inicial

De **40 frases** reales del entrenador, el generador solo encontraba ejercicio
para **2**:

| Frase | Estilo | Por qué sí coincide |
|---|---|---|
| `rolido insuficiente` | Libre | La ficha dice literalmente «Rolido insuficiente/excesivo» |
| `cabeza levantada` | Espalda | La ficha dice literalmente «cabeza levantada / cadera hundida» |

Las otras 38 fallan. **No porque falten ejercicios**, sino porque la búsqueda
exige que la frase aparezca literal dentro del texto de la ficha. `rolido
insuficiente` coincide en Libre y falla en Espalda, donde la misma idea está
escrita «Rolido de cadera/hombro insuficiente»: las dos palabras quedan
separadas por otras tres.

Esto confirma lo que la tarea T070 sospechaba y acota la causa: **el problema no
es la Biblioteca, es el método de búsqueda.**

---

## 1. Decisiones que requieren al entrenador

Cuatro casos donde la Biblioteca y el diagnóstico se contradicen. No los resuelvo
por mi cuenta porque elegir mal aquí significa **prescribir un ejercicio que
refuerza el error en lugar de corregirlo**.

### 1.1 Espalda · «patada desde las rodillas» y «patada caída»

Señalaste dos ejercicios, y corrigen errores **opuestos**:

| Ejercicio | Qué dice que corrige | Qué hace el ejercicio |
|---|---|---|
| `CHUTAR EL AGUA – DOBLAR RODILLA` | Patada con rodillas **en extensión** | **Añade** flexión de rodilla |
| `PATADA MI EXTENDIDOS – ANTI-BICICLETA` | Patada **tipo bicicleta** (exceso de rodilla) | **Quita** flexión de rodilla |

«Patada desde las rodillas» es exceso de rodilla, así que le corresponde
`PATADA MI EXTENDIDOS – ANTI-BICICLETA`. `CHUTAR EL AGUA – DOBLAR RODILLA` corregiría el error contrario.

**Pregunta:** ¿los nombraste como pareja de contraste, para que el nadador
sienta los dos extremos? Si es así lo registro como progresión y no como
correctivo, porque el generador los prescribiría a la vez.

**Respuesta** Aquí me equivoqué, funciona como tu lo sospechas que debería funcionar, arréglalo y quita el ejercicio que no corrige.

### 1.2 Espalda · «brazo flexionado en fase aérea»

Señalaste `TOCANDO FRENTE` y `MANO AL CIELO`. Pero la ejecución de
`TOCANDO FRENTE` es, literalmente: «en la fase aérea, **flexionar el codo** para
tocar la frente y volver a estirar». Y su ficha dice que corrige «recobro con
brazo **rígido**».

Es decir: para el error «brazo flexionado en fase aérea», ese ejercicio hace
exactamente lo que quieres eliminar. `MANO AL CIELO` sí encaja: brazos quietos,
uno apuntando al cielo, que es la posición extendida.

**Pregunta:** ¿`TOCANDO FRENTE` lo usas como paso previo —sentir el recorrido
antes de extenderlo— o fue un desliz al listarlo?

**Respuesta** Quita ese ejercicio, no sirve. Error mío.

### 1.3 Mariposa · «brazos no salen del agua»

| Ejercicio | Qué hace |
|---|---|
| `DELFINEO` | Los brazos **regresan por dentro** del agua |
| `DELFINEO COMPLETO` | Los brazos **regresan por fuera** del agua |

Para ese error corresponde `DELFINEO COMPLETO`. `DELFINEO` es el ejercicio donde
los brazos justamente no salen.

**Respuesta** Delfineo no corrige la fase aérea de la brazada, más bien ayuda a sincronizar el primer recorrido de la brazada con la respiración. (el timing)
Y el Delfineo completo si corrige la brazada y el timing.

### 1.4 Mariposa · «muchas patadas por cada brazada»

`DELFÍN 2 BATIDAS – ENTRADA/SALIDA` fija dos batidas por ciclo, así que sirve
para tu error. Pero su ficha solo nombra el error contrario: «un solo batido por
ciclo». **Propongo** que la ficha nombre los dos sentidos, porque el ejercicio
corrige ambos.

**Respuesta** Córrelo así como lo propones.

---

## 2. Vacíos reales de la Biblioteca

Aquí no hay ejercicio que corresponda. Según la regla R2 no se sustituye por uno
aproximado: el generador reporta el vacío.

| Frase | Estilo | Lo más cercano que existe | Observación |
|---|---|---|---|
| `dosiflexión` · `patada sin flexionar tobillos` · `patada con plantiflexión` | Pecho | `TOCANDO TALÓN/TOBILLO` | **Ningún ejercicio de pecho menciona el tobillo ni la dorsiflexión.** Son tres frases tuyas para el mismo error, y es un error central de la patada de pecho |
| `respira al frente` | Libre | — | Ningún ejercicio de libre trata la respiración |
| `brazada cruzada` | Libre | `ROTAR PALMAS EN RECUPERACIÓN` | Ese corrige la orientación de la mano, no que cruce la línea media |
| `separa los pies` | Mariposa | `FLECHA (Mariposa)` | Ningún ejercicio de mariposa menciona los pies juntos |
| `brazos flexionados en el recobro` | Mariposa | `DELFINEO COMPLETO` | Ningún ejercicio trata la forma del brazo en el recobro de mariposa |

**Decisión tuya:** o añadimos ejercicios a la sección 19, o aceptamos que el
generador reporte el vacío en estos casos y los resuelvas a mano.

**Respuesta**
Para las 3 de pecho aplica Tocando Talón/Tobillo.
Para respirar al frente, se corrige con ejercicios de patada de libre en flecha. La flecha debe estar bien hecha, cabeza abajo y brazos pegados a la cabeza.
Brazada cruzada se corrige con punto muerto
Separar los pies se corrige con patada en soldado o en flecha pero es más el énfasis que haga el entrenador en su momento.
Brazos flexionados en el recobro con Delfineo completo o 2-2-2 y el énfasis que se haga en su momento por parte del entrenador.
---

## 3. Frases que significan cosas distintas según el contexto

Dos frases tuyas apuntan a errores distintos según dónde ocurran. El generador
necesita saber cuál, porque los ejercicios no son los mismos.

| Frase | Si ocurre... | Ejercicio |
|---|---|---|
| `codo bajo` | en el **recobro** | `TOCAR AXILA`, `ROZAR SUPERFICIE` |
| | en la **tracción** (codo caído en el agarre) | `TRACC`, `PUÑOS`, `VADEO`, `REMO` |
| `mirada al frente` | **nadando** | `PATADA MIRANDO EL FONDO` |
| | en la **aproximación al viraje** | `SIN RESPIRAR ANTES DEL VIRAJE` |

**Respuesta** 
Codo bajo apunta al recobro ahí tienes los ejercicios
codo caído en el agarre también tienes los ejercicios correctos
Mirada al frente se corrige con patada mirando al fondo, está correcto, o patada en flecha.
Todo esta ok aquí
---

## 4. Tabla de correspondencia propuesta

Marca cada fila: **OK** si corresponde, o escribe el ejercicio correcto.

### Libre

| # | Frase | Ejercicio propuesto | Secundarios |
|---|---|---|---|
| L1 | `rolido insuficiente` | `ROLIDO (Libre)` | `ROLIDO CON 1 BRAZO (Libre)`, `3+3 PATADA LATERAL` | OK
| L2 | `poco rolido` | `ROLIDO (Libre)` | igual que L1 | OK
| L3 | `no gira la cadera` | `3+3 PATADA LATERAL` | `ROLIDO (Libre)` | OK
| L4 | `codo bajo` | ver §3 | — | OK 
| L5 | `cabeza alta` | `PATADA MIRANDO EL FONDO` | `FLECHA (Libre)` | OK
| L6 | `mirada al frente` | ver §3 | — | OK
| L7 | `cadera abajo` | `PATADA MIRANDO EL FONDO` | `FLECHA (Libre)`, `DESLIZAMIENTO HIDRODINÁMICO` | OK
| L8 | `cadera caída` | `PATADA MIRANDO EL FONDO` | igual que L7 | OK
| L9 | `piernas caídas` | `PATADA MIRANDO EL FONDO` | `FLECHA (Libre)`, `BAND` | OK
| L10 | `brazada cruzada` | **vacío** (ver §2) | `ROTAR PALMAS EN RECUPERACIÓN` | YA TE LO ANOTÉ EN §2
| L11 | `empujes cortos` | `PULGAR ROZA EL MUSLO` | `TRACC`, `REMO` | OK
| L12 | `patada desde rodillas` | `PATADA CORTA – PIES CON ESPUMA` | ¿usar `PATADA MI EXTENDIDOS – ANTI-BICICLETA`, que es de Espalda? | OK
| L13 | `respira al frente` | **vacío** (ver §2) | — |RESPONDIDO EN §2

Nota sobre L7-L9: ninguna ficha de libre menciona la cadera en su campo de error,
aunque la **descripción** de `PATADA MIRANDO EL FONDO` sí dice «cadera alta». El
campo de error habría que completarlo.

### Espalda

| # | Frase | Ejercicio propuesto | Secundarios |
|---|---|---|---|
| E1 | `rolido insuficiente` | `ROLIDO (Espalda)` | `ROLIDO CON 1 BRAZO (Espalda)`, `3+3 PATADA LATERAL (Espalda)` |OK
| E2 | `cabeza alta` · `cabeza levantada` | `PATADA MIRANDO EL TECHO` | `FLECHA (Espalda)` | OK
| E3 | `patada desde las rodillas` | `PATADA MI EXTENDIDOS – ANTI-BICICLETA` | ver §1.1 | RESPONDIDO EN §1
| E4 | `patada caída` | `PATADA MI EXTENDIDOS – ANTI-BICICLETA` | `PATADA MIRANDO EL TECHO` · ver §1.1 | RESPONDIDO EN §1
| E5 | `cadera caída` | `PATADA MIRANDO EL TECHO` | `FLECHA (Espalda)` | OK
| E6 | `brazo flexionado en fase aérea` | `MANO AL CIELO` | ver §1.2 | OK

### Pecho

| # | Frase | Ejercicio propuesto | Secundarios |
|---|---|---|---|
| P1 | `dosiflexión` | **vacío** (ver §2) | `TOCANDO TALÓN/TOBILLO` | RESPONDIDO EN §2 OK
| P2 | `patada sin flexionar tobillos` | **vacío** (ver §2) | `TOCANDO TALÓN/TOBILLO` | OK RESPONDIDO EN §2
| P3 | `patada con plantiflexión` | **vacío** (ver §2) | `TOCANDO TALÓN/TOBILLO` | OK
| P4 | `saca los pies del agua` | `MI × RESPIRACIÓN (Pecho)` | — | OK
| P5 | `mirada al frente` | `MI × RESPIRACIÓN (Pecho)` | `FLECHA (Pecho)` | OK
| P6 | `cabeza arriba` | `MI × RESPIRACIÓN (Pecho)` | `FLECHA (Pecho)` | OK
| P7 | `no coordina el estilo` | `BRAZA 1-2-3` | `2 PN X 1 BR`, `COORD DE EXTREMIDADES` | OK
| P8 | `patada y brazada al mismo tiempo` | `BRAZA 1-2-3` | `2 PN X 1 BR` | OK
| P9 | `baja las manos hasta la cadera` | `BRAZADA CORTA – CODOS JUNTOS` | — | OK
| P10 | `no desliza` | `FLECHA (Pecho)` | `BRAZA 1-2-3`, `TALÓN A LAS MANOS – DORSAL/VENTRAL` |OK
| P11 | `sin timing` | `BRAZA 1-2-3` | `2 PN X 1 BR` | OK

`MI × RESPIRACIÓN (Pecho)` cubre P4, P5 y P6 porque su ficha dice «cuerpo poco
inclinado; pies que emergen». Es la única que nombra los pies emergiendo.

### Mariposa

| # | Frase | Ejercicio propuesto | Secundarios |
|---|---|---|---|
| M1 | `patada desde las rodillas` | `SACAR LA CADERA – ONDULACIÓN` | `FLECHA (Mariposa)` | OK
| M2 | `no mueve la cadera` | `SACAR LA CADERA – ONDULACIÓN` | `DELFINEO` | OK
| M3 | `separa los pies` | **vacío** (ver §2) | `FLECHA (Mariposa)` | RESPONDIDO EN §2
| M4 | `brazos no salen del agua` | `DELFINEO COMPLETO` | ver §1.3 | OK
| M5 | `cabeza levantada siempre` | `PN EN SOLDADO` | `FLECHA (Mariposa)` | OK
| M6 | `no empuja hasta la cadera` | `PULGAR ROZA EL MUSLO (Mariposa)` | — | OK
| M7 | `brazos flexionados en el recobro` | **vacío** (ver §2) | `DELFINEO COMPLETO` | OK
| M8 | `no lleva las manos hasta adelante` | `PN EN SOLDADO` | `FLECHA (Mariposa)`, `DELFINEO COMPLETO` | OK SIN PN EN SOLDADO
| M9 | `sin timing` | `DELFÍN 2 BATIDAS – ENTRADA/SALIDA` | `DELFINEO COMPLETO` | OK Y 2-2-2
| M10 | `muchas patadas por cada brazada` | `DELFÍN 2 BATIDAS – ENTRADA/SALIDA` | ver §1.4 | OK

---

## 5. Qué hay que cambiar en la app

La búsqueda literal no sirve, y subirle tolerancia por parecido de letras sería
peor: haría coincidir `patada` con `brazada` antes que `dosiflexión` con
`dorsiflexión`.

Lo que corresponde es un **índice de términos** por ejercicio: cada ejercicio
declara las formas en que el entrenador nombra el error que corrige, y el
generador busca sobre ese índice en lugar de sobre la prosa. Así `poco rolido`,
`rolido insuficiente` y `no gira la cadera` llegan al mismo ejercicio sin que la
prosa de la ficha cambie, y `dosiflexión` encuentra lo mismo que `dorsiflexión`.

Lo importante: **el índice lo declara el entrenador, no lo adivina la app.** Un
término que él no haya aprobado no entra, y una frase sin término sigue
reportándose como vacío. Esa es la diferencia entre ampliar su vocabulario y
suplantar su criterio.

La tabla del §4, una vez confirmada, **es** ese índice.

### Cómo quedó implementado

La correspondencia va por **palabras significativas**, no por texto literal ni
por parecido de letras. Los términos de la entrada tienen que estar todos en la
frase diagnosticada; la frase puede decir más, pero no menos.

Consecuencias prácticas:

| Caso | Resultado | Por qué |
|---|---|---|
| `patada desde rodillas` ≡ `patada desde las rodillas` | misma cosa | los artículos no cuentan |
| `patada caida` ≡ `patada caída` | misma cosa | las tildes no cuentan |
| `tiene el codo bajo en el recobro` → `TOCAR AXILA` | encuentra | la frase dice más que el término |
| `patada` a secas | reporta vacío | demasiado genérica para elegir un correctivo |
| `no gira la cadera` ≠ `gira la cadera` | distintas | **la negación no se descarta**: son errores opuestos |

Lo que **no** hace: comparar por parecido de letras. Esa tolerancia haría
coincidir `patada` con `brazada` antes que `dosiflexión` con `dorsiflexión`.
Las dos grafías de esa palabra están en el índice como entradas propias, que es
la forma honesta de resolverlo.

Tampoco hay vía de respaldo por la prosa de la ficha. Una frase que no esté
declarada se reporta como vacío, y el bloque técnico de la sesión se completa
con la progresión de la sección 15 —porque una sesión no puede quedarse sin
técnica—, pero **nunca** con un ejercicio elegido a ojo para ese error.

El índice no toca la sección 19. La prosa del campo «error que corrige» queda
intacta, así que la versión de la metodología no cambia y los planes aprobados
conservan su trazabilidad.
