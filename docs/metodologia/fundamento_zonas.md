# Fundamento científico de las zonas de intensidad

Propósito: dejar las zonas que usa la app **ancladas a literatura publicada**, para
que sean defendibles cuando el producto se ofrezca a otros entrenadores, y no
dependan de lo que un entrenador declare.

**Estado: propuesta pendiente de decisión del entrenador.** Las discrepancias
están identificadas con cita; lo que hay que decidir está marcado como DECISIÓN.

## Fuentes revisadas

Todas están en `A. Planificación`. Se leyeron completas.

| Fuente | Qué aporta | ¿La cita la sección 9? |
|---|---|---|
| Vandenbogaerde, T. (2024). *Swim Training Zone Terminology*. Swimming Canada / CSI Pacific | Las bandas de zona, %FCmáx, latidos por debajo del máximo y RPE | Sí |
| Wakayoshi, K. et al. (1992). *Determination and validity of critical velocity...* Eur J Appl Physiol 64:153-157 | Primera validación de la velocidad crítica en natación | Sí |
| Scott, B. et al. (2024). *Stroke-Specific Swimming Critical Speed Testing*. J Hum Kinet 90:239-251 | Fiabilidad de la velocidad crítica por estilo; protocolo de dos distancias | Sí |
| Ginn, E. M. (1993). *Critical Speed and Training Intensities for Swimming*. The Performance Edge | **Sistema de zonas expresado como % de velocidad crítica**; aproxima las categorías usadas con A. Popov (Touretski, 1993) | **No** |
| Issurin, V. (2010). *New Horizons for the Methodology and Physiology of Training Periodization*. Sports Med 40(3):189-206 | Periodización en bloques: acumulación, transmutación, realización | Sí (sección 12) |
| Issurin, V. (2016). *Benefits and Limitations of Block Periodized Training Approaches*. Sports Med | Revisión de la evidencia de la periodización en bloques | No |

---

## 1. Lo que la literatura **sí** respalda

Esto queda como está. Se comprobó una por una.

### Las bandas de zona coinciden con la fuente, exactamente

| Zona en la app | %FCmáx | RPE | Swimming Canada (2024) |
|---|---|---|---|
| A1 | 60-70 | 1-2 | A1 · 60-70 · 1-2 ✔ |
| A2 | 70-80 | 2-4 | A2 · 70-80 · 2-4 ✔ |
| A3 | 80-85 | 4-5 | A3 · 80-85 · 4-5 ✔ |
| AT | 85-92 | 5-6 | Threshold · 85-92 · 5-6 ✔ |
| Máx | 92+ | 7-10 | Endurance-Intensive · 92+ · 7-10 ✔ |

Las bandas son contiguas y sin solapamiento, como las codifica el dominio. La
escala RPE es la de Borg 0-10 anclada en 10, igual que la fuente.

### La velocidad crítica es específica por estilo

Scott (2024) es precisamente un estudio de fiabilidad de la velocidad crítica
**por estilo**, y encuentra que tanto las marcas de 200 m y 400 m (CV < 2%) como
la velocidad crítica derivada (error típico ≈ 0,04 m/s; CV < 4%) son fiables en
todos los estilos. La afirmación de la sección 9 —«es específica por estilo»—
está respaldada.

### La estructura de tres bloques es la de Issurin

Issurin (2010) define los tres bloques: el primero para capacidades básicas
(«relatively high volume and reduced intensity»), el segundo para capacidades
específicas aerobio-anaeróbicas («the most exhausting training cycle») y el
tercero para restaurar y preparar la competencia. La secuencia y el concepto de
efecto residual que invoca la sección 12 están bien citados.

---

## 2. Donde la app se aparta de su propia fuente

Cuatro puntos. Ninguno es opinable: la fuente dice otra cosa.

### 2.1 «Máx» está mal nombrada — no es VO₂ máx

