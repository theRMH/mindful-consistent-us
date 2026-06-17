-- Add difficulty to courses
ALTER TABLE courses ADD COLUMN IF NOT EXISTS difficulty TEXT DEFAULT 'Beginner';

-- Create body_metrics table (run if not already done)
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

-- Create app_settings table (run if not already done)
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO app_settings (key, value) VALUES ('steps_goal', '10000') ON CONFLICT (key) DO NOTHING;
