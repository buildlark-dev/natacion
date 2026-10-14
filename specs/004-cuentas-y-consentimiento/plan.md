# Plan de implementación: cuentas, roles y consentimiento verificable

**Branch**: `004-accounts-and-consent` | **Date**: 2026-10-14 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/004-cuentas-y-consentimiento/spec.md`

## Summary

Las tres features anteriores construyeron un producto correcto que nadie puede usar: no hay
cuentas, no hay nada guardado y no hay consentimiento. Esta feature cierra las tres cosas y
desbloquea el despliegue.

El enfoque técnico gira sobre **una decisión que ordena todo lo demás**: la puerta de
consentimiento no vive en la pantalla, vive en las **reglas de acceso de Firestore**. Una
puerta que solo comprueba el cliente no es una puerta, es una cortesía. El cliente la
comprueba también —para no enviar lo que sabe que va a rebotar y para explicárselo al
nadador—, pero quien la hace cumplir es el servidor.

De ahí se sigue el resto. Las reglas necesitan saber el rol sin pagar una lectura por
comprobación, y eso son **custom claims**; los claims los firma el Admin SDK, y eso exige un
servidor. La constitución dejó esa elección pendiente «al `plan.md` de la primera feature
que la necesite»: es esta, y se resuelve en [research.md](research.md) a favor de **Cloud
Functions en TypeScript**, con su justificación y su coste declarado.

La retención del envío —que es como el consentimiento bloquea sin bloquear a nadie— no
necesita nada nuevo: la bandeja de salida de la feature 003 ya sostiene registros pendientes
sin perderlos. Gana una condición más para soltarlos.

## Technical Context

**Language/Version**: Dart 3.12.2, Flutter 3.44.2. **TypeScript** para las Cloud Functions,
que es lenguaje nuevo en el proyecto y se justifica abajo.

**Primary Dependencies**: `firebase_auth` (nueva), `cloud_firestore` ^5.5.0, `firebase_core`
^3.8.0, `provider` ^6.1.2, `shared_preferences` 2.5.6. En el servidor,
`firebase-admin` y `firebase-functions`.

**Storage**: Firestore para planes, perfiles, registros y consentimientos. Almacenamiento
local del dispositivo para la bandeja de salida, **particionado por cuenta**.

**Testing**: `flutter_test` para dominio e interfaz; `@firebase/rules-unit-testing` sobre el
emulador para las reglas, que es donde vive la puerta; `node --test` para las funciones,
sobre el emulador de Auth y Firestore.

**Target Platform**: Web (Firebase Hosting) y móvil. El uso real sigue siendo **a pie de
piscina**, y las cuentas no pueden romperlo.

**Project Type**: aplicación Flutter con dominio en Dart puro, capa de datos aislada y, desde
esta feature, una **superficie mínima de servidor**.

**Performance Goals**: iniciar sesión una vez y no volver a pensar en ello. Abrir la app con
sesión iniciada y ver la sesión del día **sin ningún paso de red**, igual que antes de esta
feature.

**Constraints**:
- La ausencia de consentimiento **no impide usar la app**; impide que los datos salgan.
- La puerta la hace cumplir el servidor, no la pantalla.
- La fecha de un consentimiento la pone el servidor, nunca el dispositivo.
- Leer lo propio **nunca** requiere red.
- Cerrar sesión no deja datos del anterior en el dispositivo.
- La categoría **no** se deriva de la edad (metodología 3.6.0, sección 11.1).
- Sin credenciales en el repositorio.

**Scale/Scope**: un entrenador, decenas de nadadores. La superficie de servidor son cuatro
operaciones, no un backend.

## Constitution Check

*GATE: debe pasar antes de la Fase 0 y volver a comprobarse tras la Fase 1.*

| Principio | Cómo lo cumple | Estado |
|---|---|---|
| **I. Metodología como norma** | FR-007 traslada al software la sección 11.1 de la 3.6.0: la categoría la declara el entrenador y no se deriva de la edad. SC-016 lo vigila con una prueba | ✅ |
| **II. Dominio en Dart puro** | `Cuenta`, `Rol`, `Consentimiento` y la puerta viven en `lib/dominio/`. Ninguna firma menciona `firebase_auth`. La prueba de frontera lo vigila | ✅ |
| **III. Pruebas de las reglas que llegan al nadador** | Es la feature donde las reglas por fin distinguen a un nadador de otro. Cada regla llega con su caso negativo sobre el emulador | ✅ |
| **IV. El criterio del entrenador no se delega** | FR-004: un nadador no mueve un plan a `aprobado` ni a `publicado`, y ahora la regla lo impide de verdad en lugar de confiarlo a la pantalla | ✅ |
| **V. Datos de deportistas** | Es la razón de ser de la feature. **Retira la desviación declarada de la 003** | ✅ |
| **VI. Freemium honesto** | FR-040: lo que el nadador generó nunca queda tras un muro de pago. No hay cobro en esta feature, así que se cumple por omisión y queda escrito para que siga cumpliéndose | ✅ |
| **VII. Rebanadas verticales y simplicidad** | Seis historias comprobables por separado. **Con desviación declarada: un lenguaje nuevo en el proyecto.** Ver Complexity Tracking | ⚠️ |
| **VIII. Control de carga interna** | No la toca, y esa es la exigencia: el recorrido de la 003 tiene que seguir funcionando igual, con sesión iniciada y sin señal (SC-011) | ✅ |

### Lo que esta feature cierra

La feature 003 dejó escrita esta desviación del principio V:

> «Las reglas de acceso de esta feature **no distinguen a un nadador de otro** […] La regla
> por nadador se añade en la 004. Cada registro ya lleva su `nadadorId`, así que entonces no
> habrá que migrar datos.»

Se cumple lo prometido: las reglas pasan a comparar contra `request.auth.uid`, y **no hay
migración de datos** porque el campo ya estaba. También se retira
`lib/ui/nadadores/aviso_consentimiento.dart`, que lleva escrito en su propia documentación
«debe retirarse cuando la feature de cuentas implemente el consentimiento verificable, no
antes».

## Project Structure

### Documentation (this feature)

```text
specs/004-cuentas-y-consentimiento/
├── plan.md              # Este archivo
├── research.md          # Fase 0: las seis decisiones y por qué
├── data-model.md        # Fase 1: entidades, invariantes y esquema
├── quickstart.md        # Fase 1: verificación de extremo a extremo
├── contracts/
│   ├── cuentas_y_roles.md
│   └── consentimiento.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Fase 2: lo produce /speckit-tasks
```

### Source Code (repository root)

```text
lib/
├── dominio/
│   ├── cuentas/
│   │   ├── cuenta.dart              # Cuenta, Rol, SesionActiva
│   │   └── permisos.dart            # qué puede hacer cada rol, en Dart puro
│   ├── consentimiento/
│   │   ├── consentimiento.dart      # el registro y su vigencia
│   │   ├── solicitud.dart           # el enlace de un solo uso y su estado
│   │   └── puerta.dart              # PuertaDeConsentimiento: la condición
│   ├── repositorios/repositorios.dart   # gana las interfaces nuevas
│   └── sincronizacion/bandeja_salida.dart  # gana la condición de la puerta
├── datos/
│   ├── auth/
│   │   ├── identidad.dart           # la interfaz del dominio, implementada aquí
│   │   └── sesion_firebase.dart     # firebase_auth vive solo aquí
│   ├── firestore/
│   │   ├── repositorios_firestore.dart  # ya existe; gana consentimientos
│   │   └── consentimientos.dart
│   └── local/almacen_local.dart     # gana partición por cuenta
├── ui/
│   ├── acceso/
│   │   ├── pantalla_acceso.dart
│   │   └── estado_sesion.dart
│   ├── consentimiento/
│   │   ├── pantalla_confirmacion.dart   # lo que abre el acudiente
│   │   └── panel_estado.dart            # lo que ve el entrenador
│   └── nadadores/aviso_consentimiento.dart  # SE RETIRA
└── main.dart                        # deja de tener planes en memoria