La app describe la zona de 92%+ como **«VO₂ máx / resistencia intensiva»**.
Swimming Canada llama a esa banda **«Endurance-Intensive Efforts»** y la define
como *«~400-m pace in longer duration efforts with medium to low rest»*, con
ejemplos de 30×100 al mejor promedio y 5×400. Eso es trabajo de resistencia
intensiva, **no** el trabajo interválico que la literatura llama VO₂ máx.

Mezclar los dos nombres importa porque sugiere una prescripción distinta de la
que la fuente respalda.

> **DECISIÓN 1.** Renombrar la zona a **«Resistencia intensiva (~ritmo 400)»** y
> retirar «VO₂ máx» de su descripción. ¿De acuerdo?

### 2.2 La app fusiona dos categorías que la fuente separa

Swimming Canada distingue:

| Categoría | Qué es | Sistema energético |
|---|---|---|
| High-Intensity Efforts | repeticiones de ~25-100 m, a ritmo 200 o más rápido | aerobio y anaerobio: hidratos |
| Explosive Efforts | ~10-20 m a velocidad muy alta, con descanso pasivo largo | **fosfágenos** y anaerobio |

La app tiene **una sola** zona `Velocidad` para las dos. Son esfuerzos de
duración, descanso y sistema energético distintos: 10×50 a ritmo de 100 y 4×15 m
de salida con dos minutos de descanso no son la misma carga.

> **DECISIÓN 2.** Dos opciones:
> - **(a) Separarlas**, y pasar a siete zonas: `Velocidad` (~ritmo 200 o más
>   rápido, 25-100 m) y `Explosivo` (~10-20 m, descanso pasivo largo).
> - **(b) Mantenerlas fusionadas** y dejar escrito en el documento por qué, para
>   que la diferencia con la fuente sea deliberada y no un descuido.
>
> Recomiendo **(a)**: la distinción es la que permite auditar que una sesión de
> afinación tiene trabajo explosivo y no solo velocidad sostenida.

### 2.3 El ritmo de competencia **no es una zona**, y la app lo trata como si lo fuera

Esto es el origen del bloqueo de T092.

Swimming Canada es explícito: **«Race-Specific training is not a training
zone.»** Y precisa cómo clasificarlo:

> *«for sprint swimmers [it] would be categorized high-intensity, while for
> middle-distance swimmers it could be high-intensity or endurance-intensive
> dependent on the set, and for distance and open-water swimmers, it will be
> endurance-intensive and/or threshold.»*

Las etiquetas `RP1`, `RP2`, `RP4`, `RP8`, `RP15` de la sección 9 son **ritmos**,
no zonas. Pero en el `Macrociclo - Precompetitivo Agosto` aparecen en la columna
de intensidad, como si lo fueran: `AT / RP8`, `RP8 / Máx`, `RP8` a secas.

De ahí que no se pudiera calcular la distribución por zonas. La pregunta que hice
—«¿RP8 es A3, AT, o mitad de cada una?»— **tiene respuesta objetiva**, y no
depende de que el entrenador la declare:

- La prueba objetivo del nadador es **800 Libre** → fondo / medio fondo.
- Según la fuente, para esos nadadores el trabajo específico es
  **«endurance-intensive and/or threshold»** → en la nomenclatura de la app,
  **AT y/o Máx**.
- Ginn (1993): nadar a velocidad crítica equivale a ~90-95% de la velocidad
  máxima de 400 m. El ritmo de 800 es más lento que el de 400, así que cae
  **en el entorno de la velocidad crítica**, es decir en el límite AT/Máx.

> **DECISIÓN 3.** `RP8` se clasifica por defecto como **AT**, y pasa a **Máx**
> cuando el conjunto lo lleva al dominio severo (descanso corto, volumen alto al
> ritmo objetivo). Y lo mismo por analogía: `RP15` → AT; `RP4` → Máx; `RP2` y
> `RP1` → Velocidad.
>
> Pero esto queda como **regla por defecto, declarada y citable**, no como
> verdad: la propia fuente dice que depende del nadador y del conjunto. Lo
> correcto es que el entrenador pueda sobreescribirla en una serie concreta.

### 2.4 Un detalle menor, para que no sorprenda después

