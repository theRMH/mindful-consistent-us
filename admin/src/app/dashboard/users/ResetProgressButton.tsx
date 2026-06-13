"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

export default function ResetProgressButton({
  userId,
  userName,
}: {
  userId: string;
  userName: string;
}) {
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleReset = async () => {
    if (
      !confirm(
        `Reset ALL progress for ${userName}? This deletes streaks, daily logs, and video completions. This cannot be undone.`,
      )
    )
      return;

    setLoading(true);
    try {
      const res = await fetch("/api/admin/users/reset-progress", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userId }),
      });
      if (!res.ok) {
        const err = await res.json();
        alert(`Error: ${err.error}`);
      } else {
        router.refresh();
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <button
      onClick={handleReset}
      disabled={loading}
      className="w-full px-4 py-2 bg-red-50 hover:bg-red-100 border border-red-200 text-red-700 font-bold text-sm rounded-lg transition-colors disabled:opacity-50"
    >
      {loading ? "Resetting…" : "Reset Progress"}
    </button>
  );
}
