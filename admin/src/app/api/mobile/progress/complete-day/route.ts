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
    const { courseId, dayNumber } = body;

    if (!courseId || !dayNumber) {
      return NextResponse.json({ error: 'Missing courseId or dayNumber' }, { status: 400 });
    }

    // 1. Get Course Day
    const courseDay = await prisma.courseDay.findFirst({
      where: {
        courseId: courseId,
        dayNumber: parseInt(dayNumber, 10),
      },
    });

    if (!courseDay) {
      return NextResponse.json({ error: 'Course Day not found' }, { status: 404 });
    }

    // 2. Get active enrollment
    const enrollment = await prisma.enrollment.findUnique({
      where: {
        userId_courseId: {
          userId: user.id,
          courseId: courseId,
        },
      },
    });

    if (!enrollment || !enrollment.isActive) {
      return NextResponse.json({ error: 'Not enrolled in this course' }, { status: 403 });
    }

    // 3. Check if already completed
    const existingProgress = await prisma.dailyProgress.findUnique({
      where: {
        userId_enrollmentId_courseDayId: {
          userId: user.id,
          enrollmentId: enrollment.id,
          courseDayId: courseDay.id,
        },
      },
    });

    if (existingProgress && existingProgress.isComplete) {
      return NextResponse.json({ message: 'Day already completed', progress: existingProgress }, { status: 200 });
    }

    const today = new Date();
    // Normalize to date-only
    const dayDate = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate()));

    // 4. Create or complete daily progress
    const progress = await prisma.dailyProgress.upsert({
      where: {
        userId_enrollmentId_courseDayId: {
          userId: user.id,
          enrollmentId: enrollment.id,
          courseDayId: courseDay.id,
        },
      },
      update: {
        isComplete: true,
        completedAt: today,
        dayDate: dayDate,
        totalWatchSeconds: { increment: 900 }, // Simulate 15 min video session
      },
      create: {
        userId: user.id,
        enrollmentId: enrollment.id,
        courseDayId: courseDay.id,
        isComplete: true,
        completedAt: today,
        dayDate: dayDate,
        totalWatchSeconds: 900,
        caloriesBurnt: 0,
        stepsCount: 0,
      },
    });

    // 5. Update user stats & streak
    const userStats = await prisma.userStats.findUnique({
      where: { userId: user.id },
    });

    const currentStreak = userStats?.currentStreak ?? 0;
    let newStreak: number;

    // Check if the user already completed a different day today (streak already counted for today)
    const completedTodayElsewhere = await prisma.dailyProgress.findFirst({
      where: {
        userId: user.id,
        isComplete: true,
        dayDate: dayDate,
        NOT: {
          AND: [
            { userId: user.id },
            { enrollmentId: enrollment.id },
            { courseDayId: courseDay.id },
          ],
        },
      },
    });

    if (completedTodayElsewhere) {
      // Streak already counted for today — don't change it
      newStreak = currentStreak;
    } else {
      // Find the most recently completed day strictly before today
      const lastCompleted = await prisma.dailyProgress.findFirst({
        where: {
          userId: user.id,
          isComplete: true,
          dayDate: { lt: dayDate },
        },
        orderBy: { dayDate: 'desc' },
      });

      if (!lastCompleted) {
        newStreak = 1;
      } else {
        const daysDiff = Math.round(
          (dayDate.getTime() - new Date(lastCompleted.dayDate).getTime()) / (1000 * 60 * 60 * 24)
        );
        newStreak = daysDiff === 1 ? currentStreak + 1 : 1;
      }
    }

    const newLongest = Math.max(userStats?.longestStreak ?? 0, newStreak);

    const updatedStats = await prisma.userStats.upsert({
      where: { userId: user.id },
      update: {
        totalWatchSeconds: { increment: 900 },
        totalSessions: { increment: 1 },
        currentStreak: newStreak,
        longestStreak: newLongest,
        updatedAt: today,
      },
      create: {
        userId: user.id,
        totalWatchSeconds: 900,
        totalSessions: 1,
        currentStreak: 1,
        longestStreak: 1,
      },
    });

    // 6. Update Leaderboard Entry score
    const allCompletedCount = await prisma.dailyProgress.count({
      where: {
        userId: user.id,
        enrollmentId: enrollment.id,
        isComplete: true,
      },
    });

    // Score = days completed * 100 + streak * 10
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
        courseId: courseId,
        enrollmentId: enrollment.id,
        daysCompleted: allCompletedCount,
        score: newScore,
        snapshotDate: dayDate,
      },
    });

    return NextResponse.json({
      success: true,
      progress,
      stats: updatedStats,
    }, { status: 200 });
  } catch (error: any) {
    console.error('Error completing course day:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
