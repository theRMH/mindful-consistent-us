import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const body = await req.json();
    const { title, description, category, durationSeconds, bunnyVideoId, bunnyLibraryId, youtubeVideoId, videoSource, sortOrder, isPublished } = body;
    const source = videoSource || 'bunny';

    if (!title) {
      return NextResponse.json({ error: 'Missing required field: title' }, { status: 400 });
    }

    if (source === 'bunny' && (!bunnyVideoId || !bunnyLibraryId)) {
      return NextResponse.json({ error: 'Bunny Video ID and Library ID are required for Bunny source' }, { status: 400 });
    }

    if (source === 'youtube' && !youtubeVideoId) {
      return NextResponse.json({ error: 'YouTube Video ID is required for YouTube source' }, { status: 400 });
    }

    const updated = await prisma.freeVideo.update({
      where: { id },
      data: {
        title,
        description,
        category: category ?? 'general',
        durationSeconds: parseInt(durationSeconds || 0, 10),
        videoSource: source,
        bunnyVideoId: source === 'bunny' ? bunnyVideoId : null,
        bunnyLibraryId: source === 'bunny' ? bunnyLibraryId : null,
        youtubeVideoId: source === 'youtube' ? youtubeVideoId : null,
        sortOrder: parseInt(sortOrder || 0, 10),
        isPublished: isPublished ?? true,
      },
    });

    return NextResponse.json(updated, { status: 200 });
  } catch (error: any) {
    console.error('Error updating free video:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    await prisma.freeVideo.delete({
      where: { id },
    });

    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error: any) {
    console.error('Error deleting free video:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
