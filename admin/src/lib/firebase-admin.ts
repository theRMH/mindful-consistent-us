import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync } from 'fs';
import { join } from 'path';

if (!getApps().length) {
  const serviceAccount = JSON.parse(
    readFileSync(join(process.cwd(), 'firebase-service-account.json'), 'utf8')
  );
  initializeApp({ credential: cert(serviceAccount) });
}

export const firebaseAuth = getAuth();
