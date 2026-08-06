import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function GET(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    const userId = user?.id ?? null;

    const courseId = req.nextUrl.searchParams.get('courseId') ?? undefined;
    const period = req.nextUrl.searchParams.get('period') ?? 'all';

    const now = new Date();
    let since: Date | undefined;
    if (period === 'week') {
      since = new Date(now);
      since.setDate(since.getDate() - 7);
    } else if (period === 'month') {
      since = new Date(now);
      since.setMonth(since.getMonth() - 1);
    }

    const entries = await prisma.leaderboardEntry.findMany({
      where: {
        ...(courseId ? { courseId } : {}),
        ...(since ? { updatedAt: { gte: since } } : {}),
      },
      orderBy: { score: 'desc' },
      distinct: ['userId'],
      take: 50,
      include: {
        user: {
          select: {
            email: true,
            fullName: true,
            avatarUrl: true,
            userStats: { select: { currentStreak: true } },
          },
        },
      },
    });

    const top10 = entries.slice(0, 10).map((e, i) => ({
      rank: i + 1,
      userId: e.userId,
      name: e.user.fullName || e.user.email?.split('@')[0] || 'User',
      avatarUrl: e.user.avatarUrl ?? '',
      streak: e.user.userStats?.currentStreak ?? 0,
      score: Number(e.score),
      daysCompleted: e.daysCompleted,
      isCurrentUser: e.userId === userId,
    }));

    let userRank: number | null = null;
    let currentUserEntry: object | null = null;
    if (userId) {
      const userPositionIndex = entries.findIndex(e => e.userId === userId);
      if (userPositionIndex >= 0) {
        userRank = userPositionIndex + 1;
        if (userPositionIndex >= 10) {
          const e = entries[userPositionIndex];
          currentUserEntry = {
            rank: userRank,
            userId: e.userId,
            name: e.user.fullName || e.user.email?.split('@')[0] || 'User',
            avatarUrl: e.user.avatarUrl ?? '',
            streak: e.user.userStats?.currentStreak ?? 0,
            score: Number(e.score),
            daysCompleted: e.daysCompleted,
            isCurrentUser: true,
          };
        }
      }
    }

    return NextResponse.json({ entries: top10, userRank, currentUserEntry }, { status: 200 });
  } catch (error) {
    console.error('Error fetching mobile leaderboard:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