La tabla de Swimming Canada da para A2 «60 to 40» latidos por debajo del máximo,
pero su propio texto en prosa dice «~50 to 40 beats below max». La sección 9
copió la tabla. Es una **inconsistencia interna de la fuente**, no un error del
documento. Se deja anotada.

---

## 3. Donde el documento se aparta de la ciencia que cita

### 3.1 La definición de velocidad crítica es la que Scott (2024) rechaza

La sección 9 define:

> «**Velocidad crítica**: máxima velocidad que el nadador puede sostener **por
> tiempo prolongado sin fatiga**.»

Y cita, en esa misma fila, a Wakayoshi (1992) y a Scott (2024). El problema es que
Scott (2024) dice literalmente que esa definición es imprecisa:

> *«previous attempts to define CS as a speed that could be sustained for "long
> periods of time" or "forever" without exhaustion (Wakayoshi et al., 1992, 1993)
> are imprecise and misleading (Zacca et al., 2010)»*

Y da el dato: la velocidad crítica se sostiene **~14,3 a 39,4 minutos** (Dekerle
et al., 2010), no indefinidamente. Lo que Scott propone en su lugar:

> *«CS should represent the lower boundary of the severe exercise intensity
> domain, separating an exercise intensity at which physiological homeostasis can
> be maintained from an exercise intensity at which it cannot»*

> **DECISIÓN 4.** Redefinir en la sección 9: «**Velocidad crítica**: límite
> inferior del dominio de intensidad severa — la frontera entre la intensidad en
> la que el organismo mantiene el equilibrio y la que no. Sostenible del orden de
> 15 a 40 minutos, no indefinidamente. Fisiológicamente cercana al umbral
> anaeróbico.»
>
> La parte de «cercana al umbral» **sí** se conserva: tanto Ginn como Scott la
> respaldan.

### 3.2 El protocolo de dos distancias es un compromiso, y conviene decirlo

La sección 9 dice que la velocidad crítica «se estima con esfuerzos máximos de
dos distancias (p. ej., 200 y 400 m)», sin más. Scott (2024) matiza:

> *«a scientifically valid two-parameter CS model requires 3-7 performance trial
> efforts lasting ~2 to ~15 minutes [...] The number of trials recommended
> provides degrees of freedom and less error being introduced from one "bad"
> trial»*

El protocolo de 200+400 es el que **Scott valida como practicable** y resulta
fiable (CV < 4%), así que usarlo está bien fundado. Pero es una concesión a la
viabilidad, no el ideal metodológico, y el documento debería decirlo para que
nadie lo lea como «dos pruebas bastan científicamente».

---

## 4. Donde su macrociclo se aparta del documento

### 4.1 Las distribuciones ATR no tienen respaldo en la literatura. Ninguno.

Este es el hallazgo que resuelve T092.

La tabla de porcentajes por fase (`A1 60 · A2 25 · A3 10 · AT 5`, etc.) que la
app **exige como criterio de auditoría** está marcada en el propio documento como
`[MEJORA PROPUESTA]`, y termina con esta nota:

> «Ajustar los porcentajes es una decisión metodológica del entrenador: esta es
> la propuesta que mejor concuerda con la sección 9.»

Es decir: es una propuesta esperando su decisión, y la app la trata como norma.

**Issurin, que es la fuente citada, no da porcentajes de distribución de
intensidades.** Lo que da es:

- Concentración de carga: *«the allocation of 60-70% of the entire time budget to
  developing two to three targets»* — que es sobre **concentración en pocos
  objetivos**, no sobre reparto entre zonas.
- Duración de los bloques: acumulación 2-6 semanas, transmutación 2-4 semanas,
  realización 8-15 días.

No hay en toda la carpeta una fuente que respalde «A3 = 10% en Acumulación». Por
eso su macrociclo no lo cumple: **nunca adoptó esa tabla.** El A3 aparece en dos
sesiones de treinta y nueve, y la app lo marca como incumplimiento de −6 a −15
puntos según la fase.

