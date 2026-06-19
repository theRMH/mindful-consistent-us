import prisma from "@/lib/prisma";
import Link from "next/link";
import { notFound } from "next/navigation";
import AssignCourseButton from "../AssignCourseButton";
import TestingTools from "./TestingTools";
import CurrencyToggle from "./CurrencyToggle";

export const dynamic = "force-dynamic";

export default async function UserDetailPage({
  params,
}: {
  params: Promise<{ userId: string }>;
}) {
  const { userId } = await params;

  const [profile, allCourses, dailyProgresses] = await Promise.all([
    prisma.profile.findUnique({
      where: { id: userId },
      include: {
        userStats: true,
        enrollments: {
          include: {
            course: { select: { id: true, title: true, totalDays: true } },
          },
          orderBy: { enrolledAt: "desc" },
        },
      },
    }),
    prisma.course.findMany({
      select: { id: true, title: true },
      orderBy: { title: "asc" },
    }),
    prisma.dailyProgress.findMany({
      where: { userId },
      include: {
        courseDay: {
          select: {
            dayNumber: true,
            course: { select: { title: true } },
          },
        },
      },
      orderBy: { dayDate: "desc" },
      take: 50,
    }),
  ]);

  if (!profile) return notFound();

  const stats = profile.userStats;
  const streak = stats?.currentStreak ?? 0;
  const longestStreak = stats?.longestStreak ?? 0;
  const totalSteps = stats?.totalSteps ?? 0;
  const totalMinutes = Math.round((stats?.totalWatchSeconds ?? 0) / 60);
  const totalCalories = Math.round(Number(stats?.totalCalories ?? 0));
  const enrolledCourseIds = profile.enrollments.map((e) => e.courseId);

  return (
    <div className="space-y-6">
      {/* Breadcrumb */}
      <div>
        <Link
          href="/dashboard/users"
          className="inline-flex items-center gap-1 text-sm text-gray-400 hover:text-gray-600 mb-3 transition-colors"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          Back to Users
        </Link>
        <div className="flex items-start justify-between flex-wrap gap-3">
          <div>
            <h2 className="text-2xl font-extrabold text-gray-900">
              {profile.fullName || "Unnamed User"}
            </h2>
            <p className="text-sm text-gray-500 mt-0.5">{profile.email}</p>
          </div>
          <div className="text-xs text-gray-400 bg-gray-50 px-3 py-1.5 rounded-lg font-mono break-all">
            {profile.id}
          </div>
        </div>
      </div>

      {/* Profile + Stats — 2 column */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Profile card */}
        <div className="bg-white shadow rounded-lg border border-gray-100 p-6">
          <h3 className="font-bold text-gray-900 text-sm mb-4 pb-2 border-b border-gray-100">
            Profile
          </h3>
          <div className="flex items-start gap-4">
            <div className="h-16 w-16 rounded-full bg-slate-900 text-white flex items-center justify-center font-extrabold text-2xl flex-shrink-0">
              {profile.fullName ? profile.fullName[0].toUpperCase() : "U"}
            </div>
            <dl className="space-y-3 flex-1 min-w-0">
              <div>
                <dt className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Full Name</dt>
                <dd className="text-sm font-semibold text-gray-800">{profile.fullName || "—"}</dd>
              </div>
              <div>
                <dt className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Email</dt>
                <dd className="text-sm font-semibold text-gray-800 break-all">{profile.email}</dd>
              </div>
              <div>
                <dt className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Phone</dt>
                <dd className="text-sm font-semibold text-gray-800">{profile.phone || "—"}</dd>
              </div>
              <div>
                <dt className="text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">Currency</dt>
                <CurrencyToggle userId={profile.id} current={profile.currency ?? 'INR'} />
                <p className="text-[10px] text-gray-400 mt-1">Controls price display — USD for non-Indian users</p>
              </div>
              <div>
                <dt className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Notifications</dt>
                <dd className="text-sm font-semibold text-gray-800">
                  {profile.notificationsEnabled
                    ? `Enabled${profile.notificationTime ? ` · ${profile.notificationTime}` : ""}`
                    : "Disabled"}
                </dd>
              </div>
              <div>
                <dt className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Joined</dt>
                <dd className="text-sm font-semibold text-gray-800">
                  {new Date(profile.createdAt).toLocaleDateString("en-IN", {
                    day: "2-digit",
                    month: "long",
                    year: "numeric",
                  })}
                </dd>
              </div>
            </dl>
          </div>
        </div>

        {/* Stats grid */}
        <div className="bg-white shadow rounded-lg border border-gray-100 p-6">
          <h3 className="font-bold text-gray-900 text-sm mb-4 pb-2 border-b border-gray-100">
            Practice Stats
          </h3>
          <div className="grid grid-cols-3 gap-3">
            <div className="bg-amber-50 border border-amber-100 rounded-xl p-3 text-center">
              <div className="text-2xl font-extrabold text-amber-600">{streak}</div>
              <div className="text-[10px] text-amber-500 font-bold mt-0.5 leading-tight">Current<br />Streak</div>
            </div>
            <div className="bg-orange-50 border border-orange-100 rounded-xl p-3 text-center">
              <div className="text-2xl font-extrabold text-orange-600">{longestStreak}</div>
              <div className="text-[10px] text-orange-500 font-bold mt-0.5 leading-tight">Longest<br />Streak</div>
            </div>
            <div className="bg-emerald-50 border border-emerald-100 rounded-xl p-3 text-center">
              <div className="text-2xl font-extrabold text-emerald-600">{profile.enrollments.length}</div>
              <div className="text-[10px] text-emerald-500 font-bold mt-0.5 leading-tight">Programs<br />Enrolled</div>
            </div>
            <div className="bg-blue-50 border border-blue-100 rounded-xl p-3 text-center">
              <div className="text-xl font-extrabold text-blue-600">{totalSteps.toLocaleString()}</div>
              <div className="text-[10px] text-blue-500 font-bold mt-0.5">Total Steps</div>
            </div>
            <div className="bg-purple-50 border border-purple-100 rounded-xl p-3 text-center">
              <div className="text-xl font-extrabold text-purple-600">{totalMinutes}</div>
              <div className="text-[10px] text-purple-500 font-bold mt-0.5 leading-tight">Watch<br />Minutes</div>
            </div>
            <div className="bg-red-50 border border-red-100 rounded-xl p-3 text-center">
              <div className="text-xl font-extrabold text-red-600">{totalCalories}</div>
              <div className="text-[10px] text-red-500 font-bold mt-0.5 leading-tight">Calories<br />Burnt</div>
            </div>
          </div>
        </div>
      </div>

      {/* Actions row — 2 column */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white shadow rounded-lg border border-gray-100 p-6">
          <h3 className="font-bold text-gray-900 text-sm mb-1">Assign Program</h3>
          <p className="text-xs text-gray-400 mb-4">
            Manually enroll with completed payment status.
          </p>
          <AssignCourseButton
            userId={profile.id}
            availableCourses={allCourses}
            enrolledCourseIds={enrolledCourseIds}
          />
        </div>

        <div className="bg-white shadow rounded-lg border border-gray-100 p-6">
          <h3 className="font-bold text-gray-900 text-sm mb-1">Testing Tools</h3>
          <p className="text-xs text-gray-400 mb-4">
            Admin-only QA tools. Use with caution.
          </p>
          <TestingTools
            userId={profile.id}
            enrollments={profile.enrollments.map((e) => ({
              id: e.id,
              course: { id: e.course.id, title: e.course.title, totalDays: e.course.totalDays },
            }))}
          />
        </div>
      </div>

      {/* Enrolled Programs — full width */}
      <div className="bg-white shadow rounded-lg border border-gray-100 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-100 flex items-baseline justify-between">
          <h3 className="font-bold text-gray-900">Enrolled Programs</h3>
          <span className="text-xs text-gray-400">
            {profile.enrollments.length} program{profile.enrollments.length !== 1 ? "s" : ""}
          </span>
        </div>
        {profile.enrollments.length === 0 ? (
          <div className="p-12 text-center text-gray-400 text-sm">No programs enrolled yet.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-100">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Program</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Total Days</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Enrolled On</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Payment</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 bg-white">
                {profile.enrollments.map((enr) => (
                  <tr key={enr.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4 font-semibold text-gray-900 text-sm">
                      {enr.course.title}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-500">
                      {enr.course.totalDays} days
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-500 whitespace-nowrap">
                      {new Date(enr.enrolledAt).toLocaleDateString("en-IN", {
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                      })}
                    </td>
                    <td className="px-6 py-4">
                      <span
                        className={`inline-block text-xs font-bold px-2.5 py-1 rounded-full ${
                          enr.paymentStatus === "completed"
                            ? "bg-emerald-50 text-emerald-700 border border-emerald-100"
                            : "bg-yellow-50 text-yellow-700 border border-yellow-100"
                        }`}
                      >
                        {enr.paymentStatus || "pending"}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span
                        className={`inline-block text-xs font-bold px-2.5 py-1 rounded-full ${
                          enr.isActive
                            ? "bg-green-50 text-green-700 border border-green-100"
                            : "bg-gray-100 text-gray-500 border border-gray-200"
                        }`}
                      >
                        {enr.isActive ? "Active" : "Inactive"}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Daily Progress Log — full width */}
      <div className="bg-white shadow rounded-lg border border-gray-100 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-100 flex items-baseline justify-between">
          <h3 className="font-bold text-gray-900">Daily Progress Log</h3>
          <span className="text-xs text-gray-400">
            {dailyProgresses.length > 0
              ? `Last ${dailyProgresses.length} entries`
              : "No entries"}
          </span>
        </div>
        {dailyProgresses.length === 0 ? (
          <div className="p-12 text-center text-gray-400 text-sm">
            No progress recorded yet.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-100">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Date</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Program</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Day #</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Steps</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Calories</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Watch Time</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Videos</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 bg-white">
                {dailyProgresses.map((dp) => (
                  <tr key={dp.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-3 text-sm text-gray-700 whitespace-nowrap">
                      {new Date(dp.dayDate).toLocaleDateString("en-IN", {
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                      })}
                    </td>
                    <td className="px-6 py-3 text-sm font-semibold text-gray-900 whitespace-nowrap">
                      {dp.courseDay.course.title}
                    </td>
                    <td className="px-6 py-3 text-sm text-gray-600 whitespace-nowrap">
                      Day {dp.courseDay.dayNumber}
                    </td>
                    <td className="px-6 py-3 text-sm text-gray-700 whitespace-nowrap">
                      {dp.stepsCount.toLocaleString()}
                    </td>
                    <td className="px-6 py-3 text-sm text-gray-700 whitespace-nowrap">
                      {Math.round(Number(dp.caloriesBurnt))} kcal
                    </td>
                    <td className="px-6 py-3 text-sm text-gray-700 whitespace-nowrap">
                      {Math.round(dp.totalWatchSeconds / 60)} min
                    </td>
                    <td className="px-6 py-3 text-sm text-gray-700 whitespace-nowrap">
                      {dp.videosWatched}
                    </td>
                    <td className="px-6 py-3 whitespace-nowrap">
                      {dp.isComplete ? (
                        <span className="inline-block text-xs font-bold px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-100">
                          Complete
                        </span>
                      ) : (
                        <span className="inline-block text-xs font-bold px-2.5 py-1 rounded-full bg-yellow-50 text-yellow-700 border border-yellow-100">
                          In Progress
                        </span>
                      )}
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
