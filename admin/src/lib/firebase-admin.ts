import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

function ensureInitialized() {
  if (getApps().length) return;

  const json = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (json) {
    initializeApp({ credential: cert(JSON.parse(json)) });
    return;
  }

  if (process.env.NODE_ENV !== 'production') {
    try {
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const { readFileSync } = require('fs');
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const { join } = require('path');
      initializeApp({ credential: cert(JSON.parse(readFileSync(join(process.cwd(), 'firebase-service-account.json'), 'utf8'))) });
    } catch { /* file absent in some local setups */ }
  }
}

export function getFirebaseAuth() {
  ensureInitialized();
  return getAuth();
}
