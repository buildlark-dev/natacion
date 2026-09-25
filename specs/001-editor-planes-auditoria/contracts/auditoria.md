# Contrato — Auditoría Metodológica

Los once criterios de la tabla de auditoría del documento normativo, convertidos en reglas
verificables. Cada uno es una unidad independiente con identificador estable, severidad
fija, entradas declaradas y un veredicto.

**La severidad quedó fijada en la sesión de aclaración**: bloquean la no invención, la
nomenclatura, la notación, las zonas mal asignadas y los datos obligatorios faltantes.
Admiten justificación escrita el volumen fuera de rango por afinación y las desviaciones de
distribución.

## Forma del veredicto

Cada criterio devuelve:

| Campo | Contenido |
|---|---|
| `id` | Identificador estable, nunca cambia aunque se reescriba el nombre |
| `cumple` | Verdadero o falso |
| `observacion` | Siempre con números concretos: valor real, valor esperado y diferencia |
| `ubicacion` | Sesión, parte o serie donde ocurre, cuando aplica |

Un criterio que no puede evaluarse por falta de datos **no cumple**, con la observación
indicando qué falta. Nunca se considera cumplido por omisión.

## Los once criterios

| id | Nombre | Severidad | Entradas | Falla cuando |
|---|---|---|---|---|
| `C01_biblioteca` | Todos los ejercicios pertenecen a la Biblioteca Oficial | **Bloqueante** | Series del plan, biblioteca | Alguna serie referencia un ejercicio inexistente, o un nombre ambiguo sin estilo |
| `C02_tecnica_prioritaria` | La técnica sigue siendo prioritaria | Justificable | % técnico real, % de la fase | El porcentaje técnico queda por debajo del prescrito para la fase |
| `C03_intensidades_fase` | La fase ATR respeta intensidades | Justificable | Distribución real de zonas, fase | Alguna zona se aparta de su porcentaje prescrito más allá de la tolerancia |
| `C04_tecnica_fase` | La fase ATR respeta porcentajes técnicos | Justificable | % técnico real, fase | Se aparta del porcentaje técnico de la fase |
| `C05_volumen_categoria` | El volumen respeta la categoría | Justificable | Metros por sesión, rango de la categoría | Una sesión queda fuera del rango. La justificación esperada es la afinación |
| `C06_transferencia` | Existe transferencia hacia la prueba objetivo | Justificable | Distribución de estilos, estilo objetivo | El reparto de estilos se aparta del prescrito |
| `C07_nomenclatura` | Nomenclatura de estilos y notación correctas | **Bloqueante** | Series, nombres de nado | Aparece una forma prohibida ("Libre técnico") o una etiqueta de bloque usada como nombre de nado |
| `C08_zonas` | Zonas de intensidad correctas | **Bloqueante** | Zona de cada serie | Una serie no tiene zona, o una zona cae fuera de las seis válidas, o una serie cuenta en dos zonas |
| `C09_modelamiento` | Plan coherente con el modelamiento | Justificable | Microciclos, objetivos | Un microciclo carece de objetivo real, o su nombre no lo refleja |
| `C10_drills_diagnostico` | Los drills corresponden a errores del diagnóstico | Justificable | Ejercicios usados, diagnóstico del nadador | Hay diagnóstico registrado y los ejercicios no atacan ninguno de sus errores. Si no hay diagnóstico, se reporta esa ausencia sin culpar al plan |
| `C11_sin_ambiguos` | No hay ejercicios ambiguos ni inventados | **Bloqueante** | Series, fragmentos pendientes | Queda algún fragmento sin interpretar, o alguna referencia ambigua sin resolver |

## Regla de aprobación

```
puedeAprobarse(plan) =
    ningún criterio bloqueante en rojo
  Y todo criterio justificable en rojo tiene justificación con texto no vacío
  Y ninguna sesión del plan está incompleta
```

## Tolerancias

Las desviaciones de distribución (`C03`, `C04`, `C06`) necesitan una tolerancia: exigir el
60,00% exacto de A1 sería inaplicable. **Valor inicial propuesto: ±3 puntos porcentuales**,
configurable en un solo lugar del dominio.

Es un valor elegido por quien escribe el plan, no por la metodología, que no lo especifica.
Conviene que el entrenador lo revise al ver los primeros resultados contra sus planes
reales: si sus propias planificaciones históricas fallan criterios con esta tolerancia, la
tolerancia está mal calibrada, no sus planes.

## Qué deben demostrar las pruebas

Por cada criterio, como mínimo dos pruebas:

1. Un plan que **viola** ese criterio y lo hace fallar, con la observación conteniendo los
   números correctos.
2. Un plan que lo **cumple** y lo deja en verde.

Un criterio que nunca falla en las pruebas no está implementado (principio III).
