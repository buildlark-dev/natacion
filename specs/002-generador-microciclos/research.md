# Investigación — Feature 002: Generador Determinista de Microciclos

**Fecha**: 2026-09-29 · **Rama**: `002-generador-microciclos`

Resuelve las incógnitas de diseño antes de la Fase 1. La feature no añade tecnología: toda
la dificultad está en el reparto con restricciones y en el orden en que ceden.

## D1 — Cómo se compone el microciclo: reparto descendente

**Decisión**: el generador reparte de arriba hacia abajo, en este orden:

1. **Volumen por sesión** = punto medio del rango de la categoría, cuantizado a la longitud
   de piscina. **Volumen del microciclo** = volumen por sesión × sesiones semanales de la
   categoría.
2. **Reparto por zonas** sobre el volumen del microciclo, según los porcentajes de la fase.
3. **Presupuesto técnico** = volumen × porcentaje técnico de la fase.
4. **Reparto por estilos** según la priorización del estilo objetivo.
5. **Reparto por sesión**: el volumen y las zonas se dividen entre las sesiones.
6. **Composición de partes** dentro de cada sesión: inicial 40%, central 50% (pre-set 10% +
   principal 40%), final 10%.
7. **Selección de ejercicios** para los metros técnicos.
8. **Renderizado a notación** del entrenador.

**Razón**: reparte primero lo que la metodología prescribe como porcentaje y deja para el
final lo que es elección (qué ejercicio concreto). Así el cumplimiento sale del reparto, no
de una comprobación posterior que habría que repetir hasta acertar.

**Alternativa descartada**: componer sesión por sesión y comprobar al final si el microciclo
cuadra. Obliga a iterar con ajustes retroactivos, es más difícil de razonar, y el resultado
depende del orden de construcción en lugar de las reglas.

**Verificado**: el reparto se comprobó numéricamente sobre las cinco categorías, las tres
fases y las dos longitudes de piscina —treinta combinaciones— antes de escribir este plan.
En todas, el volumen por sesión cae dentro del rango, el reparto cierra exacto y ninguna zona
se desvía más de la tolerancia:

| Categoría | m/sesión | Sesiones | Total microciclo |
|---|---|---|---|
| Iniciación | 650 | 2 | 1.300 m |
| Tecnificación | 900 | 2 | 1.800 m |
| Precompetitivo | 2.000 | 3 | 6.000 m |
| Competitivo | 4.500 | 5 | 22.500 m |
| Alto Rendimiento | 5.500 | 10 | 55.000 m |

---

## D2 — Orden de precedencia cuando las restricciones chocan

Es la decisión que el checklist de la spec señaló como pendiente. Las restricciones pueden
entrar en conflicto: el rango de volumen, los porcentajes de la fase, el 40/50/10 y el
reparto de estilos no siempre se pueden satisfacer todos a la vez.

**Decisión**: escala de precedencia derivada de la jerarquía R1-R7 de la metodología. Lo de
arriba nunca cede para acomodar lo de abajo.

| Nivel | Restricción | Cede |
|---|---|---|
| 1 | **No invención (R2)**: solo ejercicios de la Biblioteca | Nunca |
| 2 | **Estructura de sesión (sección 14)**: tres partes, 40/50/10, objetivos declarados | Nunca |
| 3 | **Volumen y frecuencia de la categoría (R4)** | Nunca |
| 4 | **Porcentaje técnico de la fase** | Nunca a la baja; puede quedar por encima |
| 5 | **Distribución de zonas (R5)** | Dentro de la tolerancia |
| 6 | **Reparto de estilos (sección 13)** | Dentro de la tolerancia |

**Razón**: la sección 3 de la metodología es explícita —«la técnica tiene prioridad sobre el
volumen y sobre la intensidad»— y la R1 dice que ninguna decisión puede sacrificar calidad
técnica. Por eso el porcentaje técnico está por encima de la distribución de zonas: si
cuadrar A2 al milímetro exigiera recortar técnica, se recorta A2 dentro de la tolerancia y la
técnica se queda.

