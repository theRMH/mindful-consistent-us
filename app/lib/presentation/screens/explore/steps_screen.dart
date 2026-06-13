import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class StepsScreen extends ConsumerStatefulWidget {
  const StepsScreen({super.key});

  @override
  ConsumerState<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends ConsumerState<StepsScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      return _buildLockedState(context);
    }

    final progressState = ref.watch(progressProvider);
    final currentSteps = progressState.steps;
    const goalSteps = 10000;
    final stepsLeft = max(0, goalSteps - currentSteps);
    final percentage = (currentSteps / goalSteps).clamp(0.0, 1.0);

    final distanceKm = currentSteps * 0.000773;
    final durationMin = (currentSteps * 0.0084).toInt();
    final speedKmH = currentSteps > 0 ? 5.3 : 0.0;
    final calories = (currentSteps * 0.0496).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/home'),
          child: const Icon(Icons.arrow_back_rounded, color: AppTheme.figmaGreen),
        ),
        title: Text(
          'Steps',
          style: GoogleFonts.inter(
            fontWeight: AppFontWeights.bold,
            color: AppTheme.figmaGreen,
            fontSize: AppFontSizes.h3,
          ),
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => ref.read(progressProvider.notifier).addSteps(500),
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.lg),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppTheme.figmaGreen.withAlpha(20),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                '+500',
                style: GoogleFonts.inter(
                  color: AppTheme.figmaGreen,
                  fontSize: AppFontSizes.bodyMedium,
                  fontWeight: AppFontWeights.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Live Pedometer Card ──────────────────────────────
            _buildPedometerCard(
              currentSteps: currentSteps,
              stepsLeft: stepsLeft,
              percentage: percentage,
              distanceKm: distanceKm,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── 2. Three Metric Tiles ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    emoji: '🔥',
                    value: '$calories',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.access_time_rounded,
                    iconColor: AppTheme.figmaGreen,
                    value: '$durationMin min',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildMetricTile(
                    emoji: '👣',
                    value: '${speedKmH.toStringAsFixed(1)} km/h',
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // ── 3. Step History Header ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step history',
                  style: GoogleFonts.inter(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: AppFontWeights.bold,
                    color: AppTheme.figmaCharcoal,
                  ),
                ),
                Text(
                  'View history',
                  style: GoogleFonts.inter(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.bold,
                    color: AppTheme.figmaGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── 4. History Rows ─────────────────────────────────────
            _buildHistoryItem(
              dayLabel: '12',
              steps: currentSteps,
              minutes: durationMin,
              maxSteps: 10246,
              isToday: true,
            ),
            _buildHistoryItem(
              dayLabel: '11',
              steps: 10246,
              minutes: 81,
              maxSteps: 10246,
            ),
            _buildHistoryItem(
              dayLabel: '10',
              steps: 7612,
              minutes: 61,
              maxSteps: 10246,
            ),
            _buildHistoryItem(
              dayLabel: '9',
              steps: 9118,
              minutes: 70,
              maxSteps: 10246,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── 5. Trending Card ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.xxl),
                border: Border.all(color: const Color(0xFFF0F0F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E0),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                    ),
                    child: const Center(
                      child: Text('📈', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    "You're walking more this week",
                    style: GoogleFonts.inter(
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: AppFontWeights.semiBold,
                      color: AppTheme.figmaCharcoal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  // ─── Locked State (unregistered) ─────────────────────────────────────────

  Widget _buildLockedState(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/unregistered'),
          child: const Icon(Icons.arrow_back_rounded,
              color: AppTheme.figmaGreen),
        ),
        title: Text(
          'Steps',
          style: GoogleFonts.inter(
            fontWeight: AppFontWeights.bold,
            color: AppTheme.figmaGreen,
            fontSize: AppFontSizes.h3,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.figmaGreen.withAlpha(18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppTheme.figmaGreen, size: 40),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Track Your Steps',
                style: GoogleFonts.inter(
                  fontSize: AppFontSizes.h3,
                  fontWeight: AppFontWeights.bold,
                  color: AppTheme.figmaCharcoal,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Login or register to track your daily steps and reach your fitness goals.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: AppFontSizes.bodyLarge,
                  color: AppTheme.coolGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final redirect = Uri.encodeComponent(GoRouterState.of(context).uri.toString());
                    context.go('/login?redirect=$redirect');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.figmaGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Login / Register',
                    style: GoogleFonts.inter(
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: AppFontWeights.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Live Pedometer Card ──────────────────────────────────────────────────

  Widget _buildPedometerCard({
    required int currentSteps,
    required int stepsLeft,
    required double percentage,
    required double distanceKm,
  }) {
    final pctInt = (percentage * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.figmaGreen,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Pedometer',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: AppFontWeights.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs + 1),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: Colors.white.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Live now',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: AppFontWeights.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Big step count
          Text(
            _formatSteps(currentSteps),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 44,
              fontWeight: AppFontWeights.bold,
              height: 1.0,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Steps left subtitle
          Text(
            stepsLeft > 0
                ? '$stepsLeft steps left to reach today\'s goal'
                : 'Daily goal reached! 🎉',
            style: GoogleFonts.inter(
              color: Colors.white.withAlpha(200),
              fontSize: AppFontSizes.bodyMedium,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Daily goal label
          Text(
            'Daily goal',
            style: GoogleFonts.inter(
              color: Colors.white.withAlpha(200),
              fontSize: AppFontSizes.bodyMedium,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Progress bar with floating percentage badge above fill endpoint
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final fillWidth = (totalWidth * percentage).clamp(0.0, totalWidth);
              // Badge width ~30, clamp so it doesn't overflow
              const badgeWidth = 30.0;
              final badgeLeft = (fillWidth - badgeWidth / 2).clamp(0.0, totalWidth - badgeWidth);

              return SizedBox(
                height: 36, // space for badge (20) + triangle (4) + bar (10) + gap (2)
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Progress track + fill
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.white.withAlpha(50),
                          color: Colors.white,
                          minHeight: 10,
                        ),
                      ),
                    ),

                    // Floating badge (rounded rect + downward triangle pointer)
                    Positioned(
                      left: badgeLeft,
                      top: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: badgeWidth,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                            ),
                            child: Text(
                              '$pctInt%',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: AppTheme.figmaGreen,
                                fontSize: AppFontSizes.bodySmall,
                                fontWeight: AppFontWeights.bold,
                              ),
                            ),
                          ),
                          // Downward triangle pointer
                          CustomPaint(
                            size: const Size(8, 5),
                            painter: _DownTrianglePainter(Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Goal 10,000 | distance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Goal 10,000',
                style: GoogleFonts.inter(
                  color: Colors.white.withAlpha(180),
                  fontSize: AppFontSizes.bodyMedium,
                ),
              ),
              Text(
                '${distanceKm.toStringAsFixed(1)} kms Walked today',
                style: GoogleFonts.inter(
                  color: Colors.white.withAlpha(180),
                  fontSize: AppFontSizes.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Metric Tile (icon + value, no label) ────────────────────────────────

  Widget _buildMetricTile({
    String? emoji,
    IconData? icon,
    Color? iconColor,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.figmaBgGray,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 24))
          else if (icon != null)
            Icon(icon, color: iconColor ?? AppTheme.figmaGreen, size: 24),

          const SizedBox(height: AppSpacing.sm),

          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: AppFontWeights.bold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  // ─── History Row ──────────────────────────────────────────────────────────

  Widget _buildHistoryItem({
    required String dayLabel,
    required int steps,
    required int minutes,
    required int maxSteps,
    bool isToday = false,
  }) {
    final progress = (steps / maxSteps).clamp(0.0, 1.0);
    final bool goalReached = steps >= 10000;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Day number
          SizedBox(
            width: 24,
            child: Text(
              dayLabel,
              style: GoogleFonts.inter(
                fontSize: AppFontSizes.bodyLarge,
                fontWeight: AppFontWeights.bold,
                color: AppTheme.figmaCharcoal,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Steps + progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatSteps(steps)} steps',
                      style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodyLarge,
                        fontWeight: AppFontWeights.bold,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                    Text(
                      '$minutes min',
                      style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: AppFontWeights.semiBold,
                        color: AppTheme.figmaGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Progress bar with location pin at end of fill
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Track
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                    // Fill
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.figmaGreen,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                      ),
                    ),
                    // Location pin at fill endpoint
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: const Offset(0, -6),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: goalReached
                                ? AppTheme.accentGold
                                : AppTheme.figmaGreen,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      final thousands = steps ~/ 1000;
      final remainder = steps % 1000;
      return remainder > 0
          ? '$thousands,${remainder.toString().padLeft(3, '0')}'
          : '$thousands,000';
    }
    return '$steps';
  }
}

// Downward-pointing triangle painter for the progress badge pointer
class _DownTrianglePainter extends CustomPainter {
  final Color color;
  _DownTrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DownTrianglePainter oldDelegate) => oldDelegate.color != color;
}
