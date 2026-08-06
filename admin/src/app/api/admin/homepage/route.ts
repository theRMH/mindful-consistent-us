import { NextRequest, NextResponse } from 'next/server';
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

// Stored as "home_hero_image_url" in DB → returned as "hero_image_url" to the editor
function stripPrefix(key: string) {
  return key.replace(/^home_/, '');
}

function addPrefix(key: string) {
  return `home_${key}`;
}

function parseValue(raw: string) {
  try { return JSON.parse(raw); } catch { return raw; }
}

export async function GET() {
  try {
    const rows = await prisma.appSetting.findMany({
      where: { key: { in: HOME_KEYS } },
    });
    const result: Record<string, unknown> = {};
    for (const row of rows) {
      result[stripPrefix(row.key)] = parseValue(row.value);
    }
    return NextResponse.json(result, { status: 200 });
  } catch {
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json().catch(() => ({})) as Record<string, unknown>;
    for (const [shortKey, value] of Object.entries(body)) {
      const dbKey = addPrefix(shortKey);
      if (!HOME_KEYS.includes(dbKey)) continue;
      const stored = typeof value === 'string' ? value : JSON.stringify(value);
      await prisma.appSetting.upsert({
        where: { key: dbKey },
        create: { key: dbKey, value: stored },
        update: { value: stored, updatedAt: new Date() },
      });
    }
    return NextResponse.json({ success: true }, { status: 200 });
  } catch {
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
