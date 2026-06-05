import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/progress_provider.dart';
import '../../../core/config/theme.dart';

class DayListScreen extends ConsumerWidget {
  final String courseId;

  const DayListScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider);
    
    // Figma displays a 30-day course program overview
    const int totalDays = 30;
    
    // We treat current unlocked day as day 4 (Day 1, 2, 4 are completed as per Figma)
    // Days 1 to 4 are unlocked. Days 5+ are locked.
    final int currentDay = 4; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('30-Day Yoga Journey'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          // Course Header Details
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Program',
                        style: TextStyle(
                          color: AppTheme.coolGray,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '30-Day Yoga Course',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      // Progress label
                      Text(
                        '${progressState.completedDays.length} of $totalDays Days Completed',
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Percent completion indicator circular progress
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: progressState.completedDays.length / totalDays,
                    strokeWidth: 6,
                    backgroundColor: AppTheme.lightGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          
          // List of Course Days
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: totalDays,
              itemBuilder: (context, index) {
                final dayNum = index + 1;
                final isCompleted = progressState.completedDays.contains(dayNum);
                final isUnlocked = dayNum <= currentDay;
                final isActive = dayNum == currentDay;

                return _buildDayCard(
                  context,
                  ref,
                  dayNum: dayNum,
                  isCompleted: isCompleted,
                  isUnlocked: isUnlocked,
                  isActive: isActive,
                  totalDays: totalDays,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    WidgetRef ref, {
    required int dayNum,
    required bool isCompleted,
    required bool isUnlocked,
    required bool isActive,
    required int totalDays,
  }) {
    Color cardBg = Colors.white;
    Color borderCol = AppTheme.lightGray;
    
    if (isActive) {
      cardBg = AppTheme.primaryGreen.withOpacity(0.02);
      borderCol = AppTheme.primaryGreen.withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: isActive ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkSlate.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Left icon state indicators
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.primaryGreen
                    : (!isUnlocked ? AppTheme.lightGray : AppTheme.primaryGreen.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check
                    : (!isUnlocked ? Icons.lock : Icons.play_arrow),
                color: isCompleted 
                    ? Colors.white 
                    : (!isUnlocked ? AppTheme.coolGray : AppTheme.primaryGreen),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Middle descriptions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day $dayNum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: !isUnlocked ? AppTheme.coolGray : AppTheme.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCompleted 
                        ? 'Completed' 
                        : (isActive ? 'Active session' : (!isUnlocked ? 'Locked' : 'Available')),
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted 
                          ? AppTheme.primaryGreen 
                          : (isActive ? AppTheme.accentGold : AppTheme.coolGray),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Right play buttons/indicators
            if (isUnlocked)
              TextButton(
                onPressed: () {
                  if (isCompleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Day already completed!')),
                    );
                    return;
                  }
                  
                  // Trigger simulation
                  ref.read(progressProvider.notifier).markDayComplete(dayNum);
                  
                  // If completed final day, trigger completion screen
                  if (dayNum == totalDays) {
                    context.go('/course_completed');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Completed Day $dayNum!')),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  foregroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isCompleted ? 'Review' : 'Play'),
              ),
          ],
        ),
      ),
    );
  }
}
