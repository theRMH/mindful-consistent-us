# Mindful App — Full Backend Integration Plan

## Context
Flutter wellness app for a yoga teacher. UI is fully built on mock data.
Backend: Next.js admin + Prisma + Supabase Postgres — all mobile API endpoints already exist.
Goal: replace every mock with live data, phase by phase, leaving auth (OTP) for last.

**Client:** Yoga teacher. Two content categories: **Yoga** | **General Workout**
**Course model:** Day-based (21, 30 days etc). Each day unlocks on its calendar date.
Each day has 3–5+ videos. Video sources: YouTube OR BunnyNet (admin-configurable per video).
Video plays full-screen inside the app.

---

## PHASE 1 — Admin: YouTube Support + Course Category

### Why
Admin can only add BunnyNet videos. Schema already has `youtubeVideoId` + `videoSource` fields
but the UI never exposes them. Category field doesn't exist yet.

### 1a. DB Migration — add `category` to `courses`
File: `database/migrations/006_add_course_category.sql`
```sql
ALTER TABLE courses ADD COLUMN category TEXT CHECK (category IN ('yoga', 'general_exercise'));
```
Update `admin/prisma/schema.prisma` → add `category String?` to `Course` model.
Run `npx prisma generate`.

### 1b. Edit Course form — YouTube / BunnyNet toggle
File: `admin/src/app/dashboard/courses/[courseId]/page.tsx`

In the "Add Video" form, replace the static Bunny fields with:
- Radio/toggle: **YouTube** | **BunnyNet**
- YouTube selected → show single input: `YouTube Video ID`
- BunnyNet selected → show two inputs: `Bunny Video ID`, `Bunny Library ID`
- Set `videoSource = 'youtube'` or `'bunny'` on submit

Also wire `youtubeVideoId` field to the existing API call body.

### 1c. Update video API route to accept YouTube fields
File: `admin/src/app/api/courses/[courseId]/route.ts` (action: addVideo)
- Accept `videoSource`, `youtubeVideoId` in body
- Pass to `prisma.video.create()`

### 1d. Free Videos form — same YouTube toggle
File: `admin/src/app/dashboard/free-videos/page.tsx`
- Same YouTube / BunnyNet toggle pattern
- Category select: **Yoga** | **General Workout** (replace free-text input)

File: `admin/src/app/api/videos/free/route.ts`
- Accept `videoSource`, `youtubeVideoId`, enforce category as enum

### 1e. Create / Edit Course — add Category field
Files: `admin/src/app/dashboard/courses/new/page.tsx`,
       `admin/src/app/dashboard/courses/[courseId]/page.tsx`
- Add `<select>` for category: Yoga | General Workout
- Wire to API + Prisma

### 1f. Course API — pass category through
File: `admin/src/app/api/courses/route.ts` and `courses/[courseId]/route.ts`
- Accept + store `category` field

### Verification
- Create a course, set category = Yoga
- Add a day, add a YouTube video → confirm `videoSource='youtube'`, `youtubeVideoId` saved in DB
- Add a BunnyNet video → confirm both bunny fields saved
- Edit free video with YouTube source

---

## PHASE 2 — Admin: Streak Calculation + Leaderboard Fix

### Why
`complete-day` endpoint exists but never updates streak or leaderboard.
Leaderboard endpoint returns hardcoded mock names.

### 2a. Streak logic in complete-day
File: `admin/src/app/api/mobile/progress/complete-day/route.ts`

After marking `dailyProgress.isComplete = true`:
```
1. Find last completed dailyProgress for this user (by completedAt desc)
2. Calculate daysDiff = today - lastCompletedDate (in calendar days)
3. if daysDiff == 1  → currentStreak += 1
   if daysDiff == 0  → already completed today, no change
   if daysDiff  > 1  → currentStreak = 1  (streak broken)
   if no prior record → currentStreak = 1  (first completion)
4. if currentStreak > longestStreak → longestStreak = currentStreak
5. prisma.userStats.update({ currentStreak, longestStreak, totalSessions++ })
6. Upsert leaderboard_entries:
   score = daysCompleted * 100 + currentStreak * 10
   Re-rank top entries for this course
```

