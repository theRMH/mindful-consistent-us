import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    const phone = req.nextUrl.searchParams.get('phone');
    if (!phone) {
      return NextResponse.json({ error: 'phone is required' }, { status: 400 });
    }

    const profile = await prisma.profile.findFirst({
      where: { phone },
      select: { id: true },
    });

    return NextResponse.json({ exists: profile !== null }, { status: 200 });
  } catch (error) {
    console.error('Error checking phone:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
