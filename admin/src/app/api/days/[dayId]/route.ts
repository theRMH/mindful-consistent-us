import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ dayId: string }> }
) {
  try {
    const { dayId } = await params;
    const { title, description } = await req.json();

    const updated = await prisma.courseDay.update({
      where: { id: dayId },
      data: { title, description },
    });

    return NextResponse.json(updated, { status: 200 });
  } catch (error) {
    console.error('Error updating course day:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ dayId: string }> }
) {
  try {
    const { dayId } = await params;

    await prisma.courseDay.delete({ where: { id: dayId } });

    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error) {
    console.error('Error deleting course day:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
