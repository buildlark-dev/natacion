# Habilidades por categoría — propuesta para aprobación

**Estado**: **aprobada por el entrenador el 2026-10-14**, sin correcciones.
**Origen**: el entrenador pidió que la categoría se determine por habilidades y no por edad.
**Destino**: incorporada como sección **11.1** de `PROMPT_MAESTRO_V3.4.md` en la versión
**3.6.0** del manifiesto. Este documento queda como la trazabilidad de cada criterio: el
documento normativo dice **qué**, y este dice **de dónde salió**.

---

## 1. Por qué hace falta

La sección 11 define las cinco categorías por **volumen por sesión, sesiones por semana,
uso de ATR y objetivos**. No menciona la edad en ninguna parte, y la sección 5 pide
«categoría» y «edad(es) y nivel real observado» como **dos datos distintos**, contemplando
expresamente que no coincidan.

Es decir: la metodología **ya sostiene** que la categoría no es la edad. Lo que no tiene
escrito es lo contrario — **qué sí es**. Hoy un nadador entra a una categoría porque el
entrenador lo decide, y esa decisión no está documentada en ninguna parte.

Eso no es un defecto mientras el entrenador sea uno. Lo es en cuanto la app se le ofrezca a
otra persona, que es justamente hacia donde va el proyecto.

## 2. De dónde sale cada criterio

Cada fila de la tabla lleva marcado su origen. No todo pesa lo mismo:

| Marca | Qué significa |
|---|---|
| **§n** | **Derivado.** Está en esa sección del PROMPT MAESTRO. No es interpretación. |
| **[implícito]** | Se deduce de una regla existente, pero la regla no lo dice con estas palabras. |
| **[propuesta]** | **Lo pongo yo.** No tiene respaldo en el documento normativo. Es lo que hay que leer con más cuidado. |

## 3. La tabla

### Iniciación — 500-800 m/sesión · 2 por semana · sin ATR · 1,0-1,6 km semanales

| Lo que el nadador ya hace | Origen |
|---|---|
| Está adaptado al medio y se desenvuelve con confianza en el agua | §11 |
| Nada Libre y Espalda; Pecho y Mariposa todavía no se le exigen | §11 |
| Completa la sesión aunque sea con pausas entre series | [propuesta] |
| **No** se le prescribe por zonas de intensidad: no hay velocidad crítica medida | §11, §12 |
| **No** tiene prueba objetivo ni calendario de competencia | [implícito: sin ATR] |

### Tecnificación — 800-1000 m/sesión · 2 por semana · sin ATR · 1,6-2,0 km semanales

| Lo que el nadador ya hace | Origen |
|---|---|
| Nada Libre y Espalda de forma continua, y está construyendo Pecho y Mariposa | §11 |
| Ejecuta ejercicios de la Biblioteca Oficial a partir de una consigna y corrige con ella | §15, §19 |
| El trabajo se organiza alrededor del perfeccionamiento técnico, no de una marca | §11 |
| Sostiene la alternancia obligatoria Pecho / Mariposa en programas de dos meses | §11 |
| **Sigue sin** zonas, sin prueba objetivo y sin ATR | §11 |

### Precompetitivo — 1800-2200 m/sesión · 3 por semana · con ATR · 5,4-6,6 km semanales

| Lo que el nadador ya hace | Origen |
|---|---|
| Nada los cuatro estilos de forma continua y reglamentaria | [implícito: §13 reparte volumen entre estilos] |
| **Tiene prueba objetivo y estilo objetivo declarados** | §5, §13 |
| **Tiene fecha de competencia**: es lo que hace que el modelo ATR tenga sentido | §5, §12 |
| **Sostiene series con intervalo y ritmo**, que es la condición para prescribirle por zonas | [implícito: §9] |
| **Puede hacer esfuerzos máximos de 200 y 400 m** de su estilo, que es como se mide la velocidad crítica | §9 |
| Tolera el salto de volumen: de ~2 km a ~6 km semanales, **el triple** | §11 |

### Competitivo — 4000-5000 m/sesión · 5 por semana · con ATR · 20-25 km semanales

| Lo que el nadador ya hace | Origen |
|---|---|
| Todo lo de Precompetitivo, sostenido **cinco** días por semana | §11 |
| Tolera ~22 km semanales, **casi cuatro veces** el escalón anterior | §11 |
| Compite en un calendario, no en una competencia suelta | [propuesta] |
| Reporta su carga interna con regularidad: RPE y observaciones por sesión | [propuesta, principio VIII] |

