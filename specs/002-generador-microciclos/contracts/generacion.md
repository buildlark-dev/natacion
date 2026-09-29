# Contrato — Generación de Microciclos

Define qué recibe el generador, qué devuelve, en qué orden ceden las restricciones y cómo
resuelve el redondeo.

## Forma de la llamada

```
generar(PeticionGeneracion) -> ResultadoGeneracion
```

`ResultadoGeneracion` es **una de dos cosas, nunca las dos**:

- `MicrocicloGenerado`: el plan completo, en estado borrador y marcado como generado.
- `GeneracionImposible`: la lista de impedimentos, con su explicación.

**Garantía**: el generador nunca devuelve un plan parcial ni un plan que incumpla un criterio
bloqueante. Si no puede cumplir, no entrega.

## Entradas

### Obligatorias

| Dato | Validación |
|---|---|
| `categoria` | Una de las cinco de la sección 11 |
| `estiloObjetivo` | Libre, Espalda, Pecho, Mariposa o CI |
| `pruebaObjetivo` | Texto no vacío |
| `faseAtr` | Obligatoria si la categoría usa ATR; prohibida si no |
| `componenteAcentuado` | Texto no vacío. Da nombre al microciclo |
| `diasDisponibles` | Lista de días; su cantidad se compara con la frecuencia |
| `longitudPiscina` | 25 o 50 |
| `duracionSesionMinutos` | Entero positivo |

### Opcionales

| Dato | Efecto si falta |
|---|---|
| `diagnosticoTecnico` | Sin él se aplica la progresión técnica estándar; no se inventan errores |
| `fechasSinServicio` | Sin ellas, todos los días declarados cuentan |
| `lesiones` | Sin ellas, no hay aviso. **Con ellas tampoco cambia el plan**: solo se avisa |
| `nadadoresIds` | El plan se genera sin destinatarios asignados |

## Validación previa, antes de repartir

Se comprueba en este orden y se acumulan **todos** los impedimentos antes de devolver, para
que el entrenador los vea de una vez y no de uno en uno:

| Orden | Comprobación | Impedimento |
|---|---|---|
| 1 | Datos obligatorios presentes | `datoFaltante` |
| 2 | Fase ATR admisible para la categoría | `faseNoAdmisible` |
| 3 | Días disponibles ≥ sesiones semanales de la categoría | `frecuenciaImposible` |
| 4 | Volumen por sesión alcanzable en la duración declarada | `duracionInsuficiente` |
| 5 | Componente acentuado coherente con la fase | `componenteIncoherente` |

Sobre la comprobación 4: estimar si un volumen cabe en un tiempo exige una referencia de
ritmo medio. **Esa referencia es un supuesto nuestro, no una regla del entrenador**, vive en
un solo lugar y es revisable. Cuando un plan se genera apoyándose en ella, queda marcado como
supuesto dentro del plan.

## Escala de precedencia

Cuando las restricciones no se pueden satisfacer todas, ceden **de abajo hacia arriba**.

| Nivel | Restricción | Cede |
|---|---|---|
| 1 | No invención: solo ejercicios de la Biblioteca (R2) | **Nunca** |
| 2 | Estructura de sesión: tres partes, 40/50/10, objetivos (sección 14) | **Nunca** |
| 3 | Volumen por sesión dentro del rango y frecuencia de la categoría (R4) | **Nunca** |
| 4 | Porcentaje técnico de la fase | **Nunca a la baja**; puede quedar por encima |
| 5 | Distribución de zonas de la fase (R5) | Dentro de la tolerancia |
| 6 | Reparto de estilos (sección 13) | Dentro de la tolerancia |

El nivel 4 está por encima del 5 porque la sección 3 de la metodología dice que la técnica
tiene prioridad sobre el volumen y sobre la intensidad, y la R1 prohíbe sacrificar calidad
técnica. Si cuadrar una zona exigiera recortar técnica, se recorta la zona.

**Si tras ceder los niveles 5 y 6 dentro de la tolerancia el reparto no cierra**, el resultado
es `GeneracionImposible` con el impedimento `repartoImposible`, explicando qué restricción no
se pudo satisfacer y con cuánta diferencia.

## Regla de redondeo

El reparto **no opera en metros sueltos** sino en unidades de longitud de piscina.

```
unidad = longitudPiscina        (25 m o 50 m)
unidades = volumenTotal / unidad
```

Sobre esas unidades se aplica el **método del resto mayor**:

1. A cada zona se le asigna la parte entera de `unidades × porcentaje / 100`.
2. Las unidades sobrantes se reparten una a una entre las zonas con mayor resto fraccionario.
3. **Los empates se rompen por el orden fijo** A1, A2, A3, AT, Máx, Velocidad.

El paso 3 es lo que garantiza el determinismo: sin un desempate declarado, dos zonas con el
mismo resto podrían recibir el sobrante en orden distinto según cómo itere el código.

La misma regla se aplica al reparto de estilos y al reparto entre sesiones.

**Propiedades que las pruebas deben demostrar:**

- La suma de lo repartido es exactamente el total. No aparecen ni desaparecen metros.
- Toda cantidad repartida es múltiplo de la longitud de piscina.
- Ninguna zona queda con desviación mayor que la tolerancia.
- El resultado no depende del orden de iteración.

## Salida: el microciclo generado

| Campo | Contenido |
|---|---|
| `nombre` | Derivado del componente acentuado, nunca de la posición en la fase |
| `categoria`, `estiloObjetivo`, `pruebaObjetivo`, `longitudPiscina`, `faseAtr` | Copiados de la petición |
| `estado` | Siempre `borrador` |
| `origen` | Siempre `automatico`, y se conserva aunque el entrenador edite después |
| `sesiones` | Tantas como sesiones semanales de la categoría |
| `supuestos` | Lista de supuestos marcados, vacía si no hubo ninguno |
| `vaciosDeBiblioteca` | Errores diagnosticados sin ejercicio que los corrija |
| `avisos` | Lesiones declaradas y cualquier otra advertencia que no impide generar |

Cada sesión generada trae objetivo técnico, objetivo fisiológico, RPE previsto, y sus tres
partes con series que llevan su zona asignada y su texto en notación del entrenador.

## Lo que el generador NO hace

- **No adapta por lesiones.** La Biblioteca declara qué error corrige cada ejercicio, no qué
  está contraindicado. Deducirlo sería simular criterio clínico, que el principio IV prohíbe.
- **No sabe qué se hizo la semana anterior.** No hay progresión entre microciclos.
- **No deduce la fase del calendario.** La fase es un dato de entrada.
- **No inventa errores técnicos** cuando no hay diagnóstico.
- **No sugiere ejercicios parecidos** cuando el nombre no está en la Biblioteca.
- **No usa azar.** Ninguna decisión depende de una semilla, del reloj ni del orden de un mapa.
- **No consulta ningún servicio externo.** Genera sin red.

## Ubicación de zonas dentro de la sesión

| Parte | Porcentaje | Zonas admitidas |
|---|---|---|
| Inicial | 40% | A1 |
| Central · pre-set | 10% | A1, A2 |
| Central · principal | 40% | A2, A3, AT, Máx, Velocidad |
| Final | 10% | A1 con recuperación |

Reproduce la interconexión de cargas de la sección 4: primero la calidad, después la carga
metabólica. La técnica vive donde el nadador está fresco.

El presupuesto técnico se coloca en la inicial y el pre-set. Si no cupiera, se extiende a la
principal y el hecho queda marcado como supuesto, porque la técnica no cede (nivel 4).
