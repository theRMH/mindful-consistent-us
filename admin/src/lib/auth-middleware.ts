import { NextRequest } from 'next/server';
import { createRemoteJWKSet, jwtVerify } from 'jose';

export interface AuthenticatedUser {
  id: string;
  email?: string;
  phone?: string;
}

const FIREBASE_JWKS = createRemoteJWKSet(
  new URL('https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com')
);

function getFirebaseProjectId(): string {
  const json = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (json) {
    try { return JSON.parse(json).project_id; } catch { /* fall through */ }
  }
  throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON not set or missing project_id');
}

export async function verifyAuth(req: NextRequest): Promise<AuthenticatedUser | null> {
  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) return null;
    const token = authHeader.split(' ')[1];
    if (!token) return null;
    const projectId = getFirebaseProjectId();
    const { payload } = await jwtVerify(token, FIREBASE_JWKS, {
      issuer: `https://securetoken.google.com/${projectId}`,
      audience: projectId,
    });
    return {
      id: payload.sub!,
      phone: payload['phone_number'] as string | undefined,
      email: payload.email as string | undefined,
    };
  } catch (err) {
    console.error('Error verifying auth token:', err);
    return null;
  }
}
