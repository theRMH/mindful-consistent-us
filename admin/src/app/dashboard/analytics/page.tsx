'use client';

import { useEffect, useState } from 'react';

interface AnalyticsData {
  users: { total: number; newThisWeek: number; newThisMonth: number };
  enrollments: {
    total: number;
    active: number;
    byCourse: { courseId: string; title: string; category: string | null; enrollments: number; active: number }[];
  };
  sessions: { totalCompleted: number; totalWatchHours: number; totalSteps: number; totalCalories: number };
  streaks: { average: number; max: number; usersWithActiveStreak: number; totalTracked: number };
  feedback: { totalCount: number; averageRating: number; distribution: { rating: number; count: number }[] };
  notifications: { totalSent: number; totalDelivered: number; totalReadReceipts: number; openRate: number };
  activityLast14Days: { date: string; completions: number }[];
  userGrowthLast30: { date: string; count: number }[];
}

function StatCard({
  label,
  value,
  sub,
  color = 'green',
}: {
  label: string;
  value: string | number;
  sub?: string;
  color?: 'green' | 'blue' | 'amber' | 'purple' | 'teal';
}) {
  const colorMap: Record<string, string> = {
    green: 'bg-[#EBF7EF] border-[#C8E6D4] text-[#0E3C31]',
    blue: 'bg-blue-50 border-blue-100 text-blue-900',
    amber: 'bg-amber-50 border-amber-100 text-amber-900',
    purple: 'bg-purple-50 border-purple-100 text-purple-900',
    teal: 'bg-teal-50 border-teal-100 text-teal-900',
  };
  return (
    <div className={`rounded-xl border p-5 ${colorMap[color]}`}>
      <p className="text-xs font-semibold uppercase tracking-wider opacity-60">{label}</p>
      <p className="text-3xl font-extrabold mt-1">{value}</p>
      {sub && <p className="text-xs mt-1 opacity-60">{sub}</p>}
    </div>
  );
}

function MiniBar({ value, max, color = '#019948' }: { value: number; max: number; color?: string }) {
  const pct = max > 0 ? Math.round((value / max) * 100) : 0;
  return (
    <div className="flex items-end gap-0.5 h-8">
      <div
        className="w-full rounded-sm transition-all"
        style={{ height: `${Math.max(pct, 4)}%`, backgroundColor: color, opacity: 0.85 }}
      />
    </div>
  );
}

function StarBar({ rating, count, total }: { rating: number; count: number; total: number }) {
  const pct = total > 0 ? Math.round((count / total) * 100) : 0;
  return (
    <div className="flex items-center gap-2 text-xs">
      <span className="w-4 text-right font-semibold text-gray-600">{rating}★</span>
      <div className="flex-1 bg-gray-100 rounded-full h-2 overflow-hidden">
        <div className="h-2 rounded-full bg-amber-400" style={{ width: `${pct}%` }} />
      </div>
      <span className="w-6 text-right text-gray-400">{count}</span>
    </div>
  );
}

function formatDate(iso: string) {
  const d = new Date(iso);
  return `${d.getDate()}/${d.getMonth() + 1}`;
}

function formatCategory(c: string | null) {
  if (c === 'yoga') return 'Yoga';
  if (c === 'general_exercise') return 'Workout';
  return c ?? '—';
}

