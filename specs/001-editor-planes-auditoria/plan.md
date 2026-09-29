# Implementation Plan: Editor de Planes con Auditoría Metodológica

**Branch**: `001-editor-planes-auditoria` | **Date**: 2026-09-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-editor-planes-auditoria/spec.md`

## Summary

El entrenador escribe sus series como texto libre con su notación de siempre; la app las
interpreta al vuelo, las muestra en campos editables que él puede corregir, y a partir de
esos datos estructurados calcula metros, porcentaje técnico y distribución de zonas. Sobre
eso corre una auditoría de once criterios derivada de su metodología, que bloquea la
aprobación cuando se viola una regla absoluta y exige justificación escrita cuando la
desviación es de las que su metodología admite.

El enfoque técnico se apoya en tres decisiones: un analizador de notación escrito a mano
que nunca falla y devuelve resultados parciales con los fragmentos no reconocidos marcados;
la Biblioteca Oficial extraída de la sección 19 del documento normativo y empaquetada como
recurso versionado de la app; y todo el motor de reglas en Dart puro, sin Flutter ni
Firebase, verificado por una prueba que vigila esa frontera.

## Technical Context

**Language/Version**: Dart 3.12.2 · Flutter 3.44.2 (stable), ambos ya instalados

**Primary Dependencies**: `flutter`, `provider` (gestor de estado, justificado en D8),
`firebase_core` y `cloud_firestore` (capa de datos). Sin dependencias en la capa de dominio.

**Storage**: Firestore contra emulador local durante el desarrollo. Un documento por plan
con los microciclos embebidos y las sesiones en subcolección. La Biblioteca de ejercicios
no se almacena: viaja como recurso de la app.

**Testing**: `flutter_test` para dominio e interfaz; `@firebase/rules-unit-testing` sobre
Node 22 para las reglas de acceso; emuladores vía Firebase CLI 15.29.

**Target Platform**: Chrome (web) como objetivo de desarrollo, alineado con el despliegue
previsto en Firebase Hosting. Windows escritorio como alternativa de iteración rápida.

**Project Type**: Aplicación Flutter de un solo proyecto, con una carpeta auxiliar para la
configuración y las pruebas de Firebase.

**Performance Goals**: La interpretación de una serie y el recálculo de los totales deben
sentirse instantáneos mientras el entrenador escribe. Referencia práctica: reinterpretar
una sesión completa por debajo de 50 ms, que en una sesión de unas 40 series es holgado.

**Constraints**: Funciona sin conexión a internet durante todo el desarrollo. El dominio no
puede importar Flutter ni Firebase. Ningún cálculo puede apoyarse en texto sin interpretar.

**Scale/Scope**: Un entrenador, decenas de nadadores, planes de hasta unas 60 sesiones. La
escala no condiciona ninguna decisión de diseño.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Cómo lo cumple este plan | Veredicto |
|---|---|---|
| **I. Metodología como norma** | La Biblioteca se extrae de la sección 19 del documento normativo (D3) y viaja versionada; los once criterios de auditoría se implementan como reglas verificables; cada plan queda estampado con la versión declarada en `metodologia.json` (D4) | PASA |
| **II. Dominio en Dart puro** | Todo el motor —entidades, analizador de notación, cálculos y auditoría— vive en `lib/dominio/` sin importar Flutter ni Firebase, y una prueba de arquitectura vigila la frontera (D9) | PASA |
| **III. Pruebas de las reglas** | Cada criterio de auditoría con prueba que demuestra que detecta su violación; corpus de series reales para el analizador; reglas de acceso probadas en emulador con casos negativos (D7) | PASA |
| **IV. Criterio del entrenador** | Estados `borrador` → `aprobado` → `publicado`, con la aprobación reservada al entrenador y el plan bloqueado tras aprobar. Sin generación automática de ningún tipo en esta feature | PASA |
| **V. Datos de deportistas** | Solo los campos con uso declarado; sin identificadores en registros técnicos; exportación desde el diseño del modelo. El consentimiento del acudiente está aplazado, y la spec restringe el uso a datos de prueba o del propio entrenador mientras tanto | PASA con condición |
| **VI. Freemium honesto** | No aplica: esta feature no toca cobros, suscripciones ni niveles | N/A |
| **VII. Rebanadas verticales y simplicidad** | Una sola dependencia de estado añadida, justificada en D8; sin capas de arquitectura especulativas. Ver tabla de complejidad para las dos desviaciones declaradas | PASA con salvedades |

**Condición del principio V**: el diseño no impide cargar datos reales de menores, solo la
spec lo prohíbe por escrito. Si el entrenador carga datos reales de sus nadadores antes de
que exista el registro de consentimiento, estaría incumpliendo su propia constitución. La
tarea de perfiles debe incluir un aviso visible en la interfaz mientras esa feature no
exista.

**Re-evaluación tras el diseño de Fase 1**: los artefactos de diseño (modelo de datos,
contratos y guía de arranque) no introdujeron ninguna violación nueva. El modelo de datos
mantiene el dominio libre de tipos de Firestore mediante conversores en la capa de datos;
los contratos de auditoría fijan explícitamente qué criterio bloquea y cuál admite
justificación, tal como se aclaró. **Veredicto: sigue pasando.**

## Project Structure

### Documentation (this feature)

```text
specs/001-editor-planes-auditoria/
├── plan.md              # Este archivo
├── spec.md              # Especificación con las aclaraciones integradas
├── research.md          # Fase 0: decisiones D1 a D9
├── data-model.md        # Fase 1: entidades, reglas e invariantes
├── quickstart.md        # Fase 1: cómo arrancar y cómo validar
├── contracts/
│   ├── notacion.md      # Qué acepta y qué devuelve el analizador
│   ├── auditoria.md     # Los once criterios, su severidad y sus entradas
│   └── almacenamiento.md# Forma de los documentos y reglas de acceso
├── checklists/
│   └── requirements.md  # Calidad de la especificación
└── tasks.md             # Fase 2, la crea /speckit-tasks
```

### Source Code (repository root)

```text
lib/
├── dominio/                    # Dart puro. Sin Flutter, sin Firebase.
│   ├── entidades/              # Plan, Microciclo, Sesion, Parte, Serie, Nadador
│   ├── notacion/               # Tokenizador y analizador de la notación
│   ├── biblioteca/             # Ejercicios, estilos, desambiguación
│   ├── calculo/                # Metros, porcentaje técnico, distribuciones
│   ├── auditoria/              # Los once criterios y el resultado agregado
│   ├── metodologia/            # Categorías, zonas, fases ATR, versión
│   └── repositorios/           # Interfaces que la capa de datos implementa
├── datos/                      # Implementación con Firestore y carga de recursos
│   ├── firestore/              # Conversores documento <-> entidad
│   └── recursos/               # Carga de la biblioteca empaquetada
├── ui/                         # Flutter
│   ├── editor/                 # Pantalla de edición de sesión
│   ├── planes/                 # Lista de planes, auditoría, aprobación
│   └── nadadores/              # Perfiles y asignación
└── main.dart

