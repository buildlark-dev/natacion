# Implementation Plan: Generador Determinista de Microciclos

**Branch**: `002-generador-microciclos` | **Date**: 2026-09-29 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-generador-microciclos/spec.md`

## Summary

El entrenador declara la categoría, la fase, el estilo objetivo, el componente acentuado de
la semana y los días disponibles, y el generador reparte de arriba hacia abajo: primero el
volumen del microciclo, después las zonas, el presupuesto técnico y los estilos, y al final
elige los ejercicios y escribe el resultado en su notación. El cumplimiento sale del reparto,
no de comprobar al final y volver a intentarlo.

La decisión que gobierna todo lo demás es la **escala de precedencia**: cuando las
restricciones chocan, ceden de abajo hacia arriba —reparto de estilos, después distribución de
zonas, ambos dentro de la tolerancia— y nunca ceden la no invención, la estructura de sesión,
el volumen de la categoría ni el porcentaje técnico. Si aun así no cierra, **no genera**: el
entrenador recibe la contradicción explicada, no un plan que incumple.

El reparto se verificó numéricamente sobre las treinta combinaciones de categoría, fase y
longitud de piscina antes de escribir este plan. En todas cierra exacto y dentro de tolerancia.

## Technical Context

**Language/Version**: Dart 3.12.2 · Flutter 3.44.2, sin cambios respecto a la feature 001

**Primary Dependencies**: **ninguna nueva**. El reparto, el redondeo y la selección de
ejercicios son aritmética y recorrido de listas sobre lo ya construido: constantes de la
metodología, Biblioteca, entidades, motor de auditoría y editor.

**Storage**: el mismo. Un microciclo generado es un plan como cualquier otro: documento del
plan con microciclos embebidos y sesiones en subcolección.

**Testing**: `flutter_test`. El peso de las pruebas está en el dominio: reparto, redondeo,
precedencia, determinismo y viaje redondo de la notación.

**Target Platform**: Chrome (web) para desarrollo, alineado con el despliegue en Hosting.

**Project Type**: Aplicación Flutter de un solo proyecto. Se añade `lib/dominio/generacion/`.

**Performance Goals**: la generación de un microciclo debe sentirse instantánea. Referencia:
por debajo de 200 ms para Alto Rendimiento, que es el caso mayor (diez sesiones, 55.000 m).

**Constraints**: determinista sin azar; funciona sin conexión; el dominio no importa Flutter
ni Firebase; ningún plan generado puede incumplir un criterio bloqueante.

**Scale/Scope**: un microciclo por generación. El caso mayor son diez sesiones.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitución vigente: **v1.1.0**, ocho principios.

| Principio | Cómo lo cumple este plan | Veredicto |
|---|---|---|
| **I. Metodología como norma** | El generador no interpreta nada: compone a partir de las constantes ya codificadas y probadas. Solo usa la Biblioteca. La escala de precedencia (D2) deriva de la jerarquía R1-R7, y la propia sección 3 decide que la técnica no ceda | PASA |
| **II. Dominio en Dart puro** | Todo el generador vive en `lib/dominio/generacion/`, sin Flutter ni Firebase. La prueba de frontera existente lo vigila sin cambios | PASA |
| **III. Pruebas de las reglas** | La constitución 1.1.0 añadió una exigencia concreta: todo plan generado debe tener pruebas que demuestren que **cumple por construcción**. Se prueban las treinta combinaciones de categoría, fase y piscina, más el determinismo y el viaje redondo | PASA |
| **IV. Criterio del entrenador** | Generación **determinista**, que es la vía por defecto que la constitución prescribe. Nace en borrador, marcada como generada, pasa los once criterios sin relajarlos, y solo él aprueba. Un microciclo cabe bajo el límite de veinte sesiones, así que no fragmenta los puntos de decisión. No adapta por lesiones: eso sería simular criterio clínico | PASA |
| **V. Datos de deportistas** | No recolecta ningún dato nuevo. El diagnóstico técnico y las lesiones ya estaban previstos en el perfil. Sigue vigente el uso con datos de prueba | PASA |
| **VI. Freemium honesto** | No aplica: esta feature no toca cobros ni niveles | N/A |
| **VII. Rebanadas verticales y simplicidad** | Ninguna dependencia nueva. Reutiliza el editor como superficie de revisión en lugar de construir una pantalla propia | PASA |
| **VIII. Control de carga interna** | No aplica: el registro del nadador es la feature 003. Este generador produce carga **externa**; la interna llega después. El diseño no la estorba: un plan generado es un plan normal y podrá recibir los registros del nadador sin cambios | N/A, sin deuda |

**Re-evaluación tras el diseño de Fase 1**: los artefactos no introdujeron ninguna violación.
El modelo de datos no añade entidades almacenadas —la petición y el resultado son de
ejecución—, los contratos fijan la precedencia y el redondeo por escrito, y la guía de
validación se apoya en los escenarios de la spec. **Veredicto: sigue pasando.**

## Project Structure

### Documentation (this feature)

```text
specs/002-generador-microciclos/
├── plan.md                  # Este archivo
├── spec.md                  # Especificación
├── research.md              # Fase 0: decisiones D1 a D8
├── data-model.md            # Fase 1: petición, resultado e invariantes
├── quickstart.md            # Fase 1: cómo validar
├── contracts/
│   ├── generacion.md        # Entradas, salidas, precedencia y redondeo
│   └── renderizado.md       # Estructura a notación, y el viaje redondo
├── checklists/
│   └── requirements.md      # Calidad de la especificación
└── tasks.md                 # Fase 2, la crea /speckit-tasks
```

### Source Code (repository root)

Solo se añade la carpeta de generación; el resto ya existe.

```text
lib/
├── dominio/
│   ├── generacion/                   # NUEVO. Dart puro.
│   │   ├── peticion.dart             # Datos de entrada y su validación
│   │   ├── impedimento.dart          # Datos que faltan y contradicciones
│   │   ├── reparto.dart              # Resto mayor sobre unidades de piscina
│   │   ├── presupuesto.dart          # Volumen, zonas, técnica y estilos
│   │   ├── compositor_sesion.dart    # Partes 40/50/10 y ubicación de zonas
│   │   ├── selector_ejercicios.dart  # Por diagnóstico o progresión estándar
│   │   ├── ritmos.dart               # Estimación de duración (supuesto nuestro)
│   │   └── generador.dart            # Orquesta y devuelve el resultado
│   ├── notacion/
│   │   └── renderizador.dart         # NUEVO. Camino inverso del analizador
│   ├── entidades/                    # Existente: se añade el origen del plan
│   ├── auditoria/                    # Existente, sin cambios
│   ├── biblioteca/                   # Existente, sin cambios
│   ├── calculo/                      # Existente, sin cambios
│   └── metodologia/                  # Existente, sin cambios
├── datos/                            # Existente: persistir el origen
└── ui/
    ├── generacion/                   # NUEVO
    │   ├── pantalla_peticion.dart    # El formulario de la sección 5
    │   └── panel_impedimentos.dart   # Qué falta o qué se contradice
    └── editor/                       # Existente: recibe lo generado

