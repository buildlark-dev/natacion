# Modelo de Datos — Feature 001

**Fecha**: 2026-09-25 · Deriva de [spec.md](./spec.md) y de las decisiones de
[research.md](./research.md).

Todas las entidades viven en `lib/dominio/entidades/` como Dart puro. Los tipos de
Firestore no aparecen aquí: la conversión ocurre en `lib/datos/firestore/`.

---

## 1. Datos de referencia (constantes de la metodología)

No se almacenan en la base: son reglas, viajan con la app y cambian solo al subir la
versión de metodología.

### Categoría

| Categoría | Metros por sesión | Sesiones/semana | Usa ATR |
|---|---|---|---|
| Iniciación | 500 – 800 | 2 | No |
| Tecnificación | 800 – 1000 | 2 | No |
| Precompetitivo | 1800 – 2200 | 3 | Sí |
| Competitivo | 4000 – 5000 | 5 | Sí |
| Alto Rendimiento | 5000 – 6000 | 10 | Sí |

Regla adicional de Tecnificación: en programas de dos meses, la sesión 1 es de Pecho y la
sesión 2 de Mariposa, todas las semanas.

### Zona de intensidad

| Zona | % FCmáx | RPE | Se controla por |
|---|---|---|---|
| A1 | 60 – 70 | 1 – 2 | Frecuencia cardíaca |
| A2 | 70 – 80 | 2 – 4 | Frecuencia cardíaca |
| A3 | 80 – 85 | 4 – 5 | Frecuencia cardíaca |
| AT | 85 – 92 | 5 – 6 | Frecuencia cardíaca |
| Máx | 92 + | 7 – 10 | Frecuencia cardíaca |
| Velocidad | — | Máx | Ritmo, no frecuencia cardíaca |

**Invariante**: las bandas son contiguas y no se solapan. Ninguna serie cuenta en más de
una zona.

### Fase ATR

| Fase | A1 | A2 | A3 | AT | Máx | Velocidad | Técnico |
|---|---|---|---|---|---|---|---|
| Acumulación | 60% | 25% | 10% | 5% | — | — | 50% |
| Transformación | 30% | 35% | 15% | 15% | 5% | — | 30% |
| Realización | 25% | 25% | 15% | 10% | 15% | 10% | 20% |

**Invariante**: cada fila de zonas suma exactamente 100%. El porcentaje técnico es una
medida aparte, sobre el volumen total, y no entra en esa suma.

### Distribución de estilos (Precompetitivo en adelante)

| Estilo objetivo | Reparto del volumen de nado |
|---|---|
| Libre | 80 – 85% Libre · 15 – 20% Espalda |
| Pecho | 50% Pecho · 50% Libre/Espalda |
| Mariposa | 50% Mariposa · 50% Libre/Espalda |

### Reparto de la sesión

Inicial 40% · Central 50% (pre-set 10% + principal 40%) · Final 10%.

### Ejercicio de la Biblioteca

Recurso empaquetado, extraído de la sección 19 del documento normativo.

| Campo | Tipo | Notas |
|---|---|---|
| `nombre` | texto | Exacto como aparece en la sección 19 |
| `estilo` | Libre \| Espalda \| Pecho \| Mariposa \| General | |
| `descripcion` | texto | |
| `errorQueCorrige` | texto | Para elegir el drill según el diagnóstico |
| `requiereDesambiguacion` | booleano | Verdadero cuando el nombre se repite entre estilos |

**Invariante**: la pareja (`nombre`, `estilo`) es única. Un nombre con
`requiereDesambiguacion` solo puede usarse indicando el estilo: `FLECHA (Espalda)`.

---

## 2. Entidades almacenadas

### Nadador

