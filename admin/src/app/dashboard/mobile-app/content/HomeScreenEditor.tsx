'use client';

import { useEffect, useState, useCallback } from 'react';

// ─── Types ────────────────────────────────────────────────────────────────────

interface GoalChip { icon: string; label: string; }
interface HowItWorksStep { number: number; icon: string; label: string; }
interface WhyTile { icon: string; label: string; }

interface HomeConfig {
  hero_image_url: string;
  hero_headline: string;
  hero_subtitle: string;
  goal_chips: GoalChip[];
  cta_primary_label: string;
  cta_primary_action: string;
  cta_secondary_label: string;
  cta_secondary_action: string;
  how_it_works_title: string;
  how_it_works_steps: HowItWorksStep[];
  recommended_course_id: string;
  recommended_badge: string;
  why_title: string;
  why_tiles: WhyTile[];
  free_videos_title: string;
  free_videos_count: number;
  social_proof_title: string;
  bottom_cta_headline: string;
  bottom_cta_button: string;
  bottom_cta_action: string;
  section_order: string[];
  section_visibility: Record<string, boolean>;
}

interface Course { id: string; title: string; }

// ─── Defaults ─────────────────────────────────────────────────────────────────

const DEFAULTS: HomeConfig = {
  hero_image_url: '',
  hero_headline: 'What would you like to improve today?',
  hero_subtitle: 'Build a routine that helps you feel calmer, stronger and more consistent.',
  goal_chips: [
    { icon: 'bolt', label: 'Feel More Energetic' },
    { icon: 'leaf', label: 'Reduce Stress' },
    { icon: 'accessibility', label: 'Improve Flexibility' },
    { icon: 'target', label: 'Build Consistency' },
  ],
  cta_primary_label: 'Find My Wellness Plan',
  cta_primary_action: 'login',
  cta_secondary_label: 'Watch How It Works',
  cta_secondary_action: 'login',
  how_it_works_title: 'How ConsistenUs works',
  how_it_works_steps: [
    { number: 1, icon: 'flag', label: 'Choose your goal' },
    { number: 2, icon: 'calendar', label: 'Follow daily guidance' },
    { number: 3, icon: 'chart', label: 'Track your consistency' },
  ],
  recommended_course_id: '',
  recommended_badge: 'Best for beginners',
  why_title: 'Why women start with ConsistenUs',
  why_tiles: [
    { icon: 'clock', label: 'Short guided sessions' },
    { icon: 'calendar_check', label: 'Simple daily routine' },
    { icon: 'group', label: 'Community support' },
  ],
  free_videos_title: 'Try a free session',
  free_videos_count: 2,
  social_proof_title: 'Real progress. Real people.',
  bottom_cta_headline: 'Your routine does not need to be perfect.\nIt just needs a beginning.',
  bottom_cta_button: 'Start My Journey',
  bottom_cta_action: 'login',
  section_order: ['hero', 'how_it_works', 'recommended', 'why', 'free_videos', 'social_proof', 'bottom_cta'],
  section_visibility: {
    how_it_works: true,
    recommended: true,
    why: true,
    free_videos: true,
    social_proof: true,
    bottom_cta: true,
  },
};

const SECTION_LABELS: Record<string, string> = {
  hero: 'Hero Banner',
  how_it_works: 'How It Works',
  recommended: 'Recommended Program',
  why: 'Why Section',
  free_videos: 'Free Videos',
  social_proof: 'Social Proof',
  bottom_cta: 'Bottom CTA',
};

// ─── Small reusable pieces ────────────────────────────────────────────────────

function SectionCard({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-6 space-y-4">
      <h3 className="text-base font-bold text-gray-900">{title}</h3>
      {children}
    </div>
  );
}

function Field({ label, hint, children }: { label: string; hint?: string; children: React.ReactNode }) {
  return (
    <div className="space-y-1">
      <label className="block text-xs font-semibold text-gray-600">{label}</label>
      {hint && <p className="text-xs text-gray-400">{hint}</p>}
      {children}
    </div>
  );
}

function Input({ value, onChange, placeholder }: { value: string; onChange: (v: string) => void; placeholder?: string }) {
  return (
    <input
      type="text"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#019948] focus:border-transparent"
    />
  );
}

