'use client';

import { useRouter, useSearchParams } from 'next/navigation';
import { Suspense } from 'react';
import { HomeScreenEditor } from './HomeScreenEditor';

const PAGES = [
  { value: 'home', label: 'Home Screen' },
  // Future screens added here — dropdown grows automatically
];

function ContentPageInner() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const currentPage = searchParams.get('page') ?? 'home';

  const handlePageChange = (value: string) => {
    router.push(`/dashboard/mobile-app/content?page=${value}`);
  };

  const currentLabel = PAGES.find((p) => p.value === currentPage)?.label ?? 'Home Screen';

  return (
    <div className="space-y-6 max-w-4xl">
      {/* ── Page header ── */}
      <div className="flex items-start justify-between gap-4">
        <div>
          <h2 className="text-2xl font-extrabold text-gray-900">Content</h2>
          <p className="text-sm text-gray-500 mt-1">
            Edit what users see in the mobile app — changes go live immediately.
          </p>
        </div>

        {/* Page switcher dropdown */}
        <div className="flex-shrink-0">
          <label htmlFor="page-select" className="block text-xs font-semibold text-gray-500 mb-1 text-right">
            Page
          </label>
          <div className="relative">
            <select
              id="page-select"
              value={currentPage}
              onChange={(e) => handlePageChange(e.target.value)}
              className="appearance-none bg-white border border-gray-200 rounded-lg pl-3 pr-8 py-2 text-sm font-semibold text-gray-800 shadow-sm focus:outline-none focus:ring-2 focus:ring-[#019948] focus:border-transparent cursor-pointer min-w-[160px]"
            >
              {PAGES.map((p) => (
                <option key={p.value} value={p.value}>
                  {p.label}
                </option>
              ))}
            </select>
            <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2 text-gray-500">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
              </svg>
            </div>
          </div>
        </div>
      </div>

      {/* ── Breadcrumb ── */}
      <div className="flex items-center gap-1.5 text-xs text-gray-400">
        <span>Mobile App</span>
        <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
        </svg>
        <span>Content</span>
        <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
        </svg>
        <span className="text-gray-600 font-semibold">{currentLabel}</span>
      </div>

      {/* ── Editor panel ── */}
      {currentPage === 'home' && <HomeScreenEditor />}

      {/* Future pages rendered here without changing this file */}
    </div>
  );
}

export default function ContentPage() {
  return (
    <Suspense fallback={
      <div className="flex items-center justify-center h-48 text-gray-400 text-sm">Loading…</div>
    }>
      <ContentPageInner />
    </Suspense>
  );
}
