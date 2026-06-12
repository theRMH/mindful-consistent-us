import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function DELETE(
  _req: NextRequest,
  { params }: { params: { momentId: string } }
) {
  await prisma.communityMoment.delete({ where: { id: params.momentId } });
  return NextResponse.json({ success: true });
}

export async function PATCH(
  req: NextRequest,
  { params }: { params: { momentId: string } }
) {
  const body = await req.json();
  const moment = await prisma.communityMoment.update({
    where: { id: params.momentId },
    data: {
      ...(body.name !== undefined && { name: body.name }),
      ...(body.quote !== undefined && { quote: body.quote }),
      ...(body.photoUrl !== undefined && { photoUrl: body.photoUrl }),
      ...(body.avatarUrl !== undefined && { avatarUrl: body.avatarUrl }),
      ...(body.streakDays !== undefined && { streakDays: Number(body.streakDays) }),
      ...(body.isPublished !== undefined && { isPublished: body.isPublished }),
    },
  });
  return NextResponse.json(moment);
}
