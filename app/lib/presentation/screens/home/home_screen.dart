import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../../core/config/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final progressState = ref.watch(progressProvider);
    final userProfile = authState.user;

    final userName = userProfile?.fullName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: const Icon(Icons.spa, color: AppTheme.primaryGreen),
        actions: [
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 28,
                              color: AppTheme.darkTeal,
                            ),
                      ),
                    ],
                  ),
                  // Current Course indicator badge
                  ElevatedButton.icon(
                    onPressed: () => context.go('/course/30-days-yoga'),
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
                    final isCurrentDay = dayNum == 4; // Figma shows Day 4 active

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
                        percentage: progressState.completedSessionsToday / progressState.totalSessionsToday,
                        ringColor: AppTheme.primaryGreen,
                        backgroundColor: AppTheme.lightGray,
                      ),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: Center(
                          child: Text(
                            '${((progressState.completedSessionsToday / progressState.totalSessionsToday) * 100).toInt()}%',
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
                  // Mindful minutes card
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
                  // Step counter card
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Daily Steps',
                      value: '${progressState.steps}',
                      icon: Icons.directions_walk,
                      color: AppTheme.accentGold,
                      onTap: () {
                        // Simulate taking steps
                        ref.read(progressProvider.notifier).addSteps(500);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Calorie card
              _buildMetricCard(
                context,
                title: 'Calories Burnt',
                value: '${progressState.calories.toStringAsFixed(1)} kcal',
                icon: Icons.local_fire_department,
                color: Colors.orangeAccent,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.coolGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                    ),
              ),
            ],
          ),
          if (onTap != null) ...[
            const Spacer(),
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