### 2b. Fix leaderboard endpoint — real data + profile join
File: `admin/src/app/api/mobile/leaderboard/route.ts`

Remove all hardcoded mock data. Replace with:
```ts
const entries = await prisma.leaderboardEntry.findMany({
  take: 10,
  orderBy: { score: 'desc' },
  include: { user: { select: { fullName: true, avatarUrl: true } } },
});
return entries.map((e, i) => ({
  rank: i + 1,
  name: e.user.fullName ?? 'User',
  avatarUrl: e.user.avatarUrl ?? '',
  score: Number(e.score),
  daysCompleted: e.daysCompleted,
  isCurrentUser: e.userId === user.id,
}));
```

Also return `userRank`: find authenticated user's rank in the full list.

### 2c. Add `/api/mobile/profile` endpoint
New file: `admin/src/app/api/mobile/profile/route.ts`
- `GET` → return `{ id, fullName, phone, avatarUrl, email }` from `profiles` where `id = user.id`
- `PUT` → update `fullName`, `avatarUrl`, `fcmToken`

### Verification
- Complete a day → check `user_stats.currentStreak` incremented
- Complete again same day → streak unchanged
- Check leaderboard endpoint returns real names from profiles table
- GET /api/mobile/profile returns correct user data

---

## PHASE 3 — Flutter: Core Data Wiring (progressProvider + AppConfig)

### Why
Flutter still has `useMockData = true`. This phase turns on real API calls for progress stats.

### 3a. Update AppConfig
File: `app/lib/core/config/app_config.dart`
```dart
static const String apiBaseUrl = 'http://10.0.2.2:3000'; // Android emulator
// For physical device: use machine's local IP e.g. http://192.168.x.x:3000
static const bool useMockData = false;
// Fill in real Supabase URL + anon key from admin/.env
```

### 3b. ApiService — hardcoded mock token
File: `app/lib/core/services/api_service.dart`
- Token stays as `'mock-user-123'` for now (auth-middleware accepts it as bypass)
- This lets all data work before real auth is wired
- Token will be replaced in Phase 9 (OTP auth)

### 3c. progressProvider — remove mock path
File: `app/lib/presentation/providers/progress_provider.dart`
- `loadInitialData()` always calls `refreshFromApi()` (mock path deleted)
- `refreshFromApi()` already parses the correct response shape ✓
- Verify field mapping: `progressData['stats']['totalSteps']` → `steps`

### 3d. Call `loadInitialData()` on app start
File: `app/lib/main.dart` or home screen `initState`
- `ref.read(progressProvider.notifier).loadInitialData()`

### Verification
- Run admin locally: `cd admin && npm run dev`
- Run Flutter: `flutter run`
- Home screen stats (mins, sessions, streak) should show real DB values (0 for new user)

---

## PHASE 4 — Flutter: Courses + Programs Screen

### Why
Programs screen is fully hardcoded. Need real courses, enrollments, and progress per course.

### 4a. Course + Enrollment models
New file: `app/lib/data/models/course_model.dart`
```dart
class CourseModel {
  final String id, title, slug, category;
  final String? description, thumbnailUrl;
  final int totalDays;
  final double priceInr;
  final bool isPublished;
}

class EnrollmentModel {
  final String id, courseId;
  final bool isActive;
  final DateTime enrolledAt;
}
```

### 4b. New coursesProvider
New file: `app/lib/presentation/providers/courses_provider.dart`
```dart
// Fetches courses list + enrollments simultaneously
final coursesProvider = StateNotifierProvider<CoursesNotifier, CoursesState>(...);

class CoursesState {
  final List<CourseModel> allCourses;
  final List<EnrollmentModel> enrollments;
  final bool isLoading;
  final String? error;
}
// enrolledCourseIds getter: Set<String>
// activeCourses getter: courses where enrolledCourseIds.contains(course.id)
// exploreCourses getter: courses NOT in enrolledCourseIds
```

