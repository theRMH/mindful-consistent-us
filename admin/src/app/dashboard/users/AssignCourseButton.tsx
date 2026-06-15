'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

type Course = { id: string; title: string };

export default function AssignCourseButton({
  userId,
  availableCourses,
  enrolledCourseIds,
}: {
  userId: string;
  availableCourses: Course[];
  enrolledCourseIds: string[];
}) {
  const [open, setOpen] = useState(false);
  const [courseId, setCourseId] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const router = useRouter();

  const unenrolled = availableCourses.filter((c) => !enrolledCourseIds.includes(c.id));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!courseId) return;
    setError('');
    setLoading(true);
    try {
      const res = await fetch(`/api/admin/users/${userId}/assign-course`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ courseId }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to assign course');
      setOpen(false);
      setCourseId('');
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  if (unenrolled.length === 0) {
    return (
      <p className="text-xs text-gray-400 italic">Enrolled in all available programs.</p>
    );
  }

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="w-full px-4 py-2 bg-blue-50 hover:bg-blue-100 border border-blue-200 text-blue-700 font-bold text-sm rounded-lg transition-colors"
      >
        + Assign Program
      </button>

      {open && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white rounded-2xl shadow-2xl p-6 w-full max-w-md space-y-4">
            <h3 className="font-extrabold text-gray-900 text-lg">Assign Program</h3>
            <p className="text-sm text-gray-500">Enroll this user in a program with completed payment status.</p>
            {error && (
              <p className="text-sm text-red-600 bg-red-50 px-3 py-2 rounded-lg">{error}</p>
            )}
            <form onSubmit={handleSubmit} className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-gray-500 mb-1">Select Program</label>
                <select
                  required
                  value={courseId}
                  onChange={(e) => setCourseId(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
                >
                  <option value="">Choose a program...</option>
                  {unenrolled.map((c) => (
                    <option key={c.id} value={c.id}>{c.title}</option>
                  ))}
                </select>
              </div>
              <div className="flex justify-end space-x-2 pt-2">
                <button
                  type="button"
                  onClick={() => { setOpen(false); setError(''); }}
                  className="px-4 py-2 text-sm font-bold border border-gray-200 rounded-lg text-gray-600 hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={loading || !courseId}
                  className="px-4 py-2 text-sm font-bold rounded-lg text-white bg-emerald-600 hover:bg-emerald-700 disabled:opacity-50"
                >
                  {loading ? 'Assigning...' : 'Assign Program'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}
