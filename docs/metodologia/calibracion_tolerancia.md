# Calibración de la tolerancia de distribución

Registro de la tarea **T092** de la feature 001.

La tolerancia de ±3 puntos porcentuales la eligió quien escribió el código, no el
documento normativo. T092 dice cómo validarla: **si las planificaciones
históricas del propio entrenador fallan criterios con esa tolerancia, la
tolerancia está mal puesta, no sus planes.**

Se midió contra sus dos planes reales de la carpeta `A. Planificación`:

| Plan | Sesiones | Volumen | Categoría |
|---|---|---|---|
| `Macrociclo - Precompetitivo Agosto.xlsx` | 39 en 14 microciclos | 77.000 m | Precompetitivo, con ATR |
| `Planificación Trimestre Iniciación Avanzada.xlsx` | 17 en 9 microciclos | 13.600 m | Tecnificación, sin ATR |

**Resultado: la tolerancia no es el problema.** Hay dos hallazgos anteriores a
ella, y ninguno se arregla moviendo un número.

---

## Hallazgo 1 · Sus planes no registran metros por zona

Sus hojas declaran la intensidad **por parte**, no por serie, y muchas etiquetas
son mixtas:

| Etiqueta que usa | Aparece en |
|---|---|
| `A1` | partes iniciales de Acumulación |
| `A1-A2` | partes iniciales de Transformación, centrales de MC01-MC02 |
| `A2` | centrales de MC03-MC05, MC09 |
| `A2-A3` | dos sesiones en todo el macrociclo |
| `AT / RP8`, `RP8 / AT`, `RP8` | centrales de Transformación y Realización |
| `Máx / RP8`, `RP8 / Máx` | cuatro sesiones |
| `REC/A1` | **todas** las partes finales |
| `A1 + salidas`, `A1 + virajes`, `A1 + velocidad` | iniciales de Realización |

Una parte de 900 m etiquetada `A1-A2` no dice cuántos metros son A1 y cuántos
A2. El criterio C03 compara metros por zona contra la distribución de la fase,
así que **no se puede evaluar sin que el entrenador diga cómo se reparten esas
etiquetas**.

Se puede acotar leyendo las series: la central de MC02 son 200 m de pre-set
técnico + 600 m de Libre A2 + 100 m de Espalda A1, o sea ≈ 1/3 A1 y 2/3 A2. Pero
eso es una lectura nuestra, no una declaración suya, y la regla R3 dice
preguntar en lugar de suponer.

## Hallazgo 2 · La zona A3 está prácticamente ausente del macrociclo

Este es el importante, y **no depende de cómo se repartan las etiquetas mixtas**:
sale igual en la interpretación más favorable.

`A3` aparece en **dos sesiones de las treinta y nueve**, ambas como `A2-A3`: una en MC05
y otra en MC09. Si se contaran enteras como A3 —el máximo imaginable—, daría:

| Fase | Volumen | A3 máximo posible | A3 prescrito | Desviación mínima |
|---|---|---|---|---|
| Acumulación (MC01-MC05) | 25.800 m | 1.000 m · 3,9% | 10% | **−6,1 pp** |
| Transformación (MC06-MC10) | 32.100 m | 1.000 m · 3,1% | 15% | **−11,9 pp** |
| Realización (MC11-MC14) | 19.100 m | 0 m · 0% | 15% | **−15,0 pp** |

Y lo mismo con otras dos bandas:

- **AT en Acumulación:** 0% frente al 5% prescrito → −5,0 pp.
- **Vel en Realización:** aparece como «A1 + velocidad» dentro de partes
  iniciales, sin metros propios → ≈0% frente al 10% prescrito → −10,0 pp.

Ninguna tolerancia razonable absorbe −15 puntos. Subirla hasta ahí dejaría el
criterio sin capacidad de detectar nada.

---

## Lo que hay que decidir, y es del entrenador

La explicación más probable es que **`RP8` cubra A3, o A3 y AT a la vez.** `RP8`
es ritmo de 800, y el documento normativo sitúa el umbral (AT) y la Critical
Speed en esa región. Si `RP8` comprende A3 y AT, entonces los 11.700 m de partes
`AT / RP8` de Transformación cubren de sobra el 15% + 15% prescrito, y el
criterio pasa sin tocar la tolerancia.

Pero eso **no lo puedo decidir yo**: dependiendo de la respuesta, el mismo plan
cumple holgadamente o falla por doce puntos.

Lo que falta es una tabla como la del índice de diagnóstico: **sus etiquetas de
trabajo traducidas a metros por zona**, declarada por él. Por ejemplo:

