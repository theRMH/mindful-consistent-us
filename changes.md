# Change Log — Mindful Project

This file keeps track of all codebase changes, files created, and system modifications so any developer or AI assistant can pick up immediately.

## [2026-06-05] — Initial Setup and Database Layout

### Added
- **Database Migrations:** Created SQL migration scripts under `database/migrations/` to represent the Supabase PostgreSQL structure:
  * [`001_initial_schema.sql`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/database/migrations/001_initial_schema.sql): Defines the tables (`profiles`, `courses`, `course_days`, `videos`, `free_videos`, `enrollments`, `video_progress`, `daily_progress`, `user_stats`, `leaderboard_entries`, and `feedback`).
  * [`002_rls_policies.sql`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/database/migrations/002_rls_policies.sql): Restricts user read/write access to their own data only using Supabase Row Level Security.
  * [`003_triggers.sql`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/database/migrations/003_triggers.sql): Database triggers to sync user stats upon daily progress updates, and automatically insert profile details on new auth signups.
  * [`004_views.sql`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/database/migrations/004_views.sql): Dynamically calculates leaderboard score ranking using window partitions.
- **Product Requirements Document:**
  * [`prd.md`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/prd.md): Defines all screen features and requirements based on the Figma "Completed" section.
- **Change Log:**
  * [`changes.md`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/changes.md): This file, tracking project developments.
- **Project Scaffolding:**
  * Scaffolded Next.js App in `admin/` (Next.js 14, TypeScript, Tailwind, App Router, ESLint).
  * Scaffolded Flutter App in `app/` (Flutter SDK 3.44.1, Bundle ID `com.consistentus`).
- **Backend API Development:**
  * Created global Prisma database client helper: [`prisma.ts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/lib/prisma.ts).
  * Created Supabase admin client configuration: [`supabase.ts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/lib/supabase.ts).
  * Created session token authorization middleware: [`auth-middleware.ts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/lib/auth-middleware.ts).
  * Implemented access gating rule: [`day-lock.ts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/lib/day-lock.ts).
  * Added Bunny.net token authentication generator: [`bunny.ts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/lib/bunny.ts).
  * Added serverless routes: `/api/courses` (GET courses), `/api/videos/free` (GET free videos), `/api/auth/sync` (POST sync user profiles), `/api/courses/[courseId]/days/[dayNumber]` (GET course day content), and `/api/videos/[videoId]/token` (GET secure HLS playback URL).
- **Flutter Scaffolding:**
  * Configured dependencies in [`pubspec.yaml`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/pubspec.yaml) and removed the unused Windows desktop subfolder.
  * Added design system tokens and fonts setup: [`theme.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/core/config/theme.dart).
  * Created project keys and mocking switch: [`app_config.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/core/config/app_config.dart).
  * Setup GoRouter navigation shell and bottom navigation bar paths: [`routes.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/core/config/routes.dart).
  * Created Riverpod providers for authorization ([`auth_provider.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/providers/auth_provider.dart)) and exercise step tracking ([`progress_provider.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/providers/progress_provider.dart)).
- **Flutter Screen Implementation (Figma "Completed" Section):**
  * Created onboarding and login workflow: [`login_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/auth/login_screen.dart) and [`signup_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/auth/signup_screen.dart).
  * Developed guest browsing hub with program details: [`unregistered_home_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/explore/unregistered_home_screen.dart).
  * Designed active dashboard with custom animated progress rings, calories, mindful minutes, and step-simulation events: [`home_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/home/home_screen.dart).
  * Built course directory list details: [`explore_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/explore/explore_screen.dart).
  * Integrated day session locks, unlocks, and progress updates: [`day_list_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/my_courses/day_list_screen.dart).
  * Added course completion success views: [`programs_completed_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/my_courses/programs_completed_screen.dart).
  * Updated main app bootstrap script: [`main.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/main.dart).
- **Git & GitHub Integration:**
  * Created root-level [`.gitignore`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/.gitignore) to exclude local configs and platform-specific assets.
  * Initialized Git, added origin `https://github.com/theRMH/mindful-consistent-us`, and pushed initial commits to the `main` branch.

- **Admin Dashboard Completion:**
  * Updated [`page.tsx`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/page.tsx) to automatically redirect standard homepage requests to the admin `/dashboard`.
  * Updated GET endpoint in [`route.ts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/api/videos/free/route.ts) to support query parameter `all=true` for fetching drafts and published free videos.
  * Created new REST control endpoint [`route.ts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/api/videos/free/[id]/route.ts) supporting `PATCH` / `PUT` updates and `DELETE` requests for free videos.
  * Designed and built `/dashboard/free-videos` CRUD page [`page.tsx`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/dashboard/free-videos/page.tsx) to list, add, edit, and delete free preview videos.
  * Built searchable user profiles and progress logs directory page [`page.tsx`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/dashboard/users/page.tsx).

