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

    // Mock bypass for development and testing
    if (token === 'consistent-us-mock-auth-token' || token === 'mock-user-123') {
      return {
        id: '99999999-9999-9999-9999-999999999999',
        email: 'user@consistentus.com',
        phone: '+919999999999',
      };
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
