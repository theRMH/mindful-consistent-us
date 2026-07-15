import { NextRequest } from 'next/server';
import { firebaseAuth } from './firebase-admin';

export interface AuthenticatedUser {
  id: string;
  email?: string;
  phone?: string;
}

export async function verifyAuth(req: NextRequest): Promise<AuthenticatedUser | null> {
  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
    const token = authHeader.split(' ')[1];
    if (!token) return null;
    const decoded = await firebaseAuth.verifyIdToken(token);
    return {
      id: decoded.uid,
      phone: decoded.phone_number,
      email: decoded.email,
    };
  } catch (err) {
    console.error('Error verifying auth token:', err);
    return null;
  }
}
