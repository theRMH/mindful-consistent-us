import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

function dicebearUrl(seed: string) {
  const s = encodeURIComponent(seed.trim() || 'user');
  return `https://api.dicebear.com/7.x/thumbs/svg?seed=${s}&radius=50`;
}

export async function POST() {
  try {
    const profiles = await prisma.profile.findMany({
      where: { OR: [{ avatarUrl: null }, { avatarUrl: '' }] },
      select: { id: true, fullName: true, phone: true },
    });

    const updated: string[] = [];
    for (const p of profiles) {
      const seed = p.fullName || p.phone || p.id;
      const avatarUrl = dicebearUrl(seed);
      await prisma.profile.update({ where: { id: p.id }, data: { avatarUrl } });
      updated.push(`${p.fullName || p.phone || p.id} -> ${avatarUrl}`);
    }

    return NextResponse.json({ count: updated.length, updated }, { status: 200 });
  } catch (error) {
    console.error('Avatar backfill error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
