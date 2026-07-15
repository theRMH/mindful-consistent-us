'use client';

import { useEffect, useState } from 'react';

interface Coupon {
  id: string;
  code: string;
  discountAmount: number;
  isActive: boolean;
  expiresAt: string | null;
  usageLimit: number | null;
  usageCount: number;
  createdAt: string;
}

export default function CouponsPage() {
  const [coupons, setCoupons] = useState<Coupon[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ code: '', discountAmount: '', expiresAt: '', usageLimit: '' });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const fetchCoupons = async () => {
    setLoading(true);
    const res = await fetch('/api/admin/coupons');
    const data = await res.json();
    setCoupons(data);
    setLoading(false);
  };

  useEffect(() => { fetchCoupons(); }, []);

  const handleCreate = async () => {
    setError('');
    if (!form.code || !form.discountAmount) {
      setError('Code and discount amount are required.');
      return;
    }
    setSaving(true);
    const res = await fetch('/api/admin/coupons', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        code: form.code,
        discountAmount: parseFloat(form.discountAmount),
        expiresAt: form.expiresAt || null,
        usageLimit: form.usageLimit ? parseInt(form.usageLimit) : null,
      }),
    });
    setSaving(false);
    if (res.ok) {
      setForm({ code: '', discountAmount: '', expiresAt: '', usageLimit: '' });
      setShowForm(false);
      fetchCoupons();
    } else {
      const data = await res.json();
      setError(data.error || 'Failed to create coupon.');
    }
  };

  const toggleActive = async (coupon: Coupon) => {
    await fetch(`/api/admin/coupons/${coupon.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ isActive: !coupon.isActive }),
    });
    fetchCoupons();
  };

  const deleteCoupon = async (id: string) => {
    if (!confirm('Delete this coupon?')) return;
    await fetch(`/api/admin/coupons/${id}`, { method: 'DELETE' });
    fetchCoupons();
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Coupons</h1>
          <p className="text-sm text-gray-500 mt-1">Manage discount codes for course purchases</p>
        </div>
        <button
          onClick={() => { setShowForm(!showForm); setError(''); }}
          className="bg-[#019948] text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-[#017a3a] transition-colors"
        >
          + New Coupon
        </button>
      </div>

      {showForm && (
        <div className="bg-white border border-gray-200 rounded-xl p-6 space-y-4">
          <h2 className="text-base font-semibold text-gray-800">Create Coupon</h2>
          {error && <p className="text-red-600 text-sm">{error}</p>}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1">Coupon Code</label>
              <input
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm uppercase"
                placeholder="e.g. FIT20"
                value={form.code}
                onChange={(e) => setForm({ ...form, code: e.target.value.toUpperCase() })}
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1">Discount Amount (₹)</label>
              <input
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm"
                placeholder="e.g. 300"
                type="number"
                value={form.discountAmount}
                onChange={(e) => setForm({ ...form, discountAmount: e.target.value })}
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1">Expiry Date (optional)</label>
              <input
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm"
                type="datetime-local"
                value={form.expiresAt}
                onChange={(e) => setForm({ ...form, expiresAt: e.target.value })}
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1">Usage Limit (optional)</label>
              <input
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm"
                placeholder="Unlimited"
                type="number"
                value={form.usageLimit}
                onChange={(e) => setForm({ ...form, usageLimit: e.target.value })}
              />
            </div>
          </div>
          <div className="flex gap-3">
            <button
              onClick={handleCreate}
              disabled={saving}
              className="bg-[#019948] text-white px-5 py-2 rounded-lg text-sm font-semibold hover:bg-[#017a3a] disabled:opacity-50"
            >
              {saving ? 'Creating...' : 'Create'}
            </button>
            <button
              onClick={() => { setShowForm(false); setError(''); }}
              className="border border-gray-200 text-gray-600 px-5 py-2 rounded-lg text-sm font-semibold hover:bg-gray-50"
            >
              Cancel
            </button>
          </div>
        </div>
      )}

      {loading ? (
        <div className="text-center py-12 text-gray-400">Loading...</div>
      ) : coupons.length === 0 ? (
        <div className="text-center py-12 text-gray-400">No coupons yet. Create one to get started.</div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 text-gray-500 text-xs uppercase">
              <tr>
                <th className="px-6 py-3 text-left font-semibold">Code</th>
                <th className="px-6 py-3 text-left font-semibold">Discount</th>
                <th className="px-6 py-3 text-left font-semibold">Used</th>
                <th className="px-6 py-3 text-left font-semibold">Limit</th>
                <th className="px-6 py-3 text-left font-semibold">Expires</th>
                <th className="px-6 py-3 text-left font-semibold">Status</th>
                <th className="px-6 py-3 text-right font-semibold">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {coupons.map((coupon) => (
                <tr key={coupon.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 font-mono font-bold text-[#0E3C31]">{coupon.code}</td>
                  <td className="px-6 py-4 font-semibold text-gray-800">₹{Number(coupon.discountAmount).toLocaleString('en-IN')}</td>
                  <td className="px-6 py-4 text-gray-600">{coupon.usageCount}</td>
                  <td className="px-6 py-4 text-gray-600">{coupon.usageLimit ?? '∞'}</td>
                  <td className="px-6 py-4 text-gray-600">
                    {coupon.expiresAt ? new Date(coupon.expiresAt).toLocaleDateString('en-IN') : '—'}
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                      coupon.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'
                    }`}>
                      {coupon.isActive ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right space-x-3">
                    <button
                      onClick={() => toggleActive(coupon)}
                      className="text-xs font-semibold text-[#019948] hover:underline"
                    >
                      {coupon.isActive ? 'Deactivate' : 'Activate'}
                    </button>
                    <button
                      onClick={() => deleteCoupon(coupon.id)}
                      className="text-xs font-semibold text-red-500 hover:underline"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
