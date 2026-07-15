import Link from 'next/link';
import Image from 'next/image';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Privacy Policy — ConsistentUs',
  description: 'Privacy Policy for the ConsistentUs app by MindfulHomeFitrition.',
};

const CONTACT_EMAIL = 'workingmom2202@gmail.com';
const APP_NAME = 'ConsistentUs';
const EFFECTIVE_DATE = 'July 15, 2025';

export default function PrivacyPolicyPage() {
  return (
    <div className="min-h-screen bg-white font-sans">
      {/* Nav */}
      <header className="bg-[#0E3C31] text-white">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center gap-4">
          <Link href="/" className="flex items-center gap-3">
            <Image src="/logo.png" alt="ConsistentUs" width={28} height={28} className="object-contain" />
            <span className="font-bold text-base tracking-tight">ConsistentUs</span>
          </Link>
        </div>
      </header>

      <main className="max-w-3xl mx-auto px-6 py-12">
        <h1 className="text-3xl font-extrabold text-[#0E3C31] mb-2">Privacy Policy</h1>
        <p className="text-sm text-gray-500 mb-8">Effective date: {EFFECTIVE_DATE}</p>

        <div className="prose prose-gray max-w-none space-y-8 text-[15px] leading-relaxed text-gray-700">

          <section>
            <p>
              {APP_NAME} (&quot;we&quot;, &quot;our&quot;, or &quot;us&quot;) is operated by MindfulHomeFitrition and is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use the {APP_NAME} mobile application.
            </p>
            <p className="mt-3">
              By using {APP_NAME}, you agree to the collection and use of information in accordance with this policy.
            </p>
          </section>

          <Section title="1. Information We Collect">
            <p>We collect the following types of information:</p>
            <ul className="mt-3 space-y-2 list-disc list-inside">
              <li><strong>Phone number</strong> — used for authentication via OTP (One-Time Password)</li>
              <li><strong>Display name and profile photo</strong> — provided by you during sign-up</li>
              <li><strong>Fitness activity data</strong> — daily step counts and calories (from Apple Health / Google Fit, only with your explicit permission)</li>
              <li><strong>Body metrics</strong> — optional data you enter (height, weight, waist, hip measurements)</li>
              <li><strong>Progress data</strong> — sessions completed, streaks, and course activity within the app</li>
              <li><strong>Device token (FCM)</strong> — used to send you push notifications</li>
              <li><strong>Payment information</strong> — processed securely via Razorpay; we do not store card or UPI details</li>
              <li><strong>Usage analytics</strong> — anonymised app events (screen views, feature usage) via Firebase Analytics</li>
              <li><strong>Crash reports</strong> — anonymised crash and error data via Firebase Crashlytics</li>
            </ul>
          </Section>

          <Section title="2. How We Use Your Information">
            <ul className="mt-3 space-y-2 list-disc list-inside">
              <li>To authenticate your account securely via phone OTP</li>
              <li>To personalise your experience and track your fitness progress</li>
              <li>To process course purchases and manage your enrollments</li>
              <li>To send you daily workout reminders and important app notifications</li>
              <li>To display community features like leaderboards and community moments</li>
              <li>To improve app performance and fix issues using analytics and crash data</li>
              <li>To respond to your support queries</li>
            </ul>
          </Section>

          <Section title="3. Third-Party Services">
            <p>We use the following third-party services to operate {APP_NAME}:</p>
            <ul className="mt-3 space-y-2 list-disc list-inside">
              <li>
                <strong>Firebase (Google)</strong> — Authentication, cloud messaging, analytics, and crash reporting.
                {' '}<a href="https://firebase.google.com/support/privacy" target="_blank" rel="noopener noreferrer" className="text-[#019948] underline">Firebase Privacy Policy</a>
              </li>
              <li>
                <strong>Supabase</strong> — Database hosting for your profile and progress data.
                {' '}<a href="https://supabase.com/privacy" target="_blank" rel="noopener noreferrer" className="text-[#019948] underline">Supabase Privacy Policy</a>
              </li>
              <li>
                <strong>Razorpay</strong> — Payment processing. We never store payment card or UPI credentials.
                {' '}<a href="https://razorpay.com/privacy/" target="_blank" rel="noopener noreferrer" className="text-[#019948] underline">Razorpay Privacy Policy</a>
              </li>
            </ul>
          </Section>

          <Section title="4. Health & Fitness Data">
            <p>
              {APP_NAME} can optionally connect to Apple Health (iOS) or Google Fit (Android) to read your daily step count. We only request this permission when you choose to use the step-tracking feature. This data is used solely to display your activity within the app and is never sold or shared with advertisers.
            </p>
          </Section>

          <Section title="5. Data Retention">
            <p>
              We retain your personal data for as long as your account is active or as needed to provide the service. If you delete your account, we will delete your personal data within 30 days, except where we are required to retain it for legal or financial compliance purposes (e.g., transaction records for Razorpay payments).
            </p>
          </Section>

          <Section title="6. Data Security">
            <p>
              We use industry-standard security measures including encrypted connections (HTTPS/TLS), Firebase Authentication for token-based access, and server-side signature verification for all payments. However, no method of transmission over the internet is 100% secure.
            </p>
          </Section>

          <Section title="7. Children's Privacy">
            <p>
              {APP_NAME} is not directed at children under 13. We do not knowingly collect personal information from children under 13. If you believe we have inadvertently collected such information, please contact us immediately.
            </p>
          </Section>

          <Section title="8. Your Rights">
            <p>You have the right to:</p>
            <ul className="mt-3 space-y-2 list-disc list-inside">
              <li>Access the personal data we hold about you</li>
              <li>Request correction of inaccurate data</li>
              <li>Request deletion of your account and associated data</li>
              <li>Withdraw consent for push notifications at any time (via device settings)</li>
            </ul>
            <p className="mt-3">
              To exercise any of these rights, email us at{' '}
              <a href={`mailto:${CONTACT_EMAIL}`} className="text-[#019948] underline">{CONTACT_EMAIL}</a>.
              For account deletion, see our{' '}
              <Link href="/delete-account" className="text-[#019948] underline">Delete Account page</Link>.
            </p>
          </Section>

          <Section title="9. Changes to This Policy">
            <p>
              We may update this Privacy Policy from time to time. We will notify you of significant changes via the app or email. Continued use of the app after changes constitutes acceptance of the updated policy.
            </p>
          </Section>

          <Section title="10. Contact Us">
            <p>
              If you have any questions about this Privacy Policy or your data, please contact us:
            </p>
            <div className="mt-3 p-4 bg-gray-50 rounded-xl text-sm">
              <p><strong>{APP_NAME}</strong> · MindfulHomeFitrition</p>
              <p className="mt-1">
                Email:{' '}
                <a href={`mailto:${CONTACT_EMAIL}`} className="text-[#019948] underline">{CONTACT_EMAIL}</a>
              </p>
              <p className="mt-1">
                Website:{' '}
                <a href="https://mindfulhomefitrition.com" target="_blank" rel="noopener noreferrer" className="text-[#019948] underline">mindfulhomefitrition.com</a>
              </p>
            </div>
          </Section>

        </div>
      </main>

      <footer className="bg-gray-900 text-gray-400 py-6 px-6 text-center text-sm mt-12">
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <span>© {new Date().getFullYear()} ConsistentUs · MindfulHomeFitrition</span>
          <div className="flex gap-5">
            <Link href="/" className="hover:text-white transition-colors">Home</Link>
            <Link href="/delete-account" className="hover:text-white transition-colors">Delete Account</Link>
          </div>
        </div>
      </footer>
    </div>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section>
      <h2 className="text-lg font-bold text-[#0E3C31] mb-3">{title}</h2>
      {children}
    </section>
  );
}
