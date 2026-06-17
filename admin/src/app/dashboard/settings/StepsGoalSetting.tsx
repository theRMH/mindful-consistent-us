'use client';

import { useState, useEffect } from 'react';

export function StepsGoalSetting() {
  const [goal, setGoal] = useState('10000');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/admin/settings')
      .then(r => r.json())
      .then(d => { if (d.steps_goal) setGoal(d.steps_goal); })
      .catch(() => {});
  }, []);

  const save = async () => {
    const num = parseInt(goal, 10);
    if (isNaN(num) || num < 1000 || num > 100000) {
      setError('Enter a value between 1,000 and 100,000');
      return;
    }
    setSaving(true);
    setError('');
    try {
      const res = await fetch('/api/admin/settings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ steps_goal: String(num) }),
      });
      if (!res.ok) throw new Error('Failed to save');
      setSaved(true);
      setTimeout(() => setSaved(false), 2500);
    } catch {
      setError('Failed to save. Try again.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="bg-white border border-gray-100 rounded-xl p-6 shadow-sm space-y-4">
      <div>
        <h3 className="text-base font-bold text-gray-900">Daily Steps Goal</h3>
        <p className="text-xs text-gray-500 mt-0.5">
          Users earn +25 pts per day when they reach this target. Affects all users.
        </p>
      </div>
      <div className="flex items-center gap-3">
        <input
          type="number"
          min={1000}
          max={100000}
          step={500}
          value={goal}
          onChange={e => { setGoal(e.target.value); setSaved(false); }}
          className="w-36 px-3 py-2 border border-gray-300 rounded-lg text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
        />
        <span className="text-sm text-gray-500">steps / day</span>
        <button
          onClick={save}
          disabled={saving}
          className="ml-auto px-4 py-2 text-sm font-bold rounded-lg text-white bg-emerald-600 hover:bg-emerald-700 disabled:opacity-50 transition-colors"
        >
          {saving ? 'Saving…' : saved ? '✓ Saved' : 'Save'}
        </button>
      </div>
      {error && <p className="text-xs text-red-500">{error}</p>}
      <div className="text-xs text-gray-400 bg-gray-50 rounded-lg p-3 space-y-1">
        <p className="font-semibold text-gray-600 mb-1">Points formula</p>
        <p>• <span className="font-medium">50 pts</span> — watching ≥1 video (maintains streak)</p>
        <p>• <span className="font-medium">30 pts</span> — watching <em>all</em> videos in a day (optional bonus)</p>
        <p>• <span className="font-medium">10 pts × streak</span> — current streak multiplier</p>
        <p>• <span className="font-medium">25 pts</span> — reaching daily steps goal</p>
      </div>
    </div>
  );
}
