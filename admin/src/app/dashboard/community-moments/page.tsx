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

export default function CommunityMomentsPage() {
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

  useEffect(() => { fetchMoments(); }, []);

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
      <div>
        <h2 className="text-2xl font-extrabold text-gray-900">Community Moments</h2>
        <p className="text-sm text-gray-500 mt-1">Testimonials shown on the app home screen to inspire unregistered users.</p>
      </div>

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
                    <p className="text-sm text-gray-600 max-w-xs truncate italic">"{m.quote}"</p>
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
    </div>
  );
}