| Campo | Tipo | Reglas |
|---|---|---|
| `id` | identificador | |
| `nombre` | texto | Obligatorio |
| `fechaNacimiento` | fecha | Opcional; de ella se deriva si es menor |
| `categoria` | Categoría | **Obligatorio** para dar el perfil por completo |
| `estiloObjetivo` | Estilo | **Obligatorio** para dar el perfil por completo |
| `pruebaObjetivo` | texto | 50, 100, 200, 400, 800, fondo |
| `marcas` | lista de Marca | Distancia, estilo, tiempo, fecha |
| `diagnosticoTecnico` | lista de texto | Errores observados |

**Restricción declarada en la spec**: mientras no exista el registro de consentimiento del
acudiente, solo se cargan perfiles de prueba o los del propio entrenador. La interfaz debe
advertirlo de forma visible.

### Plan

| Campo | Tipo | Reglas |
|---|---|---|
| `id` | identificador | |
| `nombre` | texto | Obligatorio |
| `categoria` | Categoría | Obligatorio |
| `estiloObjetivo` | Estilo | Obligatorio |
| `pruebaObjetivo` | texto | Obligatorio |
| `longitudPiscina` | 25 \| 50 | Obligatorio |
| `fechaInicio`, `fechaFin` | fecha | Obligatorias |
| `faseATR` | Acumulación \| Transformación \| Realización \| ninguna | Debe ser `ninguna` si la categoría no usa ATR |
| `microciclos` | lista de Microciclo | Embebida |
| `nadadoresIds` | lista de identificadores | Destinatarios del plan |
| `estado` | borrador \| aprobado \| publicado | |
| `versionMetodologia` | texto | Se estampa al aprobar, desde `metodologia.json` |
| `fechaAprobacion` | fecha | Solo si está aprobado |
| `justificaciones` | lista de Justificación | |
| `versionAnteriorId` | identificador | Presente si nace de editar un plan aprobado |

**Transiciones de estado**:

```
borrador ──aprobar()──> aprobado ──publicar()──> publicado
   ▲                        │
   └──editar() crea plan nuevo con versionAnteriorId
```

- `aprobar()` exige: cero criterios bloqueantes en rojo, y justificación no vacía para cada
  criterio justificable en rojo. Estampa `versionMetodologia` y `fechaAprobacion`.
- Un plan `aprobado` o `publicado` es inmutable. Editarlo crea un plan nuevo en `borrador`.

### Microciclo

| Campo | Tipo | Reglas |
|---|---|---|
| `id` | identificador | |
| `nombre` | texto | Debe describir el objetivo real, no solo la posición ("técnica de eficiencia", no "Acumulación 1") |
| `orden` | entero | |
| `objetivo` | texto | Componente acentuado |

### Sesión

Documento propio, en subcolección del plan.

| Campo | Tipo | Reglas |
|---|---|---|
| `id` | identificador | |
| `microcicloId` | identificador | |
| `fecha` | fecha | |
| `objetivoTecnico` | texto | **Obligatorio** para darla por completa |
| `objetivoFisiologico` | texto | **Obligatorio** para darla por completa |
| `rpePrevisto` | entero 0-10 | |
| `variablesMonitoreo` | lista de texto | Cuenta de brazadas, splits parejos, técnica bajo fatiga |
| `partes` | exactamente 3 Partes | Inicial, central, final |

**Derivados** (calculados, nunca almacenados como verdad): metros totales, reparto real
entre partes, porcentaje técnico, distribución de zonas, distribución de estilos.

### Parte

| Campo | Tipo | Reglas |
|---|---|---|
| `tipo` | inicial \| central \| final | |
| `textoOriginal` | texto | Lo que el entrenador escribió, tal cual |
| `series` | lista de Serie | Resultado de interpretar el texto |
| `fragmentosPendientes` | lista de Fragmento | Lo que no se supo interpretar |

**Invariante clave (FR-037)**: todo cálculo usa `series`. `textoOriginal` se conserva solo
como referencia para el entrenador y para que él detecte una interpretación equivocada.

### Serie

