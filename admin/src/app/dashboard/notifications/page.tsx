'use client';

import { useEffect, useState } from 'react';

type SegmentType = 'all' | 'missed_days' | 'streak' | 'course';
type NotifType = 'announcement' | 'daily_reminder' | 'streak_reminder' | 'custom';

interface SentNotification {
  id: string;
  title: string;
  body: string;
  type: string;
  targetType: string;
  sentAt: string;
  sentCount: number;
}

interface Course {
  id: string;
  title: string;
}

export default function NotificationsPage() {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [type, setType] = useState<NotifType>('announcement');
  const [segmentType, setSegmentType] = useState<SegmentType>('all');
  const [segmentValue, setSegmentValue] = useState('2');
  const [selectedCourseId, setSelectedCourseId] = useState('');
  const [redirectUrl, setRedirectUrl] = useState('');
  const [sending, setSending] = useState(false);
  const [sendResult, setSendResult] = useState<string | null>(null);

  const [history, setHistory] = useState<SentNotification[]>([]);
  const [loadingHistory, setLoadingHistory] = useState(true);
  const [courses, setCourses] = useState<Course[]>([]);

  const fetchHistory = async () => {
    setLoadingHistory(true);
    try {
      const res = await fetch('/api/admin/notifications');
      if (res.ok) setHistory(await res.json());
    } catch {}
    setLoadingHistory(false);
  };

  const fetchCourses = async () => {
    try {
      const res = await fetch('/api/courses');
      if (res.ok) {
        const data = await res.json();
        setCourses(data);
      }
    } catch {}
  };

  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => { fetchHistory(); fetchCourses(); }, []);

  const buildSegmentRule = () => {
    if (segmentType === 'all') return null;
    if (segmentType === 'missed_days') return { type: 'missed_days', value: parseInt(segmentValue) };
    if (segmentType === 'streak') return { type: 'streak', value: parseInt(segmentValue) };
    if (segmentType === 'course') return { type: 'course', courseId: selectedCourseId };
    return null;
  };

  const handleSend = async () => {
    if (!title.trim() || !body.trim()) {
      setSendResult('Title and message are required.');
      return;
    }
    setSending(true);
    setSendResult(null);
    try {
      const res = await fetch('/api/admin/notifications', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: title.trim(),
          body: body.trim(),
          type,
          targetType: segmentType === 'all' ? 'all' : 'segment',
          segmentRule: buildSegmentRule(),
          redirectUrl: redirectUrl.trim() || undefined,
        }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed');
      setSendResult(`✅ Sent to ${data.sentCount} device(s).`);
      setTitle('');
      setBody('');
      setRedirectUrl('');
      fetchHistory();
    } catch (err) {
      setSendResult(`❌ Error: ${err instanceof Error ? err.message : 'Unknown error'}`);
    }
    setSending(false);
  };

  return (
    <div className="space-y-8">
      <div>
        <h2 className="text-2xl font-extrabold text-gray-900">Notifications</h2>
        <p className="text-sm text-gray-500 mt-1">Compose and send push notifications to users.</p>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-8">
        {/* ── Compose Panel ─────────────────────────────────────── */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 space-y-5">
          <h3 className="font-bold text-gray-800 text-base border-b border-gray-100 pb-3">
            Compose Notification
          </h3>

          {/* Type */}
          <div>
            <label className="block text-xs font-bold text-gray-500 mb-1.5">Notification Type</label>
            <select
              value={type}
              onChange={(e) => setType(e.target.value as NotifType)}
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
            >
              <option value="announcement">📢 Announcement</option>
              <option value="daily_reminder">⏰ Daily Reminder</option>
              <option value="streak_reminder">🔥 Streak Reminder</option>
              <option value="custom">✏️ Custom</option>
            </select>
          </div>

          {/* Title */}
          <div>
            <label className="block text-xs font-bold text-gray-500 mb-1.5">Title</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. Don't break your streak!"
              maxLength={80}
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
            />
          </div>

          {/* Body */}
          <div>
            <label className="block text-xs font-bold text-gray-500 mb-1.5">Message</label>
            <textarea
              value={body}
              onChange={(e) => setBody(e.target.value)}
              placeholder="e.g. Your 5-day streak is at risk. Complete today's session now!"
              rows={4}
              maxLength={300}
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500 resize-none"
            />
            <p className="text-xs text-gray-400 mt-1 text-right">{body.length}/300</p>
          </div>

          {/* Redirect URL */}
          <div>
            <label className="block text-xs font-bold text-gray-500 mb-1.5">
              Deep Link <span className="font-normal text-gray-400">(optional)</span>
            </label>
            <input
              type="text"
              value={redirectUrl}
              onChange={(e) => setRedirectUrl(e.target.value)}
              placeholder="e.g. /programs or /videos"
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
            />
          </div>

          {/* Target Audience */}
          <div>
            <label className="block text-xs font-bold text-gray-500 mb-1.5">Target Audience</label>
            <select
              value={segmentType}
              onChange={(e) => setSegmentType(e.target.value as SegmentType)}
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
            >
              <option value="all">👥 All Users</option>
              <option value="missed_days">😴 Missed last N days</option>
              <option value="streak">🏆 Streak ≥ N days</option>
              <option value="course">📚 Enrolled in specific course</option>
            </select>

            {(segmentType === 'missed_days' || segmentType === 'streak') && (
              <div className="mt-2">
                <label className="block text-xs font-bold text-gray-500 mb-1">
                  {segmentType === 'missed_days' ? 'Missed last N days' : 'Min streak (days)'}
                </label>
                <input
                  type="number"
                  min={1}
                  value={segmentValue}
                  onChange={(e) => setSegmentValue(e.target.value)}
                  className="w-24 px-3 py-1.5 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white"
                />
              </div>
            )}

            {segmentType === 'course' && (
              <div className="mt-2">
                <select
                  value={selectedCourseId}
                  onChange={(e) => setSelectedCourseId(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-900 bg-white"
                >
                  <option value="">Select a course…</option>
                  {courses.map((c) => (
                    <option key={c.id} value={c.id}>{c.title}</option>
                  ))}
                </select>
              </div>
            )}
          </div>

          {/* Result */}
          {sendResult && (
            <div className={`text-sm px-3 py-2 rounded-lg ${sendResult.startsWith('✅') ? 'bg-emerald-50 text-emerald-700' : 'bg-red-50 text-red-700'}`}>
              {sendResult}
            </div>
          )}

          <button
            onClick={handleSend}
            disabled={sending}
            className="w-full py-2.5 bg-emerald-600 text-white rounded-xl text-sm font-bold hover:bg-emerald-700 disabled:opacity-50 transition-colors"
          >
            {sending ? 'Sending…' : 'Send Notification'}
          </button>
        </div>

        {/* ── Preview Panel ──────────────────────────────────────── */}
        <div className="space-y-6">
          <div className="bg-slate-900 rounded-2xl p-6">
            <p className="text-xs font-bold text-slate-400 mb-4 uppercase tracking-widest">Push Preview</p>
            <div className="bg-white rounded-2xl p-4 flex items-start space-x-3">
              <div className="w-10 h-10 bg-emerald-100 rounded-xl flex items-center justify-center flex-shrink-0">
                <span className="text-lg">
                  {type === 'daily_reminder' ? '⏰' : type === 'streak_reminder' ? '🔥' : '📢'}
                </span>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-bold text-gray-900 truncate">{title || 'Notification Title'}</p>
                <p className="text-xs text-gray-500 mt-0.5 line-clamp-2">{body || 'Your message will appear here…'}</p>
              </div>
            </div>
            <p className="text-xs text-slate-500 mt-3 text-center">
              {segmentType === 'all'
                ? 'Will reach all users with notifications enabled'
                : segmentType === 'missed_days'
                ? `Will reach users who missed last ${segmentValue} day(s)`
                : segmentType === 'streak'
                ? `Will reach users with streak ≥ ${segmentValue} days`
                : 'Will reach users enrolled in the selected course'}
            </p>
          </div>
        </div>
      </div>

      {/* ── Sent History ───────────────────────────────────────── */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
        <h3 className="font-bold text-gray-800 text-base border-b border-gray-100 pb-3 mb-4">
          Sent History
        </h3>
        {loadingHistory ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-emerald-600" />
          </div>
        ) : history.length === 0 ? (
          <p className="text-sm text-gray-400 text-center py-8">No notifications sent yet.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-xs font-bold text-gray-400 uppercase border-b border-gray-100">
                  <th className="pb-2 pr-4">Title</th>
                  <th className="pb-2 pr-4">Type</th>
                  <th className="pb-2 pr-4">Target</th>
                  <th className="pb-2 pr-4">Sent To</th>
                  <th className="pb-2">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {history.map((n) => (
                  <tr key={n.id} className="text-gray-700">
                    <td className="py-3 pr-4 font-semibold max-w-xs truncate">{n.title}</td>
                    <td className="py-3 pr-4">
                      <span className="px-2 py-0.5 bg-emerald-50 text-emerald-700 rounded-full text-xs font-bold">
                        {n.type}
                      </span>
                    </td>
                    <td className="py-3 pr-4 text-gray-500 capitalize">{n.targetType}</td>
                    <td className="py-3 pr-4 text-gray-500">{n.sentCount} users</td>
                    <td className="py-3 text-gray-400 text-xs">
                      {new Date(n.sentAt).toLocaleDateString('en-IN', {
                        day: '2-digit', month: 'short', year: 'numeric',
                      })}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