test/
├── dominio/                    # La mayor parte de las pruebas vive aquí
│   ├── notacion/               # Corpus de series reales
│   ├── auditoria/              # Una prueba por criterio, con su violación
│   └── arquitectura_test.dart  # Vigila la frontera del dominio
├── datos/
└── ui/

firebase/
├── firebase.json               # Configuración de emuladores
├── firestore.rules             # Reglas de acceso
├── firestore.indexes.json
├── package.json                # Solo para las pruebas de reglas
└── test/reglas.test.js         # Casos positivos y negativos

assets/
└── biblioteca/ejercicios.json  # Extraído de la sección 19, revisado a mano

docs/metodologia/
└── metodologia.json            # Versión y huellas de los documentos normativos
```

**Structure Decision**: proyecto Flutter único con separación estricta en tres capas
—`dominio`, `datos`, `ui`— y una carpeta `firebase/` aparte para configuración y pruebas de
reglas. Se eligió frente a una separación en paquetes de Dart (`packages/dominio`, etc.)
porque un solo desarrollador no gana nada con la ceremonia de múltiples paquetes, y la
frontera que de verdad importa —que el dominio no dependa de Flutter ni de Firebase— queda
garantizada por una prueba automática (D9) en lugar de por la estructura de carpetas.

## Complexity Tracking

> Desviaciones del principio VII que se declaran y se justifican.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Dependencia `provider` | El editor mantiene un árbol vivo (plan → microciclos → sesiones → partes → series) donde cada pulsación recalcula metros, porcentaje técnico y auditoría, y muchos widgets separados leen esos valores derivados | Solo `setState` obligaría a un widget raíz gigante y a propagar callbacks por varios niveles; en una pantalla de esta densidad se vuelve inmanejable y frágil |
| Segundo lenguaje (JavaScript sobre Node) en `firebase/test/` | El principio III exige probar automáticamente las reglas de acceso, incluidos los casos negativos, y la biblioteca oficial para eso solo existe en Node | Probar las reglas a mano desde la interfaz del emulador no es automatizable, y una regla de acceso sin prueba automática es justo lo que el principio III prohíbe |
| Tamaño de la feature (37 requisitos, 4 historias) | Es el alcance que el entrenador eligió a conciencia tras advertirle que era la pieza más grande | Recortar por decisión propia sería estrechar el encargo. La línea de corte queda marcada: si el trabajo se desborda, entregar primero las historias P1 y P2 y dejar P3 y P4 para después |
