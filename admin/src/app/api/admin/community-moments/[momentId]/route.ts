import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function DELETE(
  _req: NextRequest,
  { params }: { params: Promise<{ momentId: string }> }
) {
  const { momentId } = await params;
  await prisma.communityMoment.delete({ where: { id: momentId } });
  return NextResponse.json({ success: true });
}

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ momentId: string }> }
) {
  const { momentId } = await params;
  const body = await req.json();
  const moment = await prisma.communityMoment.update({
    where: { id: momentId },
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