- **UI Polish & Reviews Integration:**
  * Fixed cropped back button SVG path in [`page.tsx`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/dashboard/courses/[courseId]/page.tsx) and [`page.tsx`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/dashboard/courses/new/page.tsx).
  * Added course thumbnail URL support to the new course creation form [`page.tsx`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/dashboard/courses/new/page.tsx).
  * Added `PATCH` (update metadata) and `DELETE` (delete course) endpoints to [`route.ts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/api/courses/[courseId]/route.ts).
  * Designed and built **Program Settings** metadata editing panel & **Delete Program** actions inside [`page.tsx`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/dashboard/courses/[courseId]/page.tsx).
  * Implemented `POST` feedback endpoint in [`route.ts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/admin/src/app/api/feedback/route.ts) with user authorization verification and local mock-auth bypass.
  * Added "Share Your Feedback" dialog modal and POST submission requests to Flutter completed screen [`programs_completed_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/my_courses/programs_completed_screen.dart) alongside syntax checks.

- **Login Screen Redesign & Build Fixes:**
  * Added dependency overrides in [`pubspec.yaml`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/pubspec.yaml) for `path_provider_foundation` to use version `2.4.0` to remove the transitive `objective_c` dependency, resolving the Windows path-with-space build failure.
  * Commented out the `ndkVersion` in [`build.gradle.kts`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/android/app/build.gradle.kts) to bypass large NDK checks and downloads for debug mode.
  * Copied and registered the Figma logo and background leaf assets (`logo.png` and `bg_leaf.png`) inside the `app/assets/` directory.
  * Created reusable brand widgets: [`brand_logo.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/widgets/brand_logo.dart) and [`background_leaves.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/widgets/background_leaves.dart).
  * Completely redesigned the authentication page [`login_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/auth/login_screen.dart) to align pixel-perfectly with [Log in.png](file:///C:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/reference%20image/Log%20in.png), including the rounded central form container, unified country code picker input field, pill buttons, and security notice details.

- **Register Screen Redesign:**
  * Completely redesigned the registration page [`signup_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/auth/signup_screen.dart) to match [Register.png](file:///C:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/reference%20image/Register.png) exactly, sharing the curved white header card, brand logo, background leaves, rounded central form card, unified country code selector, and "Already have an Account ? Log in" redirect footer.

- **Unregistered User Home Screen Redesign:**
  * Copied and registered figma image assets (`unreg_header_bg.png`, `course_30_days.png`, `course_48_days.png`, `video_morning_flow.png`, `video_sleep_prep.png`, `community_priya.png`, `avatar_priya.png`, `community_rohit.png`, `avatar_rohit.png`) inside the `app/assets/` directory.
  * Completely redesigned the guest home dashboard [`unregistered_home_screen.dart`](file:///c:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/app/lib/presentation/screens/explore/unregistered_home_screen.dart) to align pixel-perfectly with [Unregistered user.png](file:///C:/Users/Arsath%20Haneef/Downloads/H/RMH/Mindful/reference%20image/Unregistered%20user.png), including the customized header banner, price-badge course cards, horizontal free videos row, community quote cards, and 5-tab bottom guest navigation bar with login prompts.

---

## [2026-06-07] — Flutter UI Redesigns (Home, Leaderboard, Profile)

### Changed
- **Home Screen — Weekly Activity Bar Chart** [`home_screen.dart`](app/lib/presentation/screens/home/home_screen.dart)
  - `_buildBar` fully rewritten: gradient bars using `LinearGradient` (green tones), emoji circle cap via `Stack` + `Positioned`, value badge pill for highlighted (current) day.

- **Home Screen — Community Leaderboard** [`home_screen.dart`](app/lib/presentation/screens/home/home_screen.dart)
  - `_buildLeaderItem`: rank badge circles (gold/silver/bronze) via `Stack + Positioned`, podium block at bottom of each column.
  - `_buildLeaderboardCard`: Row changed to `spaceEvenly`, "Your Rank" section has `VerticalDivider` + cleaner layout.

- **Profile Screen — Full redesign** [`profile_screen.dart`](app/lib/presentation/screens/profile/profile_screen.dart)
  - Complete rewrite to match Figma.
  - Header: pure `figmaGreen` background, `borderRadius bottomLeft/bottomRight: 72`, header bottom padding `100`, avatar with gold border `Color(0xFFFFD700)`.
  - Stats card: `Stack + Positioned` at `bottom: -52`, `SizedBox(height: 68)` spacer after Stack.
  - Stats: `IntrinsicHeight + VerticalDivider`, fire stat uses 🔥 emoji, font size reduced to `20px`.
  - Menu: plain `Column` directly on `Color(0xFFF7F7F7)` background — no white card wrapper.
  - Each menu tile: `Padding(vertical: 10)`, `InkWell(borderRadius: 14)`.
  - Menu items: My Profile, Subscription & Plans (`Icons.credit_card_rounded`), Settings, Logout (red, `Icons.logout_rounded`).

---

## [2026-06-09] — Backend Integration Plan + Phase 1 Admin Changes

### Added
- **Integration Plan** [`ai-plan/integration-plan.md`](ai-plan/integration-plan.md)
  - 9-phase plan to connect Flutter app to real backend data (replacing all mock data).
  - Phases: Admin content/category (1) → Streak/Leaderboard (2) → Flutter core wiring (3) → Courses/Programs (4) → Day list (5) → Video player (6) → Home stats (7) → Profile/Steps (8) → Supabase OTP auth (9).

- **DB Migration — Course Category** [`database/migrations/006_add_course_category.sql`](database/migrations/006_add_course_category.sql)
  - `ALTER TABLE courses ADD COLUMN IF NOT EXISTS category TEXT CHECK (category IN ('yoga', 'general_exercise'))`.

### Changed
- **Prisma Schema** [`admin/prisma/schema.prisma`](admin/prisma/schema.prisma)
  - Added `category String?` field to `Course` model with inline comment `// 'yoga' | 'general_exercise'`.
  - Ran `npx prisma generate` to regenerate Prisma client.

- **Courses API — POST** [`admin/src/app/api/courses/route.ts`](admin/src/app/api/courses/route.ts)
  - Destructures `category` from request body.
  - Passes `category` to `prisma.course.create()`.

- **Courses API — PATCH** [`admin/src/app/api/courses/[courseId]/route.ts`](admin/src/app/api/courses/[courseId]/route.ts)
  - Destructures `category` from request body.
  - Passes `category` to `prisma.course.update()`.
  - Note: `add_video` POST action already had `videoSource`/`youtubeVideoId` support — no change needed.

- **Create Course Page** [`admin/src/app/dashboard/courses/new/page.tsx`](admin/src/app/dashboard/courses/new/page.tsx)
  - Added `category` state (default `'yoga'`).
  - Added Category `<select>` field (Yoga / General Workout) between Slug and Total Days.
  - `category` included in form submission payload.

- **Edit Course Page** [`admin/src/app/dashboard/courses/[courseId]/page.tsx`](admin/src/app/dashboard/courses/[courseId]/page.tsx)
  - Added `category` to `Course` interface and `editCategory` state; initialized from fetched data.
  - Added `videoSource` state (`'bunny' | 'youtube'`, default `'bunny'`) and `youtubeVideoId` state.
  - Video form: replaced static Bunny fields with **BunnyNet | YouTube source toggle** — BunnyNet shows Bunny Video ID + Library ID; YouTube shows single YouTube Video ID field.
  - `handleAddVideo`: sends `videoSource`, conditionally sends `bunnyVideoId`/`bunnyLibraryId` or `youtubeVideoId`.
  - Program Settings form: added Category `<select>` (Yoga / General Workout).
  - `handleUpdateCourse`: now sends `editCategory`.
  - Video list items: display `YouTube: <id>` or `Bunny: <id>` based on `vid.videoSource`.
  - `Video` interface: added `videoSource`, `youtubeVideoId`; made `bunnyVideoId`/`bunnyLibraryId` nullable.

- **Free Videos Page** [`admin/src/app/dashboard/free-videos/page.tsx`](admin/src/app/dashboard/free-videos/page.tsx)
  - `FreeVideo` interface: added `videoSource`, `youtubeVideoId`; made `bunnyVideoId`/`bunnyLibraryId` nullable.
  - Added `videoSource` state + `youtubeVideoId` state.
  - Category input changed from free-text `<input>` to `<select>` (Yoga / General Workout).
  - Modal form: **BunnyNet | YouTube source toggle** with conditional ID fields.
  - `handleSubmit` payload: includes `videoSource`, conditionally sends bunny or YouTube fields.
  - `openEditModal`: restores `videoSource` and `youtubeVideoId` from existing record.
  - `openAddModal`: resets `videoSource` to `'bunny'`, clears `youtubeVideoId`.
  - Table column "Bunny Video ID" → "Video Source" with color-coded labels (YT red / Bunny green).

---

## [2026-06-09] — Phase 2: Streak Calculation + Real Leaderboard + Profile Endpoint

### Changed
- **complete-day endpoint** [`admin/src/app/api/mobile/progress/complete-day/route.ts`](admin/src/app/api/mobile/progress/complete-day/route.ts)
  - Replaced flawed streak increment-then-check logic with correct daysDiff algorithm:
    - Check if user already completed a different day **today** → if yes, streak unchanged
    - Find most recent completed day **before** today (`dayDate: { lt: todayDate }`)
    - `daysDiff == 1` → `currentStreak + 1`
    - `daysDiff > 1` → reset to `1` (streak broken)
    - No prior record → start at `1`
  - `longestStreak` updated only when `newStreak > longestStreak`

- **Leaderboard endpoint** [`admin/src/app/api/mobile/leaderboard/route.ts`](admin/src/app/api/mobile/leaderboard/route.ts)
  - Removed all hardcoded mock data (Priya S, Rohit K, mock current user)
  - Fetches up to 50 entries, deduplicates to highest score per user in JS, returns top 10
  - Each entry includes: `rank`, `userId`, `name`, `avatarUrl`, `streak`, `score`, `daysCompleted`, `isCurrentUser`
  - Response shape changed: `{ entries: [...], userRank: number | null }`
  - `userRank` = current user's position across all deduplicated entries (not just top 10)

### Added
- **Profile endpoint** [`admin/src/app/api/mobile/profile/route.ts`](admin/src/app/api/mobile/profile/route.ts) *(new file)*
  - `GET` → returns `{ id, fullName, phone, avatarUrl, email }` for the authenticated user
  - `PUT` → updates `fullName`, `avatarUrl`, and/or `fcmToken` (only fields present in body are updated)
  - Both methods require valid auth token

---

## [2026-06-09] — Phase 3: Flutter Core Data Wiring

### Changed
- **AppConfig** [`app/lib/core/config/app_config.dart`](app/lib/core/config/app_config.dart)
  - `useMockData` changed from `true` to `false`
  - `apiBaseUrl` default changed from `http://localhost:3000` to `http://10.0.2.2:3000` (Android emulator → host machine). Comment added for iOS simulator (`localhost:3000`) and physical device (local IP).

- **ApiService** [`app/lib/core/services/api_service.dart`](app/lib/core/services/api_service.dart)
  - `getLeaderboard()` return type changed from `Future<List<dynamic>>` to `Future<Map<String, dynamic>>` to match the Phase 2 response shape `{ entries: [...], userRank: number | null }`.

- **progressProvider** [`app/lib/presentation/providers/progress_provider.dart`](app/lib/presentation/providers/progress_provider.dart)
  - `loadInitialData()` mock path removed — method now directly calls `refreshFromApi()`
  - `refreshFromApi()` leaderboard parsing updated: reads `leaderboardData['entries']` instead of treating the response as a plain list

### No change
- `main.dart` — `ProgressNotifier` constructor already calls `loadInitialData()` on creation; no explicit call needed
- `api_service.dart` auth token — stays `mock-user-123` intentionally until Phase 9

---

## [2026-06-09] — Phase 4: Flutter Courses + Programs Screen

### Added
- **Course/Enrollment models** [`app/lib/data/models/course_model.dart`](app/lib/data/models/course_model.dart)
  - `CourseModel`: id, title, slug, description, thumbnailUrl, category, totalDays, priceInr
  - `EnrollmentModel`: id, courseId, isActive (enrolledAt added in Phase 5)
  - Both have `fromJson` factories matching Prisma camelCase field names

- **coursesProvider** [`app/lib/presentation/providers/courses_provider.dart`](app/lib/presentation/providers/courses_provider.dart) *(new file)*
  - `CoursesState`: allCourses, enrolledCourseIds, isLoading, error
  - Computed getters: `activeCourses` (enrolled), `exploreCourses` (not enrolled)
  - `CoursesNotifier._load()`: `Future.wait([getCourses(), getEnrollments()])` in parallel
  - `enroll(courseId)`: POST enrollment then reload
  - `refresh()`: reloads from API

### Changed
- **Programs Screen** [`app/lib/presentation/screens/my_courses/programs_screen.dart`](app/lib/presentation/screens/my_courses/programs_screen.dart)
  - Watches `coursesProvider` — handles loading / error / data states
  - **Active tab**: enrolled courses with real progress % (`completedDays.length / totalDays`)
  - **Completed tab**: enrolled courses where progress ≥ 100%
  - **Explore tab**: non-enrolled courses with real price, category label, "Enroll" pill button
  - `_thumbnailPath`: network URL if `thumbnailUrl` present; else `icon_asana.png` (yoga) or `icon_kriya.png` (workout)
  - `_buildCourseImage`: routes `http`-prefixed paths to `Image.network`, others to `Image.asset`
  - `_buildExploreCourseCard`: added `onEnroll` callback + green "Enroll" pill

---

## [2026-06-09] — Phase 5: Flutter Day List Screen

### Changed
- **Course models** [`app/lib/data/models/course_model.dart`](app/lib/data/models/course_model.dart)
  - `EnrollmentModel`: added `enrolledAt: DateTime` field (parsed from API `enrolledAt` string)
  - Added `VideoModel`: id, title, videoSource, youtubeVideoId, bunnyVideoId, bunnyLibraryId, thumbnailUrl, durationSeconds, category
  - Added `CourseDayModel`: id, dayNumber, title, description, videos (list of VideoModel)

- **coursesProvider** [`app/lib/presentation/providers/courses_provider.dart`](app/lib/presentation/providers/courses_provider.dart)
  - `CoursesState`: added `enrollments: List<EnrollmentModel>`
  - Added `enrollmentForCourse(courseId)` helper method
  - `_load()`: parses enrollments as `EnrollmentModel` list; derives `enrolledCourseIds` from it

- **progressProvider** [`app/lib/presentation/providers/progress_provider.dart`](app/lib/presentation/providers/progress_provider.dart)
  - `markDayComplete(int dayNumber, {String courseId = ''})`: added optional `courseId` param
  - Non-mock path now passes real `courseId` to `_apiService.completeDay(courseId, dayNumber)` (was hardcoded `'30-days-yoga'`)

- **VideoPlayerScreen** [`app/lib/presentation/screens/explore/video_player_screen.dart`](app/lib/presentation/screens/explore/video_player_screen.dart)
  - Both `_completeSessionAutomatically` and `_markCompleteManually` now pass `courseId: widget.courseId` to `markDayComplete`

- **DayListScreen** [`app/lib/presentation/screens/my_courses/day_list_screen.dart`](app/lib/presentation/screens/my_courses/day_list_screen.dart) *(full rewrite)*
  - `_courseDetailProvider`: `FutureProvider.autoDispose.family` — fetches `GET /api/mobile/courses/{courseId}`, parses into `_CourseDetail` (title, totalDays, days)
  - `ConsumerStatefulWidget` with `_expandedDay: int?` local state for accordion behaviour
  - Day unlock logic: `enrolledAt + (dayNumber - 1) days ≤ today` (real date from `coursesProvider`)
  - Day states: **Locked** 🔒 (shows unlock date) / **Unlocked** ▶️ / **Today's practice** ⭐ / **Completed** ✅
  - Tapping an unlocked day toggles expansion — shows video list accordion
  - Each video tile: category icon (asana/kriya), title, duration, play button
  - Play button → `context.push('/play', extra: { courseId, dayNumber, youtubeVideoId, videoTitle })`
  - Back button → `/programs?tab=active`

---

## [2026-06-09] — Phase 6: Flutter Video Player (BunnyNet + Landscape)

### Changed
- **pubspec.yaml** [`app/pubspec.yaml`](app/pubspec.yaml)
  - Added `webview_flutter: ^4.4.4` for BunnyNet embedded video playback

- **AndroidManifest.xml** [`app/android/app/src/main/AndroidManifest.xml`](app/android/app/src/main/AndroidManifest.xml)
  - Added `<uses-permission android:name="android.permission.INTERNET"/>` (required for network video + WebView)

- **routes.dart** [`app/lib/core/config/routes.dart`](app/lib/core/config/routes.dart)
  - `/play` route builder updated to read `videoSource`, `bunnyVideoId`, `bunnyLibraryId` from `extra` map
  - All new params passed through to `VideoPlayerScreen`

- **VideoPlayerScreen** [`app/lib/presentation/screens/explore/video_player_screen.dart`](app/lib/presentation/screens/explore/video_player_screen.dart) *(full rewrite)*
  - New constructor params: `videoSource` (default `'youtube'`), `bunnyVideoId?`, `bunnyLibraryId?`
  - **Landscape lock on enter**: `SystemChrome.setPreferredOrientations([landscapeLeft, landscapeRight])` + `SystemUiMode.immersiveSticky`
  - **Portrait restore on exit**: called in `dispose()` and before `context.pop()`
  - **YouTube path** (`videoSource == 'youtube'`): existing `YoutubePlayerBuilder` with 80%-watched auto-complete, unchanged behaviour
  - **BunnyNet path** (`videoSource == 'bunny'`): `WebViewController` loads `https://iframe.mediadelivery.net/embed/{libraryId}/{videoId}?autoplay=true` → `WebViewWidget` fills full screen
    - Back arrow: floating overlay (top-left, semi-transparent black circle)
    - "Complete Session & Back" button: floating overlay at bottom
    - Completion: manual only (can't detect 80% inside WebView)
  - `_completeSession()` is idempotent (guarded by `_isCompletedLogged`) — called by both auto (YouTube) and manual (both)
  - `_markCompleteAndBack()`: calls `_completeSession()` + `_restorePortrait()` + navigates

- **day_list_screen.dart** [`app/lib/presentation/screens/my_courses/day_list_screen.dart`](app/lib/presentation/screens/my_courses/day_list_screen.dart)
  - `_playVideo()` now passes `videoSource`, `bunnyVideoId`, `bunnyLibraryId` in the route extra map

---

## [2026-06-09] — Phase 7: Flutter Home Screen (Real Stats + Leaderboard + Active Course)

### Changed
- **progressProvider** [`app/lib/presentation/providers/progress_provider.dart`](app/lib/presentation/providers/progress_provider.dart)
  - `ProgressState`: added `userRank: int?` field
  - `copyWith`: added `userRank` parameter
  - `refreshFromApi()`: now parses `leaderboardData['userRank']` into `userRank`

- **HomeScreen** [`app/lib/presentation/screens/home/home_screen.dart`](app/lib/presentation/screens/home/home_screen.dart)
  - Added import for `CourseModel` and `coursesProvider`
  - `build()`: now also watches `coursesProvider`; resolves `activeCourse` by matching `progressState.activeCourseId` to courses list (falls back to first enrolled course)

  **Active Course Banner** (`_buildActiveCourseBanner`):
  - Accepts `CourseModel? activeCourse` param
  - Title: uses `activeCourse?.title` (was `'30-Day Yoga Journey'`)
  - Day pill: `'Day $currentDay of $totalDays'` (was `'Day 4 of 30'`)
  - Day strip: shows 7-day window centred on `currentDay`; completed = `ps.completedDays.contains(dayNum)`; current = `dayNum == currentDay` (was all hardcoded)
  - Progress bar text: `'$completedCount of $totalDays Days Completed'` (was session count)
  - Progress bar fill: `completedDays.length / totalDays` (was session ratio)

  **Stats Row** (`_buildStatsRow`):
  - Accepts `CourseModel? activeCourse` param
  - Goal stat: `'$goalPct%'` computed as `completedDays.length / totalDays * 100` (was `'80%'`)

  **Community Leaderboard** (`_buildLeaderboardCard`):
  - Accepts `ProgressState ps` param
  - Empty state: shows "No leaderboard data yet" when `leaderboard` is empty
  - Podium: uses `rank1/rank2/rank3` from real leaderboard list — real names and scores
  - "Your Rank": shows `myRank` (from `isCurrentUser` entry or `ps.userRank`) and `myScore`; shows `–` when not yet ranked

---

## [2026-06-09] — Phase 8: Profile Screen (Real Data) + Steps Sync Endpoint

### Added
- **Admin: Steps sync endpoint** [`admin/src/app/api/mobile/steps/route.ts`](admin/src/app/api/mobile/steps/route.ts) *(new file)*
  - `POST /api/mobile/steps` — accepts `{ steps: number, calories: number }`, upserts `user_stats.totalSteps` and `totalCalories` via Prisma increment; creates the record if it doesn't exist

### Changed
- **ApiService** [`app/lib/core/services/api_service.dart`](app/lib/core/services/api_service.dart)
  - Added `getProfile()` → `GET /api/mobile/profile` returning `{ id, fullName, phone, avatarUrl, email }`
  - Added `syncSteps(int steps, double calories)` → `POST /api/mobile/steps`

- **ProfileScreen** [`app/lib/presentation/screens/profile/profile_screen.dart`](app/lib/presentation/screens/profile/profile_screen.dart)
  - Added file-level `_profileDataProvider` (`FutureProvider.autoDispose`) that calls `ApiService().getProfile()`
  - `build()`: now watches `_profileDataProvider` and `progressProvider`
  - **Name**: resolved from real `profile['fullName']`; falls back to `authState.user?.fullName` while loading or on error
  - **Avatar**: if `avatarUrl` non-null/non-empty → `Image.network(avatarUrl)` with error fallback; else → `_buildInitialsCircle(fullName)` (first letter of name in a semi-transparent circle)
  - **Stats card**: `_buildStatsCard(ProgressState ps)` now uses real `ps.completedSessionsToday` (Sessions), `ps.mindfulMins` (Minutes), `ps.currentStreak` (Day Streak) — was hardcoded `142`, `2,850`, `12`
  - Removed `Image.asset('assets/avatar_rohit.png')` hardcoded avatar

---

## [2026-06-09] — Phase 9: Supabase Phone OTP Auth + Admin Settings Page

### Added
- **Admin: Settings page** [`admin/src/app/dashboard/settings/page.tsx`](admin/src/app/dashboard/settings/page.tsx) *(new file — server component)*
  - Environment variables status table (✓ Set / ✗ Missing for all required vars)
  - Flutter `--dart-define` commands pre-filled with Supabase URL + anon key for Android emulator, iOS simulator, and physical device (with copy button)
  - Supabase auth configuration guide: Step 1 (Enable Phone Auth), Step 2 (Add Test Numbers), recommended dev test credentials table
  - Full mobile API endpoint reference table
- **Admin: Settings nav item** [`admin/src/app/dashboard/layout.tsx`](admin/src/app/dashboard/layout.tsx) — added "Settings" link with gear icon to sidebar
- **Admin: CopyButton client component** [`admin/src/app/dashboard/settings/CopyButton.tsx`](admin/src/app/dashboard/settings/CopyButton.tsx)
- **Admin `.env`** — added `NEXT_PUBLIC_SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` placeholder entries

### Changed
- **`main.dart`** [`app/lib/main.dart`](app/lib/main.dart)
  - `main()` is now `async`
  - Calls `Supabase.initialize(url, anonKey)` before `runApp`
  - Reads `Supabase.instance.client.auth.currentSession` and calls `ApiService().setToken()` if a valid session exists on cold start

- **`auth_provider.dart`** [`app/lib/presentation/providers/auth_provider.dart`](app/lib/presentation/providers/auth_provider.dart)
  - `AuthNotifier` constructor calls `_buildInitialState()` synchronously — sets `isAuthenticated: true` from the existing Supabase session on app start
  - Listens to `auth.onAuthStateChange` to keep `ApiService` token in sync on token refresh / sign-out
  - `login(phone)` — calls `signInWithOtp(phone: '+91$phone')` instead of simulating; returns `true` on success so caller navigates to OTP screen
  - `verifyOtpAndLogin(phone, otp)` — calls `verifyOTP(phone, token, OtpType.sms)`; on success sets `ApiService` token and calls `syncProfile()` to upsert DB profile
  - `register(phone)` — delegates to `login(phone)` (Supabase phone OTP is the same for new/returning users)
  - `logout()` — calls `Supabase signOut` + `ApiService().setToken(null)`
  - Removed all simulated delays and hardcoded `mock-user-123` user object

- **`api_service.dart`** [`app/lib/core/services/api_service.dart`](app/lib/core/services/api_service.dart)
  - Added `syncProfile({String? fullName, String? avatarUrl})` → `POST /api/auth/sync`

- **`routes.dart`** [`app/lib/core/config/routes.dart`](app/lib/core/config/routes.dart)
  - Added `/otp` route: reads `phone` from query params, renders `OTPScreen(phone: phone)`
  - `_initialLocation()` checks `Supabase.instance.client.auth.currentSession` — returns `'/home'` if session exists, otherwise `'/unregistered'`

- **`login_screen.dart`** [`app/lib/presentation/screens/auth/login_screen.dart`](app/lib/presentation/screens/auth/login_screen.dart)
  - On `login()` success: navigates to `/otp?phone=<encoded-phone>` (was `/home`)

- **`signup_screen.dart`** [`app/lib/presentation/screens/auth/signup_screen.dart`](app/lib/presentation/screens/auth/signup_screen.dart)
  - On `register()` success: navigates to `/otp?phone=<encoded-phone>` (was `/home`)

- **`otp_screen.dart`** [`app/lib/presentation/screens/auth/otp_screen.dart`](app/lib/presentation/screens/auth/otp_screen.dart)
  - "Resend Code" tap now calls `authProvider.notifier.login(widget.phone)` — triggers a real OTP resend; shows error snackbar if resend fails

---

## [2026-06-13] — Phase B: Per-Video Completion + Auth Switch to Email/Password
*(commit `5be5188` — thermh)*

### Added
- **Admin: Reset Progress API** [`admin/src/app/api/admin/users/reset-progress/route.ts`](admin/src/app/api/admin/users/reset-progress/route.ts) *(new file)*
  - `POST /api/admin/users/reset-progress` — accepts `{ userId }`, deletes all `VideoProgress`, `DailyProgress`, `LeaderboardEntry`, and `UserStats` for that user in a single transaction

- **Admin: Reset Progress Button** [`admin/src/app/dashboard/users/ResetProgressButton.tsx`](admin/src/app/dashboard/users/ResetProgressButton.tsx) *(new file)*
  - Client component with confirmation dialog; calls `POST /api/admin/users/reset-progress` and refreshes page

### Changed
- **Auth: switched from phone OTP to email + password** *(Supabase `signInWithPassword` / `signUp`)*
  - **`auth_provider.dart`** [`app/lib/presentation/providers/auth_provider.dart`](app/lib/presentation/providers/auth_provider.dart)
    - `login(email, password)` — `signInWithPassword`; on success sets token, syncs profile, populates `UserProfile`
    - `register(name, email, password)` — `signUp`; on success auto-logs in if session returned; shows "check email" message if confirmation required
    - `_refreshProfileFromApi()` — fetches `/api/mobile/profile` on startup when session already exists; updates `fullName` and `avatarUrl` in state
    - `_buildInitialState()` — now also calls `ApiService().setToken(session.accessToken)` on cold start
    - Phone OTP (`sendOtp`, `verifyOtp`) kept as dead code with comment "Kept for future Firebase OTP integration"
  - **`login_screen.dart`** — form changed to email + password fields
  - **`signup_screen.dart`** — form changed to name + email + password fields
  - **`otp_screen.dart`** — no longer wired to auth flow (kept for reference)

- **HomeScreen** [`app/lib/presentation/screens/home/home_screen.dart`](app/lib/presentation/screens/home/home_screen.dart)
  - Fixed hardcoded `'KalanithiAK'` fallback — uses `email.split('@').first` when `fullName` is empty

- **Backend: complete-day route** [`admin/src/app/api/mobile/progress/complete-day/route.ts`](admin/src/app/api/mobile/progress/complete-day/route.ts)
  - Added `videoId` extraction from body
  - Added `VideoProgress.upsert` when `videoId` is provided

- **Backend: progress route** [`admin/src/app/api/mobile/progress/route.ts`](admin/src/app/api/mobile/progress/route.ts)
  - Added `completedVideoIds: string[]` to response — all `VideoProgress` records where `isCompleted = true`

- **Admin: Users page** [`admin/src/app/dashboard/users/page.tsx`](admin/src/app/dashboard/users/page.tsx)
  - Added "Testing Tools" card with `ResetProgressButton`

- **Admin: Courses page** [`admin/src/app/dashboard/courses/[courseId]/page.tsx`](admin/src/app/dashboard/courses/[courseId]/page.tsx)
  - Quote-style lint cleanup; added `formatCategory()` helper; general code quality improvements

- **Flutter providers/screens** — multiple files updated to support `completedVideoIds` and email/password auth:
  - `progress_provider.dart`: `ProgressState` gains `completedVideoIds: List<String>`; `refreshFromApi()` parses it; `markDayComplete` accepts `videoId`
  - `courses_provider.dart`: lint cleanup
  - `api_service.dart`: `completeDay` accepts optional `videoId`
  - `routes.dart`: `/play` route extracts `videoId` from extra
  - `video_player_screen.dart`: accepts `videoId` param, passes to `markDayComplete`
  - `day_list_screen.dart`: `_playVideo()` includes `videoId` in extra
  - `videos_screen.dart`: timeline tile onTap includes `videoId`; tick marks shown on completed days
  - `cart_screen.dart`: minor cleanup

---

## [2026-06-13] — Phase B: Session Lock Enforcement + Per-Video Ticks (Full Phase B Complete)
*(commit `99036c4` — thermh)*

### Added
- **Backend: complete-session shared handler** [`admin/src/app/api/mobile/progress/complete-session/handler.ts`](admin/src/app/api/mobile/progress/complete-session/handler.ts) *(new file)*
  - Both `/api/mobile/progress/complete-day` and `/api/mobile/progress/complete-session` now delegate to this handler
  - `videoId` is **required** (returns 400 if missing)
  - **Day lock enforced server-side**: rejects if `parsedDayNumber !== floor((today - enrolledAt) / 1 day) + 1`
  - **Per-video tracking**: upserts `VideoProgress` for each video on completion
  - **Day completion**: marks `DailyProgress.isComplete = true` only when `completedVideoCount >= totalDayVideos` (all videos in day watched)
  - Increments `totalWatchSeconds` and `totalSessions` in `UserStats` on new video completion only (idempotent)
  - **Score formula**: `score = allCompletedDays × 100 + currentStreak × 10`
  - Returns `{ completedVideoCount, dayCompleted }` in response

- **Backend: complete-session route** [`admin/src/app/api/mobile/progress/complete-session/route.ts`](admin/src/app/api/mobile/progress/complete-session/route.ts) *(new file)*

### Changed
- **ProgramDetailsScreen** [`app/lib/presentation/screens/explore/program_details_screen.dart`](app/lib/presentation/screens/explore/program_details_screen.dart)
  - Watches `courseDetailProvider(courseId)` to load real videos per day
  - `SessionDayTile` gains `videos: List<VideoModel>` and `completedVideoIds: List<String>` params
  - When real videos available: sub-sessions show per-video ticks (green filled circle + check) if `completedVideoIds.contains(video.id)`; play button otherwise
  - Sub-session `onTap` navigates with real `videoId`, `videoSource`, `youtubeVideoId`
  - Subtitle/duration derived from real video count and total duration; falls back to hardcoded 5 sub-sessions while loading

- **VideosScreen** [`app/lib/presentation/screens/explore/videos_screen.dart`](app/lib/presentation/screens/explore/videos_screen.dart)
  - Category labels/values normalised (`_categoryLabel`, `_categoryValue` helpers)
  - Network path helper `_isNetworkPath` added
  - Timeline tiles pass real `videoId` to `/play`

- **VideoPlayerScreen** [`app/lib/presentation/screens/explore/video_player_screen.dart`](app/lib/presentation/screens/explore/video_player_screen.dart)
  - `videoId: String?` param added; passed to `markDayComplete`

- **DayListScreen** [`app/lib/presentation/screens/my_courses/day_list_screen.dart`](app/lib/presentation/screens/my_courses/day_list_screen.dart)
  - `_playVideo()` now passes `videoId: video.id` in the extra map

- **ApiService** [`app/lib/core/services/api_service.dart`](app/lib/core/services/api_service.dart)
  - General cleanup

---

## [2026-06-13] — Admin Demo Day Controls
*(commit `1c86cb5` — thermh)*

### Added
- **Admin: Set Demo Day API** [`admin/src/app/api/admin/users/set-demo-day/route.ts`](admin/src/app/api/admin/users/set-demo-day/route.ts) *(new file)*
  - `POST /api/admin/users/set-demo-day` — accepts `{ userId, enrollmentId, dayNumber, resetProgress? }`
  - Back-dates `enrollment.enrolledAt` so that today unlocks exactly Day N (formula: `enrolledAt = today − (dayNumber − 1) days`)
  - When `resetProgress = true` (default): also wipes all `VideoProgress`, `DailyProgress`, `LeaderboardEntry`, and zeroes `UserStats` in the same transaction
  - Validates `dayNumber` is within `1..course.totalDays`

### Changed
- **Admin: Reset Progress Button** [`admin/src/app/dashboard/users/ResetProgressButton.tsx`](admin/src/app/dashboard/users/ResetProgressButton.tsx)
  - Expanded with **Demo Day Lock** section: per-enrollment number input + "Set" button
  - "Reset" checkbox — controls whether progress is wiped when setting the demo day
  - Each enrollment card shows course title, total days, and day number input
  - Calls `POST /api/admin/users/set-demo-day` with `{ userId, enrollmentId, dayNumber, resetProgress }`

- **Admin: Users page** [`admin/src/app/dashboard/users/page.tsx`](admin/src/app/dashboard/users/page.tsx)
  - Passes `enrollments` array to `ResetProgressButton` so each enrollment can be demo-day-controlled independently

---

## Score / Points Formula

Calculated server-side in [`complete-session/handler.ts`](admin/src/app/api/mobile/progress/complete-session/handler.ts):

```
score = (completed_days × 100) + (current_streak × 10)
```

- A **day is complete** only when every published video in that day has been watched
- **+100** per fully completed day (within this enrollment)
- **+10** per day in the current consecutive streak
- Score is upserted into `leaderboard_entries` with `snapshotDate = today`
- Leaderboard API deduplicates to highest score per user across all snapshot entries

---
*Phase A complete (9 phases). Phase B complete. Mock auth bypass (`mock-user-123`) retained in auth-middleware for dev convenience.*
