import prisma from "@/lib/prisma";
import Link from "next/link";
import ResetProgressButton from "./ResetProgressButton";
import CreateUserButton from "./CreateUserButton";
import AssignCourseButton from "./AssignCourseButton";

export const dynamic = "force-dynamic";

function currentDemoDay(enrolledAt: Date) {
  const start = new Date(
    enrolledAt.getFullYear(),
    enrolledAt.getMonth(),
    enrolledAt.getDate(),
  );
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  return Math.floor((today.getTime() - start.getTime()) / 86400000) + 1;
}

export default async function UsersDirectoryPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; userId?: string }>;
}) {
  const params = await searchParams;
  const query = params.q || "";
  const selectedUserId = params.userId || "";

  const allCourses = await prisma.course.findMany({
    where: { isPublished: true },
    select: { id: true, title: true },
    orderBy: { createdAt: 'asc' },
  });

  // Fetch profiles matching search query (phone or email or name)
  const profiles = await prisma.profile.findMany({
    where: query
      ? {
          OR: [
            { email: { contains: query, mode: "insensitive" } },
            { phone: { contains: query, mode: "insensitive" } },
            { fullName: { contains: query, mode: "insensitive" } },
          ],
        }
      : {},
    include: {
      userStats: true,
      enrollments: {
        include: {
          course: true,
        },
      },
    },
    orderBy: { createdAt: "desc" },
  });

  let selectedUser = null;

  if (selectedUserId) {
    selectedUser = await prisma.profile.findUnique({
      where: { id: selectedUserId },
      include: {
        userStats: true,
        enrollments: {
          include: {
            course: true,
          },
        },
      },
    });
  }

  const dailyProgresses = selectedUser ? await prisma.dailyProgress.findMany({
    where: { userId: selectedUserId },
    include: {
      courseDay: {
        include: {
          course: true,
        },
      },
    },
    orderBy: { dayDate: "desc" },
    take: 30,
  }) : [];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <h2 className="text-2xl font-extrabold text-gray-900 font-sans">
            Users Directory
          </h2>
          <p className="text-sm text-gray-500 mt-1">
            Search registered users, track progress stats, and review wellness
            logs.
          </p>
        </div>
        <div className="flex items-center gap-3 flex-shrink-0">
          <a
            href="/api/admin/users/export"
            className="px-4 py-2 border border-gray-200 text-gray-600 hover:bg-gray-50 text-sm font-bold rounded-lg transition-colors"
          >
            Export CSV
          </a>
          <CreateUserButton />
        </div>
      </div>

      {/* Search Bar */}
      <div className="bg-white shadow rounded-lg border border-gray-100 p-4">
        <form method="GET" action="/dashboard/users" className="flex gap-3">
          <div className="relative flex-1">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400">
              <svg
                className="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                />
              </svg>
            </span>
            <input
              type="text"
              name="q"
              defaultValue={query}
              placeholder="Search by full name, phone number, or email..."
              className="pl-10 block w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500 bg-gray-50/50"
            />
          </div>
          <button
            type="submit"
            className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm rounded-lg transition-colors shadow-sm"
          >
            Search
          </button>
          {query && (
            <Link
              href="/dashboard/users"
              className="px-4 py-2.5 border border-gray-300 rounded-lg text-sm font-bold text-gray-700 hover:bg-gray-50 transition-colors flex items-center"
            >
              Clear
            </Link>
          )}
        </form>
      </div>

      {/* Two-Column Layout */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3 items-start">
        {/* Left Column: Users List */}
        <div
          className={`bg-white shadow rounded-lg border border-gray-100 overflow-hidden lg:col-span-2`}
        >
          {profiles.length === 0 ? (
            <div className="p-20 text-center flex flex-col items-center">
              <svg
                className="w-16 h-16 text-gray-300 mb-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                />
              </svg>
              <p className="text-gray-500 font-bold">No matching users found</p>
              <p className="text-sm text-gray-400 mt-1">
                Try refining your search terms or view the entire list.
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-100">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">
                      User Details
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">
                      Phone / Email
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">
                      Streak
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">
                      Registered
                    </th>
                    <th className="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase tracking-wider">
                      Details
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-100">
                  {profiles.map((profile) => {
                    const isSelected = profile.id === selectedUserId;
                    const streak = profile.userStats?.currentStreak ?? 0;
                    return (
                      <tr
                        key={profile.id}
                        className={`hover:bg-gray-50/50 transition-colors ${
                          isSelected
                            ? "bg-emerald-50/20 hover:bg-emerald-50/30"
                            : ""
                        }`}
                      >
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center space-x-3">
                            <div className="h-8 w-8 rounded-full bg-slate-900 text-white flex items-center justify-center font-bold text-xs">
                              {profile.fullName
                                ? profile.fullName[0].toUpperCase()
                                : "U"}
                            </div>
                            <div>
                              <div className="font-bold text-gray-900">
                                {profile.fullName || "No name provided"}
                              </div>
                              <div className="text-xs text-gray-400">
                                ID: {profile.id.substring(0, 8)}...
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="text-sm text-gray-700 font-semibold">
                            {profile.phone || "No phone"}
                          </div>
                          <div className="text-xs text-gray-400">
                            {profile.email}
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center space-x-1">
                            <span className="text-sm font-bold text-gray-900">
                              {streak}
                            </span>
                            {streak > 0 && (
                              <span className="text-amber-500 text-sm">🔥</span>
                            )}
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-xs text-gray-500">
                          {new Date(profile.createdAt).toLocaleDateString()}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm">
                          <Link
                            href={`/dashboard/users?userId=${profile.id}${query ? `&q=${query}` : ""}`}
                            className="text-emerald-600 hover:text-emerald-700 hover:underline font-bold"
                          >
                            View Stats
                          </Link>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Right Column: Detailed panel */}
        <div className="space-y-6">
          {selectedUser ? (
            <>
              {/* User Profile Card */}
              <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
                <div className="flex items-center space-x-4">
                  <div className="h-12 w-12 rounded-full bg-slate-900 text-white flex items-center justify-center font-black text-lg">
                    {selectedUser.fullName
                      ? selectedUser.fullName[0].toUpperCase()
                      : "U"}
                  </div>
                  <div>
                    <h3 className="font-extrabold text-gray-900 text-lg leading-tight">
                      {selectedUser.fullName || "No name"}
                    </h3>
                    <p className="text-xs text-gray-500 mt-0.5">
                      Joined{" "}
                      {new Date(selectedUser.createdAt).toLocaleDateString()}
                    </p>
                  </div>
                </div>

                <div className="border-t border-gray-50 pt-4 space-y-2.5 text-sm">
                  <div className="flex justify-between">
                    <span className="text-gray-400 font-medium">Email:</span>
                    <span className="text-gray-800 font-bold">
                      {selectedUser.email}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-400 font-medium">Phone:</span>
                    <span className="text-gray-800 font-bold">
                      {selectedUser.phone || "N/A"}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-400 font-medium">
                      Current Streak:
                    </span>
                    <span className="text-amber-500 font-bold flex items-center">
                      {selectedUser.userStats?.currentStreak ?? 0} days 🔥
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-400 font-medium">
                      Longest Streak:
                    </span>
                    <span className="text-gray-800 font-bold">
                      {selectedUser.userStats?.longestStreak ?? 0} days
                    </span>
                  </div>
                </div>
              </div>

              {/* User Aggregates */}
              <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
                <h4 className="font-extrabold text-gray-800 border-b border-gray-50 pb-2">
                  Practice Aggregates
                </h4>
                <div className="grid grid-cols-3 gap-4 text-center">
                  <div className="bg-blue-50/50 border border-blue-50 p-3 rounded-lg">
                    <div className="text-xs font-bold text-blue-500 uppercase">
                      Minutes
                    </div>
                    <div className="text-lg font-black text-blue-900 mt-1">
                      {Math.round(
                        (selectedUser.userStats?.totalWatchSeconds ?? 0) / 60,
                      )}
                    </div>
                  </div>
                  <div className="bg-amber-50/50 border border-amber-50 p-3 rounded-lg">
                    <div className="text-xs font-bold text-amber-500 uppercase">
                      Steps
                    </div>
                    <div className="text-lg font-black text-amber-900 mt-1">
                      {(
                        selectedUser.userStats?.totalSteps ?? 0
                      ).toLocaleString()}
                    </div>
                  </div>
                  <div className="bg-emerald-50/50 border border-emerald-50 p-3 rounded-lg">
                    <div className="text-xs font-bold text-emerald-500 uppercase">
                      Calories
                    </div>
                    <div className="text-lg font-black text-emerald-900 mt-1">
                      {Number(
                        selectedUser.userStats?.totalCalories ?? 0,
                      ).toFixed(0)}
                    </div>
                  </div>
                </div>
              </div>

              {/* Assign Program */}
              <div className="bg-white shadow rounded-lg border border-gray-100 p-4 space-y-3">
                <h4 className="font-extrabold text-gray-800 text-sm">
                  Assign Program
                </h4>
                <AssignCourseButton
                  userId={selectedUser.id}
                  availableCourses={allCourses}
                  enrolledCourseIds={selectedUser.enrollments.map((e) => e.courseId)}
                />
              </div>

              {/* Reset Progress */}
              <div className="bg-white shadow rounded-lg border border-gray-100 p-4">
                <h4 className="font-extrabold text-gray-800 text-sm mb-3">
                  Testing Tools
                </h4>
                <ResetProgressButton
                  userId={selectedUser.id}
                  userName={selectedUser.fullName || selectedUser.email}
                  enrollments={selectedUser.enrollments}
                />
              </div>

              {/* Course Enrollments */}
              <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
                <h4 className="font-extrabold text-gray-800 border-b border-gray-50 pb-2">
                  Enrolled Programs
                </h4>
                {selectedUser.enrollments.length === 0 ? (
                  <p className="text-sm text-gray-400 italic">
                    No active enrollments.
                  </p>
                ) : (
                  <div className="space-y-3">
                    {selectedUser.enrollments.map((enr) => (
                      <div
                        key={enr.id}
                        className="p-3 bg-gray-50 rounded-lg border border-gray-100 text-sm"
                      >
                        <div className="font-bold text-gray-800">
                          {enr.course.title}
                        </div>
                        <div className="flex justify-between text-xs text-gray-500 mt-1.5 font-medium">
                          <span>
                            Bought:{" "}
                            {new Date(enr.purchaseDate).toLocaleDateString()}
                          </span>
                          <span className="capitalize text-emerald-600 font-bold">
                            {enr.paymentStatus}
                          </span>
                        </div>
                        <div className="flex justify-between text-xs text-gray-500 mt-1.5 font-medium">
                          <span>
                            Enrolled:{" "}
                            {new Date(enr.enrolledAt).toLocaleDateString()}
                          </span>
                          <span className="text-slate-700 font-bold">
                            Demo Day {currentDemoDay(enr.enrolledAt)}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Daily Progress logs */}
              <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
                <h4 className="font-extrabold text-gray-800 border-b border-gray-50 pb-2">
                  Daily Progress Log
                </h4>
                {dailyProgresses.length === 0 ? (
                  <p className="text-sm text-gray-400 italic">
                    No workout logs registered yet.
                  </p>
                ) : (
                  <div className="space-y-3 max-h-96 overflow-y-auto pr-1">
                    {dailyProgresses.map((log) => (
                      <div
                        key={log.id}
                        className="p-3 bg-gray-50 rounded-lg border border-gray-100 text-xs space-y-1"
                      >
                        <div className="flex justify-between items-center font-bold">
                          <span className="text-gray-800">
                            {new Date(log.dayDate).toLocaleDateString()}
                          </span>
                          {log.isComplete ? (
                            <span className="bg-emerald-100 text-emerald-800 font-black px-1.5 py-0.5 rounded text-[10px] uppercase">
                              Done
                            </span>
                          ) : (
                            <span className="bg-slate-200 text-slate-700 font-black px-1.5 py-0.5 rounded text-[10px] uppercase">
                              Active
                            </span>
                          )}
                        </div>
                        <p className="text-gray-500 font-semibold">
                          {log.courseDay.course.title} — Day{" "}
                          {log.courseDay.dayNumber}
                        </p>
                        <div className="grid grid-cols-3 text-gray-400 font-semibold pt-1 border-t border-gray-100/50 mt-1 text-[10px]">
                          <span>
                            👣 {log.stepsCount.toLocaleString()} steps
                          </span>
                          <span>
                            🔥 {Number(log.caloriesBurnt).toFixed(1)} kcal
                          </span>
                          <span>
                            ⏱️ {Math.round(log.totalWatchSeconds / 60)}m watch
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </>
          ) : (
            <div className="bg-gray-50 border border-dashed border-gray-200 rounded-lg p-8 text-center text-sm text-gray-400 font-semibold">
              Select a user from the directory to display progress graphs,
              streak summaries, and practice logs.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