### 4c. Programs screen — wire to real data
File: `app/lib/presentation/screens/my_courses/programs_screen.dart`
- `ref.watch(coursesProvider)` → AsyncValue loading/error/data states
- **Active tab**: `coursesState.activeCourses` → progress % = `completedDays.length / course.totalDays`
- **Completed tab**: active courses where progress == 100%
- **Explore tab**: `coursesState.exploreCourses`
- Thumbnail fallback: if `thumbnailUrl == null`:
  - category == 'yoga' → `assets/icon_asana.png`
  - category == 'general_exercise' → `assets/icon_kriya.png`

### 4d. Enroll action (from Program Details or Explore card)
- Tap "Enroll" → `POST /api/mobile/enrollments` with `{ courseId }`
- On success → invalidate coursesProvider → navigate to Active tab

### Verification
- Open Programs → Active tab shows nothing (no enrollments yet)
- Open Explore tab → real courses from DB
- Tap enroll → course moves to Active tab

---

## PHASE 5 — Flutter: Day List Screen (Lock / Unlock / Complete)

### Why
Day list is static. Needs real day data, lock logic, and video list per day.

### 5a. Day + Video models
Add to `app/lib/data/models/course_model.dart`:
```dart
class CourseDayModel {
  final String id;
  final int dayNumber;
  final String? title, description;
  final List<VideoModel> videos;
  // computed:
  bool get isUnlocked => DateTime.now().isAfter(unlockDate);
  bool get isCompleted; // from completedDays[]
}

class VideoModel {
  final String id, title, videoSource; // 'youtube' | 'bunny'
  final String? youtubeVideoId, bunnyVideoId, bunnyLibraryId, thumbnailUrl;
  final int durationSeconds;
  final String? category;
}
```

### 5b. Day list screen — states per day
File: `app/lib/presentation/screens/my_courses/day_list_screen.dart`
- Call `GET /api/mobile/courses/{courseId}` → get days with videos
- For each day determine state:
  - **Locked** 🔒: `enrolledAt + (dayNumber - 1) days > today`
  - **Today / Unlocked** ▶️: unlocked + not in `completedDays[]`
  - **Completed** ✅: dayNumber in `progressProvider.completedDays`
- Show per day: day number, title, focus text, video count, total duration, state icon
- Tap unlocked day → expand to show video list
- Each video: category icon (🧘 yoga / 💪 workout), title, duration, play button
- Completed video → checkmark overlay

### 5c. Day completion flow
- When last video of a day finishes → call `POST /api/mobile/progress/complete-day`
- Refresh `progressProvider` → streak + leaderboard update (from Phase 2)
- Show "Day Complete 🎉" celebratory dialog

### Verification
- Enroll in course → Day 1 shows as unlocked, Days 2+ locked
- Tap Day 1 → video list expands
- Complete all Day 1 videos → "Day Complete" dialog → Day 1 shows ✅ → streak increments

---

## PHASE 6 — Flutter: Video Player (YouTube + BunnyNet, Full Screen)

### Why
Currently only YouTube works. BunnyNet not handled. No completion tracking.

### 6a. pubspec.yaml — add BunnyNet video support
```yaml
better_player: ^0.0.84   # HLS/MP4 player with full screen support
# OR
chewie: ^1.7.4            # wrapper around video_player with full screen
```

### 6b. Video player screen — detect source
File: `app/lib/presentation/screens/explore/video_player_screen.dart`

```dart
// Route params: videoSource, youtubeVideoId, bunnyVideoId, bunnyLibraryId
if (videoSource == 'youtube') {
  // Existing YoutubePlayerController — keep as-is
  YoutubePlayerController(initialVideoId: youtubeVideoId)
} else {
  // BunnyNet HLS stream URL
  final hlsUrl = 'https://iframe.mediadelivery.net/embed/$bunnyLibraryId/$bunnyVideoId';
  // Use BetterPlayer or Chewie + VideoPlayerController.networkUrl(hlsUrl)
}
```