### Alto Rendimiento — 5000-6000 m/sesión · 10 por semana · con ATR · 50-60 km semanales

| Lo que el nadador ya hace | Origen |
|---|---|
| Entrena **dos veces al día**: diez sesiones semanales no caben de otra forma | §11 |
| Tolera ~55 km semanales | §11 |
| Su temporada admite afinación deliberada, con descenso de volumen justificado | §11, regla de taper |
| La planificación se construye por fases con confirmación entre cada una | §18 |

## 4. Lo que esto le permite hacer a la app — y es más de lo que parece

La sección 11 **ya termina con esta frase**:

> «Si los datos del nadador no encajan con su categoría nominal (p. ej., volumen disponible
> insuficiente), **reportar la discrepancia y preguntar antes de planificar**.»

Es una obligación que está escrita desde la 3.4 y que **hoy el software no implementa**,
porque no hay nada contra qué comparar. Con esta tabla sí lo hay.

Lo que la app podría hacer, y que respeta el principio IV:

- Un nadador declarado **Precompetitivo sin velocidad crítica medida** → avisa de que no se
  le puede prescribir por zonas, y pregunta.
- Un nadador declarado **Precompetitivo sin prueba objetivo ni fecha de competencia** →
  avisa de que el modelo ATR no tiene a qué apuntar.
- Un nadador declarado **Iniciación** con un plan que incluye Mariposa → avisa de que la
  categoría no lo contempla.

**La app no clasifica a nadie.** Reporta discrepancias y pregunta, que es exactamente lo que
la regla R3 manda y lo que la sección 11 ya pedía.

## 5. Lo que esto NO hace

- **No deriva la categoría de la edad.** Un niño de 9 años y un adulto de 40 pueden estar
  los dos en Iniciación, y la app no tiene nada que decir al respecto.
- **No decide por ti.** La categoría la declaras tú. Esto es contra qué se contrasta.
- **No bloquea.** Una discrepancia es un aviso, no un impedimento.

## 6. Lo que se decidió

Se consultó al entrenador el 2026-10-14. Sus respuestas:

| Pregunta | Respuesta |
|---|---|
| Las cuatro filas marcadas **[propuesta]**: «completa la sesión aunque sea con pausas» en Iniciación, y «compite en un calendario» y «reporta su carga interna con regularidad» en Competitivo. | **Aprobadas** tal como estaban, sin corrección. |
| ¿Falta alguna habilidad que él mire al ubicar a un nadador y que no esté en la tabla? | No. |
| De Tecnificación a Precompetitivo el volumen semanal se triplica, y de ahí a Competitivo casi se cuadruplica. ¿Hay algún escalón intermedio que use en la práctica? | **No hay escalones de por medio.** Las cinco categorías son las que hay. |
| ¿Es correcto que Pecho y Mariposa se construyan en Tecnificación y se naden continuos desde Precompetitivo? | Aprobado dentro de la tabla. |

**Lo que esto significa para el salto de volumen.** Sin escalón intermedio, pasar de
Tecnificación a Precompetitivo es pasar de ~2 km a ~6 km semanales de una vez. No es un
hueco de la metodología: es una decisión del entrenador, y la auditoría de discrepancia de
la sección 11 es justamente lo que lo vigila caso por caso.

## 7. Qué se hizo al aprobarla

Es un cambio de metodología, y fue con todo lo que eso exige:

1. La tabla entró en el documento normativo como **sección 11.1**, junto con la regla de
   auditoría de discrepancia reescrita para apoyarse en ella.
2. La versión del manifiesto subió a **3.6.0** con la huella recalculada
   (`1e47faa3…fa23dead`) y el registro de qué cambió y por qué.
3. **Ninguna prueba necesitó cambiar.** Las que mencionan `3.5.0` son datos de planes ya
   sellados, no la versión vigente: `plan_inmutable_test.dart` comprueba precisamente que un
   plan conserve la versión bajo la que se aprobó. Que no haya hecho falta tocarlas es la
   señal de que la versión es un dato y no una constante repartida por el código.
4. **La auditoría de discrepancia todavía no está implementada.** La metodología ya la
   exige —y la exigía desde la 3.4—, pero el software no la hace. Es su propia feature, y no
   entra en la 004, que es de cuentas y consentimiento.
