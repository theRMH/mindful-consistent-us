const { Pool } = require('pg');
const { PrismaPg } = require('@prisma/adapter-pg');
const { PrismaClient } = require('@prisma/client');
const dotenv = require('dotenv');

dotenv.config();

const connectionString = process.env.DIRECT_URL || process.env.DATABASE_URL;
if (!connectionString) {
  throw new Error('Missing database connection string in environment');
}

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Seeding database with courses, days, and videos...');

  // 1. Create Courses
  const coursesData = [
    {
      title: '30 Days Yoga Course',
      slug: '30-days-yoga',
      description: 'Wake up your body and mind with this 30-day mobility routine. Designed to improve your flexibility, reduce stiffness, and start your day with renewed focus.',
      thumbnailUrl: '',
      totalDays: 30,
      priceInr: 699.00,
      isPublished: true
    },
    {
      title: '48 Days Yoga Course',
      slug: '48-days-yoga',
      description: 'Deepen your practice with our intensive 48-day advanced yoga transformation program.',
      thumbnailUrl: '',
      totalDays: 48,
      priceInr: 899.00,
      isPublished: true
    },
    {
      title: '21 Days Yoga Course',
      slug: '21-days-yoga',
      description: 'A moderate 21-day program to build daily consistency and improve core strength.',
      thumbnailUrl: '',
      totalDays: 21,
      priceInr: 499.00,
      isPublished: true
    },
    {
      title: '100 Days Yoga Course',
      slug: '100-days-yoga',
      description: 'The ultimate discipline challenge: 100 days of daily continuous training and flow state yoga.',
      thumbnailUrl: '',
      totalDays: 100,
      priceInr: 1299.00,
      isPublished: true
    }
  ];

  for (const c of coursesData) {
    const course = await prisma.course.upsert({
      where: { slug: c.slug },
      update: c,
      create: c
    });
    console.log(`Upserted course: ${course.title} (ID: ${course.id})`);

    // 2. Add Day 1, 2, 3, 4 for the 30-day course
    if (c.slug === '30-days-yoga') {
      const days = [1, 2, 3, 4];
      for (const dayNum of days) {
        const courseDay = await prisma.courseDay.upsert({
          where: {
            courseId_dayNumber: {
              courseId: course.id,
              dayNumber: dayNum
            }
          },
          update: {
            title: `Day ${dayNum}: Foundation Flow`,
            description: `Guided yoga focus session for day ${dayNum}.`
          },
          create: {
            courseId: course.id,
            dayNumber: dayNum,
            title: `Day ${dayNum}: Foundation Flow`,
            description: `Guided yoga focus session for day ${dayNum}.`
          }
        });
        console.log(`  Upserted Day ${dayNum} (ID: ${courseDay.id})`);

        // 3. Add a premium video to this day
        await prisma.video.upsert({
          where: { id: `00000000-0000-0000-0000-00000000000${dayNum}` },
          update: {
            courseDayId: courseDay.id,
            title: `Morning Mobility Session ${dayNum}`,
            description: 'Focus on breath, alignment, and gentle core muscle stretch.',
            category: 'yoga',
            durationSeconds: 1200, // 20 mins
            bunnyVideoId: `mock_video_${dayNum}`,
            bunnyLibraryId: 'mock_lib_123',
            isFree: false,
            isPublished: true
          },
          create: {
            id: `00000000-0000-0000-0000-00000000000${dayNum}`,
            courseDayId: courseDay.id,
            title: `Morning Mobility Session ${dayNum}`,
            description: 'Focus on breath, alignment, and gentle core muscle stretch.',
            category: 'yoga',
            durationSeconds: 1200,
            bunnyVideoId: `mock_video_${dayNum}`,
            bunnyLibraryId: 'mock_lib_123',
            isFree: false,
            isPublished: true
          }
        });
      }
    }
  }

  // 4. Seed some free preview videos
  const freeVideos = [
    {
      id: '11111111-1111-1111-1111-111111111111',
      title: 'Intro to Yoga Breathing',
      description: 'Learn the foundational breathing techniques (Pranayama) to center yourself.',
      category: 'yoga',
      durationSeconds: 600,
      bunnyVideoId: 'free_video_1',
      bunnyLibraryId: 'mock_lib_123',
      sortOrder: 1,
      isPublished: true
    },
    {
      id: '22222222-2222-2222-2222-222222222222',
      title: '5-Minute Neck & Shoulder Stretch',
      description: 'Quick desk exercise relief session for posture recovery.',
      category: 'general_exercise',
      durationSeconds: 300,
      bunnyVideoId: 'free_video_2',
      bunnyLibraryId: 'mock_lib_123',
      sortOrder: 2,
      isPublished: true
    }
  ];

  for (const f of freeVideos) {
    await prisma.freeVideo.upsert({
      where: { id: f.id },
      update: f,
      create: f
    });
    console.log(`Upserted free video: ${f.title}`);
  }

  console.log('Seeding completed successfully!');
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
