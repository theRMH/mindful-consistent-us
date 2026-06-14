import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET() {
  const row = await prisma.helpContent.findUnique({ where: { id: 'singleton' } });
  return NextResponse.json({ content: row?.content ?? '' });
}

export async function PUT(req: NextRequest) {
  const { content } = await req.json().catch(() => ({ content: '' }));

  const row = await prisma.helpContent.upsert({
    where: { id: 'singleton' },
    update: { content, updatedAt: new Date() },
    create: { id: 'singleton', content },
  });

  return NextResponse.json({ content: row.content });
}
