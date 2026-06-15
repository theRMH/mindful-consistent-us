import prisma from "@/lib/prisma";
import Link from "next/link";
import CreateUserButton from "./CreateUserButton";

export const dynamic = "force-dynamic";

export default async function UsersDirectoryPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const params = await searchParams;
  const query = params.q || "";

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
      enrollments: { include: { course: { select: { title: true } } } },
    },
    orderBy: { createdAt: "desc" },
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <h2 className="text-2xl font-extrabold text-gray-900">Users Directory</h2>
          <p className="text-sm text-gray-500 mt-1">
            {profiles.length} user{profiles.length !== 1 ? "s" : ""}{query ? ` matching "${query}"` : " registered"}
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

      {/* Search */}
      <div className="bg-white shadow rounded-lg border border-gray-100 p-4">
        <form method="GET" action="/dashboard/users" className="flex gap-3">
          <div className="relative flex-1">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </span>
            <input
              type="text"
              name="q"
              defaultValue={query}
              placeholder="Search by name, phone, or email..."
              className="pl-10 block w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500 bg-gray-50/50"
            />
          </div>
          <button type="submit" className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm rounded-lg transition-colors">
            Search
          </button>
          {query && (
            <Link href="/dashboard/users" className="px-4 py-2.5 border border-gray-300 rounded-lg text-sm font-bold text-gray-700 hover:bg-gray-50 transition-colors flex items-center">
              Clear
            </Link>
          )}
        </form>
      </div>

      {/* Users Table */}
      <div className="bg-white shadow rounded-lg border border-gray-100 overflow-hidden">
        {profiles.length === 0 ? (
          <div className="p-20 text-center flex flex-col items-center">
            <svg className="w-16 h-16 text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
            <p className="text-gray-500 font-bold">No users found</p>
            <p className="text-sm text-gray-400 mt-1">Try refining your search or create a new user.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-100">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">User</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Contact</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Streak</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Steps</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Programs</th>
                  <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Joined</th>
                  <th className="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-100">
                {profiles.map((profile) => {
                  const streak = profile.userStats?.currentStreak ?? 0;
                  const steps = profile.userStats?.totalSteps ?? 0;
                  return (
                    <tr key={profile.id} className="hover:bg-gray-50/50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center space-x-3">
                          <div className="h-9 w-9 rounded-full bg-slate-900 text-white flex items-center justify-center font-bold text-sm flex-shrink-0">
                            {profile.fullName ? profile.fullName[0].toUpperCase() : "U"}
                          </div>
                          <div>
                            <div className="font-bold text-gray-900">{profile.fullName || "No name"}</div>
                            <div className="text-xs text-gray-400">ID: {profile.id.substring(0, 8)}…</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-semibold text-gray-700">{profile.email}</div>
                        <div className="text-xs text-gray-400">{profile.phone || "No phone"}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="text-sm font-bold text-gray-900">{streak}</span>
                        {streak > 0 && <span className="ml-1 text-amber-500">🔥</span>}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700 font-semibold">
                        {steps.toLocaleString()}
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex flex-wrap gap-1">
                          {profile.enrollments.length === 0 ? (
                            <span className="text-xs text-gray-400 italic">None</span>
                          ) : (
                            profile.enrollments.map((e) => (
                              <span key={e.id} className="text-[10px] bg-emerald-50 text-emerald-700 border border-emerald-100 px-2 py-0.5 rounded-full font-bold">
                                {e.course.title}
                              </span>
                            ))
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-xs text-gray-500">
                        {new Date(profile.createdAt).toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" })}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right">
                        <Link
                          href={`/dashboard/users/${profile.id}`}
                          className="px-3 py-1.5 text-xs font-bold rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white transition-colors"
                        >
                          View Details
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
    </div>
  );
}
