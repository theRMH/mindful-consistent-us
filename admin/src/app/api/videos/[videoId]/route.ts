import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ videoId: string }> }
) {
  try {
    const { videoId } = await params;
    const body = await req.json();
    const { title, description, category, durationSeconds, videoSource, bunnyVideoId, bunnyLibraryId, youtubeVideoId, isFree } = body;

    const updated = await prisma.video.update({
      where: { id: videoId },
      data: {
        title,
        description: description !== undefined ? description : undefined,
        category,
        durationSeconds: durationSeconds !== undefined ? parseInt(durationSeconds, 10) : undefined,
        videoSource,
        bunnyVideoId: videoSource === 'bunny' ? bunnyVideoId : null,
        bunnyLibraryId: videoSource === 'bunny' ? bunnyLibraryId : null,
        youtubeVideoId: videoSource === 'youtube' ? youtubeVideoId : null,
        isFree: isFree !== undefined ? isFree : undefined,
      },
    });

    return NextResponse.json(updated, { status: 200 });
  } catch (error) {
    console.error('Error updating video:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ videoId: string }> }
) {
  try {
    const { videoId } = await params;
    await prisma.video.delete({ where: { id: videoId } });
    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error) {
    console.error('Error deleting video:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
