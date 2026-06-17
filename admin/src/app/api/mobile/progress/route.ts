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
      include: { course: { select: { totalDays: true } } },
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

    // Steps goal (needed for weekly activity and stepsGoalDays below)
    const stepsGoalSetting = await prisma.appSetting.findUnique({ where: { key: 'steps_goal' } });
    const stepsGoal = parseInt(stepsGoalSetting?.value ?? '10000', 10);

    // Weekly activity: points per day (same formula as leaderboard) from enrollment date
    const now = new Date();
    const sevenDaysAgo = new Date(now);
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
    sevenDaysAgo.setHours(0, 0, 0, 0);
    const sevenDaysAgoStr = sevenDaysAgo.toISOString().slice(0, 10);
    const enrolledAtStr = activeEnrollment
      ? new Date(activeEnrollment.enrolledAt).toISOString().slice(0, 10)
      : sevenDaysAgoStr;
    const activityFromStr = enrolledAtStr > sevenDaysAgoStr ? enrolledAtStr : sevenDaysAgoStr;
    const activityFrom = new Date(activityFromStr);

    const weeklyProgress = activeEnrollment
      ? await prisma.dailyProgress.findMany({
          where: {
            userId: user.id,
            enrollmentId: activeEnrollment.id,
            dayDate: { gte: activityFrom },
          },
          select: { dayDate: true, videosWatched: true, isComplete: true, stepsCount: true },
        })
      : [];

    const dayAbbr = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const weeklyActivity = Array.from({ length: 7 }, (_, i) => {
      const d = new Date(now);
      d.setDate(d.getDate() - (6 - i));
      const dayStr = d.toISOString().slice(0, 10);
      const records = weeklyProgress.filter(
        p => new Date(p.dayDate).toISOString().slice(0, 10) === dayStr,
      );
      const hasActivity = records.some(p => (p.videosWatched ?? 0) > 0);
      const hasComplete = records.some(p => p.isComplete);
      const hasStepsGoal = records.some(p => (p.stepsCount ?? 0) >= stepsGoal);
      const points = (hasActivity ? 50 : 0) + (hasComplete ? 30 : 0) + (hasStepsGoal ? 25 : 0);
      return { label: dayAbbr[d.getDay()], val: points };
    });

    // Current day based on enrollment date (not completedDays.length) so missed days don't shift the pointer
    let currentDayNumber = completedDays.length + 1;
    if (activeEnrollment) {
      const enrolledAt = new Date(activeEnrollment.enrolledAt);
      const now = new Date();
      const daysSince = Math.floor((now.getTime() - enrolledAt.getTime()) / (1000 * 60 * 60 * 24));
      const totalDays = activeEnrollment.course?.totalDays ?? 9999;
      currentDayNumber = Math.min(daysSince + 1, totalDays);
    }

    // Steps goal days: count days in active enrollment where user hit the daily step target
    const stepsGoalDays = activeEnrollment
      ? await prisma.dailyProgress.count({
          where: {
            userId: user.id,
            enrollmentId: activeEnrollment.id,
            stepsCount: { gte: stepsGoal },
          },
        })
      : 0;

    return NextResponse.json(
      {
        _debug: {
          activeEnrollmentId: activeEnrollment?.id ?? null,
          activityFromStr,
          weeklyProgressCount: weeklyProgress.length,
          weeklyProgressRaw: weeklyProgress,
        },
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
        currentDayNumber,
        stepsGoalDays,
        weeklyActivity,
      },
      { status: 200 },
    );
  } catch (error) {
    console.error("Error fetching mobile progress:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 },
    );
  }
}
