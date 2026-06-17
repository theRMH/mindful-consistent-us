import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function GET(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

    const records = await prisma.bodyMetrics.findMany({
      where: { userId: user.id },
      orderBy: { recordedAt: 'desc' },
      include: {
        course: { select: { title: true } },
      },
    });

    return NextResponse.json({
      records: records.map(r => ({
        id: r.id,
        recordedAt: r.recordedAt,
        courseId: r.courseId,
        courseTitle: r.course?.title ?? null,
        name: r.name,
        age: r.age,
        heightCm: r.heightCm !== null ? Number(r.heightCm) : null,
        weightKg: r.weightKg !== null ? Number(r.weightKg) : null,
        waistIn: r.waistIn !== null ? Number(r.waistIn) : null,
        hipIn: r.hipIn !== null ? Number(r.hipIn) : null,
      })),
    });
  } catch (error) {
    console.error('Error fetching body metrics:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

    const body = await req.json();
    const { courseId, name, age, heightCm, weightKg, waistIn, hipIn } = body;

    const record = await prisma.bodyMetrics.create({
      data: {
        userId: user.id,
        courseId: courseId ?? null,
        name: name ?? null,
        age: age != null ? Number(age) : null,
        heightCm: heightCm != null ? Number(heightCm) : null,
        weightKg: weightKg != null ? Number(weightKg) : null,
        waistIn: waistIn != null ? Number(waistIn) : null,
        hipIn: hipIn != null ? Number(hipIn) : null,
      },
    });

    return NextResponse.json({ id: record.id }, { status: 201 });
  } catch (error) {
    console.error('Error saving body metrics:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
