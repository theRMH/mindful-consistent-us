import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { getFirebaseAdmin } from '@/lib/firebase-admin';

export async function GET() {
  const notifications = await prisma.appNotification.findMany({
    orderBy: { sentAt: 'desc' },
    take: 100,
    select: {
      id: true,
      title: true,
      body: true,
      type: true,
      targetType: true,
      segmentRule: true,
      redirectUrl: true,
      sentAt: true,
      sentCount: true,
    },
  });
  return NextResponse.json(notifications);
}

export async function POST(req: NextRequest) {
  try {
    const { title, body, type, targetType, segmentRule, redirectUrl } = await req.json();

    if (!title || !body) {
      return NextResponse.json({ error: 'title and body required' }, { status: 400 });
    }

    // Build target FCM token list based on segment rule
    const tokens = await resolveTargetTokens(targetType, segmentRule);

    // Save notification record first
    const notification = await prisma.appNotification.create({
      data: {
        title,
        body,
        type: type ?? 'announcement',
        targetType: targetType ?? 'all',
        segmentRule: segmentRule ?? undefined,
        redirectUrl: redirectUrl ?? undefined,
        sentCount: tokens.length,
      },
    });

    // Send via Firebase if configured and there are tokens
    let firebaseResult: { successCount: number; failureCount: number } = { successCount: 0, failureCount: 0 };
    if (tokens.length > 0) {
      try {
        const admin = getFirebaseAdmin();
        if (admin) {
          const messaging = admin.messaging();
          const CHUNK = 500; // FCM multicast limit
          for (let i = 0; i < tokens.length; i += CHUNK) {
            const chunk = tokens.slice(i, i + CHUNK);
            const response = await messaging.sendEachForMulticast({
              tokens: chunk,
              notification: { title, body },
              data: redirectUrl ? { redirectUrl } : {},
              android: { priority: 'high' },
              apns: { payload: { aps: { sound: 'default' } } },
            });
            firebaseResult.successCount += response.successCount;
            firebaseResult.failureCount += response.failureCount;
          }
        }
      } catch (fbErr) {
        console.error('Firebase send error (notification saved):', fbErr);
      }
    }

    return NextResponse.json({
      id: notification.id,
      sentCount: tokens.length,
      firebaseResult,
    });
  } catch (err: any) {
    console.error('Error sending notification:', err);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

async function resolveTargetTokens(
  targetType: string,
  segmentRule: any
): Promise<string[]> {
  let profiles: { fcmToken: string | null }[] = [];

  if (targetType === 'all') {
    profiles = await prisma.profile.findMany({
      where: { fcmToken: { not: null } },
      select: { fcmToken: true },
    });
  } else if (targetType === 'segment' && segmentRule) {
    if (segmentRule.type === 'missed_days') {
      // Users who have not completed a day in the last N days
      const days = segmentRule.value ?? 2;
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - days);

      const activeUsers = await prisma.dailyProgress.groupBy({
        by: ['userId'],
        where: { isComplete: true, dayDate: { gte: cutoff } },
      });
      const activeUserIds = new Set(activeUsers.map((u) => u.userId));

      profiles = await prisma.profile.findMany({
        where: {
          fcmToken: { not: null },
          enrollments: { some: { isActive: true } },
          id: { notIn: [...activeUserIds] },
        },
        select: { fcmToken: true },
      });
    } else if (segmentRule.type === 'streak') {
      // Users with streak >= N days
      const minStreak = segmentRule.value ?? 3;
      const stats = await prisma.userStats.findMany({
        where: { currentStreak: { gte: minStreak } },
        select: { userId: true },
      });
      const ids = stats.map((s) => s.userId);
      profiles = await prisma.profile.findMany({
        where: { id: { in: ids }, fcmToken: { not: null } },
        select: { fcmToken: true },
      });
    } else if (segmentRule.type === 'course' && segmentRule.courseId) {
      // Users enrolled in a specific course
      const enrollments = await prisma.enrollment.findMany({
        where: { courseId: segmentRule.courseId, isActive: true },
        select: { userId: true },
      });
      const ids = enrollments.map((e) => e.userId);
      profiles = await prisma.profile.findMany({
        where: { id: { in: ids }, fcmToken: { not: null } },
        select: { fcmToken: true },
      });
    }
  }

  return profiles.map((p) => p.fcmToken!).filter(Boolean);
}
