#!/usr/bin/env node
/**
 * Grant a role to an account.
 *
 *   npm --prefix firebase/functions run asignar-rol -- <uid> entrenador
 *
 * This exists because nobody can grant themselves the coach role. Signing up
 * always produces a swimmer; `entrenador` takes this script and Admin
 * credentials, which are never stored in this repository.
 *
 * Against the emulators, FIREBASE_AUTH_EMULATOR_HOST is enough and no
 * credentials are needed. Against a real project, the caller supplies
 * GOOGLE_APPLICATION_CREDENTIALS themselves.
 *
 * The friction is the point: the role that approves and publishes training for
 * children should not be a checkbox on a sign-up form.
 */

const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const ROLES = ['entrenador', 'nadador'];
const CLAVE_DEL_ROL = 'rol';

async function main() {
  const [uid, rol] = process.argv.slice(2);

  if (!uid || !rol) {
    console.error('Uso: asignar-rol <uid> <entrenador|nadador>');
    process.exit(2);
  }

  if (!ROLES.includes(rol)) {
    console.error(
      `«${rol}» no es un rol. Los que hay: ${ROLES.join(', ')}.\n` +
        'No se resuelve al mas parecido: asi es como se cuela un permiso.'
    );
    process.exit(2);
  }

  const contraEmulador = Boolean(process.env.FIREBASE_AUTH_EMULATOR_HOST);
  if (!contraEmulador && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.error(
      'Sin FIREBASE_AUTH_EMULATOR_HOST ni GOOGLE_APPLICATION_CREDENTIALS.\n' +
        'Contra un proyecto real hacen falta credenciales de administrador,\n' +
        'que este repositorio no guarda y no debe guardar.'
    );
    process.exit(2);
  }

  initializeApp({ projectId: process.env.GCLOUD_PROJECT || 'demo-natacion' });

  const usuario = await getAuth().getUser(uid);
  await getAuth().setCustomUserClaims(usuario.uid, {
    ...(usuario.customClaims || {}),
    [CLAVE_DEL_ROL]: rol,
  });

  console.log(`${usuario.uid} -> ${rol}`);
  console.log(
    'El token en curso todavia lleva el rol anterior. Quien lo tenga abierto\n' +
      'tiene que volver a entrar, o refrescar el token, para que surta efecto.'
  );
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
