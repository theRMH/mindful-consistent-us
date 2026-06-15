import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET() {
  try {
    const moments = await prisma.communityMoment.findMany({
      where: { isPublished: true },
      orderBy: { sortOrder: 'asc' },
    });
    return NextResponse.json(moments);
  } catch {
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
