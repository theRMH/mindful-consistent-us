import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

const TOPICS = [
  { title: 'Asanas',    durationSeconds: 600,  youtubeVideoId: 'L_xrDAtykMI', thumbnailUrl: 'assets/icon_asana.png'  },
  { title: 'Pranayama', durationSeconds: 1200, youtubeVideoId: '2Sf1H_1Lkr8', thumbnailUrl: 'assets/icon_lungs.png' },
  { title: 'Kriya',     durationSeconds: 2100, youtubeVideoId: 's7WpC1sL0h8', thumbnailUrl: 'assets/icon_kriya.png' },
  { title: 'Pranayama', durationSeconds: 1200, youtubeVideoId: '2Sf1H_1Lkr8', thumbnailUrl: 'assets/icon_lungs.png' },
  { title: 'Kriya',     durationSeconds: 2100, youtubeVideoId: 's7WpC1sL0h8', thumbnailUrl: 'assets/icon_kriya.png' },
];

const COURSES = [
  { title: '30 Days Yoga Course', slug: '30-days-yoga', category: 'yoga', totalDays: 30, priceInr: 699,  thumbnailUrl: 'assets/course_30_days.png' },
  { title: '48 Days Yoga Course', slug: '48-days-yoga', category: 'yoga', totalDays: 48, priceInr: 899,  thumbnailUrl: 'assets/course_48_days.png' },
];

const FREE_VIDEOS = [
  { title: '5-min Morning Flow', youtubeVideoId: 'L_xrDAtykMI', durationSeconds: 495, thumbnailUrl: 'assets/video_morning_flow.png' },
  { title: 'Deep Sleep Prep',    youtubeVideoId: '2Sf1H_1Lkr8', durationSeconds: 495, thumbnailUrl: 'assets/video_sleep_prep.png'   },
  { title: 'Desk Neck Relief',   youtubeVideoId: 's7WpC1sL0h8', durationSeconds: 495, thumbnailUrl: 'assets/video_neck_relief.png'  },
];

const DEMO_LEADERBOARD_USERS = [
  { id: '00000000-0000-0000-0000-000000000001', fullName: 'Priya S',  streak: 21, daysCompleted: 21 },
  { id: '00000000-0000-0000-0000-000000000002', fullName: 'Arjun M',  streak: 15, daysCompleted: 18 },
  { id: '00000000-0000-0000-0000-000000000003', fullName: 'Divya R',  streak: 12, daysCompleted: 15 },
  { id: '00000000-0000-0000-0000-000000000004', fullName: 'Neha P',   streak: 8,  daysCompleted: 12 },
  { id: '00000000-0000-0000-0000-000000000005', fullName: 'Karan T',  streak: 6,  daysCompleted: 10 },
  { id: '00000000-0000-0000-0000-000000000006', fullName: 'Meera J',  streak: 5,  daysCompleted: 8  },
  { id: '00000000-0000-0000-0000-000000000007', fullName: 'Rahul G',  streak: 4,  daysCompleted: 7  },
];

const COMMUNITY_MOMENTS = [
  {
    name: 'Priya S',
    quote: 'This 15 mins of yoga every day changed the way I start my mornings',
    photoUrl: 'assets/community_priya.png',
    avatarUrl: 'assets/avatar_priya.png',
    streakDays: 21,
    sortOrder: 0,
  },
  {
    name: 'Rohit K',
    quote: 'I feel stronger, calmer and more focused than ever before',
    photoUrl: 'assets/community_rohit.png',
    avatarUrl: 'assets/avatar_rohit.png',
    streakDays: 14,
    sortOrder: 1,
  },
];

