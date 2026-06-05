-- 004_views.sql
-- Create database views for reporting and leaderboard aggregations

CREATE OR REPLACE VIEW public.v_leaderboard AS
SELECT
    e.user_id,
    e.course_id,
    e.id AS enrollment_id,
    p.full_name,
    p.avatar_url,
    COALESCE(dp.days_completed, 0)::INT AS days_completed,
    COALESCE(dp.total_watch_seconds, 0)::INT AS total_watch_seconds,
    ((COALESCE(dp.days_completed, 0) * 100.0) + (COALESCE(dp.total_watch_seconds, 0) / 60.0))::NUMERIC(10,2) AS score,
    RANK() OVER (
        PARTITION BY e.course_id
        ORDER BY ((COALESCE(dp.days_completed, 0) * 100.0) + (COALESCE(dp.total_watch_seconds, 0) / 60.0)) DESC
    )::INT AS rank
FROM public.enrollments e
JOIN public.profiles p ON e.user_id = p.id
LEFT JOIN (
    SELECT
        user_id,
        enrollment_id,
        COUNT(CASE WHEN is_complete = true THEN 1 END) AS days_completed,
        SUM(total_watch_seconds) AS total_watch_seconds
    FROM public.daily_progress
    GROUP BY user_id, enrollment_id
) dp ON e.id = dp.enrollment_id
WHERE e.is_active = true;