firebase/
├── firestore.rules                  # la puerta vive aquí
├── test/reglas.test.js              # ya existe; crece mucho
└── functions/                       # NUEVO
    ├── src/
    │   ├── index.ts
    │   ├── roles.ts                 # asignar el claim de rol
    │   └── consentimiento.ts        # emitir, confirmar, revocar, avisar
    └── test/

test/
├── dominio/cuentas/
├── dominio/consentimiento/
└── ui/acceso/
```

**Structure Decision**: se conserva la separación de las tres features anteriores —dominio en
Dart puro, datos aislados, interfaz encima— y se añade **una sola carpeta nueva fuera de
Dart**, `firebase/functions/`, con la superficie mínima de servidor que la puerta exige.

El reparto importa: **`firebase_auth` se importa en un solo archivo**,
`lib/datos/auth/sesion_firebase.dart`. El dominio habla de `Cuenta` y `Rol`, y la prueba de
frontera que ya existe vigila que no se cuele.

## Complexity Tracking

| Violación | Por qué hace falta | Alternativa más simple, y por qué se descarta |
|---|---|---|
| **Un lenguaje nuevo (TypeScript) y una carpeta de servidor** | Los custom claims los firma el Admin SDK y nadie más: un cliente no puede darse a sí mismo el rol de entrenador. La fecha de un consentimiento tiene que ponerla el servidor (FR-017), y el enlace de un solo uso tiene que emitirlo y canjearlo algo que el acudiente no controla. Sin servidor, las tres cosas se convierten en declaraciones del cliente | **Todo en el cliente**: descartado, es justo lo que hace que la puerta no sea una puerta. **Cloud Run con Dart `shelf`**, para no salir de Dart: descartado en [research.md](research.md) D3 por el estado del Admin SDK para Dart y porque el proyecto ya mantiene Node para las pruebas de reglas. **Un documento de rol en lugar de claims**: descartado en D2, cuesta una lectura por comprobación y no evita el servidor |

**Coste declarado y cómo se contiene**: el proyecto lo sostiene una persona que además
entrena, y añadir un segundo lenguaje es real. Se contiene manteniendo la superficie en
**cuatro operaciones** y ninguna más, con sus pruebas sobre el emulador, y dejando escrito en
`research.md` qué entra y qué no entra nunca en el servidor.
