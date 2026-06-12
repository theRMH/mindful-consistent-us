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
              orderBy: { sortOrder: 'asc' }
            }
          }
        }
      }
    });

    if (!course) {
      return NextResponse.json({ error: 'Course not found' }, { status: 404 });
    }

    return NextResponse.json(course, { status: 200 });
  } catch (error: any) {
    console.error('Error fetching course details:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

// POST endpoint to add a Day or Session Video
export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ courseId: string }> }
) {
  try {
    const { courseId } = await params;
    const body = await req.json();
    const { action } = body; // 'add_day' or 'add_video'

    if (action === 'add_day') {
      const { dayNumber, title, description } = body;
      if (!dayNumber) {
        return NextResponse.json({ error: 'Missing day number' }, { status: 400 });
      }

      const courseDay = await prisma.courseDay.create({
        data: {
          courseId,
          dayNumber: parseInt(dayNumber, 10),
          title: title ?? '',
          description: description ?? '',
        }
      });
      return NextResponse.json(courseDay, { status: 201 });
    }

    if (action === 'add_video') {
      const { courseDayId, title, category, durationSeconds, bunnyVideoId, bunnyLibraryId, youtubeVideoId, videoSource, isFree } = body;
      const source = videoSource || 'bunny';

      if (!courseDayId || !title) {
        return NextResponse.json({ error: 'Missing required video fields (courseDayId, title)' }, { status: 400 });
      }

      if (source === 'bunny' && (!bunnyVideoId || !bunnyLibraryId)) {
        return NextResponse.json({ error: 'Bunny Video ID and Library ID are required for Bunny source' }, { status: 400 });
      }

      if (source === 'youtube' && !youtubeVideoId) {
        return NextResponse.json({ error: 'YouTube Video ID is required for YouTube source' }, { status: 400 });
      }

      const video = await prisma.video.create({
        data: {
          courseDayId,
          title,
          category: category ?? 'yoga',
          durationSeconds: parseInt(durationSeconds || 0, 10),
          videoSource: source,
          bunnyVideoId: source === 'bunny' ? bunnyVideoId : null,
          bunnyLibraryId: source === 'bunny' ? bunnyLibraryId : null,
          youtubeVideoId: source === 'youtube' ? youtubeVideoId : null,
          isFree: isFree ?? false,
        }
      });
      return NextResponse.json(video, { status: 201 });
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 });
  } catch (error: any) {
    console.error('Error processing course builder update:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

// PATCH endpoint to update course metadata
export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ courseId: string }> }
) {
  try {
    const { courseId } = await params;
    const body = await req.json();
    const { title, slug, description, priceInr, totalDays, isPublished, thumbnailUrl, category } = body;

    const updated = await prisma.course.update({
      where: { id: courseId },
      data: {
        title,
        slug,
        description,
        priceInr: priceInr !== undefined ? parseFloat(priceInr) : undefined,
        totalDays: totalDays !== undefined ? parseInt(totalDays, 10) : undefined,
        isPublished: isPublished !== undefined ? isPublished : undefined,
        thumbnailUrl,
        category: category !== undefined ? category : undefined,
      },
    });

    return NextResponse.json(updated, { status: 200 });
  } catch (error: any) {
    console.error('Error updating course details:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

// DELETE endpoint to remove a course
export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ courseId: string }> }
) {
  try {
    const { courseId } = await params;

    await prisma.course.delete({
      where: { id: courseId },
    });

    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error: any) {
    console.error('Error deleting course:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
