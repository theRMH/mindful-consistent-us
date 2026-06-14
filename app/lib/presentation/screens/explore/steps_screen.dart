import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/theme.dart';
import '../../providers/auth_provider.dart';

class StepsScreen extends ConsumerStatefulWidget {
  const StepsScreen({super.key});

  @override
  ConsumerState<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends ConsumerState<StepsScreen> {
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  int _todaySteps = 0;
  String _status = 'stopped';
  String? _error;

  // Persisted per-day history: list of {dateStr, steps, minutes}
  List<Map<String, dynamic>> _history = [];

  static const _prefBaseline = 'step_baseline';
  static const _prefBaselineDate = 'step_baseline_date';
  static const _prefHistory = 'step_history';

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _initPedometer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList(_prefHistory) ?? [];
    _history = savedHistory.map((s) {
      final parts = s.split('|');
      return {
        'dateStr': parts[0],
        'steps': int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
        'minutes': int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
      };
    }).toList();

    _statusSub = Pedometer.pedestrianStatusStream.listen(
      (PedestrianStatus event) {
        if (mounted) setState(() => _status = event.status);
      },
      onError: (_) {},
    );

    _stepSub = Pedometer.stepCountStream.listen(
      (StepCount event) async {
        final prefs = await SharedPreferences.getInstance();
        final today = _todayStr();
        final savedDate = prefs.getString(_prefBaselineDate);

        if (savedDate != today) {
          // New day — save today's steps to history before resetting baseline
          if (savedDate != null && _todaySteps > 0) {
            _saveToHistory(savedDate, _todaySteps);
          }
          await prefs.setString(_prefBaselineDate, today);
          await prefs.setInt(_prefBaseline, event.steps);
        }

        final baseline = prefs.getInt(_prefBaseline) ?? event.steps;
        final newSteps = max(0, event.steps - baseline);
        if (mounted) setState(() => _todaySteps = newSteps);
      },
      onError: (e) {
        if (mounted) setState(() => _error = e.toString());
      },
    );
  }

  Future<void> _saveToHistory(String dateStr, int steps) async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = (steps * 0.0084).toInt();
    final entry = '$dateStr|$steps|$minutes';
    final existing = prefs.getStringList(_prefHistory) ?? [];
    // Keep last 6 days
    final updated = [entry, ...existing.where((e) => !e.startsWith(dateStr))]
        .take(6)
        .toList();
    await prefs.setStringList(_prefHistory, updated);
    if (mounted) {
      setState(() {
        _history = updated.map((s) {
          final parts = s.split('|');
          return {
            'dateStr': parts[0],
            'steps': int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
            'minutes': int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
          };
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      return _buildLockedState(context);
    }

    const goalSteps = 10000;
    final stepsLeft = max(0, goalSteps - _todaySteps);
    final percentage = (_todaySteps / goalSteps).clamp(0.0, 1.0);
    final distanceKm = _todaySteps * 0.000773;
    final durationMin = (_todaySteps * 0.0084).toInt();
    final calories = (_todaySteps * 0.0496).toInt();

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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Step tracking unavailable on this device. Grant motion permissions in Settings.',
                          style: GoogleFonts.inter(
                              fontSize: AppFontSizes.bodySmall,
                              color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── 1. Live Pedometer Card ──────────────────────────────
            _buildPedometerCard(
              currentSteps: _todaySteps,
              stepsLeft: stepsLeft,
              percentage: percentage,
              distanceKm: distanceKm,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── 2. Three Metric Tiles ───────────────────────────────
            Row(
              children: [
                Expanded(child: _buildMetricTile(emoji: '🔥', value: '$calories')),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.access_time_rounded,
                    iconColor: AppTheme.figmaGreen,
                    value: '$durationMin min',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildMetricTile(emoji: '👣', value: _status == 'walking' ? 'Walking' : 'Stopped')),
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
                  'Last 7 days',
                  style: GoogleFonts.inter(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.bold,
                    color: AppTheme.figmaGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── 4. Today row ────────────────────────────────────────
            _buildHistoryItem(
              dayLabel: DateTime.now().day.toString(),
              steps: _todaySteps,
              minutes: durationMin,
              maxSteps: max(10000, _todaySteps),
              isToday: true,
            ),

            // ── 5. Historical rows from SharedPreferences ───────────
            for (final entry in _history)
              _buildHistoryItem(
                dayLabel: (entry['dateStr'] as String).split('-').last.replaceFirst(RegExp('^0'), ''),
                steps: entry['steps'] as int,
                minutes: entry['minutes'] as int,
                maxSteps: max(10000, _todaySteps),
              ),

            const SizedBox(height: AppSpacing.xl),

            // ── 6. Trending Card ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.xxl),
                border: Border.all(color: const Color(0xFFF0F0F0)),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
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
                    child: const Center(child: Text('📈', style: TextStyle(fontSize: 20))),
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
                child: const Icon(Icons.lock_outline_rounded, color: AppTheme.figmaGreen, size: 40),
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

          Text(
            'Daily goal',
            style: GoogleFonts.inter(
              color: Colors.white.withAlpha(200),
              fontSize: AppFontSizes.bodyMedium,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final fillWidth = (totalWidth * percentage).clamp(0.0, totalWidth);
              const badgeWidth = 30.0;
              final badgeLeft = (fillWidth - badgeWidth / 2).clamp(0.0, totalWidth - badgeWidth);

              return SizedBox(
                height: 36,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                    Positioned(
                      left: badgeLeft,
                      top: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: badgeWidth,
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
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

  // ─── Metric Tile ──────────────────────────────────────────────────────────

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
          SizedBox(
            width: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayLabel,
                  style: GoogleFonts.inter(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: AppFontWeights.bold,
                    color: AppTheme.figmaCharcoal,
                  ),
                ),
                if (isToday)
                  Text(
                    'Today',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: AppTheme.figmaGreen,
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
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
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: const Offset(0, -6),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: goalReached ? AppTheme.accentGold : AppTheme.figmaGreen,
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
