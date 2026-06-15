import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function POST(req: NextRequest, { params }: { params: Promise<{ userId: string }> }) {
  try {
    const { userId } = await params;
    const { courseId } = await req.json();

    if (!courseId) {
      return NextResponse.json({ error: 'courseId is required' }, { status: 400 });
    }

    const existing = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });

    if (existing) {
      return NextResponse.json({ error: 'User is already enrolled in this course' }, { status: 409 });
    }

    const enrollment = await prisma.enrollment.create({
      data: {
        userId,
        courseId,
        paymentStatus: 'completed',
        isActive: true,
        enrolledAt: new Date(),
        purchaseDate: new Date(),
      },
    });

    return NextResponse.json({ success: true, enrollmentId: enrollment.id }, { status: 201 });
  } catch (error) {
    console.error('Error assigning course:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