test/
├── dominio/
│   ├── generacion/
│   │   ├── reparto_test.dart         # Resto mayor, cierre exacto, empates
│   │   ├── presupuesto_test.dart     # Las 30 combinaciones dentro de tolerancia
│   │   ├── precedencia_test.dart     # Qué cede y qué no cuando chocan
│   │   ├── determinismo_test.dart    # Misma petición, mismo plan
│   │   ├── seleccion_test.dart       # Diagnóstico y progresión estándar
│   │   ├── impedimentos_test.dart    # No genera con datos malos
│   │   └── cumple_auditoria_test.dart# Lo generado pasa los once criterios
│   └── notacion/
│       └── viaje_redondo_test.dart   # Generar, escribir, releer, comparar
└── ui/
```

**Structure Decision**: el generador es una carpeta nueva del dominio y nada más. No se toca
el motor de auditoría, ni la Biblioteca, ni las constantes: si el generador necesitara
cambiarlos, sería señal de que está intentando saltarse una regla en lugar de cumplirla. Los
únicos cambios en código existente son añadir el **origen del plan** (manual o automático) a
la entidad y a su serialización, y abrir el editor con un plan ya poblado.

## Complexity Tracking

> Sin desviaciones que justificar.

No se añade ninguna dependencia, ninguna capa de arquitectura ni ningún segundo lenguaje. La
feature se construye con lo que ya hay.

Las tres desviaciones declaradas en la feature 001 —`provider`, JavaScript para probar las
reglas de acceso, y el tamaño de la feature— siguen vigentes y no se amplían.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| *(ninguna nueva)* | — | — |
