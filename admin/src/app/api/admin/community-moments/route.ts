import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET() {
  const moments = await prisma.communityMoment.findMany({
    orderBy: { sortOrder: 'asc' },
  });
  return NextResponse.json(moments);
}

export async function POST(req: NextRequest) {
  const { name, quote, photoUrl, avatarUrl, streakDays, sortOrder } = await req.json();
  if (!name || !quote) {
    return NextResponse.json({ error: 'name and quote are required' }, { status: 400 });
  }
  const moment = await prisma.communityMoment.create({
    data: {
      name,
      quote,
      photoUrl: photoUrl || null,
      avatarUrl: avatarUrl || null,
      streakDays: Number(streakDays) || 0,
      sortOrder: Number(sortOrder) || 0,
      isPublished: true,
    },
  });
  return NextResponse.json(moment, { status: 201 });
}
