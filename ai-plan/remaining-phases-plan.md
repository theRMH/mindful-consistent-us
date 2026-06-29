# Mindful App — Remaining Phases Plan

**Last updated:** 2026-06-13
**Status:** Phase A ✅ | Phase B ✅ | Phase C–I pending

---

## Completed

| Phase | Description | Commit |
|-------|-------------|--------|
| A | Auth isolation — remove mock token bleed | `729b09b` |
| B | Per-video completion + server-side day lock | `99036c4`, `5be5188` |
| B+ | Admin demo day controls | `1c86cb5` |

**New screens added (this session, code on disk, not yet deployed):**
- `body_metrics_form_screen.dart` — 6-field body measurements form
- `body_metrics_history_screen.dart` — timeline of historical snapshots
- `community_leaderboard_screen.dart` — full ranked leaderboard page
- `admin/src/app/api/mobile/profile/body-metrics/route.ts` — GET + POST
- `admin/prisma/migrations/add_body_metrics.sql` — must be run in Supabase

---

## Phase C — Critical Bug Fixes
**Scope:** Fix 3 bugs introduced or pre-existing. Do before any new features.

### C1 — Feedback auth token (bug, pre-existing)
**File:** `app/lib/presentation/screens/my_courses/programs_completed_screen.dart`
- `_submitFeedback()` sends `Authorization: Bearer mock-user-123` — hardcoded, not a real token
- Add `submitFeedback(int rating, String comment)` to `app/lib/core/services/api_service.dart`
- Replace the raw `HttpClient` call with `ApiService().submitFeedback(selectedRating, commentController.text)`

### C2 — Cart loading state (bug)
**File:** `app/lib/presentation/screens/cart/cart_screen.dart`
- `_checkMetricsThenPay()` is async but the Checkout button shows no spinner
- Add `bool _checkingMetrics = false` state field
- Wrap `_checkMetricsThenPay()` body with `setState(() => _checkingMetrics = true/false)`
- Checkout button: `onPressed: _checkingMetrics ? null : _checkMetricsThenPay`; show `CircularProgressIndicator` when `_checkingMetrics`

### C3 — Pass courseId to body metrics after course completion (bug)
**Files:**
- `app/lib/core/config/routes.dart` — `/course_completed` route: read `?courseId=` from `state.uri.queryParameters`; pass to `ProgramsCompletedScreen`
- `app/lib/presentation/screens/my_courses/programs_completed_screen.dart` — add `final String? courseId` constructor param; update "Log Your Progress" button to `/body-metrics?skip=false&courseId=<courseId>&redirect=/home`
- `app/lib/presentation/screens/explore/video_player_screen.dart` — change `context.go('/course_completed')` to `context.go('/course_completed?courseId=${widget.courseId}')`

---

## Phase D — Body Metrics Go-Live
**Blocking:** User must run SQL + prisma generate first. Without this, the body-metrics API returns 500.

### D0 — User action required (not code)
1. Open Supabase SQL Editor
2. Run `admin/prisma/migrations/add_body_metrics.sql`
3. In terminal: `cd admin && npx prisma generate`

### D1 — Verify body metrics end-to-end
After migration runs, test:
1. Signup → body metrics form (skippable) → save → profile → Personal Details → snapshot visible
2. Cart checkout with no metrics → form appears (no skip) → fill → cart returns → pay proceeds
3. `/course_completed?courseId=xxx` → "Log Your Progress" → form saves with courseId → visible in history linked to that course

---

## Phase E — Community Leaderboard: "Your Group" Tab
**Scope:** Add a second tab to the leaderboard showing only users in the same enrolled course.

### E1 — Backend: courseId filter
**File:** `admin/src/app/api/mobile/leaderboard/route.ts`
- Read optional `?courseId=` query param
- When present: `prisma.leaderboardEntry.findMany({ where: { courseId } })` instead of all entries
- No schema change needed (leaderboard_entries already has courseId FK)

