// Pruebas de las reglas de acceso de Firestore.
//
// El principio III de la constitucion exige probarlas automaticamente,
// incluidos los casos negativos: una regla que permite lo que no deberia es un
// fallo de la misma gravedad que un calculo equivocado.
//
// Se ejecutan contra el emulador:  npm --prefix firebase test

const assert = require('node:assert/strict');
const { test, before, after, beforeEach } = require('node:test');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const fs = require('node:fs');
const path = require('node:path');

let entorno;

before(async () => {
  entorno = await initializeTestEnvironment({
    projectId: 'demo-natacion',
    firestore: {
      rules: fs.readFileSync(
        path.join(__dirname, '..', 'firestore.rules'),
        'utf8',
      ),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  if (entorno) await entorno.cleanup();
});

beforeEach(async () => {
  await entorno.clearFirestore();
});

/** Cliente del entrenador, con el rol que las reglas esperan. */
function comoEntrenador() {
  return entorno
    .authenticatedContext('entrenador-1', { rol: 'entrenador' })
    .firestore();
}

/** Cliente sin autenticar. */
function sinAutenticar() {
  return entorno.unauthenticatedContext().firestore();
}

const planBorrador = {
  nombre: 'Tecnica de eficiencia',
  categoria: 'Precompetitivo',
  estiloObjetivo: 'Libre',
  estado: 'borrador',
};

// --- Casos negativos: lo que NO debe poder hacerse ------------------------

test('un cliente sin autenticar no puede leer planes', async () => {
  await assertFails(sinAutenticar().collection('planes').doc('p1').get());
});

test('un cliente sin autenticar no puede escribir planes', async () => {
  await assertFails(
    sinAutenticar().collection('planes').doc('p1').set(planBorrador),
  );
});

test('un cliente sin autenticar no puede leer nadadores', async () => {
  await assertFails(sinAutenticar().collection('nadadores').doc('n1').get());
});

test('un cliente sin autenticar no puede leer sesiones', async () => {
  await assertFails(
    sinAutenticar()
      .collection('planes')
      .doc('p1')
      .collection('sesiones')
      .doc('s1')
      .get(),
  );
});

test('una coleccion no contemplada esta cerrada', async () => {
  await assertFails(
    comoEntrenador().collection('coleccionCualquiera').doc('x').set({ a: 1 }),
  );
});

test('no se puede crear un plan directamente en estado aprobado', async () => {
  await assertFails(
    comoEntrenador()
      .collection('planes')
      .doc('p-nuevo')
      .set({ ...planBorrador, estado: 'aprobado' }),
  );
});

test('no se puede escribir sobre un plan aprobado', async () => {
  await entorno.withSecurityRulesDisabled(async (contexto) => {
    await contexto
      .firestore()
      .collection('planes')
      .doc('p-aprobado')
      .set({ ...planBorrador, estado: 'aprobado' });
  });

  await assertFails(
    comoEntrenador()
      .collection('planes')
      .doc('p-aprobado')
      .update({ nombre: 'Otro nombre' }),
  );
});

test('no se puede escribir sobre un plan publicado', async () => {
  await entorno.withSecurityRulesDisabled(async (contexto) => {
    await contexto
      .firestore()
      .collection('planes')
      .doc('p-publicado')
      .set({ ...planBorrador, estado: 'publicado' });
  });

  await assertFails(
    comoEntrenador()
      .collection('planes')
      .doc('p-publicado')
      .update({ nombre: 'Otro nombre' }),
  );
});

test('no se puede borrar un plan aprobado', async () => {
  await entorno.withSecurityRulesDisabled(async (contexto) => {
    await contexto
      .firestore()
      .collection('planes')
      .doc('p-aprobado')
      .set({ ...planBorrador, estado: 'aprobado' });
  });

  await assertFails(
    comoEntrenador().collection('planes').doc('p-aprobado').delete(),
  );
});

test('no se pueden escribir sesiones de un plan aprobado', async () => {
  await entorno.withSecurityRulesDisabled(async (contexto) => {
    await contexto
      .firestore()
      .collection('planes')
      .doc('p-aprobado')
      .set({ ...planBorrador, estado: 'aprobado' });
  });

  await assertFails(
    comoEntrenador()
      .collection('planes')
      .doc('p-aprobado')
      .collection('sesiones')
      .doc('s1')
      .set({ objetivoTecnico: 'x' }),
  );
});

// --- Casos positivos: lo que SI debe poder hacerse ------------------------

test('el entrenador crea un plan en borrador', async () => {
  await assertSucceeds(
    comoEntrenador().collection('planes').doc('p-borrador').set(planBorrador),
  );
});

test('el entrenador edita un plan en borrador', async () => {
  await comoEntrenador().collection('planes').doc('p-borrador').set(planBorrador);

  await assertSucceeds(
    comoEntrenador()
      .collection('planes')
      .doc('p-borrador')
      .update({ nombre: 'Ritmo competitivo' }),
  );
});

test('el entrenador lee sus planes', async () => {
  await assertSucceeds(
    comoEntrenador().collection('planes').doc('p-borrador').get(),
  );
});

test('el entrenador escribe sesiones de un plan en borrador', async () => {
  await comoEntrenador().collection('planes').doc('p-borrador').set(planBorrador);

  await assertSucceeds(
    comoEntrenador()
      .collection('planes')
      .doc('p-borrador')
      .collection('sesiones')
      .doc('s1')
      .set({ objetivoTecnico: 'Tecnica de espalda' }),
  );
});

test('el entrenador gestiona nadadores', async () => {
  await assertSucceeds(
    comoEntrenador().collection('nadadores').doc('n1').set({ nombre: 'Ana' }),
  );
});