### 6c. Full screen enforcement
- Rotate to landscape on video play: `SystemChrome.setPreferredOrientations([landscape])`
- Restore portrait on back: `SystemChrome.setPreferredOrientations([portrait])`
- Hide status/navigation bars: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)`

### 6d. Completion tracking
- On video end event → mark video as watched in local state
- If all videos in day are watched → trigger day completion flow (Phase 5c)
- Track watch seconds → pass to `POST /api/mobile/progress/complete-day` body

### Verification
- Play YouTube video → full screen landscape
- Play BunnyNet video → full screen landscape
- Finish video → day completion dialog appears (if last video)
- Back button restores portrait orientation

---

## PHASE 7 — Flutter: Home Screen (Real Stats + Leaderboard)

### Why
Home screen stats and leaderboard are all hardcoded.

### 7a. Stats row — wire to progressProvider
File: `app/lib/presentation/screens/home/home_screen.dart`
- Mindful Mins → `progressState.mindfulMins`
- Sessions → `progressState.completedSessionsToday` (or `totalSessions`)
- Calories → `progressState.calories`
- Goal % → `completedDays.length / activeCourse.totalDays * 100`

### 7b. Active course banner — real course
- Get `activeCourseId` from `progressProvider`
- Lookup in `coursesProvider` → show real title, thumbnail, day progress
- Thumbnail fallback: category icon

### 7c. Leaderboard — real data
- `progressProvider.leaderboard` already populated from `/api/mobile/leaderboard`
- Wire top 3 podium + user rank to real values from Phase 2b fix

### 7d. Profile stats (Profile screen)
File: `app/lib/presentation/screens/profile/profile_screen.dart`
- Sessions → `progressState.totalSessions`
- Minutes → `progressState.mindfulMins`
- Day Streak → `progressState.currentStreak`

### Verification
- Home shows real streak, real mins, real sessions
- Leaderboard shows real user names
- Complete a day → home stats update

---

## PHASE 8 — Flutter: Profile + Steps Sync

### 8a. Profile screen — real name/avatar
- Call `GET /api/mobile/profile` on profile screen load
- Show real `fullName` in header
- Show real avatar from `avatarUrl` (network image)
- Fallback: initials-based circle avatar

### 8b. Steps sync to backend
File: `app/lib/presentation/screens/explore/steps_screen.dart`
New endpoint needed: `POST /api/mobile/steps` (admin)
```ts
// Body: { steps: number, calories: number }
// Update user_stats.totalSteps, user_stats.totalCalories
```
- Sync on app foreground resume + every 5 minutes
- Google Fit integration: deferred (add `health` package later)

### Verification
- Profile shows real user name
- Steps count visible on steps screen
- Steps reflected in user_stats after sync

---

## PHASE 9 — Auth: Supabase Phone OTP (Final Phase)

### Why last
All screens work with mock token bypass (`mock-user-123`). Auth is pure plumbing —
everything else validates independently first.

### 9a. Initialize Supabase in Flutter
File: `app/lib/main.dart`
```dart
await Supabase.initialize(
  url: AppConfig.supabaseUrl,
  anonKey: AppConfig.supabaseAnonKey,
);
```

### 9b. Rewrite authProvider — real Supabase phone OTP
File: `app/lib/presentation/providers/auth_provider.dart`

```dart
// login(phone) — send OTP
await Supabase.instance.client.auth.signInWithOtp(phone: '+91$phone');
// → navigate to OTP screen, store phone in state

// verifyOtpAndLogin(phone, otp) — verify
final response = await Supabase.instance.client.auth.verifyOTP(
  phone: '+91$phone',
  token: otp,
  type: OtpType.sms,
);
// → response.session.accessToken → store in SharedPreferences

