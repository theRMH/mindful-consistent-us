import { NextRequest } from 'next/server';
import { supabaseAdmin } from './supabase';

export interface AuthenticatedUser {
  id: string;
  email?: string;
  phone?: string;
}

export async function verifyAuth(req: NextRequest): Promise<AuthenticatedUser | null> {
  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return null;
    }

    const { data: { user }, error } = await supabaseAdmin.auth.getUser(token);
    if (error || !user) {
      return null;
    }

    return {
      id: user.id,
      email: user.email,
      phone: user.phone
    };
  } catch (err) {
    console.error('Error verifying auth token:', err);
    return null;
  }
}