function Textarea({ value, onChange, rows = 3 }: { value: string; onChange: (v: string) => void; rows?: number }) {
  return (
    <textarea
      value={value}
      onChange={(e) => onChange(e.target.value)}
      rows={rows}
      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#019948] focus:border-transparent resize-none"
    />
  );
}

function ActionField({ label, actionValue, onLabelChange, onActionChange, labelValue }: {
  label: string;
  labelValue: string;
  actionValue: string;
  onLabelChange: (v: string) => void;
  onActionChange: (v: string) => void;
}) {
  const isUrl = actionValue.startsWith('url:');
  const urlPart = isUrl ? actionValue.slice(4) : '';

  return (
    <div className="space-y-2 p-4 bg-gray-50 rounded-lg border border-gray-100">
      <p className="text-xs font-bold text-gray-500">{label}</p>
      <Field label="Button Label">
        <Input value={labelValue} onChange={onLabelChange} placeholder="e.g. Find My Wellness Plan" />
      </Field>
      <Field label="Action">
        <div className="flex gap-2">
          <select
            value={isUrl ? 'url' : 'login'}
            onChange={(e) => {
              if (e.target.value === 'login') onActionChange('login');
              else onActionChange('url:');
            }}
            className="border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#019948] bg-white"
          >
            <option value="login">Show login prompt</option>
            <option value="url">Open URL</option>
          </select>
          {isUrl && (
            <input
              type="url"
              value={urlPart}
              onChange={(e) => onActionChange(`url:${e.target.value}`)}
              placeholder="https://..."
              className="flex-1 border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#019948]"
            />
          )}
        </div>
      </Field>
    </div>
  );
}

function SaveButton({ onSave, saving, saved }: { onSave: () => void; saving: boolean; saved: boolean }) {
  return (
    <button
      onClick={onSave}
      disabled={saving}
      className={`px-5 py-2 rounded-lg text-sm font-bold transition-colors ${
        saved
          ? 'bg-emerald-100 text-emerald-700'
          : 'bg-[#019948] text-white hover:bg-[#017a3a]'
      } disabled:opacity-50`}
    >
      {saving ? 'Saving…' : saved ? '✓ Saved' : 'Save'}
    </button>
  );
}

// ─── Main Editor ──────────────────────────────────────────────────────────────

