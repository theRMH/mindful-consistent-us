import { NextRequest, NextResponse } from "next/server";
import Razorpay from "razorpay";
import prisma from "@/lib/prisma";
import { verifyAuth } from "@/lib/auth-middleware";

// Fetch live USD→INR rate. Falls back to 84 if the API is unreachable.
async function getUsdToInrRate(): Promise<number> {
  try {
    const res = await fetch(
      "https://api.exchangerate-api.com/v4/latest/USD",
      { next: { revalidate: 3600 } }, // cache for 1 hour
    );
    if (!res.ok) throw new Error("rate fetch failed");
    const data = await res.json();
    const rate = data?.rates?.INR;
    if (typeof rate === "number" && rate > 0) return rate;
    throw new Error("invalid rate");
  } catch {
    return 84; // safe fallback
  }
}

export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user)
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const body = await req.json().catch(() => ({}));
    const { courseId, couponCode } = body;

    if (!courseId)
      return NextResponse.json({ error: "Missing courseId" }, { status: 400 });

    const [course, profile] = await Promise.all([
      prisma.course.findUnique({
        where: { id: courseId },
        select: { priceInr: true, priceUsd: true, title: true, isPublished: true },
      }),
      prisma.profile.findUnique({
        where: { id: user.id },
        select: { currency: true },
      }),
    ]);

    if (!course || !course.isPublished) {
      return NextResponse.json({ error: "Course not found" }, { status: 404 });
    }

    const isUsdUser = profile?.currency === "USD" && course.priceUsd != null;

    // For USD users: show price in USD, but charge INR equivalent via live rate.
    // Razorpay always charges INR (works on all Indian accounts).
    let finalPriceInr: number;
    let displayPriceUsd: number | null = null;

    if (isUsdUser) {
      const usdPrice = Number(course.priceUsd);
      const rate = await getUsdToInrRate();
      finalPriceInr = Math.round(usdPrice * rate);
      displayPriceUsd = usdPrice;
    } else {
      finalPriceInr = Number(course.priceInr);
    }

    // Coupons are INR-denominated
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
      finalPriceInr = Math.max(0, finalPriceInr - Number(coupon.discountAmount));
    }

    const amountPaise = Math.round(finalPriceInr * 100);
    if (amountPaise <= 0) {
      return NextResponse.json({
        free: true,
        amount: 0,
        currency: "INR",
        displayCurrency: isUsdUser ? "USD" : "INR",
        displayPrice: isUsdUser ? displayPriceUsd : 0,
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
      amount: order.amount,       // paise in INR
      currency: order.currency,   // always "INR"
      displayCurrency: isUsdUser ? "USD" : "INR",
      displayPrice: isUsdUser ? displayPriceUsd : finalPriceInr,
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
