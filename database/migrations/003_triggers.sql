-- 003_triggers.sql
-- Create functions and triggers for automated database orchestration

-- 1. Trigger to auto-create profile and stats on Auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data->>'full_name', ''),
        COALESCE(new.raw_user_meta_data->>'avatar_url', '')
    );

    INSERT INTO public.user_stats (user_id)
    VALUES (new.id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- 2. Trigger to sync stats on daily progress updates
CREATE OR REPLACE FUNCTION public.sync_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_stats (
        user_id,
        total_watch_seconds,
        total_sessions,
        total_calories,
        total_steps,
        updated_at
    )
    VALUES (
        NEW.user_id,
        NEW.total_watch_seconds,
        CASE WHEN NEW.is_complete THEN 1 ELSE 0 END,
        NEW.calories_burnt,
        NEW.steps_count,
        NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        total_watch_seconds = (
            SELECT COALESCE(SUM(total_watch_seconds), 0)
            FROM public.daily_progress
            WHERE daily_progress.user_id = NEW.user_id
        ),
        total_sessions = (
            SELECT COALESCE(COUNT(*), 0)
            FROM public.daily_progress
            WHERE daily_progress.user_id = NEW.user_id AND is_complete = true
        ),
        total_calories = (
            SELECT COALESCE(SUM(calories_burnt), 0)
            FROM public.daily_progress
            WHERE daily_progress.user_id = NEW.user_id
        ),
        total_steps = (
            SELECT COALESCE(SUM(steps_count), 0)
            FROM public.daily_progress
            WHERE daily_progress.user_id = NEW.user_id
        ),
        updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_daily_progress_upsert ON public.daily_progress;

CREATE TRIGGER on_daily_progress_upsert
    AFTER INSERT OR UPDATE ON public.daily_progress
    FOR EACH ROW EXECUTE PROCEDURE public.sync_user_stats();