export async function POST() {
  try {
    const [courseCount, freeCount, momentCount, leaderboardCount] = await Promise.all([
      prisma.course.count(),
      prisma.freeVideo.count(),
      prisma.communityMoment.count(),
      prisma.leaderboardEntry.count({ where: { userId: { in: DEMO_LEADERBOARD_USERS.map(u => u.id) } } }),
    ]);

    let seededCourses = false;
    let seededFreeVideos = false;
    let seededMoments = false;
    let seededLeaderboard = false;

    if (courseCount === 0) {
      for (const courseData of COURSES) {
        const course = await prisma.course.create({
          data: {
            title:        courseData.title,
            slug:         courseData.slug,
            category:     courseData.category,
            totalDays:    courseData.totalDays,
            priceInr:     courseData.priceInr,
            thumbnailUrl: courseData.thumbnailUrl,
            isPublished:  true,
            description:  `A ${courseData.totalDays}-day yoga journey designed to build strength, flexibility and inner calm through daily practice.`,
          },
        });

        for (let day = 1; day <= courseData.totalDays; day++) {
          const courseDay = await prisma.courseDay.create({
            data: {
              courseId:    course.id,
              dayNumber:   day,
              title:       `Day ${day}`,
              description: `Day ${day} of your ${courseData.totalDays}-day journey.`,
            },
          });

          for (let i = 0; i < TOPICS.length; i++) {
            const topic = TOPICS[i];
            await prisma.video.create({
              data: {
                courseDayId:     courseDay.id,
                title:           topic.title,
                category:        courseData.category,
                durationSeconds: topic.durationSeconds,
                videoSource:     'youtube',
                youtubeVideoId:  topic.youtubeVideoId,
                thumbnailUrl:    topic.thumbnailUrl,
                sortOrder:       i,
                isFree:          false,
                isPublished:     true,
              },
            });
          }
        }
      }
      seededCourses = true;
    }

    if (freeCount === 0) {
      for (let i = 0; i < FREE_VIDEOS.length; i++) {
        const v = FREE_VIDEOS[i];
        await prisma.freeVideo.create({
          data: {
            title:           v.title,
            category:        'yoga',
            durationSeconds: v.durationSeconds,
            videoSource:     'youtube',
            youtubeVideoId:  v.youtubeVideoId,
            thumbnailUrl:    v.thumbnailUrl,
            sortOrder:       i,
            isPublished:     true,
          },
        });
      }
      seededFreeVideos = true;
    }

    if (momentCount === 0) {
      for (const m of COMMUNITY_MOMENTS) {
        await prisma.communityMoment.create({ data: m });
      }
      seededMoments = true;
    }

    if (leaderboardCount === 0) {
      // Get the first course to attach demo enrollments + entries to
      const firstCourse = await prisma.course.findFirst({ orderBy: { createdAt: 'asc' } });
      if (firstCourse) {
        for (const u of DEMO_LEADERBOARD_USERS) {
          const score = u.daysCompleted * 100 + u.streak * 10;
          // Upsert fake profile (demo users live outside Supabase auth — safe for display only)
          await prisma.profile.upsert({
            where: { id: u.id },
            create: { id: u.id, email: `demo-${u.id}@consistentus.internal`, fullName: u.fullName },
            update: { fullName: u.fullName },
          });
          // Upsert UserStats so streak shows correctly
          await prisma.userStats.upsert({
            where: { userId: u.id },
            create: { userId: u.id, currentStreak: u.streak, longestStreak: u.streak },
            update: { currentStreak: u.streak, longestStreak: u.streak },
          });
          // Create a demo enrollment
          const enrollment = await prisma.enrollment.create({
            data: {
              userId: u.id,
              courseId: firstCourse.id,
              isActive: true,
              paymentStatus: 'paid',
            },
          });
          // Create the leaderboard entry
          await prisma.leaderboardEntry.create({
            data: {
              userId: u.id,
              courseId: firstCourse.id,
              enrollmentId: enrollment.id,
              daysCompleted: u.daysCompleted,
              score,
            },
          });
        }
        seededLeaderboard = true;
      }
    }

    if (!seededCourses && !seededFreeVideos && !seededMoments && !seededLeaderboard) {
      return NextResponse.json({ message: 'Already seeded', courseCount, freeCount, momentCount, leaderboardCount });
    }

    return NextResponse.json({ success: true, seededCourses, seededFreeVideos, seededMoments, seededLeaderboard });
  } catch (error) {
    console.error('Seed error:', error);
    return NextResponse.json({ error: error instanceof Error ? error.message : 'Seed failed' }, { status: 500 });
  }
}
