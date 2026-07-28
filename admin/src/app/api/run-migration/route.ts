import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

const MIGRATION_SECRET = 'rmh-migrate-uuid-to-text-2026';

export async function POST(req: NextRequest) {
  const { secret } = await req.json();
  if (secret !== MIGRATION_SECRET) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const statements = [
    `ALTER TABLE enrollments        DROP CONSTRAINT IF EXISTS enrollments_user_id_fkey`,
    `ALTER TABLE video_progress     DROP CONSTRAINT IF EXISTS video_progress_user_id_fkey`,
    `ALTER TABLE daily_progress     DROP CONSTRAINT IF EXISTS daily_progress_user_id_fkey`,
    `ALTER TABLE user_stats         DROP CONSTRAINT IF EXISTS user_stats_user_id_fkey`,
    `ALTER TABLE daily_step_history DROP CONSTRAINT IF EXISTS daily_step_history_user_id_fkey`,
    `ALTER TABLE leaderboard_entries DROP CONSTRAINT IF EXISTS leaderboard_entries_user_id_fkey`,
    `ALTER TABLE feedback            DROP CONSTRAINT IF EXISTS feedback_user_id_fkey`,
    `ALTER TABLE body_metrics        DROP CONSTRAINT IF EXISTS body_metrics_user_id_fkey`,
    `ALTER TABLE notification_reads  DROP CONSTRAINT IF EXISTS notification_reads_user_id_fkey`,
    `ALTER TABLE user_stats DROP CONSTRAINT IF EXISTS user_stats_pkey`,
    `ALTER TABLE profiles ALTER COLUMN id TYPE TEXT USING id::TEXT`,
    `ALTER TABLE enrollments         ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT`,
    `ALTER TABLE video_progress      ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT`,
    `ALTER TABLE daily_progress      ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT`,
    `ALTER TABLE user_stats          ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT`,
    `ALTER TABLE daily_step_history  ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT`,
    `ALTER TABLE leaderboard_entries ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT`,
    `ALTER TABLE feedback             ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT`,
    `ALTER TABLE body_metrics         ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT`,
    `ALTER TABLE notification_reads   ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT`,
    `ALTER TABLE user_stats ADD CONSTRAINT user_stats_pkey PRIMARY KEY (user_id)`,
    `ALTER TABLE enrollments         ADD CONSTRAINT enrollments_user_id_fkey         FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE`,
    `ALTER TABLE video_progress      ADD CONSTRAINT video_progress_user_id_fkey      FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE`,
    `ALTER TABLE daily_progress      ADD CONSTRAINT daily_progress_user_id_fkey      FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE`,
    `ALTER TABLE user_stats          ADD CONSTRAINT user_stats_user_id_fkey          FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE`,
    `ALTER TABLE daily_step_history  ADD CONSTRAINT daily_step_history_user_id_fkey  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE`,
    `ALTER TABLE leaderboard_entries ADD CONSTRAINT leaderboard_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE`,
    `ALTER TABLE feedback             ADD CONSTRAINT feedback_user_id_fkey            FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE`,
    `ALTER TABLE body_metrics         ADD CONSTRAINT body_metrics_user_id_fkey        FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE`,
    `ALTER TABLE notification_reads   ADD CONSTRAINT notification_reads_user_id_fkey  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE`,
  ];

  const results: { stmt: string; ok: boolean; error?: string }[] = [];

  for (const stmt of statements) {
    try {
      await prisma.$executeRawUnsafe(stmt);
      results.push({ stmt: stmt.substring(0, 60), ok: true });
    } catch (err) {
      results.push({ stmt: stmt.substring(0, 60), ok: false, error: (err as Error).message });
    }
  }

  const failed = results.filter(r => !r.ok);
  return NextResponse.json({ results, failed: failed.length }, { status: 200 });
}
