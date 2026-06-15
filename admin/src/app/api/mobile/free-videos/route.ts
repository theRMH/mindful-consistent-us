import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET() {
  try {
    const freeVideos = await prisma.freeVideo.findMany({
      where: { isPublished: true },
      orderBy: { sortOrder: 'asc' },
    });
    return NextResponse.json(freeVideos, { status: 200 });
  } catch (error) {
    console.error('Error fetching mobile free videos:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
