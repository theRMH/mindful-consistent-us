import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json().catch(() => ({}));
    const { userId } = body;

    if (!userId) {
      return NextResponse.json({ error: "Missing userId" }, { status: 400 });
    }

    // Verify user exists
    const profile = await prisma.profile.findUnique({ where: { id: userId } });
    if (!profile) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    // Delete progress history and reset aggregate stats for this user.
    await prisma.$transaction([
      prisma.videoProgress.deleteMany({ where: { userId } }),
      prisma.dailyProgress.deleteMany({ where: { userId } }),
      prisma.leaderboardEntry.deleteMany({ where: { userId } }),
      prisma.userStats.upsert({
        where: { userId },
        update: {
          totalWatchSeconds: 0,
          totalSessions: 0,
          totalCalories: 0,
          totalSteps: 0,
          currentStreak: 0,
          longestStreak: 0,
          updatedAt: new Date(),
        },
        create: {
          userId,
          totalWatchSeconds: 0,
          totalSessions: 0,
          totalCalories: 0,
          totalSteps: 0,
          currentStreak: 0,
          longestStreak: 0,
        },
      }),
    ]);

    return NextResponse.json({ success: true, userId }, { status: 200 });
  } catch (error) {
    console.error("Error resetting progress:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 },
    );
  }
}
