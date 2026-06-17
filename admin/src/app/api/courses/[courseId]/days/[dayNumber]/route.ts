import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';
import { isDayUnlocked } from '@/lib/day-lock';

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ courseId: string; dayNumber: string }> }
) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { courseId, dayNumber } = await params;
    const parsedDayNumber = parseInt(dayNumber, 10);

    if (isNaN(parsedDayNumber)) {
      return NextResponse.json({ error: 'Invalid day number' }, { status: 400 });
    }

    // Check Day-Lock rules
    const unlocked = await isDayUnlocked(user.id, courseId, parsedDayNumber);
    if (!unlocked) {
      return NextResponse.json({ 
        error: 'Locked', 
        message: `Day ${parsedDayNumber} is locked. Show up daily to unlock new content.` 
      }, { status: 403 });
    }

    // Fetch course day content
    const courseDay = await prisma.courseDay.findFirst({
      where: {
        courseId,
        dayNumber: parsedDayNumber,
      },
      include: {
        videos: {
          where: {
            isPublished: true,
          },
          orderBy: {
            sortOrder: 'asc',
          },
        },
      },
    });

    if (!courseDay) {
      return NextResponse.json({ error: 'Day content not found' }, { status: 404 });
    }

    return NextResponse.json(courseDay, { status: 200 });
  } catch (error) {
    console.error('Error fetching day content:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
