-- Migration: Add YouTube video support
-- Adds video_source toggle and youtube_video_id to both videos and free_videos tables
-- Existing bunny fields are made nullable to support YouTube-only videos

-- 1. Videos table: Add new columns
ALTER TABLE "videos" ADD COLUMN IF NOT EXISTS "video_source" TEXT NOT NULL DEFAULT 'bunny';
ALTER TABLE "videos" ADD COLUMN IF NOT EXISTS "youtube_video_id" TEXT;

-- Make bunny fields nullable (they were required before, now optional when source is youtube)
ALTER TABLE "videos" ALTER COLUMN "bunny_video_id" DROP NOT NULL;
ALTER TABLE "videos" ALTER COLUMN "bunny_library_id" DROP NOT NULL;

-- 2. Free videos table: Add new columns
ALTER TABLE "free_videos" ADD COLUMN IF NOT EXISTS "video_source" TEXT NOT NULL DEFAULT 'bunny';
ALTER TABLE "free_videos" ADD COLUMN IF NOT EXISTS "youtube_video_id" TEXT;

-- Make bunny fields nullable
ALTER TABLE "free_videos" ALTER COLUMN "bunny_video_id" DROP NOT NULL;
ALTER TABLE "free_videos" ALTER COLUMN "bunny_library_id" DROP NOT NULL;

-- 3. Add check constraints for valid video source values
ALTER TABLE "videos" ADD CONSTRAINT "videos_video_source_check" CHECK ("video_source" IN ('bunny', 'youtube'));
ALTER TABLE "free_videos" ADD CONSTRAINT "free_videos_video_source_check" CHECK ("video_source" IN ('bunny', 'youtube'));
