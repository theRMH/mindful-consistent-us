import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const courseId = searchParams.get('courseId') || '';
    const sortBy = searchParams.get('sortBy') || 'streak';

    const profiles = await prisma.profile.findMany({
      where: courseId ? { enrollments: { some: { courseId } } } : {},
      include: {
        userStats: true,
        enrollments: {
          include: { course: { select: { id: true, title: true, totalDays: true } } },
          orderBy: { enrolledAt: 'desc' },
        },
      },
    });

    const completedDaysData = await prisma.dailyProgress.groupBy({
      by: ['userId'],
      where: {
        isComplete: true,
        ...(courseId ? { enrollment: { courseId } } : {}),
      },
      _count: { id: true },
    });

    const daysMap = new Map(completedDaysData.map((d) => [d.userId, d._count.id]));

    const entries = profiles.map((p) => ({
      id: p.id,
      name: p.fullName || p.email,
      avatarUrl: p.avatarUrl,
      currentStreak: p.userStats?.currentStreak ?? 0,
      longestStreak: p.userStats?.longestStreak ?? 0,
      totalSteps: p.userStats?.totalSteps ?? 0,
      totalMinutes: Math.round((p.userStats?.totalWatchSeconds ?? 0) / 60),
      daysCompleted: daysMap.get(p.id) ?? 0,
      programs: p.enrollments.map((e) => ({ id: e.courseId, title: e.course.title, isActive: e.isActive })),
    }));

    const sorted = entries.sort((a, b) => {
      if (sortBy === 'steps') return b.totalSteps - a.totalSteps;
      if (sortBy === 'minutes') return b.totalMinutes - a.totalMinutes;
      if (sortBy === 'days') return b.daysCompleted - a.daysCompleted;
      return b.currentStreak - a.currentStreak;
    });

    return NextResponse.json(sorted, { status: 200 });
  } catch (error) {
    console.error('Leaderboard error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
