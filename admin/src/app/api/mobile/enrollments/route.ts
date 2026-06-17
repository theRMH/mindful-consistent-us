import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function GET(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const enrollments = await prisma.enrollment.findMany({
      where: {
        userId: user.id,
        isActive: true,
      },
      include: {
        course: {
          include: {
            _count: {
              select: { courseDays: true }
            }
          }
        },
      },
    });

    return NextResponse.json(enrollments, { status: 200 });
  } catch (error) {
    console.error('Error fetching mobile enrollments:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await req.json().catch(() => ({}));
    const { courseId } = body;

    if (!courseId) {
      return NextResponse.json({ error: 'Missing courseId' }, { status: 400 });
    }

    // Check if enrollment already exists
    const existingEnrollment = await prisma.enrollment.findUnique({
      where: {
        userId_courseId: {
          userId: user.id,
          courseId: courseId,
        },
      },
    });

    if (existingEnrollment) {
      // Re-activate if inactive
      if (!existingEnrollment.isActive) {
        const updated = await prisma.enrollment.update({
          where: { id: existingEnrollment.id },
          data: { isActive: true },
        });
        return NextResponse.json(updated, { status: 200 });
      }
      return NextResponse.json(existingEnrollment, { status: 200 });
    }

    // Create new enrollment
    const enrollment = await prisma.enrollment.create({
      data: {
        userId: user.id,
        courseId: courseId,
        paymentId: `pay_${Math.random().toString(36).substring(2, 9)}`,
        paymentStatus: 'completed',
        isActive: true,
      },
    });

    // Also ensure LeaderboardEntry exists
    await prisma.leaderboardEntry.upsert({
      where: {
        userId_enrollmentId_snapshotDate: {
          userId: user.id,
          enrollmentId: enrollment.id,
          snapshotDate: new Date(),
        },
      },
      update: {},
      create: {
        userId: user.id,
        courseId: courseId,
        enrollmentId: enrollment.id,
        daysCompleted: 0,
        score: 0.00,
        snapshotDate: new Date(),
      },
    });

    return NextResponse.json(enrollment, { status: 201 });
  } catch (error) {
    console.error('Error creating mobile enrollment:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