export function HomeScreenEditor() {
  const [config, setConfig] = useState<HomeConfig>(DEFAULTS);
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);
  const [sectionSaving, setSectionSaving] = useState<Record<string, boolean>>({});
  const [sectionSaved, setSectionSaved] = useState<Record<string, boolean>>({});
  const [error, setError] = useState('');

  // Load saved config + course list
  useEffect(() => {
    Promise.all([
      fetch('/api/admin/homepage').then((r) => r.json()),
      fetch('/api/courses').then((r) => r.json()),
    ])
      .then(([cfg, courseList]) => {
        setConfig((prev) => ({ ...prev, ...cfg }));
        setCourses(Array.isArray(courseList) ? courseList : []);
      })
      .catch(() => setError('Failed to load settings.'))
      .finally(() => setLoading(false));
  }, []);

  const set = useCallback(<K extends keyof HomeConfig>(key: K, value: HomeConfig[K]) => {
    setConfig((prev) => ({ ...prev, [key]: value }));
  }, []);

  const saveSection = async (sectionKey: string, keys: (keyof HomeConfig)[]) => {
    setSectionSaving((s) => ({ ...s, [sectionKey]: true }));
    const body: Record<string, unknown> = {};
    for (const k of keys) body[k] = config[k];
    try {
      await fetch('/api/admin/homepage', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      setSectionSaved((s) => ({ ...s, [sectionKey]: true }));
      setTimeout(() => setSectionSaved((s) => ({ ...s, [sectionKey]: false })), 2500);
    } catch {
      alert('Save failed — please try again.');
    } finally {
      setSectionSaving((s) => ({ ...s, [sectionKey]: false }));
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-48 text-gray-400 text-sm">
        Loading settings…
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 rounded-lg bg-red-50 border border-red-200 text-sm text-red-700">{error}</div>
    );
  }

  return (
    <div className="space-y-6">

      {/* ── 1. Hero Banner ── */}
      <SectionCard title="Hero Banner">
        <Field label="Background Image URL" hint="Leave blank to use the app's bundled image asset.">
          <Input value={config.hero_image_url} onChange={(v) => set('hero_image_url', v)} placeholder="https://..." />
        </Field>
        <Field label="Headline">
          <Input value={config.hero_headline} onChange={(v) => set('hero_headline', v)} />
        </Field>
        <Field label="Subtitle">
          <Textarea value={config.hero_subtitle} onChange={(v) => set('hero_subtitle', v)} rows={2} />
        </Field>
        <Field label="Goal Chips" hint="Up to 4 chips. Icon is a keyword the app maps to a Material icon (bolt, leaf, accessibility, target, clock, calendar, group, flag, chart, spa).">
          <div className="space-y-2">
            {config.goal_chips.map((chip, i) => (
              <div key={i} className="flex gap-2 items-center">
                <input
                  type="text"
                  value={chip.icon}
                  onChange={(e) => {
                    const next = [...config.goal_chips];
                    next[i] = { ...chip, icon: e.target.value };
                    set('goal_chips', next);
                  }}
                  placeholder="icon"
                  className="w-28 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#019948]"
                />
                <input
                  type="text"
                  value={chip.label}
                  onChange={(e) => {
                    const next = [...config.goal_chips];
                    next[i] = { ...chip, label: e.target.value };
                    set('goal_chips', next);
                  }}
                  placeholder="label"
                  className="flex-1 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#019948]"
                />
                {config.goal_chips.length > 1 && (
                  <button
                    onClick={() => set('goal_chips', config.goal_chips.filter((_, j) => j !== i))}
                    className="text-gray-400 hover:text-red-500 transition-colors"
                    title="Remove"
                  >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                )}
              </div>
            ))}
            {config.goal_chips.length < 4 && (
              <button
                onClick={() => set('goal_chips', [...config.goal_chips, { icon: '', label: '' }])}
                className="text-xs font-semibold text-[#019948] hover:underline"
              >
                + Add chip
              </button>
            )}
          </div>
        </Field>
        <div className="flex justify-end">
          <SaveButton
            onSave={() => saveSection('hero', ['hero_image_url', 'hero_headline', 'hero_subtitle', 'goal_chips'])}
            saving={sectionSaving.hero ?? false}
            saved={sectionSaved.hero ?? false}
          />
        </div>
      </SectionCard>

      {/* ── 2. CTA Buttons ── */}
      <SectionCard title="CTA Buttons">
        <ActionField
          label="Primary Button"
          labelValue={config.cta_primary_label}
          actionValue={config.cta_primary_action}
          onLabelChange={(v) => set('cta_primary_label', v)}
          onActionChange={(v) => set('cta_primary_action', v)}
        />
        <ActionField
          label="Secondary Button"
          labelValue={config.cta_secondary_label}
          actionValue={config.cta_secondary_action}
          onLabelChange={(v) => set('cta_secondary_label', v)}
          onActionChange={(v) => set('cta_secondary_action', v)}
        />
        <div className="flex justify-end">
          <SaveButton
            onSave={() => saveSection('cta', ['cta_primary_label', 'cta_primary_action', 'cta_secondary_label', 'cta_secondary_action'])}
            saving={sectionSaving.cta ?? false}
            saved={sectionSaved.cta ?? false}
          />
        </div>
      </SectionCard>

      {/* ── 3. How It Works ── */}
      <SectionCard title="How It Works">
        <Field label="Section Title">
          <Input value={config.how_it_works_title} onChange={(v) => set('how_it_works_title', v)} />
        </Field>
        <Field label="Steps" hint="3 steps — icon keyword + label for each.">
          <div className="space-y-2">
            {config.how_it_works_steps.map((step, i) => (
              <div key={i} className="flex gap-2 items-center">
                <span className="w-6 text-xs font-bold text-gray-400 text-center">{step.number}</span>
                <input
                  type="text"
                  value={step.icon}
                  onChange={(e) => {
                    const next = [...config.how_it_works_steps];
                    next[i] = { ...step, icon: e.target.value };
                    set('how_it_works_steps', next);
                  }}
                  placeholder="icon"
                  className="w-28 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#019948]"
                />
                <input
                  type="text"
                  value={step.label}
                  onChange={(e) => {
                    const next = [...config.how_it_works_steps];
                    next[i] = { ...step, label: e.target.value };
                    set('how_it_works_steps', next);
                  }}
                  placeholder="label"
                  className="flex-1 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#019948]"
                />
              </div>
            ))}
          </div>
        </Field>
        <div className="flex justify-end">
          <SaveButton
            onSave={() => saveSection('how_it_works', ['how_it_works_title', 'how_it_works_steps'])}
            saving={sectionSaving.how_it_works ?? false}
            saved={sectionSaved.how_it_works ?? false}
          />
        </div>
      </SectionCard>

      {/* ── 4. Recommended Program ── */}
      <SectionCard title="Recommended Program">
        <Field label="Course" hint="Pick the course to feature. Title, price and thumbnail are pulled live from the course record.">
          <select
            value={config.recommended_course_id}
            onChange={(e) => set('recommended_course_id', e.target.value)}
            className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#019948] bg-white"
          >
            <option value="">— None (hide section) —</option>
            {courses.map((c) => (
              <option key={c.id} value={c.id}>{c.title}</option>
            ))}
          </select>
        </Field>
        <Field label="Badge Label" hint='e.g. "Best for beginners"'>
          <Input value={config.recommended_badge} onChange={(v) => set('recommended_badge', v)} placeholder="Best for beginners" />
        </Field>
        <div className="flex justify-end">
          <SaveButton
            onSave={() => saveSection('recommended', ['recommended_course_id', 'recommended_badge'])}
            saving={sectionSaving.recommended ?? false}
            saved={sectionSaved.recommended ?? false}
          />
        </div>
      </SectionCard>

      {/* ── 5. Why Section ── */}
      <SectionCard title="Why Section">
        <Field label="Section Title">
          <Input value={config.why_title} onChange={(v) => set('why_title', v)} />
        </Field>
        <Field label="Tiles" hint="3 tiles — icon keyword + label.">
          <div className="space-y-2">
            {config.why_tiles.map((tile, i) => (
              <div key={i} className="flex gap-2 items-center">
                <input
                  type="text"
                  value={tile.icon}
                  onChange={(e) => {
                    const next = [...config.why_tiles];
                    next[i] = { ...tile, icon: e.target.value };
                    set('why_tiles', next);
                  }}
                  placeholder="icon"
                  className="w-28 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#019948]"
                />
                <input
                  type="text"
                  value={tile.label}
                  onChange={(e) => {
                    const next = [...config.why_tiles];
                    next[i] = { ...tile, label: e.target.value };
                    set('why_tiles', next);
                  }}
                  placeholder="label"
                  className="flex-1 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#019948]"
                />
              </div>
            ))}
          </div>
        </Field>
        <div className="flex justify-end">
          <SaveButton
            onSave={() => saveSection('why', ['why_title', 'why_tiles'])}
            saving={sectionSaving.why ?? false}
            saved={sectionSaved.why ?? false}
          />
        </div>
      </SectionCard>

      {/* ── 6. Free Videos ── */}
      <SectionCard title="Free Videos">
        <Field label="Section Title">
          <Input value={config.free_videos_title} onChange={(v) => set('free_videos_title', v)} placeholder="Try a free session" />
        </Field>
        <Field label="Number of videos to show (1–4)">
          <input
            type="number"
            min={1}
            max={4}
            value={config.free_videos_count}
            onChange={(e) => set('free_videos_count', Math.min(4, Math.max(1, Number(e.target.value))))}
            className="w-24 border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#019948]"
          />
        </Field>
        <div className="flex justify-end">
          <SaveButton
            onSave={() => saveSection('free_videos', ['free_videos_title', 'free_videos_count'])}
            saving={sectionSaving.free_videos ?? false}
            saved={sectionSaved.free_videos ?? false}
          />
        </div>
      </SectionCard>

      {/* ── 7. Social Proof ── */}
      <SectionCard title="Social Proof">
        <p className="text-xs text-gray-400">
          Content (photos, quotes, names) is managed in the{' '}
          <a href="/dashboard/community-moments" className="text-[#019948] font-semibold hover:underline">
            Community Moments
          </a>{' '}
          section. Only the section title is set here.
        </p>
        <Field label="Section Title">
          <Input value={config.social_proof_title} onChange={(v) => set('social_proof_title', v)} placeholder="Real progress. Real people." />
        </Field>
        <div className="flex justify-end">
          <SaveButton
            onSave={() => saveSection('social_proof', ['social_proof_title'])}
            saving={sectionSaving.social_proof ?? false}
            saved={sectionSaved.social_proof ?? false}
          />
        </div>
      </SectionCard>

      {/* ── 8. Bottom CTA ── */}
      <SectionCard title="Bottom CTA">
        <Field label="Headline" hint="Use a newline (\n) to split into two lines.">
          <Textarea value={config.bottom_cta_headline} onChange={(v) => set('bottom_cta_headline', v)} rows={2} />
        </Field>
        <ActionField
          label="Button"
          labelValue={config.bottom_cta_button}
          actionValue={config.bottom_cta_action}
          onLabelChange={(v) => set('bottom_cta_button', v)}
          onActionChange={(v) => set('bottom_cta_action', v)}
        />
        <div className="flex justify-end">
          <SaveButton
            onSave={() => saveSection('bottom_cta', ['bottom_cta_headline', 'bottom_cta_button', 'bottom_cta_action'])}
            saving={sectionSaving.bottom_cta ?? false}
            saved={sectionSaved.bottom_cta ?? false}
          />
        </div>
      </SectionCard>

      {/* ── 9. Section Order & Visibility ── */}
      <SectionCard title="Section Order & Visibility">
        <p className="text-xs text-gray-400">
          Toggle sections on/off. Drag-to-reorder coming soon — for now use the order controls.
        </p>
        <div className="space-y-2">
          {config.section_order.map((sectionKey, i) => {
            const isHero = sectionKey === 'hero';
            const isVisible = isHero || (config.section_visibility[sectionKey] !== false);
            return (
              <div
                key={sectionKey}
                className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg border border-gray-100"
              >
                {/* Order arrows */}
                <div className="flex flex-col gap-0.5">
                  <button
                    disabled={i === 0}
                    onClick={() => {
                      const next = [...config.section_order];
                      [next[i - 1], next[i]] = [next[i], next[i - 1]];
                      set('section_order', next);
                    }}
                    className="text-gray-400 hover:text-gray-700 disabled:opacity-20"
                    title="Move up"
                  >
                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 15l7-7 7 7" />
                    </svg>
                  </button>
                  <button
                    disabled={i === config.section_order.length - 1}
                    onClick={() => {
                      const next = [...config.section_order];
                      [next[i + 1], next[i]] = [next[i], next[i + 1]];
                      set('section_order', next);
                    }}
                    className="text-gray-400 hover:text-gray-700 disabled:opacity-20"
                    title="Move down"
                  >
                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                    </svg>
                  </button>
                </div>

                {/* Visibility toggle */}
                <button
                  disabled={isHero}
                  onClick={() => {
                    if (isHero) return;
                    set('section_visibility', {
                      ...config.section_visibility,
                      [sectionKey]: !isVisible,
                    });
                  }}
                  title={isHero ? 'Hero is always visible' : isVisible ? 'Hide section' : 'Show section'}
                  className={`flex-shrink-0 w-9 h-5 rounded-full transition-colors ${
                    isVisible ? 'bg-[#019948]' : 'bg-gray-300'
                  } ${isHero ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}`}
                >
                  <span
                    className={`block w-4 h-4 rounded-full bg-white shadow transform transition-transform mx-0.5 ${
                      isVisible ? 'translate-x-4' : 'translate-x-0'
                    }`}
                  />
                </button>

                <span className={`text-sm font-semibold ${isVisible ? 'text-gray-800' : 'text-gray-400'}`}>
                  {SECTION_LABELS[sectionKey] ?? sectionKey}
                </span>

                {isHero && (
                  <span className="ml-auto text-xs text-gray-400 italic">always visible</span>
                )}
              </div>
            );
          })}
        </div>
        <div className="flex justify-end">
          <SaveButton
            onSave={() => saveSection('layout', ['section_order', 'section_visibility'])}
            saving={sectionSaving.layout ?? false}
            saved={sectionSaved.layout ?? false}
          />
        </div>
      </SectionCard>

    </div>
  );
}