### E2 — Flutter: two-tab leaderboard
**File:** `app/lib/presentation/screens/profile/community_leaderboard_screen.dart`
- Wrap scaffold body in `DefaultTabController(length: 2)`
- Add `TabBar` with "All Time" and "Your Group" tabs
- Tab 1 — All Time: existing fetch, no param
- Tab 2 — Your Group: read `progressProvider.activeCourseId`, call `ApiService().getLeaderboard(courseId: activeCourseId)`; empty state if no active course: "Enroll in a program to see your group"

### E3 — Fix Home "View All" leaderboard button
**File:** `app/lib/presentation/screens/home/home_screen.dart` — line ~1204
- Change `onTap: () {}` to `onTap: () => context.push('/community-leaderboard')`

---

## Phase F — Profile Features

### F1 — Edit Profile (name + avatar upload)
**Backend:** `PUT /api/mobile/profile` already accepts `{ fullName, avatarUrl }` — no backend change.

**Supabase Storage:** Create `avatars` bucket (public access) in Supabase dashboard.

**pubspec.yaml:** Add `image_picker: ^1.0.4` if not already present.

**Flutter:**
- `app/lib/presentation/screens/profile/profile_screen.dart`
  - Add edit icon (`Icons.edit_rounded`) overlaid on avatar circle (bottom-right, small white circle)
  - Tap avatar or edit icon → `_showEditSheet(context, ref)` bottom sheet
  - Sheet: current avatar with "Change Photo" tap → `ImagePicker().pickImage(source: ImageSource.gallery)`; name `TextField` pre-filled; "Save" button
  - On save: upload image if changed → `Supabase.instance.client.storage.from('avatars').uploadBinary(...)` → get public URL → call `ApiService().syncProfile(fullName, avatarUrl)`
  - On success: `ref.invalidate(_profileDataProvider)`

### F2 — Notifications & Reminders screen
**DB migration** (new file: `admin/prisma/migrations/add_notification_prefs.sql`):
```sql
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS notifications_enabled BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS notification_time TEXT;
```

**Schema:** `admin/prisma/schema.prisma` — add to Profile model:
```prisma
notificationsEnabled Boolean @default(false) @map("notifications_enabled")
notificationTime     String? @map("notification_time")
```

**Backend:** `admin/src/app/api/mobile/profile/route.ts`
- GET: include `notificationsEnabled`, `notificationTime` in response
- PUT: accept and save these two fields

**Flutter — new file:** `app/lib/presentation/screens/profile/notification_preferences_screen.dart`
- Toggle: "Daily Practice Reminder" (SwitchListTile)
- Time picker row (visible when toggle on): tap → `showTimePicker`
- Save button → `ApiService().updateProfile(notificationsEnabled: ..., notificationTime: ...)`
- Pre-fills from profile API on load

**Routes + Profile menu:**
- `routes.dart`: add `/notifications` route
- `profile_screen.dart`: "Notifications & Reminders" → `context.push('/notifications')`

### F3 — Subscription & Plans screen
**Backend:** Uses existing `GET /api/mobile/enrollments` — no change.

**Flutter — new file:** `app/lib/presentation/screens/profile/subscription_screen.dart`
- List of enrollments: course thumbnail, title, enrolled date, days completed / total, "Active" / "Completed" badge
- Empty state: "No active subscriptions" + CTA → /programs?tab=explore

**Routes + Profile menu:**
- `routes.dart`: add `/subscriptions` route
- `profile_screen.dart`: "Subscription & Plans" → `context.push('/subscriptions')`

---

## Phase G — Payment (Razorpay)

### G1 — pubspec.yaml
Add `razorpay_flutter: ^1.3.6`

### G2 — Backend: create order
**New file:** `admin/src/app/api/mobile/payment/create-order/route.ts`
- `POST` — accepts `{ courseId, couponCode? }`, calls Razorpay API to create order, returns `{ orderId, amount, currency, keyId }`

