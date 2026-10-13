# Cómo se trabaja en este repositorio

Para levantar el proyecto, correr las pruebas y entender su estructura:
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md). Este documento es solo el flujo.

## Nada entra directo a `main`

Todo cambio va en una rama y entra por pull request, incluso los de una línea.
`main` es la rama desde la que se despliega y la que sella la versión de
metodología de los planes aprobados: no se escribe a mano sobre ella.

```bash
git checkout -b <tipo>/<descripcion-corta>
```

| Prefijo | Para qué |
|---|---|
| `NNN-nombre-feature` | Una feature de Spec Kit, con su carpeta en `specs/` |
| `fix/` | Corrección de un defecto |
| `docs/` | Solo documentación |
| `ci/` | Flujo de integración, herramientas, configuración del repositorio |
| `chore/` | Mantenimiento que no cambia comportamiento |

## El CI tiene que estar en verde

Cada pull request corre [`.github/workflows/ci.yml`](.github/workflows/ci.yml):
análisis estático, pruebas de dominio e interfaz, frontera del dominio, huella de
los documentos normativos, build web y pruebas de reglas de acceso con sus casos
negativos.

Antes de abrir el PR conviene correr lo mismo en local, que es más rápido que
esperar al CI:

```bash
flutter analyze && flutter test && dart run tool/verificar_metodologia.dart
```

```bash
npm --prefix firebase test
```

Las pruebas de reglas necesitan la CLI de Firebase y Java 21, porque el emulador
de Firestore corre sobre la JVM:

```bash
npm install -g firebase-tools@15.29.0
```

## Las features siguen el flujo de Spec Kit

`/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`,
con `/speckit-clarify` cuando la especificación tiene huecos. Los documentos de
cada feature viven en `specs/NNN-nombre/` y son parte del entregable: la
especificación, el plan y las tareas se revisan igual que el código.

## Reglas que no se negocian

Vienen de [`.specify/memory/constitution.md`](.specify/memory/constitution.md) y
el pull request pregunta por ellas:

- **La metodología del entrenador es la norma.** La app no la interpreta: la
  verifica. Si una cifra la exige la app, tiene que poder citarse.
- **El dominio es Dart puro.** `lib/dominio/` no importa Flutter ni Firebase, y
  hay una prueba que lo vigila.
- **Las reglas que llegan al nadador se prueban**, con sus casos negativos.
- **El criterio del entrenador no se delega.** Lo generado nace borrador, va
  marcado como generado y no llega a un nadador sin su firma.
- **Datos de deportistas**: el consentimiento verificable del acudiente es una
  puerta de publicación. Sin nombres, marcas, videos ni identificadores en
  registros ni analítica.
- **Ni una credencial en el repositorio.** Ninguna clave de API viaja al
  cliente: las llamadas a un modelo pasan por un servidor.

## Mensajes de commit

En español, en imperativo, con el prefijo del tipo de cambio:

```text
fix: corregir el reparto de zonas cuando la sesión no es múltiplo de la piscina
```

El cuerpo explica **por qué**, no qué: el qué ya está en el diff. Si el cambio
sale de una decisión del entrenador o de una fuente publicada, el cuerpo la
nombra.
