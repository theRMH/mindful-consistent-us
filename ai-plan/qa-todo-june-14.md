# QA TODO - June 14, 2026

Senior QA review summary for the Mindful mobile app and admin/mobile API. This is a no-code-change action plan based on the full app QA pass.

## Priority 0 - Launch Blockers

- [ ] Replace fake cart payment flow with a real payment provider integration.
  - Current cart simulates payment with a delay, enrolls the user, and opens thank-you.
  - Backend currently creates `paymentId` with `Math.random()` and marks `paymentStatus` as `completed`.
  - Add payment order creation, payment success verification, failure/cancel handling, and receipt/order details.

- [ ] Remove production OTP/auth bypass.
  - Mobile accepts OTP `123456` as a mock login.
  - Backend accepts `mock-user-123` and `consistent-us-mock-auth-token`.
  - Gate dev bypasses behind a development-only flag or remove before release.

- [ ] Fix cart auth redirect.
  - Cart sends `redirect=cart`, but auth screens call `context.go(widget.redirect!)`.
  - `cart` is not a valid absolute route and loses selected `courseId`.
  - Redirect should preserve `/cart?courseId=<id>` after login/signup/body metrics.

- [ ] Implement real step tracking.
  - Steps screen says “Live Pedometer” but uses simulated `+500` and static history rows.
  - Wire the `pedometer` package to live device step streams.
  - Add permissions, background/sync behavior, daily reset/history, and error states.

## Priority 1 - High Risk Functional Gaps

- [ ] Connect cart pricing/course details to live course data.
  - Cart hardcodes course title, image, price, discount, coupon code, and quantity.
  - Use the selected course from API/provider and validate coupon/discount from backend.

- [ ] Fix video completion logic.
  - Progress is saved when the video screen opens, before the user watches.
  - Mark complete only after user action plus playback threshold or actual video completion event.
  - Store meaningful watch duration instead of defaulting to zero for session progress.

- [ ] Complete notification/reminder implementation.
  - Preferences are saved, but no permission flow, FCM token registration, local notification scheduling, or push delivery is implemented.
  - Add reminder scheduling and confirm behavior on Android/iOS.

- [ ] Replace Help & Support placeholder.
  - Profile menu currently shows “Help & Support coming soon.”
  - Add support screen, email/WhatsApp/contact link, FAQ, or ticket flow.

- [ ] Remove mock Bunny defaults from admin.
  - Admin course/free-video forms default `bunnyLibraryId` to `mock_lib_123`.
  - Bunny token generator falls back to `mock_token_key`.
  - Require real env/config before publishing Bunny videos.

## Priority 2 - Product Completeness

- [ ] Add payment failure, cancellation, retry, and pending states.
- [ ] Add purchase receipt/order summary in thank-you and subscription pages.
- [ ] Add subscription status details: active, expired, completed, renewal/cancel if applicable.
- [ ] Add empty/error/retry states for profile, course detail, leaderboard, free videos, and enrollments.
- [ ] Add offline/slow-network handling for key pages.
- [ ] Confirm body metrics validation ranges for age, height, weight, waist, and hip.
- [ ] Add user-facing copy for locked course days and unavailable video sources.
- [ ] Confirm Supabase avatar bucket permissions and image upload size/type limits.

## QA Validation Status

- [x] Flutter static analysis passed: `flutter analyze`.
- [x] Admin production build passed: `npm run build`.
- [ ] Flutter tests failed because the default counter test is stale and does not wrap the app in `ProviderScope`.
- [ ] Admin lint failed due to existing lint debt: `any` usage, CommonJS `require`, React hook lint, and unescaped entities.

## Recommended Release Gate

- [ ] All Priority 0 items complete.
- [ ] Payment success verified from gateway webhook/server-side verification.
- [ ] Mock auth tokens removed or disabled in production.
- [ ] Real device QA completed on Android and iOS for auth, payment, video playback, steps, notifications, profile upload, and logout.
- [ ] Regression checklist completed for guest, new user, returning user, enrolled user, and expired/inactive enrollment states.
