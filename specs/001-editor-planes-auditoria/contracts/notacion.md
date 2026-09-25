# Contrato — Analizador de la Notación

Define qué acepta el analizador, qué devuelve y cómo se comporta ante lo que no entiende.

## Garantía fundamental

**El analizador nunca lanza una excepción y nunca devuelve nada vacío.** Ante cualquier
entrada devuelve las series que sí pudo interpretar más la lista de fragmentos que no, cada
uno con su posición exacta en el texto original. Esta garantía es lo que permite cumplir
FR-036: el entrenador sigue escribiendo aunque la app no entienda una parte.

```
analizar(texto) -> { series: [Serie], pendientes: [Fragmento] }
```

## Vocabulario reconocido

### Implementos y modificadores

| Notación | Significado | | Notación | Significado |
|---|---|---|---|---|
| `AL` | Aletas | | `N` | Nado completo normal |
| `PL` | Palas | | `EST` / `Est` | Estilo principal del nadador |
| `Pp` | Palas pequeñas | | `L/E` | Libre/Espalda |
| `PULL` | Pull buoy | | `CI` | Combinado individual |
| `PN` / `Pn` / `pat` | Patada | | `Hyp n` | Hipóxico: respirar cada n brazadas |
| `BR` / `braz` | Brazada | | `UW` | Subacuático |
| `SNK` | Snorkel | | `REC` | Recuperación / afloje |
| `PARAC` | Paracaídas | | `C.L` | Cámara lenta (ejercicio de biblioteca) |
| `CAUCHO` | Banda elástica | | `Partido` | Nado fraccionado |
| `PM` | Sesión de la tarde | | `^` | Con salida desde el bloque |
| `1<4` / `1>4` | Progresivo / regresivo | | `+5''` / `-5''` | Por encima/debajo del tiempo de referencia |

`FC2` y `FC1` están en desuso: si aparecen en texto histórico se ignoran, y se informa de
ello sin bloquear.

### Estructuras

| Forma | Ejemplo | Interpretación |
|---|---|---|
| `N x D` | `4x100` | 4 repeticiones de 100 m |
| `N x D / t` | `4x100 / 2'` | Saliendo cada 2 minutos |
| `D` suelta | `200 N` | Una repetición de 200 m |
| Serie con implemento | `200 PULL PL` | 200 m con pull buoy y palas |
| Serie con ejercicio | `300 REC Pp TEC L` | Bloque técnico de libre |
| Agrupación | `8x50 (1L 1Estilo 1>4)` | El paréntesis describe el contenido de cada repetición |
| Composición | `200 AL (25m Pn E FLECHA + 75 N)` | Una repetición compuesta de tramos |
| Etiqueta de bloque | `200 TEC L` | 200 m de ejercicios técnicos de libre, que deben detallarse |

### Nombres de nado permitidos

Solo `Nado Libre`, `Nado Espalda`, `Nado Pecho`, `Nado Mariposa`, `Nado CI`.

Formas **rechazadas** con mensaje explícito: "Libre técnico", "Pecho asistido", "Mariposa
técnica", "Espalda técnica", "Libre corregido", "Pecho corregido" y variantes. Las
etiquetas `TEC L`, `TEC E`, `TEC P`, `TEC M`, `TEC EST` son válidas solo como etiqueta de
bloque, nunca como nombre de un nado completo.

## Ejercicios y desambiguación

Un nombre de la Biblioteca se reconoce por coincidencia exacta. **No hay corrección
automática, ni sinónimos, ni sugerencias de "quizá quiso decir"** (FR-002): un nombre que
no coincide produce un fragmento pendiente con motivo `ejercicio fuera de biblioteca`.

Los nombres que se repiten entre estilos (`FLECHA`, `ROLIDO`, `ROLIDO CON 1 BRAZO`) exigen
el estilo: `FLECHA (Espalda)`. Sin él, fragmento pendiente con motivo `ambiguo`.

## Motivos de fragmento pendiente

| Motivo | Cuándo |
|---|---|
| `termino_desconocido` | Abreviatura ausente del glosario y de la biblioteca |
| `estructura_no_reconocida` | La forma de la serie no encaja en ninguna estructura conocida |
| `ejercicio_fuera_de_biblioteca` | Nombre que parece ejercicio pero no está en la sección 19 |
| `ambiguo` | Ejercicio que se repite entre estilos y no se indicó cuál |
| `nomenclatura_prohibida` | Forma de nado que la metodología no admite |

## Qué NO hace el analizador

- **No adivina la zona de intensidad.** La zona la asigna el entrenador (FR-011); el
  analizador solo la recoge si está escrita explícitamente.
- **No inventa ejercicios** ni corrige nombres.
- **No rellena datos que faltan.** Si no hay tiempo de salida, el campo queda vacío, no se
  supone uno.
- **No decide si una serie es técnica**: eso se deriva de que referencie un ejercicio de la
  biblioteca.

## Precedencia de la corrección manual

Si el entrenador corrige a mano un campo interpretado, la serie queda marcada con
`origen: corregido a mano` y **una reinterpretación posterior del texto no puede
sobrescribir ese campo** (FR-035).

## Corpus de pruebas

El analizador se valida contra las series reales que aparecen en la sección 14 del
documento normativo y en el plan de referencia `Macrociclo - Precompetitivo Agosto`. Cada
serie del corpus es un caso con su resultado estructurado esperado, incluidos los metros.

Casos obligatorios del corpus:

```
200 N
4x100 AL SNK PN / 2'
8x50 (1L 1Estilo 1>4)
200 PULL PL (75N=25 Prog)
400 AL (75 Estilo − 25 UW)
200 AL (25m Pn E FLECHA + 75 N)
200 PU/Pp E (50 c/brazo)
300 REC Pp TEC L
```

La suma de metros del ejemplo completo de la sección 14 debe dar 3.600 m: inicial 1.800,
central 1.500, final 300. Es la prueba que ancla todo el analizador a un resultado que el
entrenador ya conoce.
