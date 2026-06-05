# Product Requirements Document (PRD) — Mindful (Consistent US)

This document defines the product requirements for the "Consistent US" wellness/yoga application, focusing specifically on the designs present in the **Completed** section of the Figma file.

## 1. Project Context & Objectives
Consistent US is a wellness platform where users track their yoga practice, daily step count, and mindful activity. 
For the current phase, we are implementing **only** the screens and flows in the Figma **Completed** section. 

## 2. Key Screen Requirements

### A. Onboarding & Authentication
*   **Log in Screen (Figma ID: `3:74`):**
    *   **Fields:** Mobile number input with country code picker (defaults to `+91`).
    *   **CTAs:** "Log in" button; link to "Register Now" / "Create one".
    *   **Behavior:** Authenticate via Supabase phone auth. For local/development environments, a mock OTP verification flow will be implemented to bypass SMS gateway setup.
*   **Register Screen (Figma ID: `4:658`):**
    *   **Fields:** Mobile number input with country code picker.
    *   **CTAs:** "Log in" / "Register" action button; link to "Already have an Account ? Log in".
    *   **Behavior:** Trigger account registration under Supabase. Upon completion, a trigger auto-populates the corresponding `profiles` and `user_stats` tables.

### B. Dashboard Experience
*   **Unregistered User Dashboard (Figma ID: `6:2527`):**
    *   **Access:** Displayed to non-logged-in users (guests).
    *   **Features:**
        *   Browse premium course catalogue cards.
        *   View card details: course name (e.g., "30 Days Yoga Course", "48 Days Yoga Course"), price in INR (e.g. `₹699`, `₹899`), duration, difficulty, and daily duration commit (e.g. `15m /day`).
        *   Direct access to play free sample/preview videos.
        *   Prompt login/registration when clicking premium courses or deep interaction.
*   **Registered User Dashboard (`Home-V2-new` - Figma ID: `6:94`):**
    *   **Greeting:** Tamil greeting *"Vanakkam"* followed by the user's name.
    *   **Streak Calendar:** A horizontal scrollable weekly timeline displaying daily practice completions highlighted with checkmarks. Shows active streak days (e.g. "3 Day Streak").
    *   **Active Course Card:** Shows the user's current course (e.g., "30-Day Yoga Journey"), listing the day index ("Day 4 of 30").
    *   **Progress Summary Circle:** Labeled *"Today's Progress: X of Y sessions completed"*, displaying an animated circular completion percentage (e.g., "50%").
    *   **Stats Card:** Displays daily accumulated metrics:
        *   *Mindful Mins:* Total watched video duration.
        *   *Steps:* Pedometer step count.
        *   *Calories:* Calculated step-based calories (`steps * 0.04`).

### C. Course Catalogue & Details
*   **Explore Programs (`Explore-V2` - Figma ID: `12:4756`):**
    *   **Contents:** Detailed page for a single course showing:
        *   Title, duration, level, daily commitment.
        *   "About this program" text describing the mobility/yoga routine.
        *   Instructor card containing name (e.g. Deepa), title, and experience.
        *   Sessions list showing list of video titles, lengths (e.g., "20Mins"), and active/locked state.
*   **Programs Directory — Active Tab (Figma ID: `10:3643`):**
    *   **Contents:** List of ongoing courses with a visual progress bar indicating completed days (e.g. "17 of 21 Days", "22 of 48 Days") and "In Progress" status.
*   **Programs Directory — Completed Tab (Figma ID: `12:4175`):**
    *   **Contents:** List of fully finished courses (100% completion) and a primary "Home" CTA button.

## 3. Technology Stack & Architecture
*   **Mobile Client:** Flutter (Dart) + Riverpod (state management) + GoRouter (navigation).
*   **Backend Server:** Next.js 14 serverless API routes under `admin/`.
*   **Database:** Supabase (PostgreSQL) + Prisma ORM (in Next.js).
*   **Video CDN:** Bunny.net Stream (simulated with standard HLS streams for testing).
*   **Pedometer:** Flutter `pedometer` library (with mock input for emulators).

## 4. Key Business Logic
*   **Day-Lock Formula:** Day $N$ content is accessible only when `CURRENT_DATE >= purchase_date + (N - 1) days`. Future days must appear locked.
*   **Session Completion:** A video is counted as completed when watch duration reaches $\ge 80\%$ of the total length.
*   **Calorie Formula:** `calories = steps * 0.04`.
