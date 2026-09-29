# Contrato — Almacenamiento y Acceso

Forma de los documentos, interfaces que el dominio espera, y reglas de acceso con sus
pruebas.

## Interfaces del dominio

El dominio no conoce Firestore. Declara en `lib/dominio/repositorios/` lo que necesita, y
`lib/datos/firestore/` lo implementa.

```
RepositorioPlanes
  obtener(id) -> Plan
  listar({categoria, estado}) -> [Plan]
  guardarBorrador(Plan) -> id
  aprobar(id, ResultadoAuditoria, [Justificacion]) -> Plan
  crearVersionDesde(idAprobado) -> Plan        // FR-025
  exportar(id) -> documento serializado         // FR-031

RepositorioSesiones
  obtenerDePlan(planId) -> [Sesion]
  guardar(planId, Sesion) -> id
  eliminar(planId, sesionId)

RepositorioNadadores
  obtener(id) -> Nadador
  listar() -> [Nadador]
  guardar(Nadador) -> id
  exportar(id) -> documento serializado

RepositorioBiblioteca                            // Recurso empaquetado, no base de datos
  todos() -> [Ejercicio]
  buscarExacto(nombre, estilo) -> Ejercicio?
```

**Regla**: ninguna firma de estas interfaces menciona tipos de Firestore. Los errores se
expresan como resultados del dominio, no como excepciones de la biblioteca de datos.

## Estructura de colecciones

```
planes/{planId}
  ├── (campos del plan, microciclos embebidos como lista)
  └── sesiones/{sesionId}

nadadores/{nadadorId}

propuestasEjercicio/{propuestaId}

glosario/{terminoId}
```

### Documento de plan

```
{
  nombre, categoria, estiloObjetivo, pruebaObjetivo,
  longitudPiscina, fechaInicio, fechaFin, faseATR,
  microciclos: [ { id, nombre, orden, objetivo } ],
  nadadoresIds: [ ... ],
  estado: "borrador" | "aprobado" | "publicado",
  versionMetodologia, fechaAprobacion,
  justificaciones: [ { criterioId, texto, fecha } ],
  auditoriaAlAprobar: { ... },
  versionAnteriorId
}
```

### Documento de sesión

```
{
  microcicloId, fecha, objetivoTecnico, objetivoFisiologico,
  rpePrevisto, variablesMonitoreo: [ ... ],
  partes: [
    { tipo: "inicial" | "central" | "final",
      textoOriginal,
      series: [ { repeticiones, distancia, tiempoSalida, implementos,
                  ejercicioNombre, ejercicioEstilo, estilo, zona,
                  esTecnica, modificadores, origen } ],
      fragmentosPendientes: [ { texto, posicionInicio, posicionFin, motivo } ] }
  ]
}
```

**No se guardan los derivados** (metros, porcentajes, distribuciones): se recalculan a
partir de las series. Guardar un total sería tener dos fuentes de verdad que pueden
discrepar, y la metodología exige verificación aritmética.

## Exportación

Un plan exportado es un único JSON con el documento del plan y sus sesiones embebidas. Debe
poder leerse sin la app: esa es la garantía de portabilidad del principio V y el seguro
contra la dependencia de un proveedor que exige la constitución.

## Reglas de acceso

Hoy no hay autenticación (aplazada a otra feature), pero las reglas se escriben y se
prueban desde ahora, como exige el principio III.

**Postura**: denegar por defecto. Ninguna colección es legible ni escribible salvo por
concesión explícita.

```
Estado actual (sin autenticación, solo uso local):
  - Todo acceso denegado salvo desde el emulador con el contexto de prueba.
  - Ninguna regla abierta "hasta que llegue la autenticación": una regla permisiva
    provisional es exactamente el tipo de cosa que se queda puesta.

Preparado para la feature de cuentas:
  - planes: lectura del entrenador; lectura del nadador solo si su id está en
    nadadoresIds y el plan está publicado; escritura solo del entrenador.
  - nadadores: lectura y escritura del entrenador; el nadador solo lee el suyo.
  - Un plan aprobado o publicado no admite escritura, ni siquiera del entrenador.
```

### Pruebas obligatorias de reglas

En `firebase/test/reglas.test.js`, con casos negativos explícitos:

| Caso | Resultado esperado |
|---|---|
| Cliente sin autenticar lee `planes` | Denegado |
| Cliente sin autenticar escribe `planes` | Denegado |
| Cliente sin autenticar lee `nadadores` | Denegado |
| Escritura sobre un plan en estado `aprobado` | Denegada |
| Escritura sobre un plan en estado `publicado` | Denegada |
| Escritura sobre un plan en estado `borrador` con contexto válido | Permitida |

Las pruebas de acceso entre nadadores distintos se añaden con la feature de cuentas, cuando
exista identidad que comprobar.

## Emuladores

Configurados en `firebase/firebase.json`. Firestore es el único imprescindible ahora; Auth
y Storage se añaden con sus features. Los datos de prueba se importan y exportan como
ficheros del proyecto, de modo que el corpus de validación sea reproducible.