// logout()
await Supabase.instance.client.auth.signOut();
await prefs.remove('auth_token');
```

Add phone to `AuthState` to pass between login and OTP screens.
Add `_restoreSession()` in constructor — check Supabase current session on app launch,
call `GET /api/mobile/profile` to validate + restore AuthState.

### 9c. ApiService — use real token
File: `app/lib/core/services/api_service.dart`
```dart
static Future<String> _getAuthToken() async {
  return Supabase.instance.client.auth.currentSession?.accessToken ?? '';
}
```
Remove `'mock-user-123'` hardcode.

### 9d. Profile sync — create profiles record on first login
After OTP verify succeeds:
- Supabase auto-creates `auth.users` entry
- Call `POST /api/auth/sync` (already exists) to ensure `profiles` row is created
- Set `fullName` from signup input if provided

### 9e. Supabase dashboard config
- Enable Phone Auth provider in Supabase dashboard
- For dev: add test phone numbers (e.g. `+91 9999999999` → OTP `123456`) — no Twilio needed
- For production: configure Twilio SMS provider

### Verification
- Enter phone → receive OTP (test number in dev)
- Enter OTP → navigates to /home
- Kill app and relaunch → session restored, stays logged in
- Logout → token cleared → back to /unregistered

---

## File Change Summary

### Admin (`admin/`)
| File | Phase | Change |
|------|-------|--------|
| `prisma/schema.prisma` | 1 | Add `category` to Course model |
| `database/migrations/006_*.sql` | 1 | ALTER TABLE courses ADD COLUMN category |
| `dashboard/courses/[courseId]/page.tsx` | 1 | YouTube/BunnyNet toggle in video form |
| `dashboard/courses/new/page.tsx` | 1 | Add category select |
| `dashboard/free-videos/page.tsx` | 1 | YouTube toggle + category select |
| `api/courses/[courseId]/route.ts` | 1 | Accept videoSource, youtubeVideoId |
| `api/videos/free/route.ts` | 1 | Accept videoSource, youtubeVideoId |
| `api/mobile/progress/complete-day/route.ts` | 2 | Streak calculation logic |
| `api/mobile/leaderboard/route.ts` | 2 | Real data + profile join, remove mock |
| `api/mobile/profile/route.ts` | 2 | New GET/PUT endpoint |
| `api/mobile/steps/route.ts` | 8 | New POST endpoint for steps sync |

### Flutter (`app/`)
| File | Phase | Change |
|------|-------|--------|
| `lib/core/config/app_config.dart` | 3 | Real URL, useMockData=false |
| `lib/core/services/api_service.dart` | 3 | Remove mock token (Phase 3), real token (Phase 9) |
| `lib/presentation/providers/progress_provider.dart` | 3 | Remove mock path |
| `lib/main.dart` | 3, 9 | loadInitialData(), Supabase.initialize() |
| `lib/data/models/course_model.dart` | 4 | New — Course, Enrollment, Day, Video models |
| `lib/presentation/providers/courses_provider.dart` | 4 | New — courses + enrollments state |
| `lib/presentation/screens/my_courses/programs_screen.dart` | 4 | Real courses, enrollment, progress |
| `lib/presentation/screens/my_courses/day_list_screen.dart` | 5 | Real days, lock logic, video list |
| `pubspec.yaml` | 6 | Add better_player or chewie |
| `lib/presentation/screens/explore/video_player_screen.dart` | 6 | BunnyNet + full screen + completion |
| `lib/presentation/screens/home/home_screen.dart` | 7 | Real stats, real leaderboard, active course |
| `lib/presentation/screens/profile/profile_screen.dart` | 7, 8 | Real stats, real name/avatar |
| `lib/presentation/screens/explore/steps_screen.dart` | 8 | Steps sync to backend |
| `lib/presentation/providers/auth_provider.dart` | 9 | Supabase OTP auth |

---

## Quick-Start per Phase
```bash
# Phase 1 — Admin video/category changes
cd admin && npm run dev
# Edit forms, test in browser, verify DB via Prisma Studio: npx prisma studio

# Phase 2 — Streak + leaderboard
# Test: curl -H "Authorization: Bearer mock-user-123" localhost:3000/api/mobile/leaderboard

# Phase 3 onwards — Flutter
cd app && flutter run
# Verify with: flutter analyze
```
