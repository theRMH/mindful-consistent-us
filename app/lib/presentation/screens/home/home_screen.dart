import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/developer_simulator_sheet.dart';
import '../../../core/config/theme.dart';

// Riverpod provider to track active category selection
final selectedCategoryProvider = StateProvider<String>((ref) => 'Yoga');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final progressState = ref.watch(progressProvider);
    final userProfile = authState.user;
    final activeCategory = ref.watch(selectedCategoryProvider);

    final userName = userProfile?.fullName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: const Icon(Icons.spa, color: AppTheme.primaryGreen),
        actions: [
          // Developer Simulator Board button
          IconButton(
            icon: const Icon(Icons.tune, color: AppTheme.primaryGreen),
            tooltip: 'Developer Simulator',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const DeveloperSimulatorSheet(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.coolGray),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/unregistered');
            },
            tooltip: 'Log out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vanakkam',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.coolGray,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 26,
                                color: AppTheme.darkTeal,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        '/program_details',
                        extra: {
                          'title': '30 Days Yoga Course',
                          'imagePath': 'assets/course_30_days.png',
                        },
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 14),
                    label: const Text('Active Program'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Streak Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.darkTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_fire_department, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${progressState.currentStreak} Day Streak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Daily discipline. Lasting transformation.',
                            style: TextStyle(
                              color: AppTheme.lightSage,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Active Course Progress details
              Text(
                '30-Day Yoga Journey',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Show up for yourself, Every single day.',
                style: TextStyle(color: AppTheme.coolGray, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Horizontal Calendar timeline Strip
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightGray),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final dayNum = index + 1;
                    final isCompleted = progressState.completedDays.contains(dayNum);
                    final isCurrentDay = dayNum == 4; // Day 4 is current unlocked day

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'D$dayNum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCurrentDay ? AppTheme.primaryGreen : AppTheme.coolGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompleted 
                                ? AppTheme.primaryGreen 
                                : (isCurrentDay ? Colors.white : AppTheme.lightGray),
                            shape: BoxShape.circle,
                            border: isCurrentDay 
                                ? Border.all(color: AppTheme.primaryGreen, width: 2) 
                                : null,
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : (isCurrentDay 
                                  ? Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Today's Goal Ring and details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkSlate.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Circular Progress Canvas
                    CustomPaint(
                      size: const Size(90, 90),
                      painter: GoalRingPainter(
                        percentage: progressState.totalSessionsToday > 0 
                            ? progressState.completedSessionsToday / progressState.totalSessionsToday 
                            : 0,
                        ringColor: AppTheme.primaryGreen,
                        backgroundColor: AppTheme.lightGray,
                      ),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: Center(
                          child: Text(
                            progressState.totalSessionsToday > 0
                                ? '${((progressState.completedSessionsToday / progressState.totalSessionsToday) * 100).toInt()}%'
                                : '0%',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                  color: AppTheme.primaryGreen,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today’s Progress",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${progressState.completedSessionsToday} of ${progressState.totalSessionsToday} sessions completed",
                            style: const TextStyle(
                              color: AppTheme.coolGray,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Simulated Debug Trigger
                          GestureNotifierTrigger(
                            onTap: () {
                              ref.read(progressProvider.notifier).completeSession();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Mindful Mins',
                      value: '${progressState.mindfulMins} min',
                      icon: Icons.timer_outlined,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Daily Steps',
                      value: '${progressState.steps}',
                      icon: Icons.directions_walk,
                      color: AppTheme.accentGold,
                      onTap: () {
                        ref.read(progressProvider.notifier).addSteps(500);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                context,
                title: 'Calories Burnt',
                value: '${progressState.calories.toStringAsFixed(1)} kcal',
                icon: Icons.local_fire_department,
                color: Colors.orangeAccent,
                fullWidth: true,
              ),
              const SizedBox(height: 28),

              // 7. Yoga / General Exercise Section
              Text(
                'Yoga / General Exercise',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 12),
              
              // Selector Tabs
              Row(
                children: [
                  _buildCategoryTab(ref, 'Yoga', activeCategory == 'Yoga'),
                  const SizedBox(width: 12),
                  _buildCategoryTab(ref, 'General Exercise', activeCategory == 'General Exercise'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Video / Workout list under selector
              _buildWorkoutList(context, activeCategory),

              const SizedBox(height: 28),

              // 8. Community Leaderboard Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Community Leaderboard',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                  ),
                  const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 24),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Real people. Real progress. Real inspiration.',
                style: TextStyle(color: AppTheme.coolGray, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Leaderboard Rankings
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.lightGray),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: progressState.leaderboard.map((user) {
                    return _buildLeaderboardTile(context, user);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Home Screen V2 Widget Builders ---

  Widget _buildCategoryTab(WidgetRef ref, String category, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedCategoryProvider.notifier).state = category;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppTheme.primaryGreen : AppTheme.lightGray,
            ),
          ),
          child: Center(
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive ? Colors.white : AppTheme.coolGray,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context, String category) {
    final List<Map<String, dynamic>> yogaWorkouts = [
      {
        'title': 'Morning Alignment',
        'duration': '15 mins',
        'level': 'Beginner',
        'youtubeVideoId': 's7WpC1sL0h8',
        'image': 'assets/video_morning_flow.png',
      },
      {
        'title': 'Core Stability Flow',
        'duration': '20 mins',
        'level': 'Intermediate',
        'youtubeVideoId': 'Eml2x1YrVlI',
        'image': 'assets/video_neck_relief.png',
      }
    ];

    final List<Map<String, dynamic>> generalWorkouts = [
      {
        'title': 'Mobility Stretching',
        'duration': '10 mins',
        'level': 'Beginner',
        'youtubeVideoId': 'L_xrDAtykMI',
        'image': 'assets/video_sleep_prep.png',
      },
      {
        'title': 'Daily Warm-up Routine',
        'duration': '12 mins',
        'level': 'Beginner',
        'youtubeVideoId': '2Sf1H_1Lkr8',
        'image': 'assets/video_morning_flow.png',
      }
    ];

    final workouts = category == 'Yoga' ? yogaWorkouts : generalWorkouts;

    return Column(
      children: workouts.map((w) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.lightGray),
          ),
          child: ListTile(
            onTap: () {
              context.push('/play', extra: {
                'courseId': '30-days-yoga',
                'dayNumber': 4,
                'youtubeVideoId': w['youtubeVideoId'],
                'videoTitle': w['title'],
              });
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                w['image'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: AppTheme.lightGray,
                  child: const Icon(Icons.play_circle_fill, color: AppTheme.primaryGreen),
                ),
              ),
            ),
            title: Text(
              w['title'],
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkSlate),
            ),
            subtitle: Text('${w['duration']} • ${w['level']}'),
            trailing: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.lightGray,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primaryGreen, size: 20),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, LeaderboardUser user) {
    Color bg = Colors.white;
    if (user.isCurrentUser) {
      bg = AppTheme.primaryGreen.withOpacity(0.04);
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: AppTheme.lightGray.withOpacity(0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: user.rank == 1 
                  ? AppTheme.accentGold 
                  : (user.rank == 2 ? AppTheme.lightGray : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${user.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: user.rank == 1 ? Colors.white : AppTheme.darkSlate,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // User Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryGreen,
            backgroundImage: user.avatarUrl.isNotEmpty ? AssetImage(user.avatarUrl) : null,
            child: user.avatarUrl.isEmpty
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // User Name
          Expanded(
            child: Text(
              user.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: user.isCurrentUser ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
                color: AppTheme.darkSlate,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Streak Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 12),
                const SizedBox(width: 2),
                Text(
                  '${user.streak}d',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // User Score Points
          Text(
            '${user.score} pts',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // --- Metric Card Builder with Overflow Fixes ---
  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
    VoidCallback? onTap,
  }) {
    final cardContent = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkSlate.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.coolGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen, size: 20),
          ]
        ],
      ),
    );

    return onTap != null 
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: cardContent,
          )
        : cardContent;
  }
}

// Custom Painter for Premium Goal Ring
class GoalRingPainter extends CustomPainter {
  final double percentage;
  final Color ringColor;
  final Color backgroundColor;

  GoalRingPainter({
    required this.percentage,
    required this.ringColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;

    // Draw background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = ringColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double sweepAngle = 2 * pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GoalRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}

// Small helper widget to trigger simulated step integrations
class GestureNotifierTrigger extends StatelessWidget {
  final VoidCallback onTap;
  const GestureNotifierTrigger({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow_outlined, color: AppTheme.primaryGreen, size: 16),
          SizedBox(width: 4),
          Text(
            'Complete Session (Simulate)',
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
