import { NextRequest, NextResponse } from 'next/server';
import { timingSafeEqual } from 'crypto';
import { createSessionToken } from '@/lib/admin-session';

export async function POST(req: NextRequest) {
  const { email, password } = await req.json().catch(() => ({}));

  const adminEmail = process.env.ADMIN_EMAIL;
  const adminPassword = process.env.ADMIN_PASSWORD;

  if (!adminEmail || !adminPassword) {
    console.error('ADMIN_EMAIL or ADMIN_PASSWORD not configured');
    return NextResponse.json({ error: 'Server misconfigured' }, { status: 500 });
  }

  const emailMatch = typeof email === 'string' && email === adminEmail;
  let passwordMatch = false;
  try {
    passwordMatch =
      typeof password === 'string' &&
      password.length === adminPassword.length &&
      timingSafeEqual(Buffer.from(password), Buffer.from(adminPassword));
  } catch {
    passwordMatch = false;
  }

  if (!emailMatch || !passwordMatch) {
    await new Promise((r) => setTimeout(r, 500));
    return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 });
  }

  const token = createSessionToken();
  const res = NextResponse.json({ ok: true });
  res.cookies.set('admin_session', token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    maxAge: 8 * 60 * 60,
    path: '/',
  });
  return res;
}