**Y hay algo más, que corrige lo que yo mismo había supuesto.** Al revisar Ginn
(1993) resulta que su sistema de cinco niveles —el que aproxima las categorías
usadas en la preparación de Alexandre Popov— **no tiene A3**: va A1, A2, AT,
MVO2, LT/LP. El A3 es una banda del esquema de Swimming Canada, no una constante
de la literatura.

Así que la ausencia de A3 en su macrociclo no es un descuido: **coincide con un
sistema publicado** y discrepa de otro. Lo que la app está marcando como error es
en realidad una elección entre dos esquemas, y ninguno de los dos es «la ciencia»
a secas.

> **DECISIÓN 5.** La más importante. Tres caminos:
>
> - **(a) Adoptar la tabla** como su criterio, reconociendo que es metodología
>   propia y no literatura. La app sigue auditando contra ella; sus macrociclos
>   históricos quedan marcados como no conformes.
> - **(b) Degradar el criterio a informativo.** La app muestra la distribución
>   real y la propuesta al lado, sin aprobar ni suspender. Es lo honesto mientras
>   la tabla no tenga respaldo ni adopción.
> - **(c) Reemplazar la tabla** por lo que sí está publicado sobre distribución de
>   intensidades —modelos piramidal y polarizado—, que **no está en esta carpeta**
>   y habría que traer.
>
> Recomiendo **(b) ahora y (c) después**: dejar de suspender sus planes con una
> regla que nadie firmó, y buscar la literatura de distribución de intensidades
> como trabajo aparte. La **(a)** es defendible si la tabla es realmente su
> criterio, pero entonces hay que decirlo en el documento: «esto es metodología
> del entrenador, no hallazgo publicado».

### 4.2 Las duraciones de bloque no coinciden con Issurin

| Bloque | Issurin (2010) | Su macrociclo | |
|---|---|---|---|
| Acumulación | 2-6 semanas | 5 semanas (MC01-MC05) | ✔ |
| Transformación | 2-4 semanas | 5 semanas (MC06-MC10) | una semana de más |
| Realización | **8-15 días** | ~26 días (MC11-MC14) | **casi el doble** |

Hay que ponderarlo: los rangos de Issurin son para deportistas de alto
rendimiento en periodización en bloques, y un grupo precompetitivo juvenil puede
legítimamente necesitar transiciones más largas. No es un error, es una
diferencia que conviene tener declarada.

> **DECISIÓN 6.** ¿Se deja constancia de que sus duraciones se apartan de Issurin
> a propósito, o se quiere que la app avise cuando una fase se sale de esos
> rangos?

### 4.3 Terminología

Issurin dice **«transmutación»**. El documento dice **«Transformación»**. Es la
traducción habitual en la literatura en español y no hay nada que corregir, pero
queda anotado para que la cita sea trazable.

---

## 5. La propuesta de fondo: anclar las zonas al ritmo, no solo a la frecuencia cardíaca

Aquí está la respuesta a lo que pidió: que las zonas no dependan de lo que él
declare subjetivamente.

Hoy las zonas se definen por **%FCmáx**. Eso tiene dos problemas prácticos, y la
propia Swimming Canada los reconoce al ofrecer «latidos por debajo del máximo»
como alternativa y al advertir que *«the relationship between swim speed and
underlying physiology is individual»*:

1. Exige conocer la frecuencia cardíaca máxima **individual** de cada nadador.
2. Exige medirla en el agua, durante la serie.

Sus hojas no registran frecuencia cardíaca. Registran **metros y ritmos**. Por eso
la columna de intensidad lleva etiquetas como `AT / RP8` en lugar de metros por
zona: está anotando lo que de verdad controla en el borde de la piscina.

Ginn (1993) ofrece la salida, y es la fuente de la carpeta que la sección 9 no
cita: **un sistema de intensidades expresado como porcentaje de la velocidad
crítica**, no invasivo, con muy poco equipo. Y Scott (2024) aporta lo que le
faltaba a Ginn: que la velocidad crítica por estilo, estimada con 200+400, es
fiable.

Combinadas, dan un anclaje objetivo:

