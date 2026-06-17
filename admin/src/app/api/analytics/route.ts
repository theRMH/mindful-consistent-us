import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    const now = new Date();
    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - 7);
    const startOfMonth = new Date(now);
    startOfMonth.setDate(now.getDate() - 30);
    const last14Days = new Date(now);
    last14Days.setDate(now.getDate() - 13);

    const [
      totalUsers,
      newThisWeek,
      newThisMonth,
      totalEnrollments,
      activeEnrollments,
      enrollmentsByCourse,
      userStatsAgg,
      maxStreak,
      usersWithStreak,
      feedbackAgg,
      feedbackDistribution,
      totalNotifications,
      totalReadReceipts,
      dailyActivity,
      userGrowth,
    ] = await Promise.all([
      prisma.profile.count(),

      prisma.profile.count({ where: { createdAt: { gte: startOfWeek } } }),

      prisma.profile.count({ where: { createdAt: { gte: startOfMonth } } }),

      prisma.enrollment.count(),

      prisma.enrollment.count({ where: { isActive: true } }),

      prisma.enrollment.groupBy({
        by: ['courseId'],
        _count: { id: true },
        where: {},
      }).then(async (groups) => {
        const courseIds = groups.map((g) => g.courseId);
        const courses = await prisma.course.findMany({
          where: { id: { in: courseIds } },
          select: { id: true, title: true, category: true },
        });
        const activeGroups = await prisma.enrollment.groupBy({
          by: ['courseId'],
          _count: { id: true },
          where: { isActive: true },
        });
        const activeMap = new Map(activeGroups.map((g) => [g.courseId, g._count.id]));
        const courseMap = new Map(courses.map((c) => [c.id, c]));
        return groups
          .sort((a, b) => b._count.id - a._count.id)
          .map((g) => ({
            courseId: g.courseId,
            title: courseMap.get(g.courseId)?.title ?? 'Unknown',
            category: courseMap.get(g.courseId)?.category ?? null,
            enrollments: g._count.id,
            active: activeMap.get(g.courseId) ?? 0,
          }));
      }),

      prisma.userStats.aggregate({
        _sum: { totalSessions: true, totalWatchSeconds: true, totalSteps: true, totalCalories: true, currentStreak: true },
        _avg: { currentStreak: true },
        _count: { userId: true },
      }),

      prisma.userStats.aggregate({ _max: { longestStreak: true } }),

      prisma.userStats.count({ where: { currentStreak: { gt: 0 } } }),

      prisma.feedback.aggregate({ _avg: { rating: true }, _count: { id: true } }),

      prisma.feedback.groupBy({
        by: ['rating'],
        _count: { id: true },
        orderBy: { rating: 'asc' },
      }),

      prisma.appNotification.aggregate({ _count: { id: true }, _sum: { sentCount: true } }),

      prisma.notificationRead.count(),

      // Daily completions last 14 days
      prisma.dailyProgress.groupBy({
        by: ['dayDate'],
        _count: { id: true },
        where: { isComplete: true, dayDate: { gte: last14Days } },
        orderBy: { dayDate: 'asc' },
      }),

      // User registrations last 30 days
      prisma.profile.findMany({
        where: { createdAt: { gte: startOfMonth } },
        select: { createdAt: true },
        orderBy: { createdAt: 'asc' },
      }),
    ]);

    // Build last-14-days activity map
    const activityMap = new Map(
      dailyActivity.map((d) => [d.dayDate.toISOString().slice(0, 10), d._count.id])
    );
    const activityLast14Days = Array.from({ length: 14 }, (_, i) => {
      const d = new Date(last14Days);
      d.setDate(d.getDate() + i);
      const key = d.toISOString().slice(0, 10);
      return { date: key, completions: activityMap.get(key) ?? 0 };
    });

    // User growth: bucket by day
    const growthMap = new Map<string, number>();
    for (const p of userGrowth) {
      const key = p.createdAt.toISOString().slice(0, 10);
      growthMap.set(key, (growthMap.get(key) ?? 0) + 1);
    }
    const userGrowthLast30 = Array.from({ length: 30 }, (_, i) => {
      const d = new Date(startOfMonth);
      d.setDate(d.getDate() + i);
      const key = d.toISOString().slice(0, 10);
      return { date: key, count: growthMap.get(key) ?? 0 };
    });

    const ratingDist = [1, 2, 3, 4, 5].map((r) => ({
      rating: r,
      count: feedbackDistribution.find((f) => f.rating === r)?._count.id ?? 0,
    }));

    const totalDelivered = totalNotifications._sum.sentCount ?? 0;
    const openRate = totalDelivered > 0 ? Math.round((totalReadReceipts / totalDelivered) * 100) : 0;

    return NextResponse.json({
      users: {
        total: totalUsers,
        newThisWeek,
        newThisMonth,
      },
      enrollments: {
        total: totalEnrollments,
        active: activeEnrollments,
        byCourse: enrollmentsByCourse,
      },
      sessions: {
        totalCompleted: userStatsAgg._sum.totalSessions ?? 0,
        totalWatchHours: Math.round(((userStatsAgg._sum.totalWatchSeconds ?? 0) / 3600) * 10) / 10,
        totalSteps: userStatsAgg._sum.totalSteps ?? 0,
        totalCalories: Math.round(Number(userStatsAgg._sum.totalCalories ?? 0)),
      },
      streaks: {
        average: Math.round((userStatsAgg._avg.currentStreak ?? 0) * 10) / 10,
        max: maxStreak._max.longestStreak ?? 0,
        usersWithActiveStreak: usersWithStreak,
        totalTracked: userStatsAgg._count.userId,
      },
      feedback: {
        totalCount: feedbackAgg._count.id,
        averageRating: Math.round((feedbackAgg._avg.rating ?? 0) * 10) / 10,
        distribution: ratingDist,
      },
      notifications: {
        totalSent: totalNotifications._count.id,
        totalDelivered,
        totalReadReceipts,
        openRate,
      },
      activityLast14Days,
      userGrowthLast30,
    });
  } catch (error) {
    console.error('Analytics error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
