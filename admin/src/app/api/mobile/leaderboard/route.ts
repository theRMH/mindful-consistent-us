import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function GET(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    const userId = user?.id ?? null;

    const courseId = req.nextUrl.searchParams.get('courseId') ?? undefined;

    const entries = await prisma.leaderboardEntry.findMany({
      where: courseId ? { courseId } : undefined,
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
    if (userId) {
      const userPositionIndex = entries.findIndex(e => e.userId === userId);
      userRank = userPositionIndex >= 0 ? userPositionIndex + 1 : null;
    }

    return NextResponse.json({ entries: top10, userRank }, { status: 200 });
  } catch (error) {
    console.error('Error fetching mobile leaderboard:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
