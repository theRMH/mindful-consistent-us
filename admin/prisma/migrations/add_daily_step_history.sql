CREATE TABLE IF NOT EXISTS daily_step_history (
  id         UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID    NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  date_str   TEXT    NOT NULL,   -- 'YYYY-MM-DD'
  steps      INTEGER NOT NULL DEFAULT 0,
  UNIQUE(user_id, date_str)
);

CREATE INDEX IF NOT EXISTS daily_step_history_user_date_idx
  ON daily_step_history(user_id, date_str DESC);
