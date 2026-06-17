import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET() {
  try {
    const courses = await prisma.course.findMany({
      where: {
        isPublished: true,
        courseDays: {
          some: {
            videos: { some: { isPublished: true } },
          },
        },
      },
      orderBy: { createdAt: 'asc' },
      include: {
        courseDays: {
          include: {
            videos: { select: { durationSeconds: true } },
          },
        },
      },
    });

    const result = courses.map((course) => {
      const totalSecs = course.courseDays.reduce(
        (sum, day) => sum + day.videos.reduce((s, v) => s + (v.durationSeconds ?? 0), 0),
        0,
      );
      const totalDays = course.totalDays > 0 ? course.totalDays : 1;
      const avgSecsPerDay = totalSecs / totalDays;
      const avgMinsRaw = avgSecsPerDay / 60;
      // Round to nearest 5 minutes (min 5m)
      const avgDailyMins = Math.max(5, Math.round(avgMinsRaw / 5) * 5);

      return {
        id: course.id,
        title: course.title,
        slug: course.slug,
        description: course.description,
        thumbnailUrl: course.thumbnailUrl,
        category: course.category,
        difficulty: course.difficulty ?? 'Beginner',
        totalDays: course.totalDays,
        priceInr: course.priceInr,
        avgDailyMins,
      };
    });

    return NextResponse.json(result, { status: 200 });
  } catch (error) {
    console.error('Error fetching mobile courses:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
