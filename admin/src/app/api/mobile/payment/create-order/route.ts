import { NextRequest, NextResponse } from "next/server";
import Razorpay from "razorpay";
import prisma from "@/lib/prisma";
import { verifyAuth } from "@/lib/auth-middleware";

export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user)
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const body = await req.json().catch(() => ({}));
    const { courseId, couponCode } = body;

    if (!courseId)
      return NextResponse.json({ error: "Missing courseId" }, { status: 400 });

    const course = await prisma.course.findUnique({
      where: { id: courseId },
      select: { priceInr: true, title: true, isPublished: true },
    });
    if (!course || !course.isPublished) {
      return NextResponse.json({ error: "Course not found" }, { status: 404 });
    }

    let finalPrice = Number(course.priceInr);

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
      finalPrice = Math.max(0, finalPrice - Number(coupon.discountAmount));
    }

    const amountPaise = Math.round(finalPrice * 100);
    if (amountPaise <= 0) {
      return NextResponse.json({
        free: true,
        amount: 0,
        currency: "INR",
        keyId: process.env.RAZORPAY_KEY_ID,
      });
    }

    if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
      return NextResponse.json(
        { error: "Payment gateway not configured" },
        { status: 500 },
      );
    }

    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });

    const order = await razorpay.orders.create({
      amount: amountPaise,
      currency: "INR",
      receipt: `rcpt_${user.id.slice(0, 8)}_${Date.now()}`,
    });

    return NextResponse.json({
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId: process.env.RAZORPAY_KEY_ID,
    });
  } catch (error) {
    console.error("Error creating Razorpay order:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 },
    );
  }
}
