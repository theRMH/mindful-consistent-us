import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await req.json().catch(() => ({}));
    const { action, streak, steps, mindfulMins, score, completedDay } = body;

    // Ensure user stats exist
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
      where: { userId: user.id, isActive: true },
    });

    if (action === 'reset') {
      // Clear progress
      await prisma.dailyProgress.deleteMany({
        where: { userId: user.id },
      });
      await prisma.videoProgress.deleteMany({
        where: { userId: user.id },
      });
      await prisma.leaderboardEntry.deleteMany({
        where: { userId: user.id },
      });

      stats = await prisma.userStats.update({
        where: { userId: user.id },
        data: {
          currentStreak: 0,
          longestStreak: 0,
          totalSteps: 0,
          totalCalories: 0,
          totalSessions: 0,
          totalWatchSeconds: 0,
        },
      });

      return NextResponse.json({ success: true, message: 'All progress reset successfully', stats }, { status: 200 });
    }

    // Prepare update payload for UserStats
    const updateData: Record<string, number | { increment: number }> = {};

    if (streak !== undefined) {
      updateData.currentStreak = parseInt(streak, 10);
      updateData.longestStreak = Math.max(stats.longestStreak, parseInt(streak, 10));
    }

    if (steps !== undefined) {
      const addedSteps = parseInt(steps, 10);
      updateData.totalSteps = { increment: addedSteps };
      updateData.totalCalories = { increment: addedSteps * 0.04 };
    }

    if (mindfulMins !== undefined) {
      const addedSeconds = parseInt(mindfulMins, 10) * 60;
      updateData.totalWatchSeconds = { increment: addedSeconds };
    }

    if (Object.keys(updateData).length > 0) {
      stats = await prisma.userStats.update({
        where: { userId: user.id },
        data: updateData,
      });
    }

    // Toggle completed day if provided
    if (completedDay !== undefined && activeEnrollment) {
      const dayNum = parseInt(completedDay, 10);
      const courseDay = await prisma.courseDay.findFirst({
        where: {
          courseId: activeEnrollment.courseId,
          dayNumber: dayNum,
        },
      });

      if (courseDay) {
        // Find existing
        const existingDP = await prisma.dailyProgress.findUnique({
          where: {
            userId_enrollmentId_courseDayId: {
              userId: user.id,
              enrollmentId: activeEnrollment.id,
              courseDayId: courseDay.id,
            },
          },
        });

        if (existingDP) {
          // Toggle completion
          await prisma.dailyProgress.update({
            where: { id: existingDP.id },
            data: { isComplete: !existingDP.isComplete },
          });
        } else {
          // Create new completed day
          await prisma.dailyProgress.create({
            data: {
              userId: user.id,
              enrollmentId: activeEnrollment.id,
              courseDayId: courseDay.id,
              isComplete: true,
              dayDate: new Date(),
              completedAt: new Date(),
            },
          });
        }
      }
    }

    // Update Leaderboard score if provided
    if (score !== undefined && activeEnrollment) {
      const targetScore = parseFloat(score);
      const today = new Date();
      const dayDate = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate()));

      const allCompletedCount = await prisma.dailyProgress.count({
        where: {
          userId: user.id,
          enrollmentId: activeEnrollment.id,
          isComplete: true,
        },
      });

      await prisma.leaderboardEntry.upsert({
        where: {
          userId_enrollmentId_snapshotDate: {
            userId: user.id,
            enrollmentId: activeEnrollment.id,
            snapshotDate: dayDate,
          },
        },
        update: {
          score: targetScore,
          daysCompleted: allCompletedCount,
        },
        create: {
          userId: user.id,
          courseId: activeEnrollment.courseId,
          enrollmentId: activeEnrollment.id,
          daysCompleted: allCompletedCount,
          score: targetScore,
          snapshotDate: dayDate,
        },
      });
    }

    // Fetch the final updated details to return
    let completedDays: number[] = [];
    if (activeEnrollment) {
      const progress = await prisma.dailyProgress.findMany({
        where: {
          userId: user.id,
          enrollmentId: activeEnrollment.id,
          isComplete: true,
        },
        include: { courseDay: true },
      });
      completedDays = progress.map(p => p.courseDay.dayNumber);
    }

    return NextResponse.json({
      success: true,
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
      activeCourseId: activeEnrollment?.courseId || null,
    }, { status: 200 });
  } catch (error) {
    console.error('Error simulating progress:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
