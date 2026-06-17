CREATE TABLE IF NOT EXISTS app_settings (
  key        TEXT PRIMARY KEY,
  value      TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Default steps goal
INSERT INTO app_settings (key, value) VALUES ('steps_goal', '10000')
  ON CONFLICT (key) DO NOTHING;
