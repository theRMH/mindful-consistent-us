import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET() {
  try {
    const courses = await prisma.course.findMany({
      where: {
        isPublished: true,
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    return NextResponse.json(courses, { status: 200 });
  } catch (error) {
    console.error('Error fetching courses:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { title, slug, description, thumbnailUrl, category, totalDays, priceInr, isPublished } = body;

    if (!title || !slug || !totalDays) {
      return NextResponse.json({ error: 'Missing required fields (title, slug, totalDays)' }, { status: 400 });
    }

    const course = await prisma.course.create({
      data: {
        title,
        slug,
        description,
        thumbnailUrl,
        category: category ?? null,
        totalDays: parseInt(totalDays, 10),
        priceInr: parseFloat(priceInr || 0),
        isPublished: isPublished ?? false,
      },
    });

    return NextResponse.json(course, { status: 201 });
  } catch (error) {
    console.error('Error creating course:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
