import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import '@/lib/firebase-admin';
import { getMessaging } from 'firebase-admin/messaging';

export async function GET(req: NextRequest) {
  const authHeader = req.headers.get('Authorization');
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    // Compute current IST hour (UTC+5:30)
    const now = new Date();
    const istMinutes = (now.getUTCHours() * 60 + now.getUTCMinutes() + 330) % 1440;
    const istHour = Math.floor(istMinutes / 60);
    const hourPrefix = String(istHour).padStart(2, '0');

    const users = await prisma.profile.findMany({
      where: {
        notificationsEnabled: true,
        fcmToken: { not: null },
        notificationTime: { startsWith: hourPrefix },
      },
      select: { fcmToken: true },
    });

    if (users.length === 0) {
      return NextResponse.json({ sent: 0, hour: hourPrefix });
    }

    const tokens = users.map((u) => u.fcmToken!).filter(Boolean);
    const messaging = getMessaging();
    let successCount = 0;
    let failureCount = 0;

    const CHUNK = 500;
    for (let i = 0; i < tokens.length; i += CHUNK) {
      const chunk = tokens.slice(i, i + CHUNK);
      const result = await messaging.sendEachForMulticast({
        tokens: chunk,
        notification: {
          title: "Time for today's practice! 🧘",
          body: "Don't break your streak — your session is waiting.",
        },
        android: {
          notification: { channelId: 'daily_reminder', priority: 'high' },
        },
        apns: {
          payload: { aps: { sound: 'default', badge: 1 } },
        },
      });
      successCount += result.successCount;
      failureCount += result.failureCount;
    }

    return NextResponse.json({ sent: successCount, failed: failureCount, hour: hourPrefix });
  } catch (error) {
    console.error('Cron daily-reminders error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
