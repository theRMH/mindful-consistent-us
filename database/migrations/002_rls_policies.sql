-- 002_rls_policies.sql
-- Enable Row Level Security (RLS) and define access rules

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.free_videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.video_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leaderboard_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- 1. Profiles Policies
CREATE POLICY "Users can read own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- 2. Courses Policies (Public read for published courses)
CREATE POLICY "Public read for published courses" ON public.courses
    FOR SELECT USING (is_published = true);

-- 3. Course Days Policies (Public read)
CREATE POLICY "Public read for course days" ON public.course_days
    FOR SELECT USING (true);

-- 4. Videos Policies
-- Registered users can read videos of courses they are enrolled in.
-- We also allow reading free videos.
CREATE POLICY "Read access for videos" ON public.videos
    FOR SELECT USING (
        is_free = true OR 
        is_published = true
    );

-- 5. Free Videos Policies
CREATE POLICY "Public read for free videos" ON public.free_videos
    FOR SELECT USING (is_published = true);

-- 6. Enrollments Policies
CREATE POLICY "Users can view own enrollments" ON public.enrollments
    FOR SELECT USING (auth.uid() = user_id);

-- 7. Video Progress Policies
CREATE POLICY "Users can view own video progress" ON public.video_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own video progress" ON public.video_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own video progress" ON public.video_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- 8. Daily Progress Policies
CREATE POLICY "Users can view own daily progress" ON public.daily_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily progress" ON public.daily_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own daily progress" ON public.daily_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- 9. User Stats Policies
CREATE POLICY "Users can view own stats" ON public.user_stats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update/insert own stats" ON public.user_stats
    FOR ALL USING (auth.uid() = user_id);

-- 10. Leaderboard Entries Policies
CREATE POLICY "Users can view leaderboard entries" ON public.leaderboard_entries
    FOR SELECT USING (true);

-- 11. Feedback Policies
CREATE POLICY "Users can submit feedback" ON public.feedback
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own feedback" ON public.feedback
    FOR SELECT USING (auth.uid() = user_id);
