"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

type EnrollmentOption = {
  id: string;
  courseId: string;
  enrolledAt: Date | string;
  course: {
    title: string;
    totalDays: number;
  };
};

export default function ResetProgressButton({
  userId,
  userName,
  enrollments = [],
}: {
  userId: string;
  userName: string;
  enrollments?: EnrollmentOption[];
}) {
  const [loading, setLoading] = useState(false);
  const [demoLoadingId, setDemoLoadingId] = useState<string | null>(null);
  const [demoDays, setDemoDays] = useState<Record<string, string>>({});
  const [resetOnSet, setResetOnSet] = useState(true);
  const router = useRouter();

  const handleReset = async () => {
    if (
      !confirm(
        `Reset ALL progress for ${userName}? This deletes streaks, daily logs, and video completions. This cannot be undone.`,
      )
    ) {
      return;
    }

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

  const handleSetDemoDay = async (enrollment: EnrollmentOption) => {
    const value = demoDays[enrollment.id] || "1";
    const dayNumber = Number.parseInt(value, 10);

    if (!Number.isFinite(dayNumber) || dayNumber < 1) {
      alert("Enter a valid day number.");
      return;
    }

    if (dayNumber > enrollment.course.totalDays) {
      alert(`This course only has ${enrollment.course.totalDays} days.`);
      return;
    }

    const resetText = resetOnSet ? " and reset progress" : "";
    if (
      !confirm(
        `Set ${userName} to Day ${dayNumber} for "${enrollment.course.title}"${resetText}?`,
      )
    ) {
      return;
    }

    setDemoLoadingId(enrollment.id);
    try {
      const res = await fetch("/api/admin/users/set-demo-day", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          userId,
          enrollmentId: enrollment.id,
          dayNumber,
          resetProgress: resetOnSet,
        }),
      });
      if (!res.ok) {
        const err = await res.json();
        alert(`Error: ${err.error}`);
      } else {
        router.refresh();
      }
    } finally {
      setDemoLoadingId(null);
    }
  };

  return (
    <div className="space-y-4">
      <button
        onClick={handleReset}
        disabled={loading}
        className="w-full px-4 py-2 bg-red-50 hover:bg-red-100 border border-red-200 text-red-700 font-bold text-sm rounded-lg transition-colors disabled:opacity-50"
      >
        {loading ? "Resetting..." : "Reset Progress"}
      </button>

      <div className="border-t border-gray-100 pt-4 space-y-3">
        <div className="flex items-center justify-between gap-3">
          <div>
            <div className="text-xs font-black text-gray-700 uppercase">
              Demo Day Lock
            </div>
            <p className="text-[11px] text-gray-400 mt-0.5">
              Sets enrollment date so today unlocks Day N.
            </p>
          </div>
          <label className="flex items-center gap-1.5 text-[11px] font-bold text-gray-600">
            <input
              type="checkbox"
              checked={resetOnSet}
              onChange={(e) => setResetOnSet(e.target.checked)}
              className="h-3.5 w-3.5 rounded border-gray-300 text-emerald-600"
            />
            Reset
          </label>
        </div>

        {enrollments.length === 0 ? (
          <p className="text-xs text-gray-400 italic">
            Enroll this user in a program to set a demo day.
          </p>
        ) : (
          <div className="space-y-2">
            {enrollments.map((enrollment) => (
              <div
                key={enrollment.id}
                className="rounded-lg border border-gray-100 bg-gray-50 p-3 space-y-2"
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <div className="text-xs font-bold text-gray-800 truncate">
                      {enrollment.course.title}
                    </div>
                    <div className="text-[10px] text-gray-400 font-semibold">
                      {enrollment.course.totalDays} days
                    </div>
                  </div>
                </div>
                <div className="flex gap-2">
                  <input
                    type="number"
                    min={1}
                    max={enrollment.course.totalDays}
                    value={demoDays[enrollment.id] || ""}
                    onChange={(e) =>
                      setDemoDays((prev) => ({
                        ...prev,
                        [enrollment.id]: e.target.value,
                      }))
                    }
                    placeholder="Day"
                    className="min-w-0 flex-1 rounded-md border border-gray-200 bg-white px-2 py-1.5 text-xs font-bold text-gray-900"
                  />
                  <button
                    onClick={() => handleSetDemoDay(enrollment)}
                    disabled={demoLoadingId === enrollment.id}
                    className="px-3 py-1.5 rounded-md bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold disabled:opacity-50"
                  >
                    {demoLoadingId === enrollment.id ? "Setting..." : "Set"}
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
