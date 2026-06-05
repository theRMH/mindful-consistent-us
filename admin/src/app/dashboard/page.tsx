import prisma from '@/lib/prisma';

export const revalidate = 0; // Disable static compilation caching to always fetch live values

export default async function DashboardOverview() {
  // Fetch real database aggregates in parallel
  const [
    totalUsers,
    totalEnrollments,
    completedSessions,
    stepsAgg,
    recentFeedback
  ] = await Promise.all([
    prisma.profile.count(),
    prisma.enrollment.count({ where: { isActive: true } }),
    prisma.dailyProgress.count({ where: { isComplete: true } }),
    prisma.dailyProgress.aggregate({
      _sum: {
        stepsCount: true,
        totalWatchSeconds: true,
      }
    }),
    prisma.feedback.findMany({
      take: 5,
      orderBy: { createdAt: 'desc' },
      include: { user: true }
    })
  ]);

  const totalSteps = stepsAgg._sum.stepsCount ?? 0;
  const totalCalories = totalSteps * 0.04;
  const totalWatchMins = Math.round((stepsAgg._sum.totalWatchSeconds ?? 0) / 60);

  const stats = [
    {
      name: 'Registered Users',
      value: totalUsers,
      color: 'bg-blue-500',
      icon: (
        <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
      )
    },
    {
      name: 'Active Subscriptions',
      value: totalEnrollments,
      color: 'bg-emerald-500',
      icon: (
        <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      )
    },
    {
      name: 'Accumulated Steps',
      value: totalSteps.toLocaleString(),
      color: 'bg-amber-500',
      icon: (
        <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 5H19V11H13V5Z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11h-6v6h6v-6z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v1m0 11v1m0-6V7M4 12h16" />
        </svg>
      )
    },
    {
      name: 'Sessions Completed',
      value: completedSessions,
      color: 'bg-purple-500',
      icon: (
        <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      )
    }
  ];

  return (
    <div className="space-y-8">
      <div>
        <h2 className="text-2xl font-extrabold text-gray-900">Dashboard Overview</h2>
        <p className="text-sm text-gray-500 mt-1">Real-time statistics synced with active user mobile sessions.</p>
      </div>

      {/* Stats Cards Row */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <div key={stat.name} className="bg-white overflow-hidden shadow rounded-lg border border-gray-100 p-5 flex items-center space-x-4">
            <div className={`p-3 rounded-lg ${stat.color}`}>
              {stat.icon}
            </div>
            <div>
              <p className="text-sm font-semibold text-gray-500 truncate">{stat.name}</p>
              <p className="mt-1 text-2xl font-bold text-gray-900">{stat.value}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 gap-5 lg:grid-cols-2">
        {/* Derived Wellness Metrics */}
        <div className="bg-white shadow rounded-lg border border-gray-100 p-6">
          <h3 className="text-lg font-bold text-gray-900 mb-4">Wellness Achievements</h3>
          <div className="space-y-4">
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
              <span className="text-sm font-semibold text-gray-600">Total Practice Time</span>
              <span className="font-bold text-gray-900">{totalWatchMins} minutes</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
              <span className="text-sm font-semibold text-gray-600">Estimated Calories Burned</span>
              <span className="font-bold text-gray-900">{totalCalories.toFixed(1)} kcal</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
              <span className="text-sm font-semibold text-gray-600">Average User Steps</span>
              <span className="font-bold text-gray-900">
                {totalUsers > 0 ? Math.round(totalSteps / totalUsers).toLocaleString() : 0} steps/user
              </span>
            </div>
          </div>
        </div>

        {/* Recent User Feedbacks */}
        <div className="bg-white shadow rounded-lg border border-gray-100 p-6">
          <h3 className="text-lg font-bold text-gray-900 mb-4">Recent Feedback</h3>
          {recentFeedback.length === 0 ? (
            <div className="h-32 flex items-center justify-center text-sm text-gray-400 font-medium">
              No feedback submitted yet.
            </div>
          ) : (
            <div className="space-y-4">
              {recentFeedback.map((feedback) => (
                <div key={feedback.id} className="border-b border-gray-50 pb-3 last:border-0 last:pb-0">
                  <div className="flex justify-between">
                    <span className="text-sm font-bold text-gray-800">
                      {feedback.user?.fullName || feedback.user?.phone || 'Anonymous'}
                    </span>
                    <div className="flex items-center space-x-1">
                      <span className="text-xs font-bold text-amber-500">★ {feedback.rating}</span>
                    </div>
                  </div>
                  <p className="text-sm text-gray-500 mt-1 italic">"{feedback.comment || 'No comment provided.'}"</p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
