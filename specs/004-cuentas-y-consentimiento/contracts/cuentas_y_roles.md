# Contrato — cuentas, roles y acceso

**Feature**: 004 · **Modelo**: [data-model.md](../data-model.md) ·
**Decisiones**: [research.md](../research.md)

Lo que este contrato fija son **garantías comprobables**. Cada una lleva su identificador
para que una prueba pueda citarla y para que, si alguien la rompe, se sepa qué prometimos.

---

## La interfaz que el dominio declara

```dart
/// Quién está usando la app. El dominio no sabe que existe Firebase.
abstract class Identidad {
  /// La cuenta activa, o null si no hay sesión iniciada.
  Future<Cuenta?> actual();

  /// Emite cada vez que la sesión cambia: entra, sale o caduca.
  Stream<Cuenta?> get cambios;

  Future<void> cerrarSesion();
}
```

`firebase_auth` se importa **en un solo archivo** del proyecto,
`lib/datos/auth/sesion_firebase.dart`. La prueba de frontera que ya existe lo vigila.

---

## Garantías

### A1 — El rol no se declara desde el cliente

El rol llega dentro del token, firmado. Ninguna ruta del cliente puede fijarlo, proponerlo ni
alterarlo.

**Se comprueba**: una cuenta intenta escribir en una colección de entrenador tras haber
escrito `rol: 'entrenador'` en su propio documento de usuario. Se deniega.

### A2 — Toda cuenta nueva nace como nadador

El rol `entrenador` se concede por una operación administrativa explícita, nunca por
registrarse.

**Se comprueba**: se crea una cuenta y se verifica que su token trae `rol: 'nadador'` y que
no puede aprobar ni publicar.

### A3 — Un nadador no aprueba ni publica

Ni por la interfaz, que no se lo ofrece, ni por las reglas, que lo deniegan. Principio IV.

**Se comprueba**: con una cuenta de nadador se intenta escribir `estado: 'aprobado'` y
`estado: 'publicado'` sobre un plan. Las dos se deniegan.

### A4 — Cada nadador lee y escribe lo suyo

Un nadador lee los planes `publicado` que le están asignados, y lee y escribe únicamente los
registros cuyo `nadadorId` le corresponde.

**Se comprueba**, como casos negativos, uno por uno: leer el plan de otro, leer el registro de
otro, escribir un registro con el `nadadorId` de otro, leer un plan en `borrador`, leer un
plan `aprobado` pero no publicado, leer un plan publicado que no le está asignado.

### A5 — El entrenador no escribe los registros del nadador

Lee los de su comunidad. No los escribe. Lo que el nadador responde es suyo.

**Se comprueba**: con la cuenta del entrenador se intenta escribir un registro. Se deniega.
Es un cambio respecto de la feature 003, donde el entrenador era el único que podía.

### A6 — Sin sesión no se obtiene nada

Ninguna colección responde a una petición sin autenticar. Ni siquiera de lectura.

**Se comprueba**: sin autenticar, se intenta leer cada colección del esquema. Todas deniegan.

### A7 — Cerrar sesión no deja rastro en el dispositivo

Tras cerrar sesión, el dispositivo no conserva planes, registros ni perfil del nadador
anterior. Incluye la caché de Firestore y el almacenamiento local.

**Se comprueba**: se inicia sesión, se consulta un plan —que queda en caché—, se cierra
sesión y se inspecciona el almacenamiento local. No hay datos del anterior.

**Por qué importa aquí y no en otro proyecto**: el grupo son hermanos que comparten teléfono.

### A8 — La caducidad no deja al nadador sin entrenamiento

Si la sesión caduca a pie de piscina y sin señal, el nadador sigue viendo el plan que ya
tiene en el dispositivo y sigue pudiendo anotar. Lo que queda retenido es el envío.

**Se comprueba**: con la sesión caducada y sin red, se abre la app, se lee la sesión del día y
se anota. Las tres cosas funcionan.

**Por qué**: una app que exige reautenticarse para enseñarte lo que ya tenías descargado es
una app que no se usa donde se entrena.

### A9 — La partición por cuenta

El almacenamiento local está particionado por cuenta. Dos cuentas en el mismo dispositivo no
ven ni mezclan lo del otro, ni siquiera en la bandeja de salida.

**Se comprueba**: dos cuentas escriben registros en el mismo dispositivo sin red. Cada
bandeja contiene lo suyo y nada más.

### A10 — Los permisos del dominio y las reglas dicen lo mismo

`lib/dominio/cuentas/permisos.dart` decide en Dart puro lo mismo que `firestore.rules` hace
cumplir en el servidor. Son dos escrituras de la misma decisión, y tienen que coincidir.

**Se comprueba**: la tabla de permisos del dominio y la suite de reglas recorren el mismo
conjunto de casos. Si una regla cambia y el dominio no, o al revés, una de las dos suites
falla.

**Lo que esta garantía admite**: no hay forma automática de demostrar que dos lenguajes
distintos expresan la misma regla. Lo que hay es una lista de casos compartida y la disciplina
de ampliarla en los dos sitios. Queda dicho para que nadie la lea como una prueba de
equivalencia.
