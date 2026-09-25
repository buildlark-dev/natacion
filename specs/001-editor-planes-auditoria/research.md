# Investigación — Feature 001: Editor de Planes con Auditoría Metodológica

**Fecha**: 2026-09-25 · **Rama**: `001-editor-planes-auditoria`

Resuelve las incógnitas técnicas de la spec antes del diseño. Cada decisión indica qué se
eligió, por qué, y qué se descartó.

## Entorno verificado en el equipo del entrenador

| Herramienta | Versión detectada | Para qué |
|---|---|---|
| Flutter | 3.44.2 (stable) | Framework de la app |
| Dart | 3.12.2 | Lenguaje, coincide con `pubspec.yaml` (`sdk: ^3.12.2`) |
| Node | 22.23.1 | Pruebas de reglas de seguridad |
| npm | 10.9.8 | Dependencias de esas pruebas |
| Firebase CLI | 15.29.0 | Emuladores y, más adelante, despliegue |
| Java | 21.0.12 (Temurin) | Requisito del emulador de Firestore |
| Dispositivos | Windows escritorio, Chrome, Edge | Sin móvil conectado |

Todo lo necesario ya está instalado. No hace falta instalar nada para empezar.

---

## D1 — Plataforma objetivo durante el desarrollo

**Decisión**: Chrome (web) como objetivo principal de desarrollo y pruebas manuales, con
Windows escritorio como alternativa para iterar rápido.

**Razón**: el despliegue previsto es Firebase Hosting, que sirve web; desarrollar en web
significa que lo que se prueba es lo que se publicará. Además no hay dispositivo móvil
conectado hoy, y el editor es una pantalla densa de escritura que se maneja mejor con
teclado.

**Alternativas descartadas**: Android como objetivo primario (requiere emulador pesado y no
coincide con el canal de despliegue); iOS (no disponible desde Windows).

**Consecuencia**: el diseño responsivo para móvil no es objetivo de esta feature. El
consumo por parte del nadador a pie de piscina, que sí es móvil, corresponde a otra feature.

---

## D2 — Interpretación de la notación del entrenador

Es el riesgo técnico central de la feature (FR-005, FR-033 a FR-037).

**Decisión**: analizador escrito a mano en Dart puro, en dos etapas —tokenizador y
analizador descendente— con **recuperación de errores como comportamiento normal**. El
analizador NUNCA lanza excepción: devuelve una serie estructurada, más la lista de
fragmentos que no supo interpretar, cada uno con su posición exacta dentro del texto
original.

**Razón**:

- FR-036 exige marcar lo no interpretado sin bloquear la escritura. Eso obliga a un
  analizador que produce resultados parciales; los generadores de analizadores tienden a
  fallar por completo ante entrada inesperada.
- La notación es pequeña pero irregular (`4x100 AL / 2'`, `8x50 (1L 1Estilo 1>4)`,
  `200 AL (25m Pn E FLECHA + 75 N)`, `Hyp 5`, `1<4`, `^`). Un analizador a mano permite
  tratar cada irregularidad con una regla explícita y un mensaje comprensible.
- No añade dependencias, lo que respeta el principio VII.
- Al vivir en Dart puro es directamente testeable sin Flutter, como exige el principio II.

**Alternativas descartadas**: `petitparser` (dependencia y curva de aprendizaje para una
gramática que cabe en pocos cientos de líneas); solo expresiones regulares (se rompe con
los paréntesis anidados y no sabe informar de la posición del fallo); pedir la estructura
al usuario en formularios (descartado ya en la aclaración: sería más lento que su Excel).

**Estrategia de validación**: corpus de pruebas construido a partir de las series reales
que ya aparecen en `docs/metodologia/PROMPT_MAESTRO_V3.4.md` y en el plan de referencia.
Cada serie del corpus es un caso de prueba con su resultado estructurado esperado.

---

## D3 — Fuente de datos de la Biblioteca Oficial

**Decisión**: extraer la biblioteca de la **sección 19 de
`docs/metodologia/PROMPT_MAESTRO_V3.4.md`**, no del `.docx`, y publicarla como recurso de
la app (`assets/biblioteca/ejercicios.json`), versionado junto al código.

**Razón**:

- El Markdown ya es texto estructurado en tablas (`| Nombre | Descripción | Error que
  corrige |`), legible por máquina sin conversión intermedia.
- La metodología designa la sección 19 como la fuente válida; el `.docx` es material de
  apoyo. Extraer de la fuente normativa evita dos versiones divergentes.
- Como recurso empaquetado, la biblioteca está disponible sin conexión y siempre coincide
  con la versión de la app, que es lo que permite validar la regla de no invención en todo
  momento.

**Alternativas descartadas**: guardarla en Firestore (es dato de referencia estático,
idéntico para todos; ponerlo en la base añade latencia, costo y la posibilidad de que la
app y la biblioteca queden desfasadas); leer el `.docx` en tiempo de ejecución (formato
comprimido, innecesariamente costoso de interpretar).

**Riesgo a vigilar**: la extracción es un paso de una sola vez que el entrenador debe
revisar. Un ejercicio mal transcrito se convierte en una regla mal aplicada. La tarea de
extracción debe terminar con una revisión manual y un conteo confirmado por estilo.

---

## D4 — Versión legible de la metodología

**Decisión**: añadir `docs/metodologia/metodologia.json`, un manifiesto que declara la
versión (`"3.4"`), la fecha, y la huella SHA-256 de cada documento normativo. La app
incrusta esa versión y la estampa en cada plan (FR-026).

