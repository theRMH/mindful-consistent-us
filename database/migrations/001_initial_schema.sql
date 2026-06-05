-- 001_initial_schema.sql
-- Create initial schema tables for the Consistent US wellness application

-- Enable uuid-ossp extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Profiles (linked to auth.users in Supabase)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    phone TEXT,
    fcm_token TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Courses
CREATE TABLE IF NOT EXISTS public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    total_days INT NOT NULL,
    price_inr NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Course Days (day_number within a course)
CREATE TABLE IF NOT EXISTS public.course_days (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
    day_number INT NOT NULL,
    title TEXT,
    description TEXT,
    UNIQUE(course_id, day_number)
);

-- 4. Videos (belongs to a course_day or is a free video if course_day_id is null)
CREATE TABLE IF NOT EXISTS public.videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_day_id UUID REFERENCES public.course_days(id) ON DELETE CASCADE NULL,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT CHECK(category IN ('yoga', 'general_exercise')),
    duration_seconds INT NOT NULL DEFAULT 0,
    bunny_video_id TEXT NOT NULL,
    bunny_library_id TEXT NOT NULL,
    thumbnail_url TEXT,
    sort_order INT DEFAULT 0,
    is_free BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Free Videos (Direct standalone collection for easy unregistered consumption)
CREATE TABLE IF NOT EXISTS public.free_videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    duration_seconds INT NOT NULL DEFAULT 0,
    bunny_video_id TEXT NOT NULL,
    bunny_library_id TEXT NOT NULL,
    thumbnail_url TEXT,
    sort_order INT DEFAULT 0,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Enrollments (user purchases/subscriptions to courses)
CREATE TABLE IF NOT EXISTS public.enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
    purchase_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_id TEXT,
    payment_status TEXT CHECK(payment_status IN ('pending', 'completed', 'refunded')) DEFAULT 'pending',
    is_active BOOLEAN DEFAULT true,
    enrolled_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, course_id)
);

-- 7. Video Progress (individual video play positions and completion markers)
CREATE TABLE IF NOT EXISTS public.video_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    video_id UUID REFERENCES public.videos(id) ON DELETE CASCADE NOT NULL,
    enrollment_id UUID REFERENCES public.enrollments(id) ON DELETE CASCADE NULL,
    watch_duration_seconds INT DEFAULT 0,
    last_position_seconds INT DEFAULT 0,
    is_completed BOOLEAN DEFAULT false,
    watched_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, video_id)
);

-- 8. Daily Progress (aggregated day-level completion metrics)
CREATE TABLE IF NOT EXISTS public.daily_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    enrollment_id UUID REFERENCES public.enrollments(id) ON DELETE CASCADE NOT NULL,
    course_day_id UUID REFERENCES public.course_days(id) ON DELETE CASCADE NOT NULL,
    day_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_complete BOOLEAN DEFAULT false,
    videos_watched INT DEFAULT 0,
    total_watch_seconds INT DEFAULT 0,
    calories_burnt NUMERIC(6,2) DEFAULT 0.00,
    steps_count INT DEFAULT 0,
    completed_at TIMESTAMPTZ,
    UNIQUE(user_id, enrollment_id, course_day_id)
);

-- 9. User Stats (accumulated overall profile stats for dashboards/streaks)
CREATE TABLE IF NOT EXISTS public.user_stats (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    total_watch_seconds INT DEFAULT 0,
    total_sessions INT DEFAULT 0,
    total_calories NUMERIC(8,2) DEFAULT 0.00,
    total_steps INT DEFAULT 0,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Leaderboard Entries (snapshots of ranking data per course)
CREATE TABLE IF NOT EXISTS public.leaderboard_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
    enrollment_id UUID REFERENCES public.enrollments(id) ON DELETE CASCADE NOT NULL,
    days_completed INT DEFAULT 0,
    score NUMERIC(10,2) DEFAULT 0.00,
    rank INT,
    snapshot_date DATE DEFAULT CURRENT_DATE,
    UNIQUE(user_id, enrollment_id, snapshot_date)
);

-- 11. Feedback
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    target_type TEXT CHECK(target_type IN ('course', 'video', 'app')) NOT NULL,
    target_id UUID,
    rating INT CHECK(rating BETWEEN 1 AND 5) NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
