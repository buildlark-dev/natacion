# Contrato — Renderizado a la Notación del Entrenador

El camino inverso del analizador: convierte series estructuradas en el texto que el entrenador
lee y edita.

```
renderizar(Serie) -> String
renderizarParte(Parte) -> String
```

## Por qué existe

El entrenador revisa y ajusta el plan generado en el mismo editor que usa para escribir a
mano (FR-027, FR-029). Ese editor lee notación. Sin renderizado, un plan generado tendría que
mostrarse en una pantalla aparte de solo lectura, y la historia US2 sería imposible.

## Forma de una serie renderizada

El orden de los elementos es **fijo**, para que el resultado sea determinista y reconocible:

```
[repeticiones×]distancia [implementos] [modificadores] [ejercicio|estilo] [zona] [/ tiempo]
```

| Elemento | Se escribe | Se omite |
|---|---|---|
| Repeticiones | `8×50` cuando hay más de una | Cuando es una sola: `200` |
| Distancia | Siempre | Nunca |
| Implementos | En el orden del glosario: `AL`, `PL`, `Pp`, `PULL`, `SNK`, `PARAC`, `CAUCHO` | Si no hay |
| Modificadores | `PN`, `BR`, `UW`, `REC`, `1<4`, `1>4`, `^`, `Hyp n` | Si no hay |
| Ejercicio | Nombre exacto de la Biblioteca, con estilo entre paréntesis cuando lo exija | Si es nado completo |
| Estilo | Abreviatura del glosario, o `Nado Libre` en nado completo | Si lo implica el ejercicio |
| Zona | Entre paréntesis: `(A1)` | Si no está asignada |
| Tiempo de salida | `/ 2'` o `/ 1'30"` | Si no hay |

Se usa el signo `×` y no la letra `x`, porque es lo que aparece en los documentos del
entrenador.

## Ejemplos

| Serie estructurada | Texto renderizado |
|---|---|
| 1 × 300, Libre, A1, nado completo | `300 Nado Libre (A1)` |
| 8 × 50, bloque técnico de Espalda, salida 20" | `8×50 TEC E (A1) / 20"` |
| 4 × 100, aletas y snorkel, patada, salida 2' | `4×100 AL SNK PN / 2'` |
| 1 × 200, ejercicio VADEO, Libre | `200 VADEO (A1)` |
| 1 × 200, ejercicio FLECHA de Espalda | `200 FLECHA (Espalda) (A1)` |
| 1 × 200, recuperación, palas pequeñas | `200 REC Pp (A1)` |

## El viaje redondo

Es la prueba que demuestra que el texto corresponde a lo calculado.

```
generar → renderizar → analizar → comparar
```

**Debe coincidir**, para cada serie:

- los metros;
- las repeticiones y la distancia;
- los implementos y los modificadores;
- el ejercicio de la Biblioteca, si lo hay;
- el estilo;
- la zona de intensidad.

Y para el microciclo completo: los metros totales, el porcentaje técnico y la distribución de
zonas, con diferencia de **0 m** y 0 puntos porcentuales.

**Si el viaje redondo no cierra, el defecto está en el renderizador o en el analizador, nunca
en el plan generado.** El generador trabaja con datos estructurados; el texto es solo su
representación. Un desajuste aquí significa que el entrenador vería una cosa y la auditoría
evaluaría otra, que es exactamente lo que el principio I prohíbe.

## Doble comprobación con la notación ambigua

El renderizador DEBE producir texto que el analizador lea sin dejar fragmentos pendientes.
Los casos que hay que vigilar, porque ya dieron problemas en la feature 001:

| Caso | Exigencia |
|---|---|
| Ejercicio que se repite entre estilos | Se escribe siempre con el estilo: `FLECHA (Espalda)` |
| Ejercicio cuyo nombre lleva `+` | `3+3 PATADA LATERAL` se escribe tal cual; el analizador ya protege ese `+` |
| Etiqueta de bloque técnico | `TEC L`, `TEC E`, `TEC P`, `TEC M`, `TEC EST`, nunca como nombre de nado |
| Nado completo | Solo `Nado Libre`, `Nado Espalda`, `Nado Pecho`, `Nado Mariposa`, `Nado CI` |
| Zona escrita | Entre paréntesis, con la abreviatura exacta de la sección 9 |

## Lo que el renderizador NO hace

- **No abrevia ni embellece.** No comprime dos series iguales en una, ni reordena para que
  quede más bonito: el texto refleja la estructura tal como está.
- **No añade comentarios ni notas** que el generador no haya puesto.
- **No inventa la zona** cuando la serie no la tiene: la omite.
- **No corrige** una serie mal formada. Si la estructura es inválida, eso es un defecto del
  generador y debe fallar ahí, no maquillarse aquí.
