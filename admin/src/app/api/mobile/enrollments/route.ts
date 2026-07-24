import crypto from "crypto";
import { NextRequest, NextResponse } from "next/server";
import Razorpay from "razorpay";
import prisma from "@/lib/prisma";
import { verifyAuth } from "@/lib/auth-middleware";

export async function GET(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
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
    console.error("Error fetching mobile enrollments:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 },
    );
  }
}

export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await req.json().catch(() => ({}));
    const {
      courseId,
      razorpayOrderId,
      razorpayPaymentId,
      razorpaySignature,
      couponCode,
    } = body;

    if (!courseId) {
      return NextResponse.json({ error: "Missing courseId" }, { status: 400 });
    }

    const course = await prisma.course.findUnique({
      where: { id: courseId },
      select: { priceInr: true, isPublished: true },
    });
    if (!course || !course.isPublished) {
      return NextResponse.json({ error: "Course not found" }, { status: 404 });
    }

    let finalPrice = Number(course.priceInr);
    let couponId: string | null = null;
    let couponUsageLimit: number | null = null;
    if (couponCode) {
      const coupon = await prisma.coupon.findUnique({
        where: { code: (couponCode as string).toUpperCase() },
      });
      if (
        !coupon ||
        !coupon.isActive ||
        (coupon.expiresAt && new Date() > coupon.expiresAt) ||
        (coupon.usageLimit !== null && coupon.usageCount >= coupon.usageLimit)
      ) {
        return NextResponse.json(
          { error: "Invalid or expired coupon" },
          { status: 400 },
        );
      }
      couponId = coupon.id;
      couponUsageLimit = coupon.usageLimit;
      finalPrice = Math.max(0, finalPrice - Number(coupon.discountAmount));
    }
    const amountPaise = Math.round(finalPrice * 100);

    let verifiedPaymentId: string;
    if (amountPaise <= 0) {
      verifiedPaymentId = couponId ? `free_coupon_${couponId}` : "free_course";
    } else if (razorpayOrderId && razorpayPaymentId && razorpaySignature) {
      if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
        return NextResponse.json(
          { error: "Payment gateway not configured" },
          { status: 500 },
        );
      }

      const expectedSig = crypto
        .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
        .update(`${razorpayOrderId}|${razorpayPaymentId}`)
        .digest("hex");

      if (expectedSig !== razorpaySignature) {
        return NextResponse.json(
          { error: "Payment verification failed" },
          { status: 400 },
        );
      }

      const razorpay = new Razorpay({
        key_id: process.env.RAZORPAY_KEY_ID,
        key_secret: process.env.RAZORPAY_KEY_SECRET,
      });
      const order = await razorpay.orders.fetch(razorpayOrderId);
      if (
        order.currency !== "INR" ||
        Number(order.amount) !== amountPaise ||
        !String(order.receipt ?? "").startsWith(`rcpt_${user.id.slice(0, 8)}_`)
      ) {
        return NextResponse.json(
          { error: "Payment order mismatch" },
          { status: 400 },
        );
      }

      const payment = await razorpay.payments.fetch(razorpayPaymentId);
      if (
        payment.order_id !== razorpayOrderId ||
        payment.currency !== "INR" ||
        Number(payment.amount) !== amountPaise ||
        !["authorized", "captured"].includes(String(payment.status))
      ) {
        return NextResponse.json(
          { error: "Payment details mismatch" },
          { status: 400 },
        );
      }

      verifiedPaymentId = razorpayPaymentId;
    } else {
      return NextResponse.json(
        { error: "Payment details are required" },
        { status: 400 },
      );
    }

    let txResult: { existingEnrollment: { id: string; [key: string]: unknown } | null; enrollment: { id: string; [key: string]: unknown } | null };
    try {
      txResult = await prisma.$transaction(async (tx) => {
        // Atomically increment the coupon counter only if the limit hasn't been hit.
        // The conditional WHERE acts as the gate — zero rows updated means exhausted.
        if (couponId) {
          const updated = await tx.coupon.updateMany({
            where: {
              id: couponId,
              isActive: true,
              ...(couponUsageLimit !== null && {
                usageCount: { lt: couponUsageLimit },
              }),
            },
            data: { usageCount: { increment: 1 } },
          });
          if (updated.count === 0) {
            throw new Error("COUPON_EXHAUSTED");
          }
        }

        const existingEnrollment = await tx.enrollment.findUnique({
          where: { userId_courseId: { userId: user.id, courseId } },
        });

        if (!verifiedPaymentId.startsWith("free_")) {
          const existingPayment = await tx.enrollment.findFirst({
            where: {
              paymentId: verifiedPaymentId,
              NOT: { userId: user.id, courseId },
            },
            select: { id: true },
          });
          if (existingPayment) {
            throw new Error("PAYMENT_REUSED");
          }
        }

        if (existingEnrollment) {
          if (!existingEnrollment.isActive) {
            const updated = await tx.enrollment.update({
              where: { id: existingEnrollment.id },
              data: {
                isActive: true,
                paymentId: verifiedPaymentId,
                paymentStatus: "completed",
              },
            });
            return { existingEnrollment: updated, enrollment: null };
          }
          return { existingEnrollment, enrollment: null };
        }

        const enrollment = await tx.enrollment.create({
          data: {
            userId: user.id,
            courseId,
            paymentId: verifiedPaymentId,
            paymentStatus: "completed",
            isActive: true,
          },
        });

        return { existingEnrollment: null, enrollment };
      });
    } catch (err) {
      if (err instanceof Error && err.message === "COUPON_EXHAUSTED") {
        return NextResponse.json({ error: "Invalid or expired coupon" }, { status: 400 });
      }
      if (err instanceof Error && err.message === "PAYMENT_REUSED") {
        return NextResponse.json({ error: "Payment has already been used" }, { status: 409 });
      }
      throw err;
    }

    const { existingEnrollment, enrollment } = txResult;

    if (existingEnrollment && !enrollment) {
      return NextResponse.json(existingEnrollment, { status: 200 });
    }

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
    console.error("Error creating mobile enrollment:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 },
    );
  }
}
