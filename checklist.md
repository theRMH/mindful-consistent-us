# QA Checklist — Mindful (Consistent US)

Before handing any build to the client, run through the relevant section(s) below.
Check off each item as you confirm it works. Flag anything that fails with a note.

**Legend:** ✅ Pass · ❌ Fail (add note) · ⏭ Skip (not applicable this build)

---

## SECTION 1 — Flutter App: Login & Register Screens

- [ ] Login screen renders correctly (logo, leaf background, white card, country code `+91`, phone input, pill button)
- [ ] Tapping "Log in" with empty field shows an error / disables submit
- [ ] Tapping "Register Now" navigates to the Register screen
- [ ] Register screen renders correctly (same design language as Login)
- [ ] Tapping "Already have an Account? Log in" returns to Login screen
- [ ] No overflow/layout errors on small screen (e.g. 5" device or small emulator)

---

## SECTION 2 — Flutter App: Unregistered Home Screen

- [ ] Guest home screen loads without crash
- [ ] Course cards display: name, price (₹), duration, daily commitment
- [ ] Free preview video cards are visible in horizontal row
- [ ] Tapping a premium course prompts login/register (does not crash or navigate into the course)
- [ ] Community quote cards render correctly
- [ ] Bottom navigation bar shows 5 tabs; locked tabs redirect to login
- [ ] No overflow or clipped text on course cards

---

## SECTION 3 — Flutter App: Home Screen (Registered User)

### 3a. Weekly Activity Bar Chart
- [ ] Bar chart is visible on home screen
- [ ] Bars have a green gradient (lighter top, darker bottom)
- [ ] Each bar has an emoji circle cap at the top
- [ ] The current/highlighted bar shows a value badge pill (e.g. "1.2K")
- [ ] Day labels (Mon, Tue, etc.) appear below each bar
- [ ] No bars overflow their container

### 3b. Community Leaderboard
- [ ] Top 3 users are shown in podium layout (1st centre, 2nd left, 3rd right)
- [ ] Rank badge circles use correct colours: gold (#1), silver (#2), bronze (#3)
- [ ] Podium blocks appear at the bottom of each column
- [ ] "Your Rank" section is visible below the podium
- [ ] A vertical divider separates "Your Rank" label from the rank number
- [ ] Names and scores display without overflow
- [ ] Leaderboard card has consistent spacing (`spaceEvenly`)

### 3c. Stats & General
- [ ] Mindful Mins, Steps, Calories display (mock values OK at this stage)
- [ ] Progress circle shows percentage
- [ ] Active course card shows course name and day index
- [ ] Streak calendar renders with correct day highlights
- [ ] No layout overflow on any widget on the home screen

---

## SECTION 4 — Flutter App: Profile Screen

- [ ] Profile screen loads without crash
- [ ] Header background is solid green (`#019948`)
- [ ] Header bottom corners are rounded (large radius)
- [ ] Avatar has a gold-coloured border ring
- [ ] Stats card (Sessions · Minutes · Day Streak) overlaps the header/body boundary — not pushed below
- [ ] Stats numbers are readable (not too large, not clipped)
- [ ] 🔥 fire emoji appears next to the streak stat
- [ ] A vertical divider separates the three stat columns
- [ ] Menu items appear directly on the light gray background — **no white card/box wrapper**
- [ ] Four menu items visible: My Profile, Subscription & Plans, Settings, Logout
- [ ] Logout is styled in red
- [ ] Tapping each menu item does not crash (navigation or placeholder is fine)
- [ ] No layout overflow in header or stats card

---

## SECTION 5 — Admin Panel: Create New Course

- [ ] `/dashboard/courses/new` page loads correctly
- [ ] Title field auto-generates the slug as you type
- [ ] **Category dropdown is visible** with two options: Yoga, General Workout
- [ ] Category defaults to "Yoga"
- [ ] Submitting the form with all fields saves the course and redirects to courses list
- [ ] The saved course appears in the courses list
- [ ] **Open the saved course in DB / Prisma Studio → confirm `category` column has the correct value** (e.g. `yoga`)
- [ ] Submitting without Title or Total Days shows an error (required field validation)
- [ ] Thumbnail URL field is optional — form submits without it

---

## SECTION 6 — Admin Panel: Edit Course — Settings + Category

- [ ] Open an existing course → `/dashboard/courses/[courseId]`
- [ ] Program Settings panel shows on the right sidebar
- [ ] **Category dropdown is visible** with Yoga / General Workout options
- [ ] Current category value is pre-selected (not always defaulting to Yoga)
- [ ] Change category → click "Save Settings"
- [ ] **Reload the page → confirm the correct category is still selected** (persisted to DB)
- [ ] Other fields (Title, Slug, Price, Total Days, Thumbnail, Publish toggle) still save correctly alongside category

---

## SECTION 7 — Admin Panel: Edit Course — Add Video (YouTube/BunnyNet Toggle)

- [ ] Click "Link Video" on any day → Add Video form appears in sidebar
- [ ] **Video Source toggle is visible with two buttons: BunnyNet | YouTube**
- [ ] BunnyNet is selected by default (green active state)
- [ ] When BunnyNet selected → two fields visible: "Bunny Video ID" and "Bunny Library ID"
- [ ] When YouTube selected → button turns red; only one field visible: "YouTube Video ID"
- [ ] BunnyNet fields are hidden when YouTube is selected (and vice versa)
- [ ] **Save a BunnyNet video** → appears in the day's video list with label "Bunny: [id]"
- [ ] **Save a YouTube video** → appears in the day's video list with label "YouTube: [id]"
- [ ] Submit with BunnyNet selected but empty Bunny Video ID → shows error (required)
- [ ] Submit with YouTube selected but empty YouTube Video ID → shows error (required)
- [ ] After saving, the form resets and the video source toggle returns to BunnyNet default
- [ ] Category select in video form (Yoga / Workout) still works correctly

---

## SECTION 8 — Admin Panel: Free Videos (YouTube/BunnyNet + Category)

- [ ] `/dashboard/free-videos` page loads correctly
- [ ] "Add Free Video" button opens the modal
- [ ] **Category is a dropdown** (not a free-text input) with Yoga / General Workout
- [ ] **Video Source toggle is visible: BunnyNet | YouTube**
- [ ] BunnyNet selected → Bunny Video ID + Library ID fields shown
- [ ] YouTube selected → only YouTube Video ID field shown
- [ ] **Save a BunnyNet free video** → table row shows green "Bunny" label + ID
- [ ] **Save a YouTube free video** → table row shows red "YT" label + ID
- [ ] **Edit an existing BunnyNet video** → modal opens with BunnyNet toggle pre-selected and correct IDs loaded
- [ ] **Edit an existing YouTube video** → modal opens with YouTube toggle pre-selected and correct YouTube ID loaded
- [ ] Edit and save → correct data persisted (check table row updates)
- [ ] Delete a video → confirmation modal appears → video removed from list after confirm
- [ ] Category dropdown in table shows readable labels (not raw DB values like `general_exercise`)

---

## SECTION 9 — Admin Panel: General Regression

- [ ] Dashboard overview page loads without error
- [ ] Courses list page loads and shows existing courses
- [ ] Users page loads
- [ ] No console errors in browser DevTools on any admin page
- [ ] All previously working features still work (courses list, add day, delete course)

---

## SECTION 10 — Database Verification (Run after Phase 1 deploy)

Run these checks in **Prisma Studio** (`npx prisma studio`) or directly in Supabase Table Editor:

- [ ] `courses` table has a `category` column of type `TEXT`
- [ ] Courses created after the migration have a `category` value (`yoga` or `general_exercise`)
- [ ] Courses created before the migration have `category = NULL` (no crash, backwards compatible)
- [ ] `videos` table has `video_source`, `youtube_video_id`, `bunny_video_id`, `bunny_library_id` columns
- [ ] A YouTube video row has `video_source = 'youtube'`, `youtube_video_id` populated, `bunny_video_id = NULL`
- [ ] A BunnyNet video row has `video_source = 'bunny'`, `bunny_video_id` populated, `youtube_video_id = NULL`
- [ ] Same checks for `free_videos` table

---

## SECTION 11 — Cross-cutting / Devices

- [ ] Flutter app tested on Android emulator (or physical device)
- [ ] Flutter app tested on iOS simulator (or physical device) if available
- [ ] No text overflow (`RenderFlex overflowed` errors) in debug console
- [ ] No `null` dereference crashes in debug console
- [ ] Admin panel tested in Chrome
- [ ] Admin panel layout is usable on 1280px wide screen (laptop)

---

---

## SECTION 12 — Phase 2: Streak Calculation

> Run after deploying the updated `complete-day` endpoint. Use `Authorization: Bearer mock-user-123` for all requests in dev.

- [ ] Call `POST /api/mobile/progress/complete-day` with a valid `courseId` + `dayNumber` → response has `success: true`
- [ ] Check `user_stats.current_streak` in DB → value is `1` on first ever completion
- [ ] Call again for a **different day** on the **same calendar date** → streak does NOT increment again (stays same value)
- [ ] Wait until next calendar day, complete another day → streak increments to `2`
- [ ] Skip a day, complete a day → streak resets to `1`
- [ ] `longest_streak` in DB is always ≥ `current_streak`
- [ ] Completing a day that is **already complete** → returns `200` with `"Day already completed"`, no double-increment

---

## SECTION 13 — Phase 2: Leaderboard (Real Data, No Mocks)

- [ ] `GET /api/mobile/leaderboard` returns `{ entries: [...], userRank: ... }` (not a plain array)
- [ ] `entries` array contains only real users from DB (no hardcoded Priya S / Rohit K)
- [ ] Each entry has: `rank`, `name`, `avatarUrl`, `streak`, `score`, `daysCompleted`, `isCurrentUser`
- [ ] `isCurrentUser: true` on the entry that matches the calling user's ID
- [ ] `userRank` is a number (the caller's position in the full list), or `null` if no entry exists yet
- [ ] If DB has no entries, response is `{ entries: [], userRank: null }` — no crash
- [ ] Same user with multiple snapshot dates appears only once (highest score)

---

## SECTION 14 — Phase 2: Profile Endpoint

- [ ] `GET /api/mobile/profile` returns `{ id, fullName, phone, avatarUrl, email }` for the authenticated user
- [ ] `GET` without auth token → `401 Unauthorized`
- [ ] `PUT /api/mobile/profile` with `{ "fullName": "Test Name" }` → updates name, returns updated profile
- [ ] `PUT` with `{ "avatarUrl": "https://example.com/pic.jpg" }` → updates only avatarUrl, fullName unchanged
- [ ] `PUT` with empty body `{}` → no fields changed, returns current profile (no crash)
- [ ] `PUT` without auth token → `401 Unauthorized`

---

## SECTION 15 — Phase 3: Flutter Core Data Wiring

> Run the Flutter app connected to the local admin server (`npm run dev` in `admin/`). Use Android emulator.

- [ ] App launches without crash (no red screen, no `null` exceptions in debug console)
- [ ] Home screen loads — stats show `0` values (not mock 1250 steps / 25 mins / 3 streak) — confirms real API is being hit
- [ ] Leaderboard section shows empty state or real DB entries — **no hardcoded Priya S / Rohit K names**
- [ ] Console (VS Code / Android Studio) shows no `Failed to connect to backend` errors
- [ ] If backend is NOT running: app shows graceful error state (not a crash) — `error` field in provider triggers UI error message
- [ ] iOS simulator: change `apiBaseUrl` to `http://localhost:3000` via `--dart-define=API_BASE_URL=http://localhost:3000` and confirm it connects
- [ ] Physical device: run with `--dart-define=API_BASE_URL=http://<local-ip>:3000` and confirm it connects

---

## SECTION 16 — Phase 4: Programs Screen (Real Data)

> Run with admin server running. Ensure at least one course exists in DB.

- [ ] Programs screen loads without crash (no red screen)
- [ ] **Active tab**: shows enrolled courses (empty if not enrolled — not a crash)
- [ ] **Completed tab**: shows courses where all days are completed (empty is fine)
- [ ] **Explore tab**: shows non-enrolled courses from DB (real titles/prices, not mock)
- [ ] Explore course card shows real price in ₹ (e.g. `₹1,999`) from DB
- [ ] Explore course card shows category label: "Yoga" or "General Workout"
- [ ] Course thumbnail: if `thumbnailUrl` is set → shows network image; if null → shows `icon_asana.png` (yoga) or `icon_kriya.png` (workout)
- [ ] Tapping "Enroll" on an Explore course → course moves to Active tab (after reload)
- [ ] Active tab progress ring shows correct % (`completedDays / totalDays`)
- [ ] Loading indicator shows briefly while courses are fetching
- [ ] Error state: if backend is down, shows error message — no crash
- [ ] Enrolling a course navigates or stays on Programs screen (no crash or hang)

---

## SECTION 17 — Phase 5: Day List Screen (Real API + Expandable Videos)

> Run with backend running. Enroll in a course first (via Explore tab). Use Android emulator.

- [ ] Tap an active course on Programs screen → navigates to Day List screen
- [ ] App bar shows real course title (not hardcoded "30-Day Yoga Journey")
- [ ] Header shows correct "X of Y Days Completed" from real progress data
- [ ] Progress circle in header reflects real completion ratio
- [ ] **Day 1 is unlocked** (shows ▶️ play icon, available on enrollment date)
- [ ] **Day 2+** are locked if `enrolledAt + (dayNumber - 1) days > today`
- [ ] Locked day shows "Unlocks DD Mon" subtitle with correct calendar date
- [ ] Completed days show ✅ green check icon and "Completed" subtitle
- [ ] Today's unlocked day shows "Today's practice" subtitle in gold
- [ ] Tapping a locked day does nothing (no crash, no expansion)
- [ ] Tapping an unlocked day **expands** the card to show its video list
- [ ] Tapping again **collapses** the card (accordion toggle)
- [ ] Expanded card shows: category icon (asana/kriya), video title, duration pill, play button per video
- [ ] Tapping a video play button navigates to `/play` screen with correct video title in app bar
- [ ] Completing a video in `/play` screen (80% watched or "Complete Session" tapped) → returns; day progress updates
- [ ] Back button from Day List → returns to Programs screen Active tab
- [ ] Loading spinner shows while course data is fetching
- [ ] Error state: if course API fails, shows error message — no crash
- [ ] Day list scrolls smoothly if course has 21+ days (bouncing physics)
- [ ] Day card title shows real day title if set (e.g. "Day 1: Introduction to Yoga"), or just "Day 1" if no title

---

## SECTION 18 — Phase 6: Video Player (BunnyNet + Landscape)

> Test on physical device or emulator with the admin backend running.

### Orientation
- [ ] Opening any video from the Day List screen → screen rotates to landscape automatically
- [ ] System status bar + navigation bar are hidden (full immersive mode)
- [ ] Tapping back / "Complete Session & Back" → screen returns to portrait
- [ ] Portrait orientation is fully restored (no stuck landscape after navigating away)

### YouTube player
- [ ] YouTube video plays automatically in landscape
- [ ] Progress bar is visible (green)
- [ ] At 80% watched → snackbar "Progress saved! Day X completed." appears automatically
- [ ] "Complete Session & Back" button is visible and tappable below the player
- [ ] Tapping "Complete Session & Back" marks day complete and navigates back

### BunnyNet player
- [ ] BunnyNet video plays in the WebView embed (full-screen black background)
- [ ] Back arrow (top-left overlay) is visible over the video
- [ ] "Complete Session & Back" button (bottom overlay) is visible over the video
- [ ] Tapping the back arrow → portrait restored, navigates back
- [ ] Tapping "Complete Session & Back" → marks day complete, restores portrait, navigates back
- [ ] BunnyNet video loads without white flash or crash (requires internet)

### Edge cases
- [ ] Tapping "Complete Session & Back" twice does not double-call `markDayComplete` (idempotent guard)
- [ ] Navigating back without completing → day not marked as complete, no crash
- [ ] Video with missing `bunnyVideoId` (null) → WebView loads an empty page gracefully, no crash

---

## SECTION 19 — Phase 7: Home Screen (Real Stats + Leaderboard + Active Course)

> Run with backend running and at least one enrolled course in the DB.

### Active Course Banner
- [ ] Banner shows real course title (not hardcoded "30-Day Yoga Journey")
- [ ] Day pill shows correct `Day X of Y` (e.g. "Day 1 of 30" for a fresh enrollment)
- [ ] Day strip shows 7 days centred on the current day
- [ ] Completed days show green filled circle with day number
- [ ] Current day shows gradient ring with white inner circle and the day number
- [ ] Future days show dark circle with lock icon
- [ ] Progress bar text reads `"X of Y Days Completed"` with real numbers
- [ ] Progress bar fill reflects real completion ratio
- [ ] If no active course: banner shows "No Active Course" gracefully

### Stats Row
- [ ] Mins stat shows real `mindfulMins` value (not mock)
- [ ] Sessions stat shows real `totalSessions` value
- [ ] Calories stat shows real `calories` value
- [ ] **Goal % stat shows correct computed value** (completedDays / totalDays × 100) — not `80%`
- [ ] All four stats display without overflow

### Community Leaderboard
- [ ] Podium shows real user names from DB (not "Abdul Ashik", "Joyashri", "Priya M")
- [ ] Podium scores are real (not hardcoded `2,840 pts` etc.)
- [ ] If leaderboard has 0 entries → shows "No leaderboard data yet" (no crash)
- [ ] If leaderboard has 1–2 entries → only available slots filled, empty slots show `–`
- [ ] "Your Rank" shows real rank number (or `–` if not yet ranked)
- [ ] "Your Rank" score shows real pts (or `No score yet` if none)
- [ ] After completing a day → leaderboard updates on next home screen visit

---

## SECTION 20 — Phase 8: Profile Screen (Real Data) + Steps Sync

> Run with backend running and a profile row in the DB for `mock-user-123`.

### Profile name & avatar
- [ ] Profile screen loads without crash when backend is running
- [ ] Name in header shows real `fullName` from DB (not hardcoded "KalanithiAK")
- [ ] Handle under name reflects the real `fullName` (e.g. `@priya_sharma`)
- [ ] If user has a non-empty `avatarUrl` → `Image.network` loads it (not `avatar_rohit.png`)
- [ ] If `avatarUrl` is null or empty → initials circle shown (first letter of name)
- [ ] If network avatar fails to load → initials circle shown as fallback (not crash)
- [ ] While profile is loading → auth fallback name shown (no blank/null text visible)

### Stats card (real values)
- [ ] Sessions stat shows `ps.completedSessionsToday` (real total sessions, not `142`)
- [ ] Minutes stat shows `ps.mindfulMins` (derived from `totalWatchSeconds / 60`, not `2,850`)
- [ ] Day Streak shows `ps.currentStreak` (real streak, not `12`)
- [ ] After completing a day → profile screen stats update on next visit

### Admin: Steps sync endpoint
- [ ] `POST /api/mobile/steps` with `{ steps: 1000, calories: 40.0 }` returns `{ success: true }`
- [ ] `user_stats.totalSteps` increments by the posted value
- [ ] `user_stats.totalCalories` increments by the posted value
- [ ] Calling with no body (empty `{}`) → no crash, no-op (steps/calories default to 0)
- [ ] Calling without auth → 401 response

---

## SECTION 21 — Phase 9: Supabase Phone OTP Auth + Admin Settings Page

> Requires Supabase Phone Auth enabled and test numbers added in Supabase dashboard.
> Run: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=API_BASE_URL=http://10.0.2.2:3000`

### OTP Login flow
- [ ] Enter phone (+91 format) → taps "Log in" → OTP screen appears (not home screen directly)
- [ ] OTP screen shows correct phone number in subtitle
- [ ] Enter correct 6-digit OTP → navigates to `/home`
- [ ] Enter wrong OTP → stays on OTP screen, shows error snackbar with Supabase error message
- [ ] Tap "Resend Code" → calls real OTP resend → timer resets to 30 s
- [ ] Resend fails (rate-limited) → shows error snackbar (not crash)

### OTP Signup flow
- [ ] Signup screen → enter phone → taps register → OTP screen appears
- [ ] Completing OTP → `POST /api/auth/sync` creates `profiles` + `user_stats` rows in DB
- [ ] Navigates to `/home` after successful OTP verification

### Session restore
- [ ] Verify OTP → kill app → relaunch → app opens directly on `/home` (not `/unregistered`)
- [ ] `ApiService` uses the Supabase access token (not `mock-user-123`) in Authorization header
- [ ] Token refreshes automatically (Supabase handles silently)

### Logout
- [ ] Tap Logout → navigates to `/unregistered`
- [ ] Relaunch app after logout → opens `/unregistered` (session cleared)

### Admin Settings page
- [ ] `/dashboard/settings` loads without errors
- [ ] Env vars table shows ✓/✗ correctly for all 4 vars
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` shows ✗ Missing until filled in `.env`
- [ ] Flutter commands section: shows amber warning when anon key is missing
- [ ] Flutter commands section: shows pre-filled `--dart-define` commands once keys are set
- [ ] "Copy" button on each command copies the single-line version to clipboard
- [ ] "Open Dashboard" button links to the correct Supabase project URL
- [ ] Test credentials table shows both dev phone numbers
- [ ] API Reference table lists all 13 endpoints with correct methods

---

## How to Use This File

1. Before each client delivery, copy the relevant sections into a new checklist run (or just tick these boxes).
2. Any item that fails: add a short note inline — `❌ Profile stats card clips on iPhone SE`.
3. The note becomes the bug to fix before the next delivery.
4. Once all items for the delivered scope are ✅, the build is client-ready.
