# Product Requirements Document — Mindful

**Source of truth for all features, screens, and business logic.**
Last updated: 2026-06-13

---

## 1. Product Overview

**Mindful** is a yoga wellness app for a yoga teacher and their students. Users follow structured day-based programs (e.g. "30-Day Morning Yoga"). Content is split into two categories: **Yoga** and **General Workout**. The app rewards consistency through a points system, streak tracking, and a community leaderboard.

**Stack**
- Mobile: Flutter (Android + iOS)
- Backend: Next.js + Prisma + Supabase Postgres, hosted on Vercel
- Auth: Supabase email + password (`signInWithPassword` / `signUp`)
- Video: YouTube (embedded) + BunnyNet (stream via WebView iframe)
- Payment: Razorpay (India) — Phase G

---

## 2. User Types

### 2.1 Unregistered (Guest)
A visitor who has not created an account.

**Can do:**
- Browse all course listings and read course details
- Watch all free videos (unlimited, no account required)
- View program detail pages (day list, session list — read only)
- See their streak count (tracked locally on device)
- Browse community moments

**Cannot do:**
- Watch paid course videos
- Enroll in or purchase a program
- Use the Steps page
- Edit their profile
- Appear on the leaderboard
- Access Active or Completed program tabs

**On any locked action:** Show a bottom sheet popup — "Sign up for free" (→ `/signup`) + "Already have an account? Login" (→ `/login`).

### 2.2 Registered (Logged In)
A user who has created an account via email + password.

**Can do everything a guest can, plus:**
- Enroll in / purchase programs
- Watch enrolled course videos (subject to daily lock)
- Track steps via Google Fit / Apple Health
- Earn points and appear on the leaderboard
- Edit their profile (name, avatar)
- View Active and Completed program tabs

---

## 3. Streak System

The streak is the number of consecutive calendar days the user opens the app. It applies to **both guest and registered users.**

- Opens app on Day 1 → streak = 1
- Opens again on Day 2 → streak = 2
- Misses Day 3 → streak resets to 0 on Day 4 when they open

**Guest:** streak stored in SharedPreferences (device-local). Displayed in the header badge on home, programs, and videos pages.

**Registered:** streak stored in `user_stats.currentStreak` on the server. Synced on every app open via `POST /api/mobile/app-open` which compares today's date against `lastOpenedDate`.

---

## 4. Points System

Points measure engagement. Registered users accumulate points and appear on the community leaderboard.

| Action | Points |
|--------|--------|
| Open app on a new calendar day | +5 pts |
| Press play on a session (video opens) | +10 pts |
| Complete all sessions in a day | +25 pts bonus |
| Every 1,000 steps synced | +1 pt (max 10 pts/day) |
| Complete entire program (all N days done) | +100 pts one-time |

**Notes:**
- "Session complete" = play button pressed, video opened. Not when video finishes.
- Day complete bonus is awarded when the last session of that day is opened.
- Points are stored per-event in `daily_points` table with a `date` field for leaderboard queries.

---

## 5. Calories Formula

Used on the home screen stats tile and steps page.

- Yoga session: `durationMins × 4` kcal
- General Workout session: `durationMins × 6` kcal
- Steps: `steps × 0.04` kcal
- **Daily total** = sum of all session calories today + steps calories today

---

## 6. Day Lock Logic

This is the core mechanic of the program. Each day of a program unlocks on a specific calendar date and is only playable on that date.

- Day 1 unlocks on `enrolledAt` (the day of enrollment)
- Day N unlocks on `enrolledAt + (N − 1) days`
- **Only today's day is playable.** Previous days are locked (no replay). Future days are locked.
- A user enrolled on June 1 can watch Day 1 on June 1, Day 2 on June 2, Day 3 on June 3, etc.
- On June 3, Day 1 and Day 2 are past-locked, Day 4+ are future-locked.

Program detail and day list always show all days (for context), but with appropriate lock indicators.

---

## 7. Screens

### 7.1 Home — Guest (`/unregistered`)

**Top bar:** App logo + streak badge (fire icon, number, "Day Streak" label).

**Section 1 — Explore Programs**
- Heading: "Explore Programs" + "See All" (→ login prompt)
- Shows 3 course cards from live API
- Card: course banner image, title, price, days, level (Yoga / Workout)
- Tap → Program Detail page

