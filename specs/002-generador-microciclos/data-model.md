# Modelo de Datos — Feature 002

**Fecha**: 2026-09-29 · Deriva de [spec.md](./spec.md) y de [research.md](./research.md).

La feature añade **pocas entidades nuevas y casi ninguna almacenada**. La petición y el
resultado son objetos de ejecución: lo que se guarda es el plan, que ya existe.

---

## 1. Entidades nuevas, de ejecución

### PeticionGeneracion

Lo que hace reproducible el resultado: misma petición, mismo plan (FR-024).

| Campo | Tipo | Obligatorio | Reglas |
|---|---|---|---|
| `categoria` | Categoría | Sí | Una de las cinco de la sección 11 |
| `estiloObjetivo` | Estilo | Sí | |
| `pruebaObjetivo` | texto | Sí | No vacío |
| `faseAtr` | FaseAtr? | Según categoría | Obligatoria si la categoría usa ATR, prohibida si no |
| `componenteAcentuado` | texto | Sí | No vacío. Da nombre al microciclo |
| `diasDisponibles` | lista de fecha | Sí | Su cantidad se compara con la frecuencia de la categoría |
| `fechasSinServicio` | lista de fecha | No | Se descuentan de los días disponibles |
| `longitudPiscina` | 25 \| 50 | Sí | |
| `duracionSesionMinutos` | entero | Sí | Positivo |
| `diagnosticoTecnico` | lista de texto | No | Sin él se aplica la progresión estándar |
| `lesiones` | lista de texto | No | Solo generan aviso; **no modifican el plan** |
| `nadadoresIds` | lista de id | No | Destinatarios del plan |

**Invariante**: dos peticiones con los mismos valores producen microciclos idénticos.

### ResultadoGeneracion

Unión de dos casos. **Nunca ambos, nunca un plan parcial.**

- `MicrocicloGenerado(plan, supuestos, vaciosDeBiblioteca, avisos)`
- `GeneracionImposible(impedimentos)`

### Impedimento

| Campo | Tipo |
|---|---|
| `tipo` | `datoFaltante` \| `faseNoAdmisible` \| `frecuenciaImposible` \| `duracionInsuficiente` \| `componenteIncoherente` \| `repartoImposible` |
| `explicacion` | texto, con los números concretos |
| `campo` | qué dato de la petición lo origina, si aplica |

Los impedimentos se **acumulan todos** antes de devolver: el entrenador los ve de una vez.

### Supuesto

| Campo | Tipo |
|---|---|
| `descripcion` | texto |
| `motivo` | por qué fue inevitable |

Se muestra dentro del plan generado, marcado visiblemente (FR-007).

### VacioDeBiblioteca

| Campo | Tipo |
|---|---|
| `errorDiagnosticado` | texto |
| `estilo` | Estilo |

Error del diagnóstico sin ejercicio que lo corrija. Se reporta; no se sustituye (FR-023).

### Presupuesto

Resultado intermedio del reparto. No se almacena, pero es la pieza que las pruebas examinan.

| Campo | Tipo | Contenido |
|---|---|---|
| `volumenTotal` | metros | Volumen del microciclo |
| `volumenPorSesion` | metros | Punto medio del rango, cuantizado |
| `unidad` | 25 \| 50 | Longitud de piscina |
| `metrosPorZona` | mapa Zona → metros | Reparto por resto mayor |
| `metrosTecnicos` | metros | Volumen × porcentaje técnico de la fase |
| `metrosPorEstilo` | mapa Estilo → metros | Reparto de la priorización |
| `metrosPorSesion` | lista de metros | Reparto entre sesiones |

**Invariantes del presupuesto** (las pruebas los demuestran):

1. `suma(metrosPorZona) == volumenTotal`
2. Toda cantidad repartida es múltiplo de `unidad`
3. `volumenPorSesion` está dentro del rango de la categoría
4. Cada zona se desvía del porcentaje prescrito menos que la tolerancia
5. `suma(metrosPorEstilo) == volumenTotal`
6. `suma(metrosPorSesion) == volumenTotal`
7. El reparto no depende del orden de iteración

---

## 2. Cambio en una entidad existente

### Plan — se añade el origen

| Campo nuevo | Tipo | Reglas |
|---|---|---|
| `origen` | `manual` \| `automatico` | Se fija al crear y **no cambia nunca**, ni al editar ni al aprobar (FR-026) |

Es el único cambio en el modelo almacenado. Va también en la serialización y, por tanto, en la
exportación.

**Por qué no cambia al editar**: un plan que nació generado y el entrenador retocó sigue siendo
de origen automático. Perder ese dato borraría la trazabilidad que el principio IV exige.

### Serie — ya está preparada

No necesita cambios. El campo `origen` que ya tiene (`interpretado` o `corregidoAMano`) sirve
igual para una serie generada: nace como interpretada y pasa a corregida si el entrenador la
toca. Las series generadas también llevan ya `zona`, que el generador asigna porque la deriva
del reparto, no porque la adivine.

---

## 3. Lo que NO se añade al modelo

- **Ninguna semilla ni número aleatorio.** El determinismo viene de que no hay azar, no de
  fijar una semilla.
- **Ningún historial de generaciones anteriores.** El generador no sabe qué se hizo la semana
  pasada; la progresión entre microciclos está fuera de alcance.
- **Ninguna taxonomía de errores técnicos.** Se usa el campo en prosa de la Biblioteca.
  Codificar los errores exigiría modificar el documento normativo y subir su versión, que es
  decisión del entrenador.
- **Ningún campo de contraindicación por lesión.** La Biblioteca no lo tiene y deducirlo sería
  simular criterio clínico.

---

## 4. Relaciones

```
PeticionGeneracion ──generar()──> ResultadoGeneracion
                                         │
                        ┌────────────────┴────────────────┐
                        │                                 │
              MicrocicloGenerado                 GeneracionImposible
                        │                                 │
        ┌───────────────┼──────────────┐           [Impedimento]
        │               │              │
      Plan        [Supuesto]   [VacioDeBiblioteca]
   (origen:
   automatico)
        │
        └──contiene──> Microciclo ──> Sesión ──> Parte (3) ──> Serie ──> Ejercicio
```

El `Plan` que sale del generador es exactamente el mismo tipo que produce el editor a mano.
Esa es la razón por la que la auditoría, el ciclo de vida y la persistencia funcionan sin
cambios: para el resto del sistema, un plan generado no es un caso especial.

---

## 5. Invariantes que las pruebas deben demostrar

Además de los siete del presupuesto:

8. Un microciclo generado tiene tantas sesiones como sesiones semanales su categoría.
9. Toda serie generada tiene zona asignada.
10. Toda serie generada con ejercicio lo referencia por su nombre exacto de la Biblioteca.
11. Ninguna sesión generada deja fragmentos pendientes al releer su notación.
12. El nombre del microciclo deriva del componente acentuado y pasa el criterio C09.
13. Un microciclo generado pasa los once criterios de auditoría sin bloqueantes en rojo.
14. `origen` es `automatico` al nacer y sigue siéndolo tras editar y tras aprobar.
15. Un resultado imposible no deja ningún plan guardado.
