-- Fix body_metrics: user_id must be TEXT (not UUID) to match profiles.id
-- Run this in Supabase SQL Editor.

-- If the table doesn't exist yet, create it correctly:
CREATE TABLE IF NOT EXISTS body_metrics (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     TEXT NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id   UUID REFERENCES courses(id) ON DELETE SET NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  name        TEXT,
  age         INTEGER,
  height_cm   NUMERIC(5,1),
  weight_kg   NUMERIC(5,1),
  waist_in    NUMERIC(5,1),
  hip_in      NUMERIC(5,1)
);

-- Enable Row Level Security (Supabase requirement)
ALTER TABLE body_metrics ENABLE ROW LEVEL SECURITY;

-- The app backend uses the service role key via Next.js API routes,
-- so no client-facing RLS policies are needed. The table is fully
-- locked to anon/authenticated Supabase clients by default once RLS is on.

CREATE INDEX IF NOT EXISTS body_metrics_user_id_idx ON body_metrics(user_id);
CREATE INDEX IF NOT EXISTS body_metrics_recorded_at_idx ON body_metrics(recorded_at DESC);

-- ─── If the table already exists with user_id UUID ───────────────────────────
-- Only run the block below if the CREATE above did nothing (table already
-- existed) AND inserts are still failing with a type error.
-- WARNING: this drops all existing body_metrics rows.
--
-- DROP TABLE IF EXISTS body_metrics;
-- CREATE TABLE body_metrics (
--   id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   user_id     TEXT NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
--   course_id   UUID REFERENCES courses(id) ON DELETE SET NULL,
--   recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
--   name        TEXT,
--   age         INTEGER,
--   height_cm   NUMERIC(5,1),
--   weight_kg   NUMERIC(5,1),
--   waist_in    NUMERIC(5,1),
--   hip_in      NUMERIC(5,1)
-- );
-- ALTER TABLE body_metrics ENABLE ROW LEVEL SECURITY;
-- CREATE INDEX IF NOT EXISTS body_metrics_user_id_idx ON body_metrics(user_id);
-- CREATE INDEX IF NOT EXISTS body_metrics_recorded_at_idx ON body_metrics(recorded_at DESC);
