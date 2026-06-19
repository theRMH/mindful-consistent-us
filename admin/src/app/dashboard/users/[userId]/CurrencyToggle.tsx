'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function CurrencyToggle({ userId, current }: { userId: string; current: string }) {
  const [currency, setCurrency] = useState(current);
  const [saving, setSaving] = useState(false);
  const router = useRouter();

  const toggle = async (next: string) => {
    if (next === currency || saving) return;
    setSaving(true);
    await fetch(`/api/admin/users/${userId}/set-currency`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ currency: next }),
    });
    setCurrency(next);
    setSaving(false);
    router.refresh();
  };

  return (
    <div className="flex rounded-md border border-gray-300 overflow-hidden text-xs font-bold w-fit">
      {(['INR', 'USD'] as const).map((c) => (
        <button
          key={c}
          onClick={() => toggle(c)}
          disabled={saving}
          className={`px-3 py-1 transition-colors ${
            currency === c
              ? 'bg-emerald-600 text-white'
              : 'bg-white text-gray-600 hover:bg-gray-50'
          }`}
        >
          {c === 'INR' ? '₹ INR' : '$ USD'}
        </button>
      ))}
    </div>
  );
}
