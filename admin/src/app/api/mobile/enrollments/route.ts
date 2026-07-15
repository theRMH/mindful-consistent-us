import crypto from 'crypto';
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
      where: { userId: user.id, isActive: true },
      include: {
        course: {
          include: { _count: { select: { courseDays: true } } },
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
    const { courseId, razorpayOrderId, razorpayPaymentId, razorpaySignature, couponCode } = body;

    if (!courseId) {
      return NextResponse.json({ error: 'Missing courseId' }, { status: 400 });
    }

    // Verify Razorpay payment signature
    let verifiedPaymentId: string;
    if (razorpayOrderId && razorpayPaymentId && razorpaySignature) {
      const expectedSig = crypto
        .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET!)
        .update(`${razorpayOrderId}|${razorpayPaymentId}`)
        .digest('hex');

      if (expectedSig !== razorpaySignature) {
        return NextResponse.json({ error: 'Payment verification failed' }, { status: 400 });
      }
      verifiedPaymentId = razorpayPaymentId;
    } else {
      // No payment details — admin-assigned enrollment path
      verifiedPaymentId = `admin_${Math.random().toString(36).substring(2, 9)}`;
    }

    // Check for existing enrollment
    const existingEnrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId: user.id, courseId } },
    });

    if (existingEnrollment) {
      if (!existingEnrollment.isActive) {
        const updated = await prisma.enrollment.update({
          where: { id: existingEnrollment.id },
          data: { isActive: true, paymentId: verifiedPaymentId, paymentStatus: 'completed' },
        });
        return NextResponse.json(updated, { status: 200 });
      }
      return NextResponse.json(existingEnrollment, { status: 200 });
    }

    // Create enrollment
    const enrollment = await prisma.enrollment.create({
      data: {
        userId: user.id,
        courseId,
        paymentId: verifiedPaymentId,
        paymentStatus: 'completed',
        isActive: true,
      },
    });

    // Increment coupon usage if one was used
    if (couponCode) {
      await prisma.coupon.updateMany({
        where: { code: (couponCode as string).toUpperCase(), isActive: true },
        data: { usageCount: { increment: 1 } },
      });
    }

    // Ensure LeaderboardEntry exists
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
        courseId,
        enrollmentId: enrollment.id,
        daysCompleted: 0,
        score: 0.0,
        snapshotDate: new Date(),
      },
    });

    return NextResponse.json(enrollment, { status: 201 });
  } catch (error) {
    console.error('Error creating mobile enrollment:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
