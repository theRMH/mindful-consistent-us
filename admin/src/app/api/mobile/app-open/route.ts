import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

    const today = new Date();
    const todayDate = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate()),
    );
    const yesterdayDate = new Date(todayDate.getTime() - 86400000);

    const userStats = await prisma.userStats.findUnique({ where: { userId: user.id } });
    if (!userStats || userStats.currentStreak === 0) {
      return NextResponse.json({ streak: userStats?.currentStreak ?? 0 });
    }

    // If streak > 0, check whether it should be reset (no activity yesterday or today)
    const recentActivity = await prisma.dailyProgress.findFirst({
      where: {
        userId: user.id,
        videosWatched: { gt: 0 },
        dayDate: { gte: yesterdayDate },
      },
    });

    if (!recentActivity) {
      // No activity yesterday or today — streak is broken
      await prisma.userStats.update({
        where: { userId: user.id },
        data: { currentStreak: 0 },
      });
      return NextResponse.json({ streak: 0, streakReset: true });
    }

    return NextResponse.json({ streak: userStats.currentStreak });
  } catch (error) {
    console.error('app-open error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
