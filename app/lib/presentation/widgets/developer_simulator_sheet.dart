import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/progress_provider.dart';
import '../../core/config/theme.dart';

class DeveloperSimulatorSheet extends ConsumerWidget {
  const DeveloperSimulatorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);

    // Get current user score
    final currentUserEntry = progressState.leaderboard.firstWhere(
      (e) => e.isCurrentUser,
      orElse: () => LeaderboardUser(rank: 3, name: 'You', avatarUrl: '', streak: 3, score: 120, isCurrentUser: true),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.coolGray.withAlpha(76),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Simulator Board',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    notifier.resetProgress();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All progress reset to zero.')),
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.redAccent),
                  label: const Text(
                    'Reset All',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // 1. Streak Slider
            _buildSectionHeader('Current Streak', '${progressState.currentStreak} Days'),
            Slider(
              value: progressState.currentStreak.toDouble(),
              min: 0,
              max: 30,
              divisions: 30,
              activeColor: AppTheme.primaryGreen,
              inactiveColor: AppTheme.lightGray,
              label: '${progressState.currentStreak}',
              onChanged: (val) {
                notifier.simulateStreak(val.toInt());
              },
            ),

            // 2. Completed Days (D1 - D7)
            _buildSectionHeader('Toggle Day Completions (Days 1 - 7)', ''),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final dayNum = index + 1;
                  final isCompleted = progressState.completedDays.contains(dayNum);
                  return InkWell(
                    onTap: () {
                      notifier.simulateDayCompletion(dayNum);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppTheme.primaryGreen : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? AppTheme.primaryGreen : AppTheme.coolGray,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'D$dayNum',
                          style: TextStyle(
                            color: isCompleted ? Colors.white : AppTheme.coolGray,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Steps Injection
            _buildSectionHeader('Daily Steps', '${progressState.steps} steps'),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => notifier.addSteps(1000),
                    child: const Text('+1,000 steps'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.addSteps(5000),
                    child: const Text('+5,000 steps'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Mindful Minutes
            _buildSectionHeader('Mindful Minutes', '${progressState.mindfulMins} mins'),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => notifier.addMindfulMinutes(5),
                    child: const Text('+5 mins'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.addMindfulMinutes(15),
                    child: const Text('+15 mins'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Leaderboard Score
            _buildSectionHeader('Leaderboard Score', '${currentUserEntry.score} pts'),
            Slider(
              value: currentUserEntry.score.toDouble(),
              min: 0,
              max: 2000,
              divisions: 40,
              activeColor: AppTheme.accentGold,
              inactiveColor: AppTheme.lightGray,
              label: '${currentUserEntry.score}',
              onChanged: (val) {
                notifier.simulateScore(val.toInt());
              },
            ),
            const SizedBox(height: 24),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Apply & Close'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String trailing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.darkSlate,
            ),
          ),
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.primaryGreen,
              ),
            ),
        ],
      ),
    );
  }
}