### G3 — Flutter: payment flow
**File:** `app/lib/presentation/screens/cart/cart_screen.dart`
- Replace `_processPayment()` mock with real Razorpay:
  1. Call `POST /api/mobile/payment/create-order` → get `orderId`
  2. Open `Razorpay` payment sheet with options
  3. `_handlePaymentSuccess`: call `POST /api/mobile/enrollments` → navigate to `/thank-you`
  4. `_handlePaymentError`: show error snackbar
  5. `_handleExternalWallet`: show snackbar

---

## Phase H — Data Accuracy & Polish

### H1 — Fix hardcoded course names
| Screen | File | Fix |
|--------|------|-----|
| Cart | `cart_screen.dart` | Read real course from API using courseId param |
| Thank You | `thank_you_screen.dart` | Accept `courseName`, `amount` as constructor params from route extra |
| Course Completed | `programs_completed_screen.dart` | Accept `courseName` as constructor param; read from route |

### H2 — Weekly activity chart (real data)
- Add `GET /api/mobile/points/weekly` endpoint: returns 7 daily totals from `daily_points` table
- Update `progressProvider` to call this endpoint
- `home_screen.dart` weekly chart: use real data instead of hardcoded M–S structure

### H3 — Category chip counts in Videos
**File:** `app/lib/presentation/screens/explore/videos_screen.dart`
- Count real videos per category from the fetched video list
- Replace hardcoded "3 Courses" / "2 Courses" with actual counts

### H4 — Remove developer simulator
**File:** `app/lib/presentation/widgets/developer_simulator_sheet.dart`
- Wrap all access points behind `AppConfig.isDev` flag
- Or simply remove the `+500 steps` app bar button and all simulator sheet triggers before production release

---

## Phase I — Admin Gaps

### I1 — Edit Day (title / description)
**File:** `admin/src/app/dashboard/courses/[courseId]/page.tsx`
- Add edit pencil icon per day row → inline form or side panel with title + description fields
- `PATCH /api/admin/courses/[courseId]/days/[dayId]`

### I2 — Delete Day
- Add delete button per day row → confirmation modal
- `DELETE /api/admin/courses/[courseId]/days/[dayId]`

### I3 — Edit Community Moment
**File:** `admin/src/app/dashboard/community-moments/page.tsx`
- Add edit button per moment → pre-filled modal
- `PATCH /api/admin/community-moments/[id]`

---

## Execution Order (recommended)

```
C1 → C2 → C3    (bug fixes, small, safe)
D0               (USER: run SQL migration)
D1               (verify body metrics)
E1 → E2 → E3    (leaderboard Your Group tab + home fix)
F1               (edit profile)
F2               (notifications screen)
F3               (subscriptions screen)
G                (payment — largest phase, do last of core)
H                (polish — can be done in parallel with F/G)
I                (admin gaps — can be done independently)
```

---

## Files Summary

### New files to create
- `app/lib/presentation/screens/profile/notification_preferences_screen.dart`
- `app/lib/presentation/screens/profile/subscription_screen.dart`
- `admin/prisma/migrations/add_notification_prefs.sql`
- `admin/src/app/api/mobile/payment/create-order/route.ts`

### Files to modify
| File | Phase |
|------|-------|
| `app/lib/core/services/api_service.dart` | C1, F1, F2 |
| `app/lib/presentation/screens/my_courses/programs_completed_screen.dart` | C1, C3 |
| `app/lib/presentation/screens/cart/cart_screen.dart` | C2, G3 |
| `app/lib/core/config/routes.dart` | C3, F2, F3 |
| `app/lib/presentation/screens/explore/video_player_screen.dart` | C3 |
| `admin/src/app/api/mobile/leaderboard/route.ts` | E1 |
| `app/lib/presentation/screens/profile/community_leaderboard_screen.dart` | E2 |
| `app/lib/presentation/screens/home/home_screen.dart` | E3, H2 |
| `app/lib/presentation/screens/profile/profile_screen.dart` | F1, F2, F3 |
| `admin/prisma/schema.prisma` | F2 |
| `admin/src/app/api/mobile/profile/route.ts` | F2 |
| `app/pubspec.yaml` | F1, G1 |
| `app/lib/presentation/screens/explore/videos_screen.dart` | H3 |
| `prd.md`, `changes.md` | documentation |
