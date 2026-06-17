import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const all = searchParams.get('all') === 'true';

    const freeVideos = await prisma.freeVideo.findMany({
      where: all ? {} : {
        isPublished: true,
      },
      orderBy: {
        sortOrder: 'asc',
      },
    });

    return NextResponse.json(freeVideos, { status: 200 });
  } catch (error) {
    console.error('Error fetching free videos:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
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

    const freeVideo = await prisma.freeVideo.create({
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

    return NextResponse.json(freeVideo, { status: 201 });
  } catch (error) {
    console.error('Error creating free video:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
