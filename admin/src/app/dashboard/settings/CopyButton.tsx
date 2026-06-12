'use client';

import { useState } from 'react';

export function CopyButton({ text, label }: { text: string; label: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <button
      onClick={handleCopy}
      className="text-xs font-semibold text-emerald-600 hover:text-emerald-700 transition-colors"
    >
      {copied ? '✓ Copied!' : label}
    </button>
  );
}