**Section 2 — Free Videos**
- Heading: "Free Videos" + "See All" (→ login prompt)
- Shows 2 free video cards
- Card: thumbnail, title, duration badge, category
- Tap → video player (plays inline, no login required)

**Section 3 — Community Moments**
- Heading: "Community"
- User quote cards with name, avatar, quote, streak days badge
- Data from `community_moments` table (admin-managed)

---

### 7.2 Home — Registered (`/home`)

**Top bar:** Greeting ("Good morning, [Name]") + streak badge.

**Section 1 — Program Day Banner**
- Shows: "Day X of Y — [Program Name]"
- X = days since enrollment (today's program day number)
- Y = total days in the program
- Sub-text: today's date
- Tap anywhere on banner → Day List screen, scrolled to today's day
- If no active enrollment: "Browse Programs" CTA instead

**Section 2 — Stats Grid (4 tiles)**

| Tile | Label | Calculation |
|------|-------|-------------|
| 1 | Mins | Sum of `durationSecs / 60` for all sessions marked complete today |
| 2 | Sessions | Count of sessions marked complete today |
| 3 | Calories | (Session calories today) + (Steps calories today) |
| 4 | Goal | `completedDays / totalDays × 100` % |

**Section 3 — Weekly Activity Graph**
- 7-day rolling bar chart (Mon–Sun or rolling 7 days)
- Bar height = total points earned on that day
- Today's bar highlighted
- Source: `daily_points` table grouped by date
- Tap a bar: show tooltip with that day's points total

**Section 4 — Leaderboard Preview**
- Shows: today's top 3 users (rank, avatar, name, points)
- Shows current user's rank below if not in top 3
- Tap → full Leaderboard page

**Section 5 — Free Videos**
- 2 free video cards (same as guest home)
- Always playable

---

### 7.3 Programs Screen (`/programs`)

Three tabs: **Active** | **Completed** | **Explore**

**Guest behavior:**
- Only the Explore tab is accessible
- Active and Completed tabs are visible but tapping them shows the login prompt bottom sheet

**Active tab (registered only):**
- Enrolled courses where `completedDays < totalDays`
- Card: course banner, title, progress bar (`completedDays / totalDays`), "Day X of Y" label
- Tap → Day List screen for that course

**Completed tab (registered only):**
- Enrolled courses where `completedDays == totalDays`
- Card: same as Active but with "Completed" badge
- Tap → Day List (read-only view)

**Explore tab (all users):**
- All published courses not yet enrolled in
- Card: course banner, title, price, days, category, level
- Tap → Program Detail page
- Header: "Programs" title + streak badge top right

---

### 7.4 Program Detail Page (`/program_details`)

Visible to both guest and registered users. Shows full course info and day-by-day breakdown.

**Header area:**
- Full-width course banner image
- Course title, category tag (Yoga / General Workout)
- Duration (e.g. "30 Days"), level, price
- Short description (expandable "Show more")

**Day list (scrollable):**
- One row per day (Day 1, Day 2, … Day N)
- Each row shows: day number, title, total session count, unlock date
- Row tap → expands to show session list for that day

**Session list (within expanded day):**
- Each session row:
  - Left: session thumbnail image → replaced by status icon once enrolled:
    - ✅ Green tick: session completed
    - ❌ Red X: today's day, session not yet done
    - 🔒 Lock icon: locked (past or future day)
  - Centre: session title, category badge (Yoga / General Workout), duration
  - Right: Play button — **green and active** only for today's unlocked sessions; **grey/disabled** for all locked sessions
- Guest: all sessions show lock icon regardless

**Enroll Now floating button (bottom of screen):**
- Guest → login/signup bottom sheet popup
- Registered, not enrolled → navigate to Cart
- Registered, already enrolled → button hidden; show "Continue Program" instead → Day List

---

### 7.5 Day List Screen (`/course/:courseId`)

Full breakdown of all days in an enrolled course.

**Header:** Course name + progress bar.

**Day rows (scrollable):**
- Each day: day number, title, lock status indicator, date (e.g. "June 3")
- Status colours:
  - Today: green highlight, "Today" badge
  - Past days: grey + lock icon
  - Future days: grey + lock icon
- Tap a day row → expands to show session list

**Session list within day:**
- Session: thumbnail/status icon, title, category (Yoga / General Workout), duration
- Play button: active (green) for today; disabled (grey) for locked days
- Tap play → Video Player

**Completion indicators:**
- ✅ = session complete (play was pressed, video opened)
- ❌ = today's day, not yet watched
- 🔒 = locked (past or future)

---

### 7.6 Video Player (`/play`)

**Supported sources:** YouTube (embedded via `youtube_player_flutter`) or BunnyNet stream (via `webview_flutter` iframe).

**Behaviour:**
- Opens fullscreen, landscape orientation locked
- Source determined by `videoSource` param in route (`'youtube'` or `'bunny'`)
- **Session marked complete the moment the video opens (on player init), not when it finishes**
- On completion mark:
  1. Call `POST /api/mobile/progress/complete-session` with `{ courseId, dayNumber, videoId }`
  2. Award +10 pts (server-side, via `daily_points` insert)
  3. If this was the last session of today's day → award +25 pts day bonus
  4. If this completed the final day of the program → award +100 pts program bonus
  5. Update `user_stats`: `totalSessions++`, `mindfulMins += durationMins`, `totalCalories += calories`
- Back button → returns to previous screen, restores portrait

---

### 7.7 Videos Page (`/videos`)

**Guest view:**
- Shows all published free videos
- Two category filter chips: **Yoga** | **General Workout**
- Selecting a chip filters the list
- Each video card: thumbnail, title, duration, category
- Tap → Video Player (playable without login, free videos only)
- Header: "Videos" title + streak badge top right

**Registered view:**
- Two category tabs: **Yoga** | **General Workout**
- Shows today's sessions from the user's active enrolled course, filtered by selected category
- Each session card: thumbnail/status icon, title, duration, completion badge (✅ / ❌)
- Tap → Video Player → session marked complete
- If no active enrollment → show "No Active Program" state with CTA → Programs page
- If enrolled but today has no sessions in this category → "No [Yoga/General Workout] sessions today"

---

### 7.8 Community Leaderboard (`/community-leaderboard`)

Two tabs: **All Time** | **Your Group**

**Score formula (server-side):**
```
score = (completed_days × 100) + (current_streak × 10)
```

**All Time tab:**
- Ranked list of all users by score (highest first)
- Top 3 shown as a gold/silver/bronze podium
- Full ranked list below
- Each row: rank, avatar initials, name, streak, days completed, score
- Current user's row highlighted in green
- "Your rank: #N" banner pinned at bottom if current user is outside top 10
- Empty state: "Be the first! Complete a session."

**Your Group tab:**
- Same layout as All Time, but filtered to users enrolled in the same active course
- Empty state when user has no active course: "Enroll in a program to see your group"
- Backend: `GET /api/mobile/leaderboard?courseId=<courseId>`

**Access:** Profile → Community Leaderboard menu item
**Also:** Home screen → leaderboard preview "View All" → navigates here

---

### 7.8b Body Metrics Form (`/body-metrics`)

Collects physical measurements. Can be skippable or required depending on context.

**Fields:** Name, Age, Height (cm), Weight (kg), Waist (inches), Hip (inches)

**Behaviour:**
- **At signup** (`?skip=true`): all fields optional; "Skip for Now" button visible; saves if filled, skips if not
- **At cart checkout** (`?skip=false`): all fields required before payment can proceed; no Skip button
- **After course completion** (`?skip=false&courseId=<id>`): required; snapshot linked to that course
- Pre-fills Name from authenticated user's profile
- On save → `POST /api/mobile/profile/body-metrics` → redirect to `?redirect=` param

**Access:** Signup flow → post-registration; Cart → if no metrics exist; Course completed screen → "Log Your Progress" button

---

### 7.8c Body Metrics History (`/body-metrics-history`)

Timeline view of all body metric snapshots for the user.

- Snapshots shown newest-first with date
- "Latest" badge on most recent
- Each snapshot: date, course name (if linked), metrics grid (Age, Height, Weight, Waist, Hip)
- "Add Entry" button in header → body metrics form (skippable, redirect back here)
- Empty state with "Add First Entry" CTA

**Access:** Profile → Personal Details

---

### 7.9 Steps Page (`/steps`)

**Guest:** Full-screen lock state — shows a lock icon and "Login to track your steps" + Login button.

**Registered:**

Syncs with **Google Fit** (Android) or **Apple Health** (iOS) via the `health` Flutter package.

**Display:**
- Large progress ring: steps today vs 10,000 goal
- Stats row: Steps, Distance (km), Calories (kcal), Active Mins
- Speed (avg km/h based on active mins)

**Sync behaviour:**
- Request permissions on first visit
- Fetch fresh data from health API on page open
- Background sync every 30 minutes via `WorkManager` (Android) / `BGTaskScheduler` (iOS)
- On each sync: `POST /api/mobile/steps` with `{ steps, calories, date }`
- Server awards points: +1 per 1,000 steps, max 10 pts/day (idempotent — server calculates delta)

---

### 7.10 Profile Page (`/profile`)

**Header:**
- Green banner with avatar (editable, circular) and user's full name
- Handle: `@firstname_lastname`
- Floating stats card: Sessions | Minutes | Day Streak

**Guest:**
- Name shows "Guest"
- Stats show 0
- Menu item at bottom: **Login** (blue) instead of Logout

**Registered menu items:**
1. **Personal Details** → `/body-metrics-history` (body measurements timeline)
2. **Community Leaderboard** → `/community-leaderboard`
3. **Free Videos** → `/free-videos`
4. **Notifications & Reminders** → `/notifications` (toggle + time picker for daily reminder)
5. **Subscription & Plans** → `/subscriptions` (enrolled courses with status)
6. **Help & Support** → (future — coming soon)
7. **Logout** (red) → signs out Supabase, clears token, → `/unregistered`

**Edit profile:** Tap avatar → bottom sheet with name field + photo picker → saves to Supabase Storage + `PUT /api/mobile/profile`

---

### 7.11 Cart / Checkout (`/cart`)

- Course name, original price, discounted price
- Coupon code input field + Apply button
- Order summary: subtotal, discount, total
- Payment button: "Pay ₹X via Razorpay"
- On tap: open Razorpay payment sheet
- On payment success: `POST /api/mobile/enrollments` with `{ courseId }` → navigate to Day List
- On payment failure: show error snackbar, allow retry

---

### 7.12 Auth Screens

**Login (`/login`):**
- Email + password fields
- "Log In" → `Supabase.signInWithPassword(email, password)`
- On success: fetch profile, navigate to `/home` (or redirect param)
- "Don't have an account? Create one" → `/signup`
- "Continue without login" → `/unregistered`
- Back button → `/unregistered`

**Signup (`/signup`):**
- Name + email + password fields
- "Sign Up" → `Supabase.signUp(email, password)` + `POST /api/auth/sync` with fullName
- On success: redirect to body metrics form (skippable) → then `/home`
- Back button → `/unregistered`

**OTP screen (`/otp`):** Kept in codebase for future Firebase phone OTP integration. Not wired to current auth flow.

---

## 8. Admin Panel

Web dashboard for the yoga teacher to manage all content.

### 8.1 Courses ✅ Implemented
- List all courses with publish status
- Create course: title, slug (auto-generated), description, category (Yoga / General Workout), price (₹), total days, thumbnail URL, published toggle
- Edit course: all same fields via sidebar settings panel
- Delete course (with confirmation modal)
- Per course → manage days:
  - **Add day**: day number, title, description ✅
  - **Edit day**: ❌ not yet — must delete and recreate to fix a day title
  - **Delete day**: ❌ not yet — no delete button on day rows
  - Per day → add sessions:
    - Title, category (Yoga / Workout), duration (seconds)
    - **Video source toggle: YouTube | BunnyNet** ✅
      - YouTube: enter YouTube Video ID
      - BunnyNet: enter Bunny Video ID + Library ID
    - Thumbnail URL (optional)
    - "Free preview" checkbox (visible to guests)
  - Edit session ✅
  - Delete session ✅

### 8.2 Free Videos ✅ Implemented
- List all free videos with status badges
- Add/edit: title, description, category (Yoga / General Workout), duration (seconds), video source toggle (YouTube / BunnyNet), sort order, published toggle
- Delete (with confirmation modal)

### 8.3 Community Moments ✅ Implemented (partial)
- List all moments with publish status
- Add: name, quote, photo URL, avatar URL, streak days, sort order
- Publish/unpublish toggle ✅
- Delete ✅
- **Edit**: ❌ not yet — must delete and re-add to change a quote or name

### 8.4 Users
- Page exists; currently shows registered user list
- **Missing**: stats view (sessions, streak, total points, enrollment) — future

### 8.5 Admin Gaps to Build
| Gap | Impact |
|-----|--------|
| Edit Day (title/description) | Teacher can't fix a typo without deleting the day and all its sessions |
| Delete Day | Can't remove a wrongly added day |
| Edit Community Moment | Can't fix a quote — must delete and recreate |
| Leaderboard view | Admin can't see who's leading |

---

## 9. API Endpoints

### Mobile API (Flutter ↔ Backend)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/mobile/courses` | None | All published courses |
| GET | `/api/mobile/enrollments` | Required | User's enrollments |
| POST | `/api/mobile/enrollments` | Required | Enroll in a course |
| GET | `/api/mobile/courses/:id` | Required | Course days + sessions |
| GET | `/api/mobile/progress` | Required | User stats + completed days |
| POST | `/api/mobile/progress/complete-session` | Required | Mark session complete, award points |
| POST | `/api/mobile/app-open` | Required | Record app open, update streak, award +5 pts |
| GET | `/api/mobile/leaderboard?period=today` | Required | Today's ranked leaderboard |
| GET | `/api/mobile/profile` | Required | User profile (name, avatar) |
| PUT | `/api/mobile/profile` | Required | Update name, avatar |
| POST | `/api/mobile/steps` | Required | Sync steps from health app |
| GET | `/api/mobile/free-videos` | None | All published free videos |
| GET | `/api/mobile/community-moments` | None | All published community moments |
| GET | `/api/mobile/profile/body-metrics` | Required | All body metric snapshots for user (newest first) |
| POST | `/api/mobile/profile/body-metrics` | Required | Save new body metric snapshot |
| GET | `/api/mobile/leaderboard` | Required | All-time leaderboard (add `?courseId=` for group filter) |
| POST | `/api/mobile/payment/create-order` | Required | Create Razorpay order — Phase G |

### Admin API

| Method | Endpoint | Description |
|--------|----------|-------------|
| CRUD | `/api/admin/courses` | Manage courses |
| CRUD | `/api/admin/courses/:id/days` | Manage days |
| CRUD | `/api/admin/courses/:id/days/:day/videos` | Manage sessions |
| CRUD | `/api/admin/videos/free` | Manage free videos |
| CRUD | `/api/admin/community-moments` | Manage moments |

---

## 10. Database Schema

### Existing tables
- `courses` — id, title, slug, description, category, thumbnailUrl, priceInr, totalDays, isPublished
- `course_days` — id, courseId, dayNumber, title, description
- `videos` — id, courseDayId, title, videoSource, youtubeVideoId, bunnyVideoId, bunnyLibraryId, durationSeconds, category, sortOrder, thumbnailUrl
- `free_videos` — id, title, category, videoSource, youtubeVideoId, bunnyVideoId, bunnyLibraryId, durationSeconds, thumbnailUrl, sortOrder, isPublished
- `community_moments` — id, name, quote, photoUrl, avatarUrl, streakDays, sortOrder, isPublished
- `profiles` — id (= auth.users.id), fullName, phone, avatarUrl, fcmToken
- `enrollments` — id, userId, courseId, enrolledAt, isActive
- `daily_progress` — id, userId, courseId, dayNumber, isComplete, completedAt
- `user_stats` — id, userId, currentStreak, longestStreak, totalSessions, mindfulMins, totalCalories, totalSteps, activeCourseId
- `leaderboard_entries` — id, userId, courseId, score, daysCompleted

### New tables — added this session

**`body_metrics`** (`admin/prisma/migrations/add_body_metrics.sql` — must be run in Supabase)
```
id          uuid PK
user_id     uuid FK profiles (CASCADE DELETE)
course_id   uuid FK courses (SET NULL on delete) — optional, links snapshot to a course
recorded_at timestamptz DEFAULT now()
name        text
age         integer
height_cm   numeric(5,1)
weight_kg   numeric(5,1)
waist_in    numeric(5,1)
hip_in      numeric(5,1)
```
Purpose: time-series physical measurements per user, optionally linked to a course

**`profiles` additions** (migration: `add_notification_prefs.sql` — Phase F2)
- `notifications_enabled boolean DEFAULT false`
- `notification_time text` — "HH:MM" e.g. "07:30"

### New tables — still needed

**`daily_points`**
```
id      uuid PK
userId  uuid FK profiles
date    date
points  int
source  enum(session, step, streak, day_complete, program_complete)
createdAt timestamp
```
Purpose: points ledger for weekly graph on home screen (Phase H2)

**`step_logs`**
```
id          uuid PK
userId      uuid FK profiles
date        date UNIQUE per user
steps       int
distanceKm  decimal
calories    decimal
activeMins  int
syncedAt    timestamp
```
Purpose: daily step sync from health apps (Phase E — steps integration)

**`user_stats` additions**
- `totalPoints int` — sum of all time points
- `lastOpenedDate date` — for server-side streak calculation

---

## 11. Implementation Phases

### ✅ Phase A — Auth Isolation (COMPLETE)
Removed mock token bleed. Guest users no longer see authenticated data. Switched auth from phone OTP to Supabase email + password.

### ✅ Phase B — Per-Video Completion + Day Lock (COMPLETE)
Server-side day lock enforced. Per-video tracking via `VideoProgress`. Score formula: `completed_days × 100 + streak × 10`. Admin YouTube/BunnyNet toggle, category field, demo day controls.

### Phase C — Bug Fixes 🔧 (next up)
Three bugs to fix before any new features:
1. **Feedback auth token** — `programs_completed_screen.dart` sends `Bearer mock-user-123`; replace with `ApiService().submitFeedback()`
2. **Cart loading state** — Checkout button shows no spinner during async metrics check
3. **courseId not passed to body metrics** — `/course_completed` doesn't pass courseId so snapshots don't link to the course

### Phase D — Body Metrics Go-Live 📋
Body metrics code is written and on disk. Blocked on user action:
- Run `admin/prisma/migrations/add_body_metrics.sql` in Supabase SQL Editor
- Run `npx prisma generate` in `admin/`
Then verify the 3 body metrics flows (signup → skip, checkout → required, course completed → linked).

### Phase E — Community Leaderboard: Your Group Tab 🏆
1. Backend: add `?courseId=` filter to `/api/mobile/leaderboard`
2. Flutter: `DefaultTabController` with "All Time" + "Your Group" tabs
3. Fix Home screen "View All" leaderboard button → `/community-leaderboard`

### Phase F — Profile Features 👤
Three profile improvements:
1. **Edit Profile** — tap avatar → bottom sheet → name + photo picker → Supabase Storage upload
2. **Notifications & Reminders** — new screen with toggle + time picker; DB migration; API update
3. **Subscription & Plans** — new screen showing enrolled courses with progress and status

### Phase G — Payment (Razorpay) 💳
1. Add `razorpay_flutter` package
2. Backend: `POST /api/mobile/payment/create-order` → Razorpay order creation
3. Flutter: open Razorpay sheet → on success enroll + navigate to thank-you with real order details

### Phase H — Data Accuracy Polish ✨
1. Fix hardcoded course names in Cart, Thank You, Course Completed screens
2. Weekly activity chart: add `GET /api/mobile/points/weekly` endpoint; use real data
3. Fix category chip counts in Videos screen
4. Remove/hide developer simulator before production

### Phase I — Admin Gaps 🔧
1. Edit Day (title/description) — currently can't fix a typo without deleting the day
2. Delete Day — no delete button on day rows
3. Edit Community Moment — can't fix a quote, must delete and recreate

---

## 12. Scalability — 500 Concurrent Users

### 12.1 Load Profile

500 active users is the near-term target. "Concurrent" here means 500 users active within the same hour (e.g. morning yoga rush 7–8am).

Estimated request volume at peak:

| Event | Frequency | Peak req/min |
|-------|-----------|--------------|
| App open (streak update) | Once per user per day | ~50 req/min (clustered morning) |
| Complete session | 2–3 per user per day | ~25 req/min |
| Steps background sync | Every 30 min per user | ~17 req/min |
| Course catalog browse | Multiple times | ~30 req/min (cached) |

**Total peak: ~120 req/min.** This is well within Vercel's limits and Supabase's free tier connection pool. No Redis, no queue, no special infrastructure needed at this scale.

---

### 12.2 Day Lock

**Client-side computation — zero DB queries per lock check.**

The `enrolledAt` date is stored in the `enrollments` record and loaded once when the user opens their program. The Flutter app computes which day is unlocked entirely locally:

```
todayDayNumber = floor((today - enrolledAt).inDays) + 1
isPlayable = (dayNumber == todayDayNumber)
```

- No API call to check if a day is locked
- Works offline after the enrollment record is loaded
- Server re-validates on `complete-session` to prevent spoofed requests (server independently checks `enrolledAt` before marking complete)

**Server validation in `complete-session`:**
```
expectedDay = floor((today - enrollment.enrolledAt).inDays) + 1
if requestedDayNumber != expectedDay → reject with 403
```

---

### 12.3 Session Completion (Concurrency Safety)

`session_completions` uses an `INSERT ... ON CONFLICT DO NOTHING` (upsert) pattern. Unique constraint on `(userId, videoId)` prevents double-completion if the user taps play twice or the network retries.

**Required DB indexes:**
```sql
-- Fast lookup: "what has this user completed today?"
CREATE INDEX idx_session_completions_user_day
  ON session_completions (userId, courseId, dayNumber);

-- Unique guard against double-insert
CREATE UNIQUE INDEX idx_session_completions_unique
  ON session_completions (userId, videoId);
```

`daily_points` inserts are append-only (one row per event). Points cannot be double-awarded because `complete-session` first checks if `session_completions` already has the row — if it does, it returns early without inserting into `daily_points`.

---

### 12.4 Steps Sync (Idempotent by Design)

The background sync fires every 30 minutes from all active users. Two edge cases handled:

**Rapid-fire / duplicate syncs:** `step_logs` has a unique constraint on `(userId, date)`. Every sync does an `upsert` — update if exists, insert if not. Safe under concurrent calls from the same device.

**Points delta:** Server stores the last known `steps` count. On each sync:
```
newPoints = floor(newSteps / 1000) - floor(previousSteps / 1000)
if newPoints > 0 → insert into daily_points (capped at 10 pts/day total)
```
This is idempotent — syncing the same step count twice awards zero additional points.

**Required DB index:**
```sql
CREATE UNIQUE INDEX idx_step_logs_user_date
  ON step_logs (userId, date);
```

---

### 12.5 Leaderboard Query

Today's leaderboard aggregates `daily_points` by `userId` for today's date. At 500 users this is a GROUP BY over ~500–1500 rows (500 users × up to 3 events each). Fast with the right index.

**Required DB index:**
```sql
-- Leaderboard query: SUM(points) WHERE date = today GROUP BY userId
CREATE INDEX idx_daily_points_date_user
  ON daily_points (date, userId);
```

The leaderboard endpoint is called on page open (not on a timer). At 500 users it's ~5 req/min — no caching needed.

---

### 12.6 Database Connection Pooling

Vercel serverless functions are stateless — each cold start opens a new Postgres connection. Without pooling, 500 concurrent requests = 500 connections, which exceeds Supabase's default limit (~100).

**Fix:** Use Supabase's **transaction-mode PgBouncer URL** as the Prisma `DATABASE_URL`:

```
DATABASE_URL="postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres?pgbouncer=true&connection_limit=1"
```

- `pgbouncer=true` tells Prisma to disable prepared statements (required for transaction mode)
- `connection_limit=1` — each serverless function uses one connection from the pool
- PgBouncer pool has up to 200 connections; at 120 req/min peak, connections are returned within milliseconds

This is a configuration change (environment variable), not a code change.

---

### 12.7 Static Data Caching

Course catalog and free videos change rarely (only when admin publishes something). Cache these at the Vercel Edge:

| Endpoint | Cache strategy | TTL |
|----------|---------------|-----|
| `GET /api/mobile/courses` | `Cache-Control: s-maxage=60, stale-while-revalidate=300` | 1 min fresh, 5 min stale |
| `GET /api/mobile/free-videos` | Same | 1 min |
| `GET /api/mobile/community-moments` | Same | 1 min |
| All other endpoints | No cache (user-specific data) | — |

This means 500 users opening the app simultaneously fire ~1 DB query for courses (cached response for the rest), not 500.

---

### 12.8 Multiple Enrollments (One Active at a Time)

The current data model supports enrolling in multiple courses but the app UI only surfaces **one active course** at a time (via `user_stats.activeCourseId`). This is intentional — the Videos page, home banner, and day lock all operate on a single "active" course.

Rules:
- Enrolling in a new course sets it as `activeCourseId`
- Previous course stays in `enrollments` (shows in Completed/Active tabs) but is no longer the "active" one for day lock and session tracking
- A user who enrolled in Course A on June 1 and Course B on June 10 has:
  - Course A: Day 10 unlocked on June 10 (still tracks independently)
  - Course B: Day 1 unlocked on June 10 (active course)
  - The Videos page shows Course B sessions (active)
  - Course A progress is still visible in the Active programs tab

**Implication for day lock:** `complete-session` uses the `enrolledAt` from the specific course's enrollment record — not from `activeCourseId`. Each course tracks its own day unlock independently.

---

### 12.9 Scalability Summary

At 500 users, **no infrastructure changes** are needed beyond:

| Item | Action |
|------|--------|
| PgBouncer pooler URL | Switch `DATABASE_URL` to Supabase transaction-mode pooler |
| DB indexes | Add 4 indexes (listed above in 12.3, 12.4, 12.5) |
| Vercel plan | Confirm on Pro plan (1000 concurrent requests vs 100 on Hobby) |
| Static cache headers | Add `Cache-Control` to 3 public endpoints |

Everything else — day lock, session completion safety, steps idempotency, leaderboard query — is already handled correctly by the data model design.

---

## 13. Build Status

| Feature | Status | Phase |
|---------|--------|-------|
| Live courses + free videos + community moments | ✅ | — |
| Guest vs registered routing + navigation shell | ✅ | — |
| Unregistered home screen (3 courses, 2 free videos, moments) | ✅ | — |
| Programs screen (3 tabs, live data) | ✅ | — |
| Program detail page (per-video ticks, lock status) | ✅ | — |
| Free videos screen | ✅ | — |
| Video player (YouTube + BunnyNet) | ✅ | — |
| Streak badge (home / programs / videos headers) | ✅ | — |
| Login prompt popup (shared widget) | ✅ | — |
| Community moments admin + API + Flutter | ✅ | — |
| Admin course CRUD + session CRUD (YouTube/Bunny toggle) | ✅ | — |
| Admin free videos CRUD | ✅ | — |
| Admin community moments add/delete/publish toggle | ✅ | — |
| Admin demo day controls | ✅ | — |
| Admin reset progress | ✅ | — |
| Auth token isolation (no mock bleed) | ✅ | A |
| Supabase email + password auth | ✅ | A/B |
| Session-level completion tracking (VideoProgress) | ✅ | B |
| Day lock logic (strict daily, client + server-side) | ✅ | B |
| Session status icons (✅ ❌ 🔒) | ✅ | B |
| Score formula (days × 100 + streak × 10) | ✅ | B |
| Real leaderboard (top 10, podium, user rank) | ✅ | B |
| Home screen (real stats, real course banner, real leaderboard preview) | ✅ | B |
| Profile screen (real name, avatar, stats) | ✅ | B |
| Body metrics form (signup, cart, post-course) | ✅ code | D (needs SQL) |
| Body metrics history screen | ✅ code | D (needs SQL) |
| Community leaderboard full page (All Time) | ✅ | — |
| Feedback auth token fix | ❌ bug | C |
| Cart loading state | ❌ bug | C |
| courseId passed to body metrics post-course | ❌ bug | C |
| Body metrics SQL migration run in Supabase | ❌ user action | D |
| Community leaderboard "Your Group" tab | ❌ | E |
| Home "View All" leaderboard → /community-leaderboard | ❌ | E |
| Edit profile (name + avatar upload) | ❌ | F |
| Notifications & Reminders screen | ❌ | F |
| Subscription & Plans screen | ❌ | F |
| Payment (Razorpay) | ❌ | G |
| Hardcoded course names (Cart, Thank You, Completed) | ❌ | H |
| Weekly activity chart (real daily_points data) | ❌ | H |
| Category chip counts in Videos | ❌ | H |
| Admin edit day / delete day | ❌ | I |
| Admin edit community moment | ❌ | I |
| Steps (Google Fit / Apple Health) | ❌ | future |
| Push notifications (FCM) | ❌ | future |
