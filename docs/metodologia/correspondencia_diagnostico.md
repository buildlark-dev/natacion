# Correspondencia entre diagnóstico y ejercicio correctivo

Registro de la tarea **T070** de la feature 002.

El generador elige ejercicios buscando el error diagnosticado dentro del campo
«error que corrige» de la Biblioteca Oficial (sección 19). Este documento recoge
las frases con las que el entrenador diagnostica de verdad, el ejercicio que le
corresponde a cada una, y los casos en que la Biblioteca y el diagnóstico no
coinciden.

**Estado:** propuesta pendiente de confirmación del entrenador. Ningún ejercicio
de esta tabla se incorpora al generador sin su visto bueno (regla R2: no
invención; principio IV: el criterio del entrenador no se delega).

## Resultado de la comprobación

De **40 frases** reales del entrenador, el generador solo encuentra ejercicio
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

### 1.3 Mariposa · «brazos no salen del agua»

| Ejercicio | Qué hace |
|---|---|
| `DELFINEO` | Los brazos **regresan por dentro** del agua |
| `DELFINEO COMPLETO` | Los brazos **regresan por fuera** del agua |

Para ese error corresponde `DELFINEO COMPLETO`. `DELFINEO` es el ejercicio donde
los brazos justamente no salen.

### 1.4 Mariposa · «muchas patadas por cada brazada»

`DELFÍN 2 BATIDAS – ENTRADA/SALIDA` fija dos batidas por ciclo, así que sirve
para tu error. Pero su ficha solo nombra el error contrario: «un solo batido por
ciclo». **Propongo** que la ficha nombre los dos sentidos, porque el ejercicio
corrige ambos.

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

---

## 4. Tabla de correspondencia propuesta

Marca cada fila: **OK** si corresponde, o escribe el ejercicio correcto.

### Libre

| # | Frase | Ejercicio propuesto | Secundarios |
|---|---|---|---|
| L1 | `rolido insuficiente` | `ROLIDO (Libre)` | `ROLIDO CON 1 BRAZO (Libre)`, `3+3 PATADA LATERAL` |
| L2 | `poco rolido` | `ROLIDO (Libre)` | igual que L1 |
| L3 | `no gira la cadera` | `3+3 PATADA LATERAL` | `ROLIDO (Libre)` |
| L4 | `codo bajo` | ver §3 | — |
| L5 | `cabeza alta` | `PATADA MIRANDO EL FONDO` | `FLECHA (Libre)` |
| L6 | `mirada al frente` | ver §3 | — |
| L7 | `cadera abajo` | `PATADA MIRANDO EL FONDO` | `FLECHA (Libre)`, `DESLIZAMIENTO HIDRODINÁMICO` |
| L8 | `cadera caída` | `PATADA MIRANDO EL FONDO` | igual que L7 |
| L9 | `piernas caídas` | `PATADA MIRANDO EL FONDO` | `FLECHA (Libre)`, `BAND` |
| L10 | `brazada cruzada` | **vacío** (ver §2) | `ROTAR PALMAS EN RECUPERACIÓN` |
| L11 | `empujes cortos` | `PULGAR ROZA EL MUSLO` | `TRACC`, `REMO` |
| L12 | `patada desde rodillas` | `PATADA CORTA – PIES CON ESPUMA` | ¿usar `PATADA MI EXTENDIDOS – ANTI-BICICLETA`, que es de Espalda? |
| L13 | `respira al frente` | **vacío** (ver §2) | — |

Nota sobre L7-L9: ninguna ficha de libre menciona la cadera en su campo de error,
aunque la **descripción** de `PATADA MIRANDO EL FONDO` sí dice «cadera alta». El
campo de error habría que completarlo.

### Espalda

