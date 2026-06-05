import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { verifyAuth } from '@/lib/auth-middleware';

export async function POST(req: NextRequest) {
  try {
    const user = await verifyAuth(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await req.json();
    const { targetType, targetId, rating, comment } = body;

    if (!targetType || rating === undefined) {
      return NextResponse.json({ error: 'Missing required fields (targetType, rating)' }, { status: 400 });
    }

    const parsedRating = parseInt(rating, 10);
    if (isNaN(parsedRating) || parsedRating < 1 || parsedRating > 5) {
      return NextResponse.json({ error: 'Rating must be an integer between 1 and 5' }, { status: 400 });
    }

    const feedback = await prisma.feedback.create({
      data: {
        userId: user.id,
        targetType,
        targetId: targetId || null,
        rating: parsedRating,
        comment: comment || '',
      },
    });

    return NextResponse.json(feedback, { status: 201 });
  } catch (error: any) {
    console.error('Error creating feedback:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