- La velocidad crítica se **mide** con dos pruebas cronometradas.
- Es **específica por estilo**.
- Las zonas se expresan en **ritmo por 100**, que es lo que él ya escribe.
- Una serie escrita `6×100 / 1'40"` se clasifica **calculando**, no declarando.

### La tabla de Ginn, tal como está publicada

Tabla 1, página 8. *«A simple system of training intensity levels based on
calculation of Critical Speed»*:

| Nivel | % de CS | % de máx. 400 m | Clasificación de Touretski |
|---|---|---|---|
| Level 1 | 75-80% | > 75 | **A1** |
| Level 2 | 80-90% | 75-85 | **A2** |
| Level 3 | 90-100% | 85-95 | **AT** |
| Level 4 | 100% | 100 | **MVO2** |
| Level 5 | 100-110% | 105% | **LT/LP** |

Más un «Level 6» que Ginn sugiere para esfuerzos máximos de corta duración, y que
deja fuera a propósito: *«this intensity is not based on CS, but represents
maximal velocity»*. Equivale a la `Velocidad` / `Explosivo` de Swimming Canada.

Dos avisos sobre esta tabla, para no citarla mejor de lo que es:

1. **Los niveles no son contiguos.** El 3 llega a 100%, el 4 es exactamente 100%
   y el 5 empieza en 100%. Como clasificación automática no sirve sin cerrar esos
   bordes — justo el problema que la sección 9 ya resolvió para las bandas de
   frecuencia cardíaca.
2. **Level 4 = «MVO2» a exactamente el 100% de CS es dudoso.** Si CS está en el
   umbral, el 100% de CS no es VO₂ máx. Es un paper de 1993 y arrastra la
   imprecisión de su época, la misma que Scott (2024) corrige.

> **DECISIÓN 7.** Añadir a cada zona un **anclaje de ritmo como % de velocidad
> crítica**, junto al de %FCmáx que ya tiene, tomando los niveles de Ginn y
> cerrando los bordes para que sean contiguos. La frecuencia cardíaca orienta; el
> ritmo contra velocidad crítica clasifica y audita.
>
> Queda un hueco que hay que resolver: **Ginn no tiene A3.** Swimming Canada sí.
> La banda de A3 caería entre el A2 y el AT de Ginn, o sea en el entorno del
> 88-92% de CS, pero **eso lo estaría interpolando yo, no está publicado.**

### Y esto da el número que faltaba para `RP8`

Con Ginn se puede calcular en lugar de preguntar:

- CS ≈ **90-95%** de la velocidad máxima de 400 m → el ritmo de 400 es
  **105-111%** de CS.
- Swimming Canada sitúa el umbral en **~ritmo de 2000 m** y la resistencia
  intensiva en **~ritmo de 400 m**.
- El ritmo de 800 está entre los dos: más rápido que el de 2000, más lento que el
  de 400 → **≈ 98-105% de CS**.

Eso cae sobre la frontera del Level 3 / Level 5 de Ginn, es decir **AT entrando en
Máx**. Que es exactamente lo que dice Swimming Canada para un nadador de fondo:
*«endurance-intensive and/or threshold»*. La regla por defecto de la DECISIÓN 3
queda respaldada con cifras, no con criterio.

---

## Resumen de lo que hay que decidir

| # | Decisión | Mi recomendación |
|---|---|---|
| 1 | Renombrar `Máx` quitando «VO₂ máx» | Sí: «Resistencia intensiva (~ritmo 400)» |
| 2 | Separar `Velocidad` de `Explosivo` | Sí, separarlas: siete zonas |
| 3 | Regla por defecto para los ritmos (`RP8` → AT, etc.) | Sí, declarada y sobreescribible por serie |
| 4 | Redefinir velocidad crítica según Scott (2024) | Sí |
| 5 | **Qué hacer con las distribuciones ATR sin respaldo** | Informativo ahora; buscar literatura de distribución después |
| 6 | Duraciones de bloque frente a Issurin | Dejar constancia; avisar solo si lo quiere |
| 7 | Anclar las zonas también al ritmo vs velocidad crítica | Sí, con los niveles de Ginn y los bordes cerrados |

