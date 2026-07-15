import Link from 'next/link';
import Image from 'next/image';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'ConsistentUs — Stay Fit, Stay Consistent',
  description: 'A mindful fitness app for women. Daily yoga, nutrition plans, and streak tracking — by Deepa of MindfulHomeFitrition.',
};

export default function HomePage() {
  return (
    <div className="min-h-screen bg-white font-sans">
      {/* Nav */}
      <header className="bg-[#0E3C31] text-white">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Image src="/logo.png" alt="ConsistentUs" width={32} height={32} className="object-contain" />
            <span className="font-bold text-lg tracking-tight">ConsistentUs</span>
          </div>
          <nav className="hidden sm:flex items-center gap-6 text-sm font-medium text-green-200">
            <a href="https://mindfulhomefitrition.com" target="_blank" rel="noopener noreferrer" className="hover:text-white transition-colors">MindfulHomeFitrition</a>
            <Link href="/privacy-policy" className="hover:text-white transition-colors">Privacy</Link>
          </nav>
        </div>
      </header>

      {/* Hero */}
      <section className="bg-gradient-to-br from-[#0E3C31] via-[#0a5c3e] to-[#019948] text-white py-20 px-6">
        <div className="max-w-3xl mx-auto text-center">
          <div className="inline-flex items-center gap-2 bg-white/10 text-green-200 text-xs font-semibold px-4 py-1.5 rounded-full mb-6 uppercase tracking-wider">
            By MindfulHomeFitrition
          </div>
          <h1 className="text-4xl sm:text-5xl font-extrabold leading-tight mb-5">
            Stay Consistent.<br />Stay Fit.
          </h1>
          <p className="text-lg text-green-100 max-w-xl mx-auto mb-8 leading-relaxed">
            ConsistentUs is your daily companion for mindful fitness — yoga challenges, nutrition guidance, and streak-based motivation crafted for women.
          </p>
          <div className="flex flex-wrap justify-center gap-4">
            <a
              href="#download"
              className="bg-white text-[#0E3C31] font-bold px-7 py-3.5 rounded-full text-sm hover:bg-green-50 transition-colors shadow-lg"
            >
              Download the App
            </a>
            <a
              href="https://mindfulhomefitrition.com"
              target="_blank"
              rel="noopener noreferrer"
              className="border-2 border-white/50 text-white font-bold px-7 py-3.5 rounded-full text-sm hover:bg-white/10 transition-colors"
            >
              Visit Website
            </a>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-16 px-6 bg-gray-50">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-2xl font-extrabold text-[#0E3C31] text-center mb-10">Everything you need to stay on track</h2>
          <div className="grid sm:grid-cols-3 gap-6">
            {[
              {
                emoji: '🧘‍♀️',
                title: 'Daily Yoga Sessions',
                desc: 'Pre-recorded sessions you can do from home, at your own pace.',
              },
              {
                emoji: '🔥',
                title: 'Streak Tracking',
                desc: 'Build momentum with daily streaks and leaderboard rankings.',
              },
              {
                emoji: '🥗',
                title: 'Nutrition Guidance',
                desc: 'Mindful eating tips and diet plans designed for real women.',
              },
              {
                emoji: '📱',
                title: 'Push Reminders',
                desc: 'Daily notifications at your chosen time so you never skip a session.',
              },
              {
                emoji: '🏆',
                title: 'Community',
                desc: 'Share your journey and celebrate wins with fellow members.',
              },
              {
                emoji: '📊',
                title: 'Progress Insights',
                desc: 'Track steps, sessions completed, and your overall fitness journey.',
              },
            ].map((f) => (
              <div key={f.title} className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
                <div className="text-3xl mb-3">{f.emoji}</div>
                <h3 className="font-bold text-[#0E3C31] mb-1">{f.title}</h3>
                <p className="text-sm text-gray-500 leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* About Founder */}
      <section className="py-16 px-6 bg-white">
        <div className="max-w-3xl mx-auto flex flex-col sm:flex-row items-center gap-10">
          <div className="flex-shrink-0 w-32 h-32 rounded-full bg-[#E5F4ED] flex items-center justify-center text-5xl">
            🌿
          </div>
          <div>
            <p className="text-xs uppercase tracking-widest text-[#019948] font-bold mb-2">Meet the Founder</p>
            <h2 className="text-2xl font-extrabold text-[#0E3C31] mb-3">Deepa</h2>
            <p className="text-gray-600 leading-relaxed mb-4">
              Deepa is a women&apos;s fitness influencer and the founder of MindfulHomeFitrition — a platform built to make healthy living simple and achievable for every woman at home. With a growing community across YouTube and Instagram, she created ConsistentUs to bring her proven programs right to your phone.
            </p>
            <div className="flex gap-4">
              <a
                href="https://www.instagram.com/gonaturalwithdeepa"
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm font-semibold text-[#019948] hover:underline"
              >
                @gonaturalwithdeepa on Instagram ↗
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* Download */}
      <section id="download" className="py-16 px-6 bg-[#0E3C31] text-white text-center">
        <div className="max-w-xl mx-auto">
          <h2 className="text-3xl font-extrabold mb-3">Get ConsistentUs</h2>
          <p className="text-green-200 mb-8 text-sm">Available on iOS and Android. Start your 30-day journey today.</p>
          <div className="flex flex-wrap justify-center gap-4">
            <a
              href="#"
              className="bg-white text-[#0E3C31] font-bold px-6 py-3 rounded-xl text-sm hover:bg-green-50 transition-colors flex items-center gap-2"
            >
              <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
              App Store
            </a>
            <a
              href="#"
              className="bg-white text-[#0E3C31] font-bold px-6 py-3 rounded-xl text-sm hover:bg-green-50 transition-colors flex items-center gap-2"
            >
              <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor"><path d="M3.18 23.76a2 2 0 0 0 2.18-.29l12.76-7.37-2.83-2.83-12.11 10.49zm-1.81-21.5C1.13 2.65 1 3.12 1 3.63v16.74c0 .51.13.98.37 1.37l.07.07 9.37-9.37v-.22L1.44 2.19l-.07.07zm19.44 8.54-2.72-1.57-3.19 3.19 3.19 3.19 2.74-1.58a2 2 0 0 0 0-3.23zM5.36.53a2 2 0 0 0-2.18-.29l.07.07 9.37 9.37v.22L.07 1.3A2 2 0 0 0 0 2.63v18.74a2 2 0 0 0 .37 1.37L5.36.53z"/></svg>
              Play Store
            </a>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-400 py-8 px-6 text-center text-sm">
        <div className="max-w-4xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <span>© {new Date().getFullYear()} ConsistentUs · MindfulHomeFitrition</span>
          <div className="flex gap-6">
            <Link href="/privacy-policy" className="hover:text-white transition-colors">Privacy Policy</Link>
            <Link href="/delete-account" className="hover:text-white transition-colors">Delete Account</Link>
            <a href="https://mindfulhomefitrition.com" target="_blank" rel="noopener noreferrer" className="hover:text-white transition-colors">Website</a>
          </div>
        </div>
      </footer>
    </div>
  );
}
