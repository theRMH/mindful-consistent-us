import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const body = await req.json();
    const { title, description, category, durationSeconds, bunnyVideoId, bunnyLibraryId, sortOrder, isPublished } = body;

    if (!title || !bunnyVideoId || !bunnyLibraryId) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
    }

    const updated = await prisma.freeVideo.update({
      where: { id },
      data: {
        title,
        description,
        category: category ?? 'general',
        durationSeconds: parseInt(durationSeconds || 0, 10),
        bunnyVideoId,
        bunnyLibraryId,
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
