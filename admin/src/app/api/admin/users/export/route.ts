import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const courseId = searchParams.get('courseId') || undefined;
    const dateFrom = searchParams.get('dateFrom') || undefined;
    const dateTo = searchParams.get('dateTo') || undefined;

    const enrollmentFilter = courseId ? { some: { courseId } } : undefined;
    const joinedFilter =
      dateFrom || dateTo
        ? {
            gte: dateFrom ? new Date(dateFrom) : undefined,
            lte: dateTo ? new Date(dateTo + 'T23:59:59Z') : undefined,
          }
        : undefined;

    const profiles = await prisma.profile.findMany({
      where: {
        ...(enrollmentFilter ? { enrollments: enrollmentFilter } : {}),
        ...(joinedFilter ? { createdAt: joinedFilter } : {}),
      },
      include: {
        userStats: true,
        enrollments: {
          include: { course: { select: { title: true } } },
          ...(courseId ? { where: { courseId } } : {}),
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 1000,
    });

    const cell = (val: unknown) => `"${String(val ?? '').replace(/"/g, '""')}"`;

    const headers = [
      'Name', 'Email', 'Phone', 'Currency', 'Current Streak', 'Longest Streak',
      'Total Steps', 'Total Minutes', 'Enrolled Programs', 'Joined',
    ];

    const rows = profiles.map((p) => [
      cell(p.fullName || ''),
      cell(p.email),
      cell(p.phone || ''),
      cell(p.currency || 'INR'),
      cell(p.userStats?.currentStreak ?? 0),
      cell(p.userStats?.longestStreak ?? 0),
      cell(p.userStats?.totalSteps ?? 0),
      cell(Math.round((p.userStats?.totalWatchSeconds ?? 0) / 60)),
      cell(p.enrollments.map((e) => e.course.title).join('; ')),
      cell(new Date(p.createdAt).toLocaleDateString('en-IN')),
    ]);

    const csv = [headers.map(cell), ...rows].map((r) => r.join(',')).join('\n');

    return new NextResponse(csv, {
      headers: {
        'Content-Type': 'text/csv; charset=utf-8',
        'Content-Disposition': `attachment; filename="users-${new Date().toISOString().slice(0, 10)}.csv"`,
      },
    });
  } catch (error) {
    console.error('Export error:', error);
    return NextResponse.json({ error: 'Export failed' }, { status: 500 });
  }
}
