import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

// GET — return last 7 days of step history for the user
export async function GET(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

    const records = await prisma.dailyStepHistory.findMany({
      where: { userId: user.id },
      orderBy: { dateStr: 'desc' },
      take: 7,
    });

    return NextResponse.json(
      records.map(r => ({ dateStr: r.dateStr, steps: r.steps })),
      { status: 200 },
    );
  } catch (error) {
    console.error('Error fetching step history:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

// POST — upsert a single day's step total
export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

    const body = await req.json().catch(() => ({}));
    const dateStr: string = body.dateStr ?? '';
    const steps: number = typeof body.steps === 'number' ? body.steps : 0;

    if (!dateStr) return NextResponse.json({ error: 'Missing dateStr' }, { status: 400 });

    await prisma.dailyStepHistory.upsert({
      where: { userId_dateStr: { userId: user.id, dateStr } },
      update: { steps },
      create: { userId: user.id, dateStr, steps },
    });

    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error) {
    console.error('Error saving step history:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
