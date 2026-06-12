import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function GET(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const profile = await prisma.profile.findUnique({
      where: { id: user.id },
      select: { id: true, fullName: true, phone: true, avatarUrl: true, email: true },
    });

    if (!profile) {
      return NextResponse.json({ error: 'Profile not found' }, { status: 404 });
    }

    return NextResponse.json(profile, { status: 200 });
  } catch (error: any) {
    console.error('Error fetching profile:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function PUT(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await req.json().catch(() => ({}));
    const { fullName, avatarUrl, fcmToken } = body;

    const updated = await prisma.profile.update({
      where: { id: user.id },
      data: {
        ...(fullName !== undefined && { fullName }),
        ...(avatarUrl !== undefined && { avatarUrl }),
        ...(fcmToken !== undefined && { fcmToken }),
      },
      select: { id: true, fullName: true, phone: true, avatarUrl: true, email: true },
    });

    return NextResponse.json(updated, { status: 200 });
  } catch (error: any) {
    console.error('Error updating profile:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
