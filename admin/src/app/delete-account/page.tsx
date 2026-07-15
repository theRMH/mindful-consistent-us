import Link from 'next/link';
import Image from 'next/image';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Delete Account — ConsistentUs',
  description: 'How to delete your ConsistentUs account and all associated data.',
};

const CONTACT_EMAIL = 'workingmom2202@gmail.com';

export default function DeleteAccountPage() {
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

      <main className="max-w-2xl mx-auto px-6 py-12">
        <h1 className="text-3xl font-extrabold text-[#0E3C31] mb-3">Delete Your Account</h1>
        <p className="text-gray-500 text-sm mb-10">
          You can delete your ConsistentUs account at any time. Deletion permanently removes your profile, progress data, and personal information.
        </p>

        {/* Option 1 — In app */}
        <div className="mb-8 rounded-2xl border border-gray-100 p-6 shadow-sm">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-8 h-8 rounded-full bg-[#E5F4ED] text-[#019948] font-bold text-sm flex items-center justify-center flex-shrink-0">1</div>
            <h2 className="text-lg font-bold text-[#0E3C31]">Delete from the app</h2>
          </div>
          <ol className="space-y-3 text-sm text-gray-600 list-none">
            {[
              'Open the ConsistentUs app and sign in',
              'Tap the Profile tab (bottom navigation)',
              'Tap Settings or the gear icon',
              'Select "Delete Account"',
              'Confirm deletion — your account will be permanently removed',
            ].map((step, i) => (
              <li key={i} className="flex items-start gap-3">
                <span className="mt-0.5 w-5 h-5 rounded-full bg-[#019948]/10 text-[#019948] text-xs font-bold flex items-center justify-center flex-shrink-0">{i + 1}</span>
                <span>{step}</span>
              </li>
            ))}
          </ol>
        </div>

        {/* Option 2 — Email */}
        <div className="mb-10 rounded-2xl border border-gray-100 p-6 shadow-sm">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-8 h-8 rounded-full bg-[#E5F4ED] text-[#019948] font-bold text-sm flex items-center justify-center flex-shrink-0">2</div>
            <h2 className="text-lg font-bold text-[#0E3C31]">Request deletion by email</h2>
          </div>
          <p className="text-sm text-gray-600 mb-4">
            If you are unable to access the app, send an email to us from the phone number registered with your account and we will delete it within <strong>7 business days</strong>.
          </p>
          <a
            href={`mailto:${CONTACT_EMAIL}?subject=Delete%20My%20ConsistentUs%20Account&body=Hi%2C%0A%0APlease%20delete%20my%20ConsistentUs%20account.%0A%0ARegistered%20phone%20number%3A%20%2B91XXXXXXXXXX%0A%0AThank%20you.`}
            className="inline-flex items-center gap-2 bg-[#019948] text-white font-semibold px-5 py-2.5 rounded-xl text-sm hover:bg-[#017a3a] transition-colors"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
            Email {CONTACT_EMAIL}
          </a>
        </div>

        {/* What gets deleted */}
        <div className="rounded-2xl bg-gray-50 p-6 mb-8">
          <h2 className="text-base font-bold text-[#0E3C31] mb-3">What gets deleted</h2>
          <ul className="space-y-2 text-sm text-gray-600">
            {[
              'Your profile (name, phone number, avatar)',
              'All progress data (streaks, sessions completed, steps)',
              'Body metrics and personal measurements',
              'Notification preferences and FCM token',
              'Community moments you have posted',
            ].map((item) => (
              <li key={item} className="flex items-center gap-2">
                <svg className="w-4 h-4 text-red-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
                {item}
              </li>
            ))}
          </ul>
        </div>

        {/* What is retained */}
        <div className="rounded-2xl bg-amber-50 border border-amber-100 p-6 mb-10">
          <h2 className="text-base font-bold text-amber-800 mb-3">What may be retained</h2>
          <p className="text-sm text-amber-700 leading-relaxed">
            For legal and financial compliance, we may retain anonymised transaction records (purchase history) for up to 5 years as required by Indian tax regulations. These records will not contain your name or phone number after deletion.
          </p>
        </div>

        <p className="text-sm text-gray-400 text-center">
          Questions?{' '}
          <a href={`mailto:${CONTACT_EMAIL}`} className="text-[#019948] underline">{CONTACT_EMAIL}</a>
          {' '}·{' '}
          <Link href="/privacy-policy" className="text-[#019948] underline">Privacy Policy</Link>
        </p>
      </main>

      <footer className="bg-gray-900 text-gray-400 py-6 px-6 text-center text-sm mt-8">
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <span>© {new Date().getFullYear()} ConsistentUs · MindfulHomeFitrition</span>
          <div className="flex gap-5">
            <Link href="/" className="hover:text-white transition-colors">Home</Link>
            <Link href="/privacy-policy" className="hover:text-white transition-colors">Privacy Policy</Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