### Lo único que no se puede resolver con esta carpeta

Dos huecos, y conviene nombrarlos para no taparlos con una interpolación:

1. **La banda de A3 en términos de velocidad crítica.** Ginn no tiene A3 y
   Swimming Canada no da ritmos. Caería en el entorno del 88-92% de CS, pero eso
   es una interpolación mía.
2. **La distribución de intensidades por fase.** Lo que está publicado sobre esto
   —modelos piramidal y polarizado— no está en la carpeta. Es lo que haría falta
   traer para cerrar la DECISIÓN 5 por la vía (c).

Nada de esto se toca en el código hasta que lo confirme. Cambiar las zonas afecta
al analizador, al generador, a la auditoría y a la versión de la metodología:
sería una 3.5, no una 3.4.2.

---

# Resolución — decisiones del entrenador, 2026-10-08

Las siete confirmadas. Decisión 5 por la vía **(c)**: reemplazar la tabla sin
respaldo por lo que está publicado. Eso obligó a traer literatura que no estaba
en la carpeta.

## Literatura añadida

| Fuente | Qué aporta |
|---|---|
| González-Ravé, J., Hermosilla, F., González-Mohíno, F., Casado, A., Pyne, D. (2021). *Training Intensity Distribution, Training Volume, and Periodization Models in Elite Swimmers: A Systematic Review*. Int J Sports Physiol Perform 16(7):913-926. DOI 10.1123/ijspp.2020-0906 | Revisión sistemática. Qué modelo usa cada tipo de nadador |
| Pla, R. et al. (2019) | Ensayo cruzado, 22 nadadores (17±3 años), dos periodos de 6 semanas: polarizado **81/4/15** frente a umbral **65/25/10** |
| Arroyo-Toledo, J. J. et al. (2021) | 12 nadadores de nivel nacional, 12 semanas: polarizado **82/0/18** frente a piramidal **60/30/10** |
| Stöggl, T., Sperlich, B. (2014) | Rangos de los modelos: polarizado 56-80/0-14/19-33; umbral 39-53/47-61/0 |
| Filipas, L. et al. (2022) | Piramidal: 75-81/12-18/6-8 |
| Papadimitriou, K. et al. (2025). *Training intensity distribution for sprinter swimmers*. Eur J Appl Physiol | Revisión invitada que recopila lo anterior; advierte que los modelos de resistencia no sirven para velocistas de 50 m |
| Maglischo (2003), citado en la anterior | Duración del taper: velocistas 3-5 semanas; medio fondo y fondo **1-3 semanas** |

### Dos advertencias que vienen con esta literatura

1. **La periodización en bloques no está bien probada en natación.** González-Ravé
   y colaboradores terminan pidiendo estudios experimentales de periodización en
   bloques y en reversa, porque no se han ensayado bien en este deporte. La
   mayoría de los estudios incluidos usan ciclos ondulatorios en mesociclos. El
   modelo ATR que usa el entrenador es una elección legítima, pero la evidencia
   que lo respalda viene de otros deportes (Issurin), no de natación.
2. **La evidencia es mayoritariamente observacional.** De los 9 estudios de la
   revisión, 6 son retrospectivos y solo 3 son de intervención. Las cifras de
   abajo son el mejor anclaje disponible, no una ley.

## Lo que sustituye a la tabla ATR

El cambio de fondo: **se audita en tres zonas, que es como la literatura mide.**
La distribución fina entre las siete zonas pasa a ser criterio del entrenador,
declarado como tal, dentro de un envolvente publicado.

### Correspondencia de las siete zonas con el modelo de tres

El modelo de tres zonas separa por los dos puntos de inflexión del lactato. El
segundo (LT2) coincide con la velocidad crítica, lo que hace la frontera
objetiva y medible:

