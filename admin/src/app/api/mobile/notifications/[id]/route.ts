import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = await verifyAuth(req);
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const { id } = await params;

  await prisma.notificationRead.upsert({
    where: { userId_notificationId: { userId: user.id, notificationId: id } },
    update: { readAt: new Date() },
    create: { userId: user.id, notificationId: id, readAt: new Date() },
  });

  return NextResponse.json({ success: true });
}