**Si después de ceder los niveles 5 y 6 dentro de la tolerancia el reparto sigue sin cerrar,
el generador NO genera** y devuelve el impedimento (historia US3). Entregar un plan que
incumple sería peor que no entregar nada, porque el entrenador tendría que descubrirlo él.

**Alternativa descartada**: aflojar la tolerancia para que la generación siempre produzca
algo. Convertiría el generador en la razón para relajar la metodología, que es exactamente lo
que la constitución prohíbe.

---

## D3 — Regla de redondeo: resto mayor sobre unidades de piscina

**Decisión**: el reparto no opera en metros sueltos sino en **unidades de longitud de
piscina** (25 m o 50 m según la piscina declarada). Sobre esas unidades se aplica el método
del **resto mayor**: se asigna la parte entera de cada cuota, y las unidades sobrantes van a
las zonas con mayor resto fraccionario. Los empates se rompen por el orden fijo de las zonas
(A1, A2, A3, AT, Máx, Velocidad).

**Razón**:

- Cuantizar a la longitud de piscina hace que toda distancia generada sea nadable sin medias
  piscinas raras, que es lo que FR-019 exige.
- El resto mayor reparte el sobrante sin azar, hace que el total cierre exacto y es fácil de
  explicar: si el entrenador pregunta por qué A1 tiene 25 m más de lo que le tocaría, la
  respuesta es una regla, no «así salió».
- El desempate por orden fijo es lo que garantiza el determinismo de FR-024. Sin él, dos
  zonas con el mismo resto podrían recibir el sobrante en orden distinto según cómo itere el
  código.

**Alternativas descartadas**: redondear cada zona por separado (el total no cierra y aparecen
o desaparecen metros); asignar el sobrante siempre a A1 (sesga la distribución hacia el
volumen aeróbico bajo de forma sistemática); redondear al alza (infla el volumen y puede
sacarlo del rango de la categoría).

---

## D4 — Composición de las partes de la sesión

**Decisión**: cada zona se asigna a la parte donde la metodología la ubica, según el propio
patrón de las sesiones del entrenador:

| Parte | Zonas | Contenido |
|---|---|---|
| Inicial (40%) | A1 | Nado suave de entrada más los ejercicios técnicos del día |
| Central: pre-set (10%) | A1 – A2 | Ejercicios técnicos de calidad antes de la serie principal |
| Central: principal (40%) | A2, A3, AT, Máx, Velocidad | El componente acentuado de la semana |
| Final (10%) | A1 con recuperación | Vuelta a la calma |

**Razón**: reproduce la lógica de interconexión de cargas de la sección 4 —«no colocar fatiga
metabólica alta antes de un trabajo de velocidad o técnica de calidad; primero la calidad,
luego la carga metabólica»—. La técnica vive en la inicial y el pre-set, donde el nadador
está fresco; la intensidad vive en la principal.

**Comprobación con un caso real**: para Precompetitivo en Acumulación, 2.000 m por sesión
reparten A1 1.200 · A2 500 · A3 200 · AT 100. Eso encaja con la estructura sin residuo:
inicial 800 (A1) + pre-set 200 (A1) + final 200 (A1) = 1.200 de A1, y principal 800 = A2 500
+ A3 200 + AT 100. Coincide con la forma de las sesiones del `Macrociclo - Precompetitivo
Agosto`.

**Consecuencia declarada**: el presupuesto técnico de la fase tiene que caber en inicial más
pre-set. En Acumulación son 1.000 m de técnica sobre inicial 800 + pre-set 200 = 1.000 m
exactos: cabe justo. En fases con más intensidad el presupuesto técnico baja, así que sobra
holgura. Si alguna combinación no cupiera, se aplica la escala de D2: la técnica no cede, así
que se extiende a la parte principal y se reporta como supuesto.

---

## D5 — Selección de ejercicios

**Decisión**: dos caminos según haya diagnóstico o no.

- **Con diagnóstico**: se eligen ejercicios cuyo campo «error que corrige» corresponda a los
  errores diagnosticados. La correspondencia es por coincidencia de términos normalizados
  sobre ese texto, no por interpretación libre.
- **Sin diagnóstico**: se sigue la progresión técnica de la sección 15 —patada, posición
  corporal, control corporal, respiración, tracción, brazada, ejercicios específicos, nado
  completo— tomando ejercicios del estilo objetivo en ese orden.

