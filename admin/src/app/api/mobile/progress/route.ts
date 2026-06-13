import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { verifyAuth } from "@/lib/auth-middleware";

export async function GET(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Get UserStats
    let stats = await prisma.userStats.findUnique({
      where: { userId: user.id },
    });

    if (!stats) {
      stats = await prisma.userStats.create({
        data: { userId: user.id },
      });
    }

    // Get active enrollment
    const activeEnrollment = await prisma.enrollment.findFirst({
      where: {
        userId: user.id,
        isActive: true,
      },
      orderBy: { enrolledAt: "desc" },
    });

    let completedDays: number[] = [];
    if (activeEnrollment) {
      // Find all completed days for this enrollment
      const progress = await prisma.dailyProgress.findMany({
        where: {
          userId: user.id,
          enrollmentId: activeEnrollment.id,
          isComplete: true,
        },
        include: {
          courseDay: true,
        },
      });
      completedDays = progress.map((p) => p.courseDay.dayNumber);
    }

    // Get all completed video IDs for this user
    const videoProgressRecords = await prisma.videoProgress.findMany({
      where: { userId: user.id, isCompleted: true },
      select: { videoId: true },
    });
    const completedVideoIds = videoProgressRecords.map((vp) => vp.videoId);

    return NextResponse.json(
      {
        stats: {
          currentStreak: stats.currentStreak,
          longestStreak: stats.longestStreak,
          totalSteps: stats.totalSteps,
          totalCalories: Number(stats.totalCalories),
          totalSessions: stats.totalSessions,
          totalWatchSeconds: stats.totalWatchSeconds,
          mindfulMins: Math.round(stats.totalWatchSeconds / 60),
        },
        completedDays,
        completedVideoIds,
        activeCourseId: activeEnrollment?.courseId || null,
      },
      { status: 200 },
    );
  } catch (error: any) {
    console.error("Error fetching mobile progress:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 },
    );
  }
}