| Zona de tres | Qué la delimita | Zonas del entrenador |
|---|---|---|
| **Z1** | por debajo de LT1 (~2 mmol·L⁻¹) | A1 + A2 |
| **Z2** | entre LT1 y LT2 | A3 + AT |
| **Z3** | por encima de LT2 ≈ **100% de velocidad crítica** | Resistencia intensiva + Velocidad + Explosivo |

### Envolventes por fase

Cada envolvente es la **unión de todos los valores publicados** para ese modelo:
cualquier cifra que aparezca en la literatura cae dentro. No hay tolerancia
inventada — el rango *es* la tolerancia, y viene citado.

| Fase | Modelo | Z1 | Z2 | Z3 | De dónde sale |
|---|---|---|---|---|---|
| Acumulación | **Piramidal** | 60-81% | 12-30% | 6-10% | Filipas 2022 (75-81/12-18/6-8) ∪ Arroyo-Toledo 2021 (60/30/10) |
| Transformación | **Umbral** | 39-65% | 25-61% | 0-10% | Stöggl & Sperlich 2014 (39-53/47-61/0) ∪ Pla 2019 (65/25/10) |
| Realización | **Polarizado** | 56-82% | 0-14% | 15-33% | Stöggl & Sperlich 2014 (56-80/0-14/19-33) ∪ Pla 2019 (81/4/15) ∪ Arroyo-Toledo 2021 (82/0/18) |

**Por qué este modelo en esta fase.** Dos estudios de caso de nadadores de élite
describen la misma progresión: piramidal en el entrenamiento general, umbral y
polarizado en el específico, polarizado antes de competir. Coincide con la
lógica de Acumulación → Transformación → Realización.

**Y depende de la prueba objetivo.** La conclusión central de González-Ravé es que
el nadador basa su volumen y su distribución en su prueba principal: velocistas
polarizado y umbral; medio fondo umbral y piramidal; **fondo principalmente
piramidal**. La tabla de arriba sirve para medio fondo y fondo, que es el perfil
del `Macrociclo - Precompetitivo Agosto` (800 Libre). Para un velocista de 50 m,
Papadimitriou advierte que ninguno de estos modelos sirve tal cual.

> La rejilla fase x modelo es **una síntesis de dos hallazgos** —el modelo por
> prueba de González-Ravé y la progresión por fase de los estudios de caso—, no
> una tabla publicada. Queda dicho para que nadie la cite como si lo fuera.

## Qué le pasa a su macrociclo con estas cifras

Recalculado en tres zonas, con `RP8` como AT según la DECISIÓN 3:

| Fase | Z1 real | Z2 real | Z3 real | Envolvente | |
|---|---|---|---|---|---|
| Acumulación | ~97% | ~2% | 0% | 60-81 / 12-30 / 6-10 | **fuera**: demasiado Z1, sin Z3 |
| Transformación | ~53% | ~38% | ~8% | 39-65 / 25-61 / 0-10 | **dentro**, las tres |
| Realización | ~50% | ~31% | ~19% | 56-82 / 0-14 / 15-33 | **fuera en Z2**: 31% contra un máximo de 14% |

Tres cosas que esto dice, y ninguna salía de la tabla anterior:

1. **Su Transformación encaja con el modelo de umbral publicado**, en las tres
   zonas. No es casualidad: es la fase donde escribe `AT / RP8`.
2. **Su Acumulación tiene más trabajo suave que cualquier modelo publicado.**
   ~97% de Z1 contra un máximo de 81%. No es que le falte A3 respecto de una
   tabla que nadie firmó: le falta intensidad respecto de la literatura.
3. **Su Realización no es polarizada, es de umbral.** Y según González-Ravé eso
   es legítimo para medio fondo. Lo que no encaja es llamarla «Realización ·
   velocidad y afinación» mientras la distribución dice umbral.

## Las zonas, con los dos anclajes

Siete zonas (DECISIÓN 2), con `Máx` renombrada (DECISIÓN 1) y el anclaje de
ritmo contra velocidad crítica (DECISIÓN 7), tomando los niveles de Ginn con los
bordes cerrados:

