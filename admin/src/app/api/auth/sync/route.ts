import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await req.json().catch(() => ({}));
    const { fullName, avatarUrl } = body;

    const existing = await prisma.profile.findUnique({ where: { id: user.id }, select: { id: true } });

    // Upsert Profile
    const profile = await prisma.profile.upsert({
      where: { id: user.id },
      update: {
        email: user.email,
        phone: user.phone ?? null,
        fullName: fullName ?? undefined,
        avatarUrl: avatarUrl ?? undefined,
        updatedAt: new Date(),
      },
      create: {
        id: user.id,
        email: user.email ?? null,
        phone: user.phone ?? null,
        fullName: fullName ?? '',
        avatarUrl: avatarUrl ?? '',
      },
    });

    // Ensure UserStats row exists
    const stats = await prisma.userStats.upsert({
      where: { userId: user.id },
      update: {},
      create: {
        userId: user.id,
      },
    });

    return NextResponse.json({ success: true, profile, stats, alreadyExisted: existing !== null }, { status: 200 });
  } catch (error) {
    console.error('Error syncing auth profile:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
