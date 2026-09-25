# natacion_app

Aplicación de planificación de natación construida sobre la metodología del
entrenador, documentada en [`docs/metodologia/`](docs/metodologia/).

La app no interpreta la metodología: **la verifica**. Un plan que viole la regla
de no invención, los volúmenes por categoría o las distribuciones ATR no se
puede aprobar.

## Qué hay construido

- **Editor de sesión con entrada híbrida**: el entrenador escribe con su
  notación de siempre (`4x100 AL SNK PN / 2'`) y la app muestra al instante lo
  que entendió en campos editables. Lo que corrige a mano prevalece sobre la
  interpretación automática.
- **Analizador de notación** que nunca falla: ante lo que no entiende devuelve
  resultados parciales y marca el fragmento con su posición exacta.
- **Motor de auditoría** con los once criterios de la sección 16, cuatro
  bloqueantes y siete justificables.
- **Ciclo de vida del plan**: `borrador` → `aprobado` → `publicado`. Aprobar
  estampa la versión de metodología; un plan aprobado es inmutable.
- **Perfiles de nadador** y asignación de planes.

## Requisitos

Todo verificado sobre el equipo de desarrollo:

| Herramienta | Versión |
|---|---|
| Flutter | 3.44+ |
| Dart | 3.12+ |
| Node | 20+ (solo para las pruebas de reglas) |
| Firebase CLI | 14+ |
| Java | 17+ (requisito del emulador de Firestore) |

## Cómo arrancar

Instalar dependencias:

```bash
flutter pub get
```

Levantar la app en el navegador:

```bash
flutter run -d chrome
```

Con emuladores locales, en dos terminales:

```bash
firebase emulators:start --project demo-natacion --config firebase/firebase.json
```

```bash
flutter run -d chrome --dart-define=USAR_EMULADORES=true
```

`demo-natacion` es un identificador ficticio. Los emuladores lo aceptan sin que
exista nada en la nube, y así no hay riesgo de escribir en un proyecto real por
descuido. La bandera es falsa por omisión, a propósito.

## Pruebas

Dominio, interfaz y frontera de arquitectura:

```bash
flutter test
```

Análisis estático, que debe salir limpio:

```bash
flutter analyze
```

Reglas de acceso de Firestore, con sus casos negativos:

```bash
npm --prefix firebase test
```

## Estructura

```text
lib/
├── dominio/      Dart puro. Sin Flutter, sin Firebase. Todas las reglas.
├── datos/        Firestore, memoria, recursos empaquetados y exportación.
└── ui/           Pantallas.

firebase/         Reglas de acceso, configuración de emuladores y sus pruebas.
docs/metodologia/ Fuente normativa del dominio.
specs/            Especificación, plan y tareas de cada feature.
tool/             Utilidades: extracción de la Biblioteca, lectura de Excel.
```

Una prueba vigila que `lib/dominio/` no importe Flutter ni Firebase. Es el
principio II de la constitución, convertido en algo que el sistema verifica en
lugar de algo que hay que recordar.

## Regenerar la Biblioteca de ejercicios

La Biblioteca se extrae de la sección 19 del documento normativo:

```bash
dart run tool/extraer_biblioteca.dart
```

El resultado **debe revisarlo el entrenador** antes de darlo por válido: un
ejercicio mal transcrito es una regla mal aplicada.

## Gobernanza

El proyecto se rige por [`.specify/memory/constitution.md`](.specify/memory/constitution.md).
Toda feature sigue el flujo de Spec Kit: `/speckit-specify` → `/speckit-plan` →
`/speckit-tasks` → `/speckit-implement`.
