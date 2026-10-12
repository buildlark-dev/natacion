# natacion_app

Aplicación de planificación de natación construida sobre la metodología del
entrenador, documentada en [`docs/metodologia/`](docs/metodologia/).

La app no interpreta la metodología: **la verifica**. Un plan que viole la regla
de no invención, los volúmenes por categoría o las distribuciones ATR no se
puede aprobar.

## Qué hay construido

- **Generador determinista de microciclos**: el entrenador declara categoría,
  fase ATR, estilo objetivo, componente acentuado de la semana, días y piscina, y
  la app le devuelve la semana completa ya cuadrada: volumen dentro del rango de
  la categoría, distribución de zonas de la fase, porcentaje técnico, reparto de
  estilos y solo ejercicios de la Biblioteca. Mismos datos, mismo plan. Sin
  conexión y sin costo: la composición sale de las reglas codificadas, no de un
  modelo de lenguaje.
- **Si los datos no alcanzan o se contradicen, no genera**: explica qué falta o
  por qué es imposible, con los números concretos, y no deja nada a medias.
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

## El vocabulario de diagnóstico del entrenador

Cuando el entrenador declara un error técnico, el generador elige el ejercicio
correctivo por el **índice de términos** de
[`assets/biblioteca/terminos_diagnostico.json`](assets/biblioteca/terminos_diagnostico.json):
cada forma en que él nombra un error, y los ejercicios que le corresponden en su
orden de prioridad. Las correspondencias las confirmó él una por una; el registro
está en [`docs/metodologia/correspondencia_diagnostico.md`](docs/metodologia/correspondencia_diagnostico.md).

Lo que el índice tolera y lo que no:

- `patada desde rodillas` y `patada desde las rodillas` son lo mismo. Los
  artículos, las tildes y las mayúsculas no deciden nada.
- `no gira la cadera` y `gira la cadera` **no** son lo mismo. La negación nunca
  se descarta: son errores opuestos.
- `patada` a secas no alcanza. Es demasiado genérica para elegir un correctivo, y
  se reporta como vacío.
- **No hay comparación por parecido de letras.** Esa tolerancia haría coincidir
  `patada` con `brazada` antes que `dosiflexión` con `dorsiflexión`. Las dos
  grafías de esa palabra están declaradas como entradas propias.

Una frase que no esté en el índice se reporta como vacío de Biblioteca. El bloque
técnico de la sesión se completa con la progresión de la sección 15 —una sesión
no puede quedarse sin técnica—, pero **nunca** con un ejercicio elegido a ojo
para ese error.

El índice **no** modifica la sección 19. La prosa del campo «error que corrige»
queda intacta, así que la versión de la metodología no cambia y los planes
aprobados conservan su trazabilidad.

Para comprobar qué encuentra la app con una frase cualquiera:

```bash
dart run tool/probar_diagnostico.dart "codo bajo" "dosiflexion"
```

Para ver el catálogo completo con su campo de error:

```bash
dart run tool/probar_diagnostico.dart --vocabulario
```

## Gobernanza

El proyecto se rige por [`.specify/memory/constitution.md`](.specify/memory/constitution.md).
Toda feature sigue el flujo de Spec Kit: `/speckit-specify` → `/speckit-plan` →
`/speckit-tasks` → `/speckit-implement`.
