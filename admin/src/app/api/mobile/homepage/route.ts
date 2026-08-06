import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

const HOME_KEYS = [
  'home_hero_image_url',
  'home_hero_headline',
  'home_hero_subtitle',
  'home_goal_chips',
  'home_cta_primary_label',
  'home_cta_primary_action',
  'home_cta_secondary_label',
  'home_cta_secondary_action',
  'home_how_it_works_title',
  'home_how_it_works_steps',
  'home_recommended_course_id',
  'home_recommended_badge',
  'home_why_title',
  'home_why_tiles',
  'home_free_videos_title',
  'home_free_videos_count',
  'home_social_proof_title',
  'home_bottom_cta_headline',
  'home_bottom_cta_button',
  'home_bottom_cta_action',
  'home_section_order',
  'home_section_visibility',
];

function parseValue(raw: string) {
  try { return JSON.parse(raw); } catch { return raw; }
}

const DEFAULTS = {
  hero_image_url: '',
  hero_headline: 'What would you like to improve today?',
  hero_subtitle: 'Build a routine that helps you feel calmer, stronger and more consistent.',
  goal_chips: [
    { icon: 'bolt', label: 'Feel More Energetic' },
    { icon: 'leaf', label: 'Reduce Stress' },
    { icon: 'accessibility', label: 'Improve Flexibility' },
    { icon: 'target', label: 'Build Consistency' },
  ],
  cta_primary_label: 'Find My Wellness Plan',
  cta_primary_action: 'login',
  cta_secondary_label: 'Watch How It Works',
  cta_secondary_action: 'login',
  how_it_works_title: 'How ConsistenUs works',
  how_it_works_steps: [
    { number: 1, icon: 'flag', label: 'Choose your goal' },
    { number: 2, icon: 'calendar', label: 'Follow daily guidance' },
    { number: 3, icon: 'chart', label: 'Track your consistency' },
  ],
  recommended_course_id: '',
  recommended_badge: 'Best for beginners',
  why_title: 'Why women start with ConsistenUs',
  why_tiles: [
    { icon: 'clock', label: 'Short guided sessions' },
    { icon: 'calendar_check', label: 'Simple daily routine' },
    { icon: 'group', label: 'Community support' },
  ],
  free_videos_title: 'Try a free session',
  free_videos_count: 2,
  social_proof_title: 'Real progress. Real people.',
  bottom_cta_headline: 'Your routine does not need to be perfect.\nIt just needs a beginning.',
  bottom_cta_button: 'Start My Journey',
  bottom_cta_action: 'login',
  section_order: ['hero', 'how_it_works', 'recommended', 'why', 'free_videos', 'social_proof', 'bottom_cta'],
  section_visibility: {
    how_it_works: true,
    recommended: true,
    why: true,
    free_videos: true,
    social_proof: true,
    bottom_cta: true,
  },
};

export async function GET() {
  try {
    // 1. Load all home_* settings
    const rows = await prisma.appSetting.findMany({
      where: { key: { in: HOME_KEYS } },
    });

    const cfg: Record<string, unknown> = { ...DEFAULTS };
    for (const row of rows) {
      const shortKey = row.key.replace(/^home_/, '');
      cfg[shortKey] = parseValue(row.value);
    }

    // 2. If a recommended course is configured, resolve its live data
    let recommended = null;
    const courseId = cfg.recommended_course_id as string;
    if (courseId) {
      const course = await prisma.course.findUnique({
        where: { id: courseId },
        select: {
          id: true,
          title: true,
          description: true,
          thumbnailUrl: true,
          priceInr: true,
          priceUsd: true,
          totalDays: true,
          isPublished: true,
        },
      });
      if (course && course.isPublished) {
        recommended = {
          courseId: course.id,
          title: course.title,
          description: course.description ?? '',
          thumbnailUrl: course.thumbnailUrl ?? '',
          price: Number(course.priceInr),
          priceUsd: course.priceUsd ? Number(course.priceUsd) : null,
          totalDays: course.totalDays,
          badgeLabel: cfg.recommended_badge as string,
        };
      }
    }

    // 3. Shape the final response
    const response = {
      hero: {
        bgImageUrl: cfg.hero_image_url || null,
        headline: cfg.hero_headline,
        subtitle: cfg.hero_subtitle,
        chips: cfg.goal_chips,
      },
      ctaPrimary:   { label: cfg.cta_primary_label,   action: cfg.cta_primary_action },
      ctaSecondary: { label: cfg.cta_secondary_label,  action: cfg.cta_secondary_action },
      howItWorks: {
        title: cfg.how_it_works_title,
        steps: cfg.how_it_works_steps,
      },
      recommended,
      whySection: {
        title: cfg.why_title,
        tiles: cfg.why_tiles,
      },
      freeVideos: {
        sectionTitle: cfg.free_videos_title,
        count: Number(cfg.free_videos_count),
      },
      socialProof: {
        title: cfg.social_proof_title,
      },
      bottomCta: {
        headline:    cfg.bottom_cta_headline,
        buttonLabel: cfg.bottom_cta_button,
        action:      cfg.bottom_cta_action,
      },
      sectionOrder:      cfg.section_order,
      sectionVisibility: cfg.section_visibility,
    };

    return NextResponse.json(response, {
      status: 200,
      headers: { 'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300' },
    });
  } catch {
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
