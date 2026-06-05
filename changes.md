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

---
*Next steps: Align register/signup page and explore pages with their Figma references.*
