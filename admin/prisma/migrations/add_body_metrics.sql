-- Migration: add body_metrics table
-- Run this in Supabase SQL Editor or via: npx prisma db push (in admin/)

CREATE TABLE IF NOT EXISTS body_metrics (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id   UUID REFERENCES courses(id) ON DELETE SET NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  name        TEXT,
  age         INTEGER,
  height_cm   NUMERIC(5,1),
  weight_kg   NUMERIC(5,1),
  waist_in    NUMERIC(5,1),
  hip_in      NUMERIC(5,1)
);

CREATE INDEX IF NOT EXISTS body_metrics_user_id_idx ON body_metrics(user_id);
CREATE INDEX IF NOT EXISTS body_metrics_recorded_at_idx ON body_metrics(recorded_at DESC);