| Zona | %FCmáx | % de CS | RPE | Ginn / Swimming Canada |
|---|---|---|---|---|
| A1 | 60-70 | 75-80 | 1-2 | Ginn L1 · SC A1 |
| A2 | 70-80 | 80-86 | 2-4 | Ginn L2 (80-90) · SC A2 |
| A3 | 80-85 | **86-90** | 4-5 | SC A3 · **borde interpolado, Ginn no tiene A3** |
| AT | 85-92 | 90-100 | 5-6 | Ginn L3 · SC Threshold (~ritmo 2000) |
| Resistencia intensiva | 92+ | 100-110 | 7-10 | Ginn L5 (LT/LP) · SC Endurance-Intensive (~ritmo 400) |
| Velocidad | por ritmo | >110 | — | SC High-Intensity (~ritmo 200 o más rápido, 25-100 m) |
| Explosivo | por ritmo | no aplica | — | SC Explosive (~10-20 m, descanso pasivo largo) · Ginn L6, que él mismo deja fuera del cálculo por CS |

**El nivel 4 de Ginn no se adopta.** Etiqueta el 100% de velocidad crítica como
«MVO2», y si la velocidad crítica está en el umbral, el 100% de velocidad crítica
no es VO2 máx. Es la imprecisión de 1993 que Scott (2024) corrige. Ese punto
queda como la frontera entre AT y Resistencia intensiva.

## Reglas por defecto de los ritmos (DECISIÓN 3)

Los ritmos **no son zonas** —Swimming Canada: «Race-Specific training is not a
training zone»—, así que lo que sigue es una regla de clasificación por defecto,
calculada, y sobreescribible en cualquier serie:

| Ritmo | % de CS aprox. | Zona por defecto |
|---|---|---|
| RP15 / RP1500 | 95-100 | AT |
| RP8 | 98-105 | **AT**, pasa a Resistencia intensiva en conjuntos del dominio severo |
| RP4 | 105-111 | Resistencia intensiva |
| RP2 | >111 | Velocidad |
| RP1 | >>111 | Velocidad |

Derivado de Ginn: la velocidad crítica es el 90-95% de la velocidad máxima de
400 m, así que el ritmo de 400 queda en el 105-111% de CS. Y de Swimming Canada:
umbral ≈ ritmo 2000, resistencia intensiva ≈ ritmo 400.

## Duraciones de bloque (DECISIÓN 6)

Las de Issurin (2010), que es lo que se pidió hacer coincidir:

| Bloque | Issurin | Su macrociclo |
|---|---|---|
| Acumulación | 2-6 semanas | 5 ✔ |
| Transformación | 2-4 semanas | 5 ✘ |
| Realización | 8-15 días | ~26 días ✘ |

> **Esto hay que conversarlo antes de implementarlo como regla dura**, porque la
> literatura de natación que se acaba de traer **no respalda** los rangos de
> Issurin:
>
> - El estudio de caso del nadador de 400 estilos usa, en sus tres macrociclos,
>   fases general/específica/competitiva de **6/10/5**, **4/7/10** y **3/10/3**
>   semanas. Ninguna de sus fases específicas cabe en los 2-4 semanas de Issurin,
>   y ninguna competitiva cabe en 8-15 días.
> - Maglischo (2003) da taper de **1-3 semanas** para medio fondo y fondo. Su
>   Realización son 4 semanas, de las cuales MC13 y MC14 son taper: **2 semanas**,
>   justo en ese rango.
> - Un estudio de cohorte de 20 años en nadadores de élite asocia el rendimiento
>   máximo a macrociclos de **14-15 semanas**. El suyo tiene 14.
>
> Es decir: su macrociclo coincide con la literatura **de natación** en duración
> total y en taper, y se aparta de Issurin, que es literatura de otros deportes.
> Hacer que coincida con Issurin lo alejaría de lo publicado en natación.
>
> **Propuesta:** validar contra los rangos de natación —macrociclo 14-15 semanas,
> taper 1-3 semanas en medio fondo y fondo— y dejar los de Issurin anotados como
> referencia de origen del modelo. Si aun así quiere los de Issurin, se
> implementan.
