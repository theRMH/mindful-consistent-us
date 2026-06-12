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

export async function POST() {
  try {
    const existing = await prisma.course.count();
    if (existing > 0) {
      return NextResponse.json({ message: 'Already seeded', count: existing });
    }

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
            courseId:  course.id,
            dayNumber: day,
            title:     `Day ${day}`,
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

    // Seed free videos
    const freeCount = await prisma.freeVideo.count();
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
    }

    return NextResponse.json({ success: true, message: 'Demo data seeded successfully.' });
  } catch (error: any) {
    console.error('Seed error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
