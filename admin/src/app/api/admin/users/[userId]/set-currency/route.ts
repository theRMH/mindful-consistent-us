import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ userId: string }> }
) {
  try {
    const { userId } = await params;
    const { currency } = await req.json();
    if (currency !== 'INR' && currency !== 'USD') {
      return NextResponse.json({ error: 'Invalid currency' }, { status: 400 });
    }
    await prisma.profile.update({ where: { id: userId }, data: { currency } });
    return NextResponse.json({ success: true });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
