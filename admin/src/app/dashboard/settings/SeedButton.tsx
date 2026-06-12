'use client';
import { useState } from 'react';

export function SeedButton() {
  const [status, setStatus] = useState<'idle' | 'loading' | 'done' | 'error'>('idle');
  const [msg, setMsg] = useState('');

  const handleSeed = async () => {
    if (!confirm('This will insert demo courses, days and videos into the database. Continue?')) return;
    setStatus('loading');
    try {
      const res = await fetch('/api/admin/seed', { method: 'POST' });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? 'Seed failed');
      setMsg(data.message ?? 'Done');
      setStatus('done');
    } catch (e: any) {
      setMsg(e.message);
      setStatus('error');
    }
  };

  return (
    <div className="flex items-center gap-4">
      <button
        onClick={handleSeed}
        disabled={status === 'loading' || status === 'done'}
        className="px-4 py-2 rounded-lg text-sm font-bold text-white bg-emerald-600 hover:bg-emerald-700 disabled:opacity-50 transition-colors"
      >
        {status === 'loading' ? 'Seeding…' : status === 'done' ? '✓ Done' : 'Seed Demo Data'}
      </button>
      {msg && (
        <span className={`text-sm font-medium ${status === 'error' ? 'text-red-600' : 'text-emerald-700'}`}>
          {msg}
        </span>
      )}
    </div>
  );
}
