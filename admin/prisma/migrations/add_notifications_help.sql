-- Migration: add app_notifications, notification_reads, help_content tables

CREATE TABLE IF NOT EXISTS "app_notifications" (
  "id"           UUID        NOT NULL DEFAULT gen_random_uuid(),
  "title"        TEXT        NOT NULL,
  "body"         TEXT        NOT NULL,
  "type"         TEXT        NOT NULL DEFAULT 'announcement',
  "target_type"  TEXT        NOT NULL DEFAULT 'all',
  "segment_rule" JSONB,
  "redirect_url" TEXT,
  "sent_at"      TIMESTAMPTZ NOT NULL DEFAULT now(),
  "sent_count"   INTEGER     NOT NULL DEFAULT 0,
  CONSTRAINT "app_notifications_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "notification_reads" (
  "id"              UUID        NOT NULL DEFAULT gen_random_uuid(),
  "user_id"         UUID        NOT NULL,
  "notification_id" UUID        NOT NULL,
  "read_at"         TIMESTAMPTZ,
  CONSTRAINT "notification_reads_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "notification_reads_user_notification_unique" UNIQUE ("user_id", "notification_id"),
  CONSTRAINT "notification_reads_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "profiles"("id") ON DELETE CASCADE,
  CONSTRAINT "notification_reads_notification_id_fkey"
    FOREIGN KEY ("notification_id") REFERENCES "app_notifications"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "help_content" (
  "id"         TEXT        NOT NULL,
  "content"    TEXT        NOT NULL DEFAULT '',
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT "help_content_pkey" PRIMARY KEY ("id")
);

-- Add FCM token + notification preference columns to profiles (if not exists)
ALTER TABLE "profiles"
  ADD COLUMN IF NOT EXISTS "fcm_token"              TEXT,
  ADD COLUMN IF NOT EXISTS "notifications_enabled"  BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "notification_time"      TEXT;