| Campo | Tipo | Notas |
|---|---|---|
| `repeticiones` | entero | 1 si no se indica |
| `distancia` | metros | |
| `tiempoSalida` | duración | De `NxD / t` |
| `implementos` | lista | Aletas, palas, palas pequeñas, pull buoy, snorkel, paracaídas, banda |
| `ejercicio` | referencia a Ejercicio | Nulo si es nado completo |
| `estilo` | Estilo | |
| `zona` | Zona | |
| `esTecnica` | booleano | Verdadero si lleva ejercicio de biblioteca; alimenta el % técnico |
| `modificadores` | lista | Hipóxico, progresivo, regresivo, salida de bloque, subacuático |
| `origen` | interpretado \| corregido a mano | La corrección manual prevalece (FR-035) |

**Metros de la serie** = `repeticiones × distancia`.

### Fragmento pendiente

| Campo | Tipo |
|---|---|
| `texto` | El trozo no reconocido |
| `posicionInicio`, `posicionFin` | Índices dentro de `textoOriginal` |
| `motivo` | Término desconocido \| estructura no reconocida \| ejercicio fuera de biblioteca |

**Invariante**: una sesión con fragmentos pendientes no puede darse por completa (FR-036),
y un plan con sesiones incompletas no puede aprobarse.

### Justificación

| Campo | Tipo | Reglas |
|---|---|---|
| `criterioId` | texto | Cuál criterio justifica |
| `texto` | texto | **No puede estar vacío** (FR-023) |
| `fecha` | fecha | |

### Propuesta de ejercicio

Vive fuera de los planes y no tiene efecto sobre ninguno (FR-004).

| Campo | Tipo |
|---|---|
| `nombrePropuesto`, `descripcion`, `estilo`, `motivo`, `fecha`, `estado` (pendiente \| aprobada \| rechazada) |

### Término de glosario

| Campo | Tipo |
|---|---|
| `termino`, `definicion`, `fechaIncorporacion` |

---

## 3. Resultado de auditoría

Se calcula, no se almacena. Al aprobar, se guarda una instantánea junto al plan para dejar
constancia de qué se aprobó y con qué observaciones.

| Campo | Tipo |
|---|---|
| `criterios` | lista de CriterioEvaluado |
| `apruebaSinBloqueos` | booleano derivado |

### Criterio evaluado

| Campo | Tipo |
|---|---|
| `id` | Identificador estable del criterio |
| `nombre` | Como aparece en la tabla de auditoría de la metodología |
| `severidad` | bloqueante \| justificable |
| `cumple` | booleano |
| `observacion` | Texto con los números concretos: real, esperado y diferencia |
| `ubicacion` | Dónde ocurre (sesión, parte, serie), si aplica |

El detalle de los once criterios, con su severidad y sus entradas, está en
[contracts/auditoria.md](./contracts/auditoria.md).

---

## 4. Relaciones

```
Nadador ──(pertenece a)── Categoría
   ▲
   │ nadadoresIds
   │
 Plan ──contiene──> Microciclo (embebido)
   │                     ▲
   │                     │ microcicloId
   └──subcolección──> Sesión ──contiene──> Parte (3) ──contiene──> Serie
                                              │                      │
                                              │                      └──referencia──> Ejercicio
                                              └──contiene──> Fragmento pendiente
```

## 5. Invariantes que las pruebas deben demostrar

1. Los metros de una parte son la suma de `repeticiones × distancia` de sus series.
2. Los metros de una sesión son la suma de sus tres partes.
3. El porcentaje técnico es metros con ejercicio de biblioteca sobre metros totales.
4. La distribución de zonas de un plan suma 100% de su volumen.
5. Ninguna serie pertenece a dos zonas.
6. Una categoría sin ATR no admite fase ATR.
7. Un plan aprobado no cambia: cualquier edición produce un plan nuevo.
8. Un plan aprobado siempre tiene `versionMetodologia` y `fechaAprobacion`.
9. Una justificación vacía no habilita la aprobación.
10. Un nombre de ejercicio ambiguo sin estilo no es una referencia válida.
