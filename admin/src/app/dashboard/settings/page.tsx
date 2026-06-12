import { CopyButton } from './CopyButton';

const TEST_PHONES = [
  { phone: '+91 9999999999', otp: '123456', note: 'Primary dev number' },
  { phone: '+91 8888888888', otp: '123456', note: 'Secondary dev number' },
];

export default function SettingsPage() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL ?? '';
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? '';
  const projectRef = supabaseUrl.replace('https://', '').replace('.supabase.co', '');
  const supabaseDashboardUrl = projectRef
    ? `https://supabase.com/dashboard/project/${projectRef}`
    : 'https://supabase.com/dashboard';

  const buildCmd = (apiUrl: string) =>
    supabaseUrl && supabaseAnonKey
      ? `flutter run \\\n  --dart-define=SUPABASE_URL=${supabaseUrl} \\\n  --dart-define=SUPABASE_ANON_KEY=${supabaseAnonKey} \\\n  --dart-define=API_BASE_URL=${apiUrl}`
      : null;

  const commands: { label: string; cmd: string | null }[] = [
    { label: 'Android Emulator', cmd: buildCmd('http://10.0.2.2:3000') },
    { label: 'iOS Simulator', cmd: buildCmd('http://localhost:3000') },
    { label: 'Physical Device', cmd: buildCmd('http://<your-local-ip>:3000') },
  ];

  const envVars = [
    { name: 'DATABASE_URL', isSet: !!process.env.DATABASE_URL, secret: true },
    { name: 'NEXT_PUBLIC_SUPABASE_URL', isSet: !!process.env.NEXT_PUBLIC_SUPABASE_URL, secret: false, display: supabaseUrl },
    { name: 'NEXT_PUBLIC_SUPABASE_ANON_KEY', isSet: !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY, secret: false, display: supabaseAnonKey ? supabaseAnonKey.slice(0, 20) + '…' : '' },
    { name: 'SUPABASE_SERVICE_ROLE_KEY', isSet: !!process.env.SUPABASE_SERVICE_ROLE_KEY, secret: true },
  ];

  const missingKeys = !supabaseUrl || !supabaseAnonKey;

  return (
    <div className="space-y-8 max-w-4xl">
      <div>
        <h2 className="text-2xl font-extrabold text-gray-900">App Settings</h2>
        <p className="text-sm text-gray-500 mt-1">
          Configuration hub for the Flutter client and Supabase integration.
        </p>
      </div>

      {/* ── Environment Variables ────────────────────────────────────── */}
      <section className="bg-white rounded-xl border border-gray-100 shadow-sm p-6 space-y-4">
        <h3 className="text-lg font-bold text-gray-900">Environment Variables</h3>
        <p className="text-sm text-gray-500">
          Edit{' '}
          <code className="bg-gray-100 px-1 rounded text-xs font-mono">admin/.env</code> to fill in
          missing values, then restart the dev server.
        </p>
        <div className="overflow-hidden rounded-lg border border-gray-100">
          <table className="w-full text-sm">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-left px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide w-72">Variable</th>
                <th className="text-left px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide w-24">Status</th>
                <th className="text-left px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">Value</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {envVars.map((v) => (
                <tr key={v.name} className="hover:bg-gray-50">
                  <td className="px-4 py-3 font-mono text-xs text-gray-700">{v.name}</td>
                  <td className="px-4 py-3">
                    {v.isSet ? (
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-emerald-100 text-emerald-700">
                        ✓ Set
                      </span>
                    ) : (
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-red-100 text-red-600">
                        ✗ Missing
                      </span>
                    )}
                  </td>
                  <td className="px-4 py-3 font-mono text-xs text-gray-500">
                    {v.secret ? (v.isSet ? '••••••••••••' : '—') : (v.display || '—')}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {/* ── Flutter App Configuration ────────────────────────────────── */}
      <section className="bg-white rounded-xl border border-gray-100 shadow-sm p-6 space-y-4">
        <h3 className="text-lg font-bold text-gray-900">Flutter App Configuration</h3>
        <p className="text-sm text-gray-500">
          Run Flutter with these commands so it connects to the correct Supabase project and backend.
        </p>

        {missingKeys ? (
          <div className="p-4 rounded-lg bg-amber-50 border border-amber-200 text-sm text-amber-700">
            <strong>Missing keys:</strong> Add{' '}
            <code className="bg-amber-100 px-1 rounded text-xs font-mono">NEXT_PUBLIC_SUPABASE_ANON_KEY</code>{' '}
            to <code className="bg-amber-100 px-1 rounded text-xs font-mono">admin/.env</code> and restart the
            dev server to generate these commands.
          </div>
        ) : (
          <div className="space-y-5">
            {commands.map(({ label, cmd }) => (
              <div key={label}>
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-xs font-semibold text-gray-600">{label}</span>
                  {cmd && (
                    <CopyButton text={cmd.replace(/\\\n\s+/g, ' ')} label="Copy" />
                  )}
                </div>
                <pre className="bg-slate-900 text-emerald-300 text-xs rounded-lg p-4 overflow-x-auto whitespace-pre leading-relaxed">
                  {cmd}
                </pre>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* ── Supabase Auth Settings ───────────────────────────────────── */}
      <section className="bg-white rounded-xl border border-gray-100 shadow-sm p-6 space-y-4">
        <div className="flex items-start justify-between">
          <div>
            <h3 className="text-lg font-bold text-gray-900">Supabase Auth Configuration</h3>
            <p className="text-sm text-gray-500 mt-1">
              Enable phone OTP and add dev test numbers in the Supabase dashboard.
            </p>
          </div>
          <a
            href={supabaseDashboardUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex-shrink-0 inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-900 text-white text-xs font-semibold hover:bg-slate-700 transition-colors"
          >
            Open Dashboard
            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
            </svg>
          </a>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="p-4 rounded-lg bg-blue-50 border border-blue-100">
            <p className="text-xs font-bold text-blue-700 mb-1">Step 1 — Enable Phone Auth</p>
            <p className="text-xs text-blue-600">
              Dashboard → Authentication → Providers → Phone → Enable.
              Connect Twilio for production SMS.
            </p>
          </div>
          <div className="p-4 rounded-lg bg-purple-50 border border-purple-100">
            <p className="text-xs font-bold text-purple-700 mb-1">Step 2 — Add Test Numbers</p>
            <p className="text-xs text-purple-600">
              Dashboard → Authentication → Phone → Test OTP section.
              Add the numbers below so you can test without real SMS.
            </p>
          </div>
        </div>

        <div className="overflow-hidden rounded-lg border border-gray-100">
          <div className="bg-gray-50 px-4 py-2 border-b border-gray-100">
            <p className="text-xs font-semibold text-gray-600">Recommended Dev Test Credentials</p>
          </div>
          <div className="divide-y divide-gray-50">
            {TEST_PHONES.map(({ phone, otp, note }) => (
              <div key={phone} className="flex items-center justify-between px-4 py-3">
                <div className="flex items-center gap-3 flex-wrap">
                  <span className="font-mono text-sm font-semibold text-gray-800">{phone}</span>
                  <span className="text-gray-300">→</span>
                  <span className="font-mono text-sm font-bold text-emerald-600">OTP: {otp}</span>
                  <span className="text-xs text-gray-400">{note}</span>
                </div>
                <CopyButton text={`${phone} → OTP: ${otp}`} label="Copy" />
              </div>
            ))}
          </div>
        </div>
        <p className="text-xs text-gray-400">
          These numbers only work in development — no real SMS is sent.
        </p>
      </section>

      {/* ── Mobile API Reference ─────────────────────────────────────── */}
      <section className="bg-white rounded-xl border border-gray-100 shadow-sm p-6 space-y-3">
        <h3 className="text-lg font-bold text-gray-900">Mobile API Reference</h3>
        <p className="text-sm text-gray-500">
          All endpoints require{' '}
          <code className="bg-gray-100 px-1 rounded text-xs font-mono">Authorization: Bearer &lt;token&gt;</code>
        </p>
        <div className="overflow-hidden rounded-lg border border-gray-100">
          <table className="w-full text-xs">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-left px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide w-16">Method</th>
                <th className="text-left px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide w-72">Path</th>
                <th className="text-left px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">Description</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {([
                ['POST', '/api/auth/sync', 'Upsert profile + ensure user_stats row'],
                ['GET', '/api/mobile/profile', 'Get current user profile'],
                ['PUT', '/api/mobile/profile', 'Update fullName, avatarUrl, fcmToken'],
                ['GET', '/api/mobile/courses', 'List all published courses'],
                ['GET', '/api/mobile/courses/:id', 'Course detail with days + videos'],
                ['GET', '/api/mobile/enrollments', 'User enrollments'],
                ['POST', '/api/mobile/enrollments', 'Enroll in a course'],
                ['GET', '/api/mobile/progress', 'Stats + completed days'],
                ['POST', '/api/mobile/progress/complete-day', 'Mark a day complete'],
                ['POST', '/api/mobile/progress/simulate', 'Dev simulator (useMockData mode)'],
                ['GET', '/api/mobile/leaderboard', 'Top 10 + user rank'],
                ['POST', '/api/mobile/steps', 'Sync steps + calories to user_stats'],
                ['GET', '/api/mobile/free-videos', 'List free videos'],
              ] as [string, string, string][]).map(([method, path, desc]) => (
                <tr key={path} className="hover:bg-gray-50">
                  <td className="px-4 py-2.5">
                    <span className={`inline-flex px-2 py-0.5 rounded text-xs font-bold ${
                      method === 'GET'
                        ? 'bg-blue-100 text-blue-700'
                        : method === 'PUT'
                        ? 'bg-amber-100 text-amber-700'
                        : 'bg-emerald-100 text-emerald-700'
                    }`}>{method}</span>
                  </td>
                  <td className="px-4 py-2.5 font-mono text-gray-700">{path}</td>
                  <td className="px-4 py-2.5 text-gray-500">{desc}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
