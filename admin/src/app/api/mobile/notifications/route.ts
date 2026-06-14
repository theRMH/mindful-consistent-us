import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function GET(req: NextRequest) {
  const user = await verifyAuth(req);
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const notifications = await prisma.appNotification.findMany({
    orderBy: { sentAt: 'desc' },
    take: 50,
    include: {
      reads: {
        where: { userId: user.id },
        select: { readAt: true },
      },
    },
  });

  const result = notifications.map((n) => ({
    id: n.id,
    title: n.title,
    body: n.body,
    type: n.type,
    redirectUrl: n.redirectUrl,
    sentAt: n.sentAt,
    isRead: n.reads.length > 0 && n.reads[0].readAt !== null,
  }));

  return NextResponse.json(result);
}