**Razón**: FR-026 exige saber bajo qué versión se construyó un plan. Deducirla del nombre
del archivo es frágil: renombrar el archivo cambiaría la historia de planes ya aprobados.
La huella permite además detectar que un documento normativo cambió sin que se subiera la
versión, que es exactamente lo que el flujo de desarrollo de la constitución prohíbe.

**Alternativas descartadas**: leer la versión del título del documento (frágil ante
ediciones); guardarla solo en el código (se desincroniza del documento).

---

## D5 — Forma de los datos y almacenamiento

**Decisión**: un documento por plan, con los microciclos como lista dentro de él, y las
sesiones en una subcolección `sesiones`. Los ejercicios y las zonas no se guardan: son
referencia estática (D3).

**Razón**:

- Las sesiones son la parte voluminosa y se editan de una en una; tenerlas como documentos
  propios evita reescribir el plan entero en cada tecla.
- La auditoría agregada (US2) necesita todas las sesiones de un plan: una subcolección se
  lee de una sola consulta.
- Los microciclos son ligeros (nombre, objetivo, orden) y siempre se leen junto al plan.
- La exportación de un plan completo (FR-031, principio V) es un documento más N sesiones:
  se serializa a un único JSON sin transformación.

**Alternativas descartadas**: todo el plan en un solo documento (riesgo de acercarse al
límite de 1 MiB por documento en planes largos, y reescritura completa en cada edición);
una colección plana de sesiones con referencia al plan (obliga a índices y consultas
compuestas para algo que la jerarquía resuelve sola).

**Sobre el versionado de planes (FR-025)**: al aprobar, el documento del plan queda
bloqueado. Editar un plan aprobado crea un **documento nuevo** que apunta al anterior
mediante `versionAnteriorId`. Se descartó guardar versiones como subcolección de
instantáneas porque complica la exportación y las consultas sin aportar nada aquí.

---

## D6 — Persistencia local durante el desarrollo

**Decisión**: emuladores de Firebase (Firestore y, más adelante, Auth y Storage) corriendo
en el equipo, configurados en `firebase/firebase.json`, con datos de prueba que se
importan y exportan como ficheros del proyecto.

**Razón**: es lo acordado en la aclaración. Los emuladores usan la misma forma de datos y
las mismas reglas que producción, no requieren conexión ni proyecto en la nube, y son la
única manera de ejecutar pruebas automáticas de reglas de acceso, que el principio III
exige. Java 21 ya está instalado, que es su único requisito externo.

**Alternativas descartadas**: almacenamiento local del dispositivo (obligaría a reescribir
la capa de datos al publicar); proyecto real en modo prueba (saca datos del equipo antes de
tiempo y exige conexión para trabajar).

---

## D7 — Pruebas de las reglas de acceso

**Decisión**: `@firebase/rules-unit-testing` sobre Node, en `firebase/test/`, con su propio
`package.json`. Se ejecuta contra el emulador.

**Razón**: el principio III exige probar las reglas automáticamente, incluyendo casos
negativos. No existe equivalente en Dart: la biblioteca oficial de pruebas de reglas es de
Node. Node 22 ya está instalado.

**Consecuencia declarada**: el repositorio tendrá un segundo lenguaje, limitado a esa
carpeta y a esa función. Queda registrado en la tabla de complejidad del plan.

**Alternativa descartada**: probar las reglas a mano desde la interfaz del emulador (no es
automatizable, y una regla de acceso sin prueba automática es exactamente lo que el
principio III prohíbe).

---

## D8 — Manejo de estado en la interfaz

**Decisión**: `provider` con `ChangeNotifier`, una sola dependencia añadida.

**Razón**: el editor mantiene un árbol vivo —plan, microciclos, sesiones, partes, series—
donde cada tecla recalcula metros, porcentaje técnico y auditoría, y muchos widgets
distintos leen esos valores derivados. Con `setState` habría que reconstruir desde un único
widget contenedor y pasar callbacks por varios niveles. `provider` es la dependencia más
pequeña que resuelve ese problema concreto, tiene API mínima y no impone estructura al
dominio, que sigue siendo Dart puro.

**Alternativas descartadas**: solo `setState` (obliga a un widget raíz gigante y a
propagar callbacks; se vuelve inmanejable en una pantalla de esta densidad); `riverpod`
(más potente y con mejor testabilidad, pero introduce conceptos nuevos —proveedores,
ámbitos, generación de código— que no hacen falta aquí); `bloc` (ceremonia
desproporcionada para un editor de un solo usuario).

**Cómo revertir si se equivocó la elección**: como el dominio no conoce a `provider`, si
más adelante conviene cambiar de gestor de estado solo se reescribe la capa de interfaz.

---

## D9 — Frontera del dominio, verificada automáticamente

**Decisión**: una prueba de arquitectura que recorre `lib/dominio/` y falla si algún
fichero importa `package:flutter/`, `package:cloud_firestore/` o `package:firebase_core/`.

**Razón**: el principio II es fácil de violar sin darse cuenta, con un solo `import` puesto
por comodidad. Una prueba lo convierte en algo que el sistema verifica en lugar de algo que
hay que recordar.

**Alternativa descartada**: confiar en la revisión manual (es precisamente lo que la
constitución pide sustituir por verificación).

---

## Incógnitas resueltas y no resueltas

Todas las incógnitas marcadas en el contexto técnico quedan resueltas por D1 a D9.

**Aplazado deliberadamente, fuera de esta feature**: canal de cobro, autenticación real,
consentimiento del acudiente, almacenamiento de video, y la estrategia de despliegue en
Firebase Hosting. Ninguna condiciona el diseño de lo que aquí se construye.
