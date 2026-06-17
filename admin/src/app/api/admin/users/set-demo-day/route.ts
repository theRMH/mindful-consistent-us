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
    // completedDayNumbers: which days to mark complete. Defaults to all days before dayNumber.
    const { userId, enrollmentId, dayNumber, resetProgress = true, completedDayNumbers } = body;

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
      where: { id: enrollmentId, userId },
      include: { course: true },
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

    // Reset all progress and backdate enrollment
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
        data: { enrolledAt: demoEnrolledAt, isActive: true },
      }),
    ]);

    // Seed dailyProgress records for completed days
    if (resetProgress) {
      const daysToComplete: number[] =
        Array.isArray(completedDayNumbers) && completedDayNumbers.length > 0
          ? completedDayNumbers.map(Number)
          : Array.from({ length: parsedDayNumber - 1 }, (_, i) => i + 1);

      if (daysToComplete.length > 0) {
        // Upsert course days so they exist even if the admin hasn't built them yet
        const courseDays = await Promise.all(
          daysToComplete.map((dayNum) =>
            prisma.courseDay.upsert({
              where: { courseId_dayNumber: { courseId: enrollment.courseId, dayNumber: dayNum } },
              create: { courseId: enrollment.courseId, dayNumber: dayNum, title: `Day ${dayNum}` },
              update: {},
              select: { id: true, dayNumber: true },
            }),
          ),
        );

        if (courseDays.length > 0) {
          await prisma.dailyProgress.createMany({
            data: courseDays.map((cd) => {
              const dayDate = new Date(demoEnrolledAt);
              dayDate.setUTCDate(dayDate.getUTCDate() + (cd.dayNumber - 1));
              return {
                userId,
                enrollmentId,
                courseDayId: cd.id,
                isComplete: true,
                completedAt: dayDate,
                dayDate,
                videosWatched: 1,
                totalWatchSeconds: 1800,
                caloriesBurnt: 0,
                stepsCount: 0,
              };
            }),
          });

          // Calculate streak: consecutive complete days ending at dayNumber-1
          const completedSet = new Set(daysToComplete);
          let streak = 0;
          for (let d = parsedDayNumber - 1; d >= 1; d--) {
            if (completedSet.has(d)) streak++;
            else break;
          }

          await prisma.userStats.update({
            where: { userId },
            data: {
              totalSessions: courseDays.length,
              totalWatchSeconds: courseDays.length * 1800,
              currentStreak: streak,
              longestStreak: streak,
              updatedAt: new Date(),
            },
          });
        }
      }
    }

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
