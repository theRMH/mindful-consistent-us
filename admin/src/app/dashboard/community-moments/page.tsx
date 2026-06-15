'use client';

import { useEffect, useState } from 'react';

interface Moment {
  id: string;
  name: string;
  quote: string;
  photoUrl: string | null;
  avatarUrl: string | null;
  streakDays: number;
  sortOrder: number;
  isPublished: boolean;
}

interface LeaderboardEntry {
  id: string;
  name: string;
  avatarUrl: string | null;
  currentStreak: number;
  longestStreak: number;
  totalSteps: number;
  totalMinutes: number;
  daysCompleted: number;
  programs: { id: string; title: string; isActive: boolean }[];
}

interface Course {
  id: string;
  title: string;
}

export default function CommunityMomentsPage() {
  const [tab, setTab] = useState<'moments' | 'leaderboard'>('moments');

  // ── Community Moments state ───────────────────────────────────────
  const [moments, setMoments] = useState<Moment[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({
    name: '', quote: '', photoUrl: '', avatarUrl: '', streakDays: '0', sortOrder: '0',
  });
  const [error, setError] = useState('');

  const fetchMoments = async () => {
    setLoading(true);
    const res = await fetch('/api/admin/community-moments');
    setMoments(await res.json());
    setLoading(false);
  };

  // ── Leaderboard state ─────────────────────────────────────────────
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([]);
  const [lbLoading, setLbLoading] = useState(false);
  const [courses, setCourses] = useState<Course[]>([]);
  const [courseFilter, setCourseFilter] = useState('');
  const [sortBy, setSortBy] = useState('streak');

  const fetchLeaderboard = async () => {
    setLbLoading(true);
    try {
      const params = new URLSearchParams();
      if (courseFilter) params.set('courseId', courseFilter);
      params.set('sortBy', sortBy);
      const res = await fetch(`/api/admin/leaderboard?${params.toString()}`);
      if (res.ok) setLeaderboard(await res.json());
    } catch {}
    setLbLoading(false);
  };

  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => { fetchMoments(); }, []);

  useEffect(() => {
    fetch('/api/courses').then(r => r.json()).then(setCourses).catch(() => {});
  }, []);

  // eslint-disable-next-line react-hooks/exhaustive-deps, react-hooks/set-state-in-effect
  useEffect(() => { if (tab === 'leaderboard') fetchLeaderboard(); }, [tab, courseFilter, sortBy]);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSaving(true);
    const res = await fetch('/api/admin/community-moments', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form),
    });
    setSaving(false);
    if (!res.ok) {
      const data = await res.json();
      setError(data.error || 'Failed to add');
      return;
    }
    setForm({ name: '', quote: '', photoUrl: '', avatarUrl: '', streakDays: '0', sortOrder: '0' });
    fetchMoments();
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this moment?')) return;
    await fetch(`/api/admin/community-moments/${id}`, { method: 'DELETE' });
    fetchMoments();
  };

  const handleToggle = async (m: Moment) => {
    await fetch(`/api/admin/community-moments/${m.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ isPublished: !m.isPublished }),
    });
    fetchMoments();
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-2xl font-extrabold text-gray-900">Community</h2>
        <p className="text-sm text-gray-500 mt-1">Manage testimonials and view the member leaderboard.</p>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="flex space-x-8">
          {(['moments', 'leaderboard'] as const).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`pb-3 text-sm font-bold transition-colors border-b-2 ${
                tab === t
                  ? 'border-emerald-600 text-emerald-700'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              {t === 'moments' ? 'Community Moments' : 'Leaderboard'}
            </button>
          ))}
        </nav>
      </div>

      {/* ── Community Moments Tab ─────────────────────────────────── */}
      {tab === 'moments' && (
        <>
          {/* Add form */}
          <div className="bg-white shadow rounded-lg border border-gray-100 p-6">
            <h3 className="font-extrabold text-gray-800 mb-4">Add New Moment</h3>
            <form onSubmit={handleAdd} className="space-y-4">
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label className="block text-xs font-bold text-gray-600 mb-1">Name *</label>
                  <input
                    required
                    value={form.name}
                    onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
                    placeholder="Priya S"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-600 mb-1">Streak Days</label>
                  <input
                    type="number"
                    min="0"
                    value={form.streakDays}
                    onChange={e => setForm(f => ({ ...f, streakDays: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500"
                  />
                </div>
              </div>
              <div>
                <label className="block text-xs font-bold text-gray-600 mb-1">Quote *</label>
                <textarea
                  required
                  rows={2}
                  value={form.quote}
                  onChange={e => setForm(f => ({ ...f, quote: e.target.value }))}
                  placeholder="This 15 mins of yoga every day changed the way I start my mornings"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 resize-none"
                />
              </div>
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label className="block text-xs font-bold text-gray-600 mb-1">Photo URL</label>
                  <input
                    value={form.photoUrl}
                    onChange={e => setForm(f => ({ ...f, photoUrl: e.target.value }))}
                    placeholder="https://... or assets/community_priya.png"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-600 mb-1">Avatar URL</label>
                  <input
                    value={form.avatarUrl}
                    onChange={e => setForm(f => ({ ...f, avatarUrl: e.target.value }))}
                    placeholder="https://... or assets/avatar_priya.png"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500"
                  />
                </div>
              </div>
              {error && <p className="text-sm text-red-600">{error}</p>}
              <button
                type="submit"
                disabled={saving}
                className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm rounded-lg transition-colors disabled:opacity-50"
              >
                {saving ? 'Adding…' : 'Add Moment'}
              </button>
            </form>
          </div>

          {/* List */}
          <div className="bg-white shadow rounded-lg border border-gray-100 overflow-hidden">
            {loading ? (
              <div className="p-12 text-center text-sm text-gray-400">Loading…</div>
            ) : moments.length === 0 ? (
              <div className="p-12 text-center text-sm text-gray-400">No community moments yet. Add one above.</div>
            ) : (
              <table className="min-w-full divide-y divide-gray-100">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Person</th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Quote</th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Streak</th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
                    <th className="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-100">
                  {moments.map(m => (
                    <tr key={m.id} className="hover:bg-gray-50/50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="font-bold text-gray-900">{m.name}</div>
                      </td>
                      <td className="px-6 py-4">
                        <p className="text-sm text-gray-600 max-w-xs truncate italic">&quot;{m.quote}&quot;</p>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-amber-600 font-bold">
                        🔥 {m.streakDays} days
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <button
                          onClick={() => handleToggle(m)}
                          className={`inline-flex px-2 py-1 text-xs font-bold rounded-full ${
                            m.isPublished
                              ? 'bg-emerald-50 text-emerald-700 border border-emerald-100'
                              : 'bg-amber-50 text-amber-700 border border-amber-100'
                          }`}
                        >
                          {m.isPublished ? 'Published' : 'Hidden'}
                        </button>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right">
                        <button
                          onClick={() => handleDelete(m.id)}
                          className="text-red-500 hover:text-red-700 text-sm font-bold"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </>
      )}

      {/* ── Leaderboard Tab ───────────────────────────────────────── */}
      {tab === 'leaderboard' && (
        <>
          {/* Filters */}
          <div className="bg-white shadow rounded-lg border border-gray-100 p-4 flex flex-wrap gap-4 items-end">
            <div>
              <label className="block text-xs font-bold text-gray-500 mb-1">Program</label>
              <select
                value={courseFilter}
                onChange={(e) => setCourseFilter(e.target.value)}
                className="px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
              >
                <option value="">All Programs</option>
                {courses.map((c) => (
                  <option key={c.id} value={c.id}>{c.title}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs font-bold text-gray-500 mb-1">Sort By</label>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
                className="px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
              >
                <option value="streak">Current Streak 🔥</option>
                <option value="steps">Total Steps 👣</option>
                <option value="minutes">Total Minutes ⏱️</option>
                <option value="days">Days Completed ✅</option>
              </select>
            </div>
            <button
              onClick={fetchLeaderboard}
              className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-bold rounded-lg transition-colors"
            >
              Refresh
            </button>
          </div>

          {/* Leaderboard Table */}
          <div className="bg-white shadow rounded-lg border border-gray-100 overflow-hidden">
            {lbLoading ? (
              <div className="p-12 text-center">
                <div className="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-emerald-600" />
              </div>
            ) : leaderboard.length === 0 ? (
              <div className="p-12 text-center text-sm text-gray-400">No users found.</div>
            ) : (
              <table className="min-w-full divide-y divide-gray-100">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase w-12">#</th>
                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase">Member</th>
                    <th className="px-4 py-3 text-center text-xs font-bold text-gray-500 uppercase">Streak 🔥</th>
                    <th className="px-4 py-3 text-center text-xs font-bold text-gray-500 uppercase">Steps 👣</th>
                    <th className="px-4 py-3 text-center text-xs font-bold text-gray-500 uppercase">Minutes ⏱️</th>
                    <th className="px-4 py-3 text-center text-xs font-bold text-gray-500 uppercase">Days Done ✅</th>
                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase">Programs</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-100">
                  {leaderboard.map((entry, idx) => (
                    <tr key={entry.id} className={`hover:bg-gray-50/50 ${idx < 3 ? 'bg-amber-50/20' : ''}`}>
                      <td className="px-4 py-3 text-center">
                        {idx === 0 ? (
                          <span className="text-lg">🥇</span>
                        ) : idx === 1 ? (
                          <span className="text-lg">🥈</span>
                        ) : idx === 2 ? (
                          <span className="text-lg">🥉</span>
                        ) : (
                          <span className="text-xs font-bold text-gray-400">{idx + 1}</span>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center space-x-3">
                          <div className="h-8 w-8 rounded-full bg-slate-800 text-white flex items-center justify-center font-bold text-xs flex-shrink-0">
                            {entry.name[0]?.toUpperCase() ?? 'U'}
                          </div>
                          <span className="font-bold text-gray-900 text-sm">{entry.name}</span>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className="font-black text-amber-600 text-sm">{entry.currentStreak}</span>
                        {entry.longestStreak > entry.currentStreak && (
                          <div className="text-[10px] text-gray-400 font-semibold">best: {entry.longestStreak}</div>
                        )}
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className="font-bold text-gray-800 text-sm">{entry.totalSteps.toLocaleString()}</span>
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className="font-bold text-gray-800 text-sm">{entry.totalMinutes}</span>
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className="font-bold text-gray-800 text-sm">{entry.daysCompleted}</span>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex flex-wrap gap-1">
                          {entry.programs.length === 0 ? (
                            <span className="text-xs text-gray-400 italic">None</span>
                          ) : (
                            entry.programs.map((p) => (
                              <span
                                key={p.id}
                                className={`text-[10px] px-2 py-0.5 rounded-full font-bold ${
                                  p.isActive
                                    ? 'bg-emerald-50 text-emerald-700 border border-emerald-100'
                                    : 'bg-gray-100 text-gray-500 border border-gray-200'
                                }`}
                              >
                                {p.title}
                              </span>
                            ))
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </>
      )}
    </div>
  );
}
