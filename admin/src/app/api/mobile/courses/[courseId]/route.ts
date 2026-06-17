import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ courseId: string }> }
) {
  try {
    const { courseId } = await params;
    const course = await prisma.course.findUnique({
      where: { id: courseId },
      include: {
        courseDays: {
          orderBy: { dayNumber: 'asc' },
          include: {
            videos: {
              where: { isPublished: true },
              orderBy: { sortOrder: 'asc' },
            },
          },
        },
      },
    });

    if (!course) {
      return NextResponse.json({ error: 'Course not found' }, { status: 404 });
    }

    const totalSecs = course.courseDays.reduce(
      (sum, day) => sum + day.videos.reduce((s, v) => s + (v.durationSeconds ?? 0), 0),
      0,
    );
    const totalDays = course.totalDays > 0 ? course.totalDays : 1;
    const avgDailyMins = Math.max(5, Math.round((totalSecs / totalDays / 60) / 5) * 5);

    return NextResponse.json({ ...course, difficulty: course.difficulty ?? 'Beginner', avgDailyMins }, { status: 200 });
  } catch (error) {
    console.error('Error fetching mobile course details:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
