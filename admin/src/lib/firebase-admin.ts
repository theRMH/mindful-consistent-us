// eslint-disable-next-line @typescript-eslint/no-explicit-any
type FirebaseAdminApp = any;

let _admin: FirebaseAdminApp | null = null;

export function getFirebaseAdmin(): FirebaseAdminApp | null {
  if (_admin) return _admin;

  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!serviceAccountJson) {
    console.warn('FIREBASE_SERVICE_ACCOUNT env not set — push notifications disabled');
    return null;
  }

  try {
    // Dynamic require so build doesn't fail when firebase-admin isn't installed yet
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const admin = require('firebase-admin');
    if (!admin.apps.length) {
      const serviceAccount = JSON.parse(serviceAccountJson);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }
    _admin = admin;
    return _admin;
  } catch (err) {
    console.error('Failed to initialize Firebase Admin:', err);
    return null;
  }
}
