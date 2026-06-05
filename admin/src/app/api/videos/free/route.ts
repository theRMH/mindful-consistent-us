import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    const freeVideos = await prisma.freeVideo.findMany({
      where: {
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
