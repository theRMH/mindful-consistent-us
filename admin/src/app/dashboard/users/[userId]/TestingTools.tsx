'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

type Enrollment = {
  id: string;
  course: { id: string; title: string; totalDays: number };
};

export default function TestingTools({
  userId,
  enrollments,
}: {
  userId: string;
  enrollments: Enrollment[];
}) {
  const router = useRouter();
  const [resetting, setResetting] = useState(false);
  const [resetMsg, setResetMsg] = useState('');

  const [demoDayEnrollmentId, setDemoDayEnrollmentId] = useState(enrollments[0]?.id || '');
  const [demoDayNumber, setDemoDayNumber] = useState(1);
  const [settingDay, setSettingDay] = useState(false);
  const [dayMsg, setDayMsg] = useState('');

  const selectedEnrollment = enrollments.find((e) => e.id === demoDayEnrollmentId);

  const handleReset = async () => {
    if (!confirm('Reset ALL progress for this user? This deletes all video & daily progress and zeroes out stats. Cannot be undone.')) return;
    setResetting(true);
    setResetMsg('');
    try {
      const res = await fetch('/api/admin/users/reset-progress', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed');
      setResetMsg('Progress reset successfully.');
      router.refresh();
    } catch (err) {
      setResetMsg(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setResetting(false);
    }
  };

  const handleSetDemoDay = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!demoDayEnrollmentId) return;
    setSettingDay(true);
    setDayMsg('');
    try {
      const res = await fetch('/api/admin/users/set-demo-day', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId, enrollmentId: demoDayEnrollmentId, dayNumber: demoDayNumber, resetProgress: false }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed');
      setDayMsg(`Demo day set to Day ${demoDayNumber} for ${selectedEnrollment?.course.title}.`);
      router.refresh();
    } catch (err) {
      setDayMsg(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setSettingDay(false);
    }
  };

  return (
    <div className="space-y-4">
      {/* Reset All Progress */}
      <div>
        <div className="text-xs font-bold text-gray-500 mb-1">Reset All Progress</div>
        <button
          onClick={handleReset}
          disabled={resetting}
          className="px-4 py-2 bg-red-50 hover:bg-red-100 border border-red-200 text-red-700 font-bold text-sm rounded-lg transition-colors disabled:opacity-50 w-full"
        >
          {resetting ? 'Resetting...' : 'Reset Progress'}
        </button>
        {resetMsg && (
          <p className="text-xs mt-1 text-gray-500">{resetMsg}</p>
        )}
      </div>

      {/* Set Demo Day */}
      {enrollments.length > 0 && (
        <div>
          <div className="text-xs font-bold text-gray-500 mb-1">Set Demo Day</div>
          <form onSubmit={handleSetDemoDay} className="space-y-2">
            {enrollments.length > 1 && (
              <select
                value={demoDayEnrollmentId}
                onChange={(e) => setDemoDayEnrollmentId(e.target.value)}
                className="w-full px-3 py-1.5 border border-gray-200 rounded-lg text-xs text-gray-800 bg-white focus:outline-none focus:ring-1 focus:ring-emerald-500"
              >
                {enrollments.map((e) => (
                  <option key={e.id} value={e.id}>{e.course.title}</option>
                ))}
              </select>
            )}
            <div className="flex gap-2 items-center">
              <input
                type="number"
                min={1}
                max={selectedEnrollment?.course.totalDays ?? 999}
                value={demoDayNumber}
                onChange={(e) => setDemoDayNumber(Number(e.target.value))}
                className="w-20 px-3 py-1.5 border border-gray-200 rounded-lg text-xs text-gray-800 bg-white focus:outline-none focus:ring-1 focus:ring-emerald-500"
                placeholder="Day"
              />
              <span className="text-xs text-gray-400">
                of {selectedEnrollment?.course.totalDays ?? '?'}
              </span>
              <button
                type="submit"
                disabled={settingDay}
                className="flex-1 px-4 py-1.5 bg-blue-50 hover:bg-blue-100 border border-blue-200 text-blue-700 font-bold text-xs rounded-lg transition-colors disabled:opacity-50"
              >
                {settingDay ? 'Setting...' : 'Set Day'}
              </button>
            </div>
            {dayMsg && <p className="text-xs text-gray-500">{dayMsg}</p>}
          </form>
        </div>
      )}
    </div>
  );
}