export default function AnalyticsPage() {
  const [data, setData] = useState<AnalyticsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/analytics')
      .then((r) => r.json())
      .then((d) => { setData(d); setLoading(false); })
      .catch(() => { setError('Failed to load analytics'); setLoading(false); });
  }, []);

  if (loading) {
    return (
      <div className="h-64 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#019948]" />
      </div>
    );
  }

  if (error || !data) {
    return <div className="bg-red-50 text-red-600 p-4 rounded-lg text-sm font-medium">{error || 'No data'}</div>;
  }

  const maxActivity = Math.max(...data.activityLast14Days.map((d) => d.completions), 1);
  const maxGrowth = Math.max(...data.userGrowthLast30.map((d) => d.count), 1);

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h2 className="text-2xl font-extrabold text-gray-900">Analytics</h2>
        <p className="text-sm text-gray-500 mt-1">Platform-wide performance overview — all time unless noted.</p>
      </div>

      {/* Users */}
      <section>
        <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Users</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatCard label="Total Users" value={data.users.total.toLocaleString()} color="green" />
          <StatCard label="New (Last 7 Days)" value={data.users.newThisWeek} color="teal" />
          <StatCard label="New (Last 30 Days)" value={data.users.newThisMonth} color="teal" />
          <StatCard label="With Active Streak" value={data.streaks.usersWithActiveStreak} sub={`of ${data.streaks.totalTracked} tracked`} color="amber" />
        </div>
      </section>

      {/* User Growth — last 30 days */}
      <section className="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
        <h3 className="text-sm font-bold text-gray-700 mb-4">User Registrations — Last 30 Days</h3>
        <div className="flex items-end gap-1 h-20">
          {data.userGrowthLast30.map((d) => (
            <div key={d.date} className="flex-1 flex flex-col items-center gap-1">
              <MiniBar value={d.count} max={maxGrowth} color="#019948" />
            </div>
          ))}
        </div>
        <div className="flex justify-between text-[10px] text-gray-400 mt-1">
          <span>{formatDate(data.userGrowthLast30[0].date)}</span>
          <span>{formatDate(data.userGrowthLast30[data.userGrowthLast30.length - 1].date)}</span>
        </div>
      </section>

      {/* Enrollments */}
      <section>
        <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Enrollments</h3>
        <div className="grid grid-cols-2 gap-4 mb-4">
          <StatCard label="Total Enrollments" value={data.enrollments.total.toLocaleString()} color="green" />
          <StatCard label="Active Enrollments" value={data.enrollments.active.toLocaleString()} sub={`${data.enrollments.total > 0 ? Math.round((data.enrollments.active / data.enrollments.total) * 100) : 0}% of total`} color="teal" />
        </div>

        {data.enrollments.byCourse.length > 0 && (
          <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-gray-50 border-b border-gray-100">
                  <th className="text-left px-4 py-3 text-xs font-bold text-gray-500 uppercase tracking-wider">Course</th>
                  <th className="text-left px-4 py-3 text-xs font-bold text-gray-500 uppercase tracking-wider">Category</th>
                  <th className="text-right px-4 py-3 text-xs font-bold text-gray-500 uppercase tracking-wider">Total</th>
                  <th className="text-right px-4 py-3 text-xs font-bold text-gray-500 uppercase tracking-wider">Active</th>
                  <th className="text-right px-4 py-3 text-xs font-bold text-gray-500 uppercase tracking-wider">Active %</th>
                </tr>
              </thead>
              <tbody>
                {data.enrollments.byCourse.map((c, i) => (
                  <tr key={c.courseId} className={i % 2 === 0 ? 'bg-white' : 'bg-gray-50/50'}>
                    <td className="px-4 py-3 font-semibold text-gray-800 truncate max-w-xs">{c.title}</td>
                    <td className="px-4 py-3 text-gray-500">{formatCategory(c.category)}</td>
                    <td className="px-4 py-3 text-right font-bold text-gray-700">{c.enrollments}</td>
                    <td className="px-4 py-3 text-right text-[#019948] font-bold">{c.active}</td>
                    <td className="px-4 py-3 text-right text-gray-400">
                      {c.enrollments > 0 ? Math.round((c.active / c.enrollments) * 100) : 0}%
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {/* Sessions & Wellness */}
      <section>
        <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Sessions & Wellness</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatCard label="Sessions Completed" value={data.sessions.totalCompleted.toLocaleString()} color="green" />
          <StatCard label="Watch Hours" value={`${data.sessions.totalWatchHours.toLocaleString()}h`} color="teal" />
          <StatCard label="Total Steps" value={data.sessions.totalSteps.toLocaleString()} color="blue" />
          <StatCard label="Calories Burned" value={`${data.sessions.totalCalories.toLocaleString()} kcal`} color="amber" />
        </div>
      </section>

      {/* Streaks */}
      <section>
        <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Streaks</h3>
        <div className="grid grid-cols-2 gap-4">
          <StatCard label="Average Current Streak" value={`${data.streaks.average} days`} color="green" />
          <StatCard label="Longest Streak Ever" value={`${data.streaks.max} days`} color="purple" />
        </div>
      </section>

      {/* Activity — last 14 days */}
      <section className="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
        <h3 className="text-sm font-bold text-gray-700 mb-4">Daily Session Completions — Last 14 Days</h3>
        <div className="flex items-end gap-1.5 h-24">
          {data.activityLast14Days.map((d) => (
            <div key={d.date} className="flex-1 flex flex-col items-center gap-1">
              <span className="text-[9px] text-gray-400 font-medium">{d.completions > 0 ? d.completions : ''}</span>
              <div className="w-full">
                <MiniBar value={d.completions} max={maxActivity} color="#019948" />
              </div>
            </div>
          ))}
        </div>
        <div className="flex justify-between text-[10px] text-gray-400 mt-1">
          {data.activityLast14Days.map((d, i) => (
            i % 2 === 0 ? <span key={d.date}>{formatDate(d.date)}</span> : <span key={d.date} />
          ))}
        </div>
      </section>

      {/* Feedback */}
      <section className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
          <h3 className="text-sm font-bold text-gray-700 mb-1">User Feedback</h3>
          <div className="flex items-baseline gap-2 mb-4">
            <span className="text-4xl font-extrabold text-gray-900">{data.feedback.averageRating || '—'}</span>
            <span className="text-lg text-amber-400">★</span>
            <span className="text-sm text-gray-400">{data.feedback.totalCount} reviews</span>
          </div>
          <div className="space-y-2">
            {[...data.feedback.distribution].reverse().map((d) => (
              <StarBar key={d.rating} rating={d.rating} count={d.count} total={data.feedback.totalCount} />
            ))}
          </div>
        </div>

        {/* Notifications */}
        <div className="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
          <h3 className="text-sm font-bold text-gray-700 mb-4">Notifications</h3>
          <div className="space-y-4">
            <div className="flex justify-between items-center py-2 border-b border-gray-50">
              <span className="text-sm text-gray-600">Campaigns Sent</span>
              <span className="font-bold text-gray-900">{data.notifications.totalSent}</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b border-gray-50">
              <span className="text-sm text-gray-600">Total Delivered</span>
              <span className="font-bold text-gray-900">{data.notifications.totalDelivered.toLocaleString()}</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b border-gray-50">
              <span className="text-sm text-gray-600">Read Receipts</span>
              <span className="font-bold text-[#019948]">{data.notifications.totalReadReceipts.toLocaleString()}</span>
            </div>
            <div className="flex justify-between items-center py-2">
              <span className="text-sm text-gray-600">Open Rate</span>
              <span className={`font-extrabold text-lg ${data.notifications.openRate >= 20 ? 'text-[#019948]' : 'text-amber-500'}`}>
                {data.notifications.openRate}%
              </span>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
