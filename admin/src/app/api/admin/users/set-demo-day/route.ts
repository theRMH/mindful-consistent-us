import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";

function enrolledAtForDemoDay(dayNumber: number) {
  const now = new Date();
  const todayUtc = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
  );
  todayUtc.setUTCDate(todayUtc.getUTCDate() - (dayNumber - 1));
  return todayUtc;
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json().catch(() => ({}));
    const { userId, enrollmentId, dayNumber, resetProgress = true } = body;

    const parsedDayNumber = parseInt(String(dayNumber), 10);

    if (!userId || !enrollmentId || !Number.isFinite(parsedDayNumber)) {
      return NextResponse.json(
        { error: "Missing userId, enrollmentId, or dayNumber" },
        { status: 400 },
      );
    }

    if (parsedDayNumber < 1) {
      return NextResponse.json(
        { error: "dayNumber must be 1 or greater" },
        { status: 400 },
      );
    }

    const enrollment = await prisma.enrollment.findFirst({
      where: {
        id: enrollmentId,
        userId,
      },
      include: {
        course: true,
      },
    });

    if (!enrollment) {
      return NextResponse.json(
        { error: "Enrollment not found for this user" },
        { status: 404 },
      );
    }

    if (parsedDayNumber > enrollment.course.totalDays) {
      return NextResponse.json(
        { error: `Day must be between 1 and ${enrollment.course.totalDays}` },
        { status: 400 },
      );
    }

    const demoEnrolledAt = enrolledAtForDemoDay(parsedDayNumber);

    await prisma.$transaction([
      ...(resetProgress
        ? [
            prisma.videoProgress.deleteMany({ where: { userId } }),
            prisma.dailyProgress.deleteMany({ where: { userId } }),
            prisma.leaderboardEntry.deleteMany({ where: { userId } }),
            prisma.userStats.upsert({
              where: { userId },
              update: {
                totalWatchSeconds: 0,
                totalSessions: 0,
                totalCalories: 0,
                totalSteps: 0,
                currentStreak: 0,
                longestStreak: 0,
                updatedAt: new Date(),
              },
              create: {
                userId,
                totalWatchSeconds: 0,
                totalSessions: 0,
                totalCalories: 0,
                totalSteps: 0,
                currentStreak: 0,
                longestStreak: 0,
              },
            }),
          ]
        : []),
      prisma.enrollment.update({
        where: { id: enrollmentId },
        data: {
          enrolledAt: demoEnrolledAt,
          isActive: true,
        },
      }),
    ]);

    return NextResponse.json(
      {
        success: true,
        userId,
        enrollmentId,
        dayNumber: parsedDayNumber,
        enrolledAt: demoEnrolledAt.toISOString(),
        resetProgress,
      },
      { status: 200 },
    );
  } catch (error) {
    console.error("Error setting demo day:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 },
    );
  }
}
