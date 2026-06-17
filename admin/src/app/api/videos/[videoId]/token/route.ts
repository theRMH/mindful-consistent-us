import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';
import { isDayUnlocked } from '@/lib/day-lock';
import { generateBunnyToken } from '@/lib/bunny';

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ videoId: string }> }
) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { videoId } = await params;

    // Fetch video details
    const video = await prisma.video.findUnique({
      where: { id: videoId },
      include: {
        courseDay: true,
      },
    });

    if (!video) {
      return NextResponse.json({ error: 'Video not found' }, { status: 404 });
    }

    // Verify access
    if (!video.isFree) {
      if (!video.courseDay) {
        return NextResponse.json({ error: 'Unlinked premium video' }, { status: 400 });
      }

      // Check if course day is unlocked for the user
      const unlocked = await isDayUnlocked(user.id, video.courseDay.courseId, video.courseDay.dayNumber);
      if (!unlocked) {
        return NextResponse.json({ error: 'Locked content' }, { status: 403 });
      }
    }

    if (!video.bunnyVideoId || !video.bunnyLibraryId) {
      return NextResponse.json({ error: 'Video has no Bunny.net source' }, { status: 400 });
    }

    // Generate signed token parameters for Bunny.net Stream
    const { token, expires } = generateBunnyToken(video.bunnyVideoId);

    // Construct signed streaming URL
    const streamUrl = `https://iframe.mediadelivery.net/embed/${video.bunnyLibraryId}/${video.bunnyVideoId}?token=${token}&expires=${expires}`;

    return NextResponse.json({
      videoId: video.id,
      bunnyVideoId: video.bunnyVideoId,
      bunnyLibraryId: video.bunnyLibraryId,
      streamUrl,
      expires,
    }, { status: 200 });
  } catch (error) {
    console.error('Error generating streaming token:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
