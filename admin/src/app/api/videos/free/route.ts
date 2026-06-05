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
  } catch (error: any) {
    console.error('Error fetching free videos:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { title, description, category, durationSeconds, bunnyVideoId, bunnyLibraryId } = body;

    if (!title || !bunnyVideoId || !bunnyLibraryId) {
      return NextResponse.json({ error: 'Missing required fields (title, bunnyVideoId, bunnyLibraryId)' }, { status: 400 });
    }

    const freeVideo = await prisma.freeVideo.create({
      data: {
        title,
        description,
        category: category ?? 'general',
        durationSeconds: parseInt(durationSeconds || 0, 10),
        bunnyVideoId,
        bunnyLibraryId,
      },
    });

    return NextResponse.json(freeVideo, { status: 201 });
  } catch (error: any) {
    console.error('Error creating free video:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
