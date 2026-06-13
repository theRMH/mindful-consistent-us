import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { verifyAuth } from "@/lib/auth-middleware";

export async function handleCompleteSession(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await req.json().catch(() => ({}));
    const { courseId, dayNumber, videoId } = body;

    if (!courseId || !dayNumber) {
      return NextResponse.json(
        { error: "Missing courseId or dayNumber" },
        { status: 400 },
      );
    }

    if (!videoId) {
      return NextResponse.json({ error: "Missing videoId" }, { status: 400 });
    }

    const parsedDayNumber = parseInt(dayNumber, 10);
    const today = new Date();
    const dayDate = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate()),
    );

    const courseDay = await prisma.courseDay.findFirst({
      where: {
        courseId,
        dayNumber: parsedDayNumber,
      },
    });

    if (!courseDay) {
      return NextResponse.json(
        { error: "Course Day not found" },
        { status: 404 },
      );
    }

    const enrollment = await prisma.enrollment.findUnique({
      where: {
        userId_courseId: {
          userId: user.id,
          courseId,
        },
      },
    });

    if (!enrollment || !enrollment.isActive) {
      return NextResponse.json(
        { error: "Not enrolled in this course" },
        { status: 403 },
      );
    }

    const enrolledAt = new Date(enrollment.enrolledAt);
    const enrolledDate = new Date(
      Date.UTC(
        enrolledAt.getUTCFullYear(),
        enrolledAt.getUTCMonth(),
        enrolledAt.getUTCDate(),
      ),
    );
    const expectedDayNumber =
      Math.floor(
        (dayDate.getTime() - enrolledDate.getTime()) / (1000 * 60 * 60 * 24),
      ) + 1;

    if (parsedDayNumber !== expectedDayNumber) {
      return NextResponse.json(
        { error: "This day is locked", expectedDayNumber },
        { status: 403 },
      );
    }

    const video = await prisma.video.findFirst({
      where: {
        id: videoId,
        courseDayId: courseDay.id,
        isPublished: true,
      },
    });

    if (!video) {
      return NextResponse.json(
        { error: "Video not found for this day" },
        { status: 404 },
      );
    }

    const existingProgress = await prisma.dailyProgress.findUnique({
      where: {
        userId_enrollmentId_courseDayId: {
          userId: user.id,
          enrollmentId: enrollment.id,
          courseDayId: courseDay.id,
        },
      },
    });

    const existingVideoProgress = await prisma.videoProgress.findUnique({
      where: { userId_videoId: { userId: user.id, videoId } },
    });
    const isNewVideoCompletion = !existingVideoProgress?.isCompleted;

    await prisma.videoProgress.upsert({
      where: { userId_videoId: { userId: user.id, videoId } },
      update: { isCompleted: true, watchedAt: today },
      create: {
        userId: user.id,
        videoId,
        enrollmentId: enrollment.id,
        isCompleted: true,
        watchDurationSeconds: 0,
        lastPositionSeconds: 0,
      },
    });

    const totalDayVideos = await prisma.video.count({
      where: {
        courseDayId: courseDay.id,
        isPublished: true,
      },
    });

    const completedVideoCount = await prisma.videoProgress.count({
      where: {
        userId: user.id,
        isCompleted: true,
        video: {
          courseDayId: courseDay.id,
          isPublished: true,
        },
      },
    });

    const wasDayComplete = existingProgress?.isComplete ?? false;
    const shouldCompleteDay =
      totalDayVideos > 0 && completedVideoCount >= totalDayVideos;
    const newlyCompletedDay = shouldCompleteDay && !wasDayComplete;

    const progress = await prisma.dailyProgress.upsert({
      where: {
        userId_enrollmentId_courseDayId: {
          userId: user.id,
          enrollmentId: enrollment.id,
          courseDayId: courseDay.id,
        },
      },
      update: {
        isComplete: shouldCompleteDay ? true : wasDayComplete,
        completedAt: newlyCompletedDay ? today : existingProgress?.completedAt,
        dayDate,
        videosWatched: completedVideoCount,
        ...(isNewVideoCompletion
          ? { totalWatchSeconds: { increment: video.durationSeconds || 0 } }
          : {}),
      },
      create: {
        userId: user.id,
        enrollmentId: enrollment.id,
        courseDayId: courseDay.id,
        isComplete: shouldCompleteDay,
        completedAt: shouldCompleteDay ? today : null,
        dayDate,
        videosWatched: completedVideoCount,
        totalWatchSeconds: isNewVideoCompletion
          ? video.durationSeconds || 0
          : 0,
        caloriesBurnt: 0,
        stepsCount: 0,
      },
    });

    const userStats = await prisma.userStats.findUnique({
      where: { userId: user.id },
    });

    const currentStreak = userStats?.currentStreak ?? 0;
    let newStreak = currentStreak;

    if (newlyCompletedDay) {
      const completedTodayElsewhere = await prisma.dailyProgress.findFirst({
        where: {
          userId: user.id,
          isComplete: true,
          dayDate,
          NOT: {
            AND: [
              { userId: user.id },
              { enrollmentId: enrollment.id },
              { courseDayId: courseDay.id },
            ],
          },
        },
      });

      if (!completedTodayElsewhere) {
        const lastCompleted = await prisma.dailyProgress.findFirst({
          where: {
            userId: user.id,
            isComplete: true,
            dayDate: { lt: dayDate },
          },
          orderBy: { dayDate: "desc" },
        });

        if (!lastCompleted) {
          newStreak = 1;
        } else {
          const daysDiff = Math.round(
            (dayDate.getTime() - new Date(lastCompleted.dayDate).getTime()) /
              (1000 * 60 * 60 * 24),
          );
          newStreak = daysDiff === 1 ? currentStreak + 1 : 1;
        }
      }
    }

    const newLongest = Math.max(userStats?.longestStreak ?? 0, newStreak);

    const updatedStats = await prisma.userStats.upsert({
      where: { userId: user.id },
      update: {
        ...(isNewVideoCompletion
          ? {
              totalWatchSeconds: { increment: video.durationSeconds || 0 },
              totalSessions: { increment: 1 },
            }
          : {}),
        currentStreak: newStreak,
        longestStreak: newLongest,
        updatedAt: today,
      },
      create: {
        userId: user.id,
        totalWatchSeconds: isNewVideoCompletion
          ? video.durationSeconds || 0
          : 0,
        totalSessions: isNewVideoCompletion ? 1 : 0,
        currentStreak: newStreak,
        longestStreak: newLongest,
      },
    });

    const allCompletedCount = await prisma.dailyProgress.count({
      where: {
        userId: user.id,
        enrollmentId: enrollment.id,
        isComplete: true,
      },
    });

    const newScore = allCompletedCount * 100 + newStreak * 10;

    await prisma.leaderboardEntry.upsert({
      where: {
        userId_enrollmentId_snapshotDate: {
          userId: user.id,
          enrollmentId: enrollment.id,
          snapshotDate: dayDate,
        },
      },
      update: {
        daysCompleted: allCompletedCount,
        score: newScore,
      },
      create: {
        userId: user.id,
        courseId,
        enrollmentId: enrollment.id,
        daysCompleted: allCompletedCount,
        score: newScore,
        snapshotDate: dayDate,
      },
    });

    return NextResponse.json(
      {
        success: true,
        progress,
        stats: updatedStats,
        completedVideoCount,
        dayCompleted: shouldCompleteDay,
      },
      { status: 200 },
    );
  } catch (error: any) {
    console.error("Error completing session:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 },
    );
  }
}
