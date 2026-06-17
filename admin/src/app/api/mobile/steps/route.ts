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
    const steps: number = typeof body.steps === 'number' ? body.steps : 0;
    const calories: number = typeof body.calories === 'number' ? body.calories : 0;

    await prisma.userStats.upsert({
      where: { userId: user.id },
      update: {
        totalSteps: { increment: steps },
        totalCalories: { increment: calories },
        updatedAt: new Date(),
      },
      create: {
        userId: user.id,
        totalSteps: steps,
        totalCalories: calories,
      },
    });

    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error) {
    console.error('Error syncing steps:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