| # | Frase | Ejercicio propuesto | Secundarios |
|---|---|---|---|
| E1 | `rolido insuficiente` | `ROLIDO (Espalda)` | `ROLIDO CON 1 BRAZO (Espalda)`, `3+3 PATADA LATERAL (Espalda)` |
| E2 | `cabeza alta` · `cabeza levantada` | `PATADA MIRANDO EL TECHO` | `FLECHA (Espalda)` |
| E3 | `patada desde las rodillas` | `PATADA MI EXTENDIDOS – ANTI-BICICLETA` | ver §1.1 |
| E4 | `patada caída` | `PATADA MI EXTENDIDOS – ANTI-BICICLETA` | `PATADA MIRANDO EL TECHO` · ver §1.1 |
| E5 | `cadera caída` | `PATADA MIRANDO EL TECHO` | `FLECHA (Espalda)` |
| E6 | `brazo flexionado en fase aérea` | `MANO AL CIELO` | ver §1.2 |

### Pecho

| # | Frase | Ejercicio propuesto | Secundarios |
|---|---|---|---|
| P1 | `dosiflexión` | **vacío** (ver §2) | `TOCANDO TALÓN/TOBILLO` |
| P2 | `patada sin flexionar tobillos` | **vacío** (ver §2) | `TOCANDO TALÓN/TOBILLO` |
| P3 | `patada con plantiflexión` | **vacío** (ver §2) | `TOCANDO TALÓN/TOBILLO` |
| P4 | `saca los pies del agua` | `MI × RESPIRACIÓN (Pecho)` | — |
| P5 | `mirada al frente` | `MI × RESPIRACIÓN (Pecho)` | `FLECHA (Pecho)` |
| P6 | `cabeza arriba` | `MI × RESPIRACIÓN (Pecho)` | `FLECHA (Pecho)` |
| P7 | `no coordina el estilo` | `BRAZA 1-2-3` | `2 PN X 1 BR`, `COORD DE EXTREMIDADES` |
| P8 | `patada y brazada al mismo tiempo` | `BRAZA 1-2-3` | `2 PN X 1 BR` |
| P9 | `baja las manos hasta la cadera` | `BRAZADA CORTA – CODOS JUNTOS` | — |
| P10 | `no desliza` | `FLECHA (Pecho)` | `BRAZA 1-2-3`, `TALÓN A LAS MANOS – DORSAL/VENTRAL` |
| P11 | `sin timing` | `BRAZA 1-2-3` | `2 PN X 1 BR` |

`MI × RESPIRACIÓN (Pecho)` cubre P4, P5 y P6 porque su ficha dice «cuerpo poco
inclinado; pies que emergen». Es la única que nombra los pies emergiendo.

### Mariposa

| # | Frase | Ejercicio propuesto | Secundarios |
|---|---|---|---|
| M1 | `patada desde las rodillas` | `SACAR LA CADERA – ONDULACIÓN` | `FLECHA (Mariposa)` |
| M2 | `no mueve la cadera` | `SACAR LA CADERA – ONDULACIÓN` | `DELFINEO` |
| M3 | `separa los pies` | **vacío** (ver §2) | `FLECHA (Mariposa)` |
| M4 | `brazos no salen del agua` | `DELFINEO COMPLETO` | ver §1.3 |
| M5 | `cabeza levantada siempre` | `PN EN SOLDADO` | `FLECHA (Mariposa)` |
| M6 | `no empuja hasta la cadera` | `PULGAR ROZA EL MUSLO (Mariposa)` | — |
| M7 | `brazos flexionados en el recobro` | **vacío** (ver §2) | `DELFINEO COMPLETO` |
| M8 | `no lleva las manos hasta adelante` | `PN EN SOLDADO` | `FLECHA (Mariposa)`, `DELFINEO COMPLETO` |
| M9 | `sin timing` | `DELFÍN 2 BATIDAS – ENTRADA/SALIDA` | `DELFINEO COMPLETO` |
| M10 | `muchas patadas por cada brazada` | `DELFÍN 2 BATIDAS – ENTRADA/SALIDA` | ver §1.4 |

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
