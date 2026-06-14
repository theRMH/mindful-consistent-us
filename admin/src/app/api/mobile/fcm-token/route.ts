import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function POST(req: NextRequest) {
  const user = await verifyAuth(req);
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const { token } = await req.json().catch(() => ({ token: null }));
  if (!token) return NextResponse.json({ error: 'token required' }, { status: 400 });

  await prisma.profile.upsert({
    where: { id: user.id },
    update: { fcmToken: token },
    create: { id: user.id, email: user.email ?? '', fcmToken: token },
  });

  return NextResponse.json({ success: true });
}
