'use client';

import { useState } from 'react';

type Course = { id: string; title: string };

export default function ExportUsersButton() {
  const [open, setOpen] = useState(false);
  const [courses, setCourses] = useState<Course[]>([]);
  const [courseId, setCourseId] = useState('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  const [loading, setLoading] = useState(false);

  const openModal = async () => {
    setOpen(true);
    if (courses.length === 0) {
      const res = await fetch('/api/courses');
      const data = await res.json();
      setCourses(data ?? []);
    }
  };

  const download = () => {
    const params = new URLSearchParams();
    if (courseId) params.set('courseId', courseId);
    if (dateFrom) params.set('dateFrom', dateFrom);
    if (dateTo) params.set('dateTo', dateTo);
    window.location.href = `/api/admin/users/export?${params.toString()}`;
    setLoading(true);
    setTimeout(() => { setLoading(false); setOpen(false); }, 1500);
  };

  return (
    <>
      <button
        onClick={openModal}
        className="px-4 py-2 border border-gray-200 text-gray-600 hover:bg-gray-50 text-sm font-bold rounded-lg transition-colors"
      >
        Export CSV
      </button>

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 space-y-5">
            <div className="flex items-center justify-between">
              <h3 className="text-base font-bold text-gray-900">Export Users</h3>
              <button onClick={() => setOpen(false)} className="text-gray-400 hover:text-gray-600 text-xl font-bold">×</button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
                  Filter by Program
                </label>
                <select
                  value={courseId}
                  onChange={(e) => setCourseId(e.target.value)}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm text-gray-900 bg-white"
                >
                  <option value="">All Programs</option>
                  {courses.map((c) => (
                    <option key={c.id} value={c.id}>{c.title}</option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
                    Joined From
                  </label>
                  <input
                    type="date"
                    value={dateFrom}
                    onChange={(e) => setDateFrom(e.target.value)}
                    className="block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm text-gray-900 bg-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">
                    Joined To
                  </label>
                  <input
                    type="date"
                    value={dateTo}
                    onChange={(e) => setDateTo(e.target.value)}
                    className="block w-full px-3 py-2 border border-gray-300 rounded-lg text-sm text-gray-900 bg-white"
                  />
                </div>
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-1">
              <button
                onClick={() => setOpen(false)}
                className="px-4 py-2 text-sm font-bold border border-gray-200 rounded-lg text-gray-600 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={download}
                disabled={loading}
                className="px-4 py-2 text-sm font-bold rounded-lg text-white bg-emerald-600 hover:bg-emerald-700 disabled:opacity-50"
              >
                {loading ? 'Downloading…' : 'Download CSV'}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