| Su etiqueta | Reparto por zona |
|---|---|
| `A1-A2` | ¿1/3 A1 + 2/3 A2? ¿mitad y mitad? |
| `REC/A1` | ¿todo A1? ¿una zona de recuperación propia por debajo de A1? |
| `RP8` | ¿A3? ¿AT? ¿mitad de cada una? |
| `AT / RP8` | ¿todo AT? ¿reparto? |
| `Máx / RP8` | ¿Máx y A3? ¿Máx y AT? |
| `A2-A3` | ¿mitad y mitad? |
| `A1 + salidas` | ¿los metros de salidas cuentan como A1, o aparte? |

Con esa tabla, la calibración es aritmética y se resuelve en una tarde. Sin ella,
cualquier número que se ponga en la tolerancia es arbitrario.

### Pregunta aparte: a qué nivel se audita

El criterio C03 evalúa un `Plan` completo. Si el plan es un mesociclo, compara
contra la distribución de la fase, que es lo correcto. Pero el **generador de la
feature 002 produce un microciclo suelto** y lo hace cumplir la distribución de
la fase semana a semana.

Sus microciclos reales no funcionan así. MC02 es 100% A1 y A2; el A3 y el AT
llegan después, en otras semanas de la misma fase. La distribución ATR es un
objetivo **de fase**, que él alcanza variando las semanas.

Eso significa que **la semana generada es más uniforme que las suyas.** No está
mal —cumple el documento—, pero es una diferencia de criterio que conviene que
conozca: si quiere semanas con carácter propio dentro de la fase, el generador
tendría que recibir qué lugar ocupa esa semana en el mesociclo.

---

## Lo que sí quedó medido

### La estructura 40/50/10

No es un criterio de auditoría hoy, pero se midió por si llega a serlo. Sobre las 56 sesiones reales:

| Forma de sesión | Sesiones | Inicial | Central | Final | Peor desviación |
|---|---|---|---|---|---|
| 800/1000/200 · 2.000 m | 12 | 40,0% | 50,0% | 10,0% | **0,0 pp** |
| 700/900/200 · 1.800 m | 1 | 38,9% | 50,0% | 11,1% | 1,1 pp |
| 800/1100/200 · 2.100 m | 6 | 38,1% | 52,4% | 9,5% | 2,4 pp |
| 800/900/200 · 1.900 m | 3 | 42,1% | 47,4% | 10,5% | 2,6 pp |
| 300/400/100 · 800 m | 17 | 37,5% | 50,0% | 12,5% | 2,5 pp |
| 600/800/200 · 1.600 m | 3 | 37,5% | 50,0% | 12,5% | 2,5 pp |
| 700/1000/200 · 1.900 m | 3 | 36,8% | 52,6% | 10,5% | **3,2 pp** |
| 800/1200/200 · 2.200 m | 9 | 36,4% | 54,5% | 9,1% | **4,5 pp** |
| 500/600/200 · 1.300 m | 2 | 38,5% | 46,2% | 15,4% | **5,4 pp** |

**14 de 56 sesiones suyas pasarían de ±3 pp.** Si el 40/50/10 llega a ser
criterio, la tolerancia tendría que ser **±6 pp** para no marcar sus propios
planes.

La causa es mecánica y vale la pena nombrarla: **su parte final son 200 m fijos**
en las treinta y nueve sesiones del macrociclo, no el 10% de la sesión. En una sesión de
2.200 m eso es el 9,1%; en una de 1.300 m, el 15,4%. En el grupo de Iniciación el
fijo son 100 m sobre 800, el 12,5%. Trata el afloje como una cantidad, no como una
proporción. Si el criterio llega a existir, debería admitir eso.

### El porcentaje técnico

Sus hojas de Acumulación declaran «téc ~50%», y la fase prescribe 50%.
**Coincide**, y es lo que el escenario G14 ya había comprobado. El criterio C04 no
necesita recalibración por lo que se ve aquí.

---

## Estado

**T092 no se puede cerrar todavía**, pero ya no está bloqueada por falta de
planes: están los dos, completos. Está bloqueada por una pregunta concreta, la
tabla de equivalencias de etiquetas de arriba.

Lo medido mientras tanto:

- La tolerancia de ±3 pp **no es la causa** de que sus planes fallen C03.
- Para la estructura 40/50/10, si llega a ser criterio, ±3 pp es demasiado
  estrecho: **±6 pp**, y mejor aún tratar la parte final como cantidad fija.
- Para el porcentaje técnico, ±3 pp sirve.