En ambos casos el recorrido es **estable**: dado el mismo conjunto de entrada, el mismo
ejercicio. La rotación entre sesiones de la semana se hace por posición, no por azar.

**Razón**: FR-021 y FR-022 exigen las dos vías, y FR-024 exige determinismo. El orden de la
sección 15 es la fuente que el propio entrenador declara para cuando no hay diagnóstico, así
que no hace falta inventar un criterio.

**Riesgo declarado y a vigilar**: el campo «error que corrige» está escrito en prosa libre.
Emparejar «dolor de hombro» o «brazada corta» con esa prosa es una correspondencia
aproximada, y puede fallar en los dos sentidos: no encontrar un ejercicio que sí serviría, o
elegir uno que no ataca el error. Por eso FR-023 obliga a reportar el vacío cuando no hay
coincidencia en lugar de elegir otro. La calidad de esta correspondencia debe probarse con
los errores reales del entrenador, y es el punto más débil de la feature.

**Alternativa descartada**: añadir a la Biblioteca una taxonomía de errores codificada. Sería
mejor, pero es modificar el documento normativo, lo que exige subir su versión y la decisión
del entrenador. Queda anotado como mejora futura.

---

## D6 — Renderizado a la notación del entrenador

**Decisión**: una pieza propia, `RenderizadorNotacion`, que convierte series estructuradas en
el texto que el entrenador lee. Es el camino inverso del analizador y vive junto a él.

Su corrección se prueba con el **viaje redondo**: generar → renderizar a notación → releer
con el analizador → los metros, las zonas y los ejercicios coinciden con lo generado.

**Razón**: FR-027 y FR-028 lo exigen. El viaje redondo es la única prueba que demuestra que
el texto que el entrenador ve corresponde a lo que el generador calculó. Sin ella, el editor
podría mostrar una cosa y la auditoría evaluar otra.

**Alternativa descartada**: mostrar el plan generado en una pantalla propia de solo lectura y
no renderizar a notación. Rompería la historia US2 —el entrenador no podría editarlo en el
editor que ya conoce— y duplicaría la superficie de revisión.

---

## D7 — Dónde vive el generador

**Decisión**: `lib/dominio/generacion/`, en Dart puro, sin Flutter ni Firebase. Recibe una
petición y devuelve un resultado; no toca la base de datos ni la interfaz.

**Razón**: el principio II lo exige y la prueba de arquitectura ya existente lo vigila. Además
es lo que permite probar el reparto sin levantar la app, que es donde está el riesgo real.

**Sin dependencias nuevas.** El reparto, el redondeo y la selección son aritmética y
recorrido de listas.

---

## D8 — Detección de imposibilidad antes de generar

**Decisión**: la petición se valida **antes** de empezar a repartir, y el resultado es o un
microciclo o una lista de impedimentos, nunca los dos. Se comprueban, en este orden: datos
obligatorios presentes; fase ATR admisible para la categoría; días disponibles suficientes
para la frecuencia; volumen por sesión compatible con la duración de sesión declarada;
componente acentuado compatible con la fase.

**Razón**: la regla R3 prohíbe planificar con datos faltantes, y FR-006 exige explicar la
contradicción. Validar antes evita dejar a medias un plan que habrá que descartar, que es lo
que FR-006 y el escenario 6 de US3 prohíben.

**Sobre la duración de sesión**: para saber si 2.000 m caben en 60 minutos hace falta una
referencia de ritmo medio. Se asume un ritmo conservador por categoría, declarado en un solo
lugar y revisable por el entrenador. No es una regla suya: es una estimación nuestra, y así
queda marcada.

---

## Incógnitas resueltas y no resueltas

D1 a D8 resuelven las incógnitas de diseño. Las dos que quedan **no bloquean** y son del
entrenador:

- **Calibración de la tolerancia** (±3 puntos porcentuales). Sigue sin contrastar contra sus
  planes históricos completos. El generador la reutiliza tal cual; no la afloja.
- **Microciclo de referencia para SC-009**. Hace falta que él señale cuál de sus semanas sirve
  de patrón para la categoría y fase que se pruebe.
