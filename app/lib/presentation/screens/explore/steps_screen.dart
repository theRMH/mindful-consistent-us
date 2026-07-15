import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class StepsScreen extends ConsumerStatefulWidget {
  const StepsScreen({super.key});

  @override
  ConsumerState<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends ConsumerState<StepsScreen> with WidgetsBindingObserver {
  // Pedometer subscriptions — only active in pedometer-fallback mode
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  int _todaySteps = 0;
  int _lastSyncedStepMark = 0;
  int _recoveredTodaySteps = 0;
  String _status = 'stopped';
  String? _error;
  bool _isInitializing = true;

  // Health platform state
  bool _isUsingHealthPlatform = false;
  int _todayCalories = 0; // from health store; 0 → fall back to formula

  List<Map<String, dynamic>> _history = [];

  static const _prefBaseline      = 'step_baseline';
  static const _prefBaselineDate  = 'step_baseline_date';
  static const _prefHistory       = 'step_history';
  static const _prefRebootOffset  = 'step_reboot_offset';

  final _health = Health();
  static const _healthTypes = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];
  static const _healthPerms = [HealthDataAccess.READ, HealthDataAccess.READ];

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAll();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isUsingHealthPlatform) {
        _readFromHealthStore(); // pick up wearable/background steps
      } else {
        _tryUpgradeToHealth(); // user may have granted in Settings
      }
    } else if (state == AppLifecycleState.paused) {
      if (!_isUsingHealthPlatform) _syncToBackend();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stepSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  // ─── Initialisation ────────────────────────────────────────────────────────

  Future<void> _initAll() async {
    if (!ref.read(authProvider).isAuthenticated) {
      if (mounted) setState(() => _isInitializing = false);
      return;
    }
    // Activity recognition is needed for both pedometer and Health Connect
    final arStatus = await Permission.activityRecognition.request();
    if (arStatus.isPermanentlyDenied) {
      if (mounted) {
        setState(() { _error = 'permanently_denied'; _isInitializing = false; });
      }
      return;
    }
    if (!arStatus.isGranted) {
      if (mounted) {
        setState(() {
          _error = 'Motion permission denied. Enable it in Settings to track steps.';
          _isInitializing = false;
        });
      }
      return;
    }

    await _loadLocalHistory();

    final healthGranted = await _tryInitHealth();

    if (!healthGranted) {
      // Pedometer fallback: restore backend history so fresh-install recovers counts
      await _restoreHistoryFromBackend();
      await _startPedometer();
    }

    if (mounted) setState(() => _isInitializing = false);
  }

  // Try to initialise the platform health store (Google Health Connect / Apple Health).
  // Returns true if permission granted and data read successfully.
  Future<bool> _tryInitHealth() async {
    try {
      final granted = await _health.requestAuthorization(_healthTypes, permissions: _healthPerms);
      if (!granted) return false;
      await _readFromHealthStore();
      await _readHistoryFromHealthStore();
      if (mounted) setState(() => _isUsingHealthPlatform = true);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Called on app resume when still in pedometer mode — silently upgrades if
  // the user granted health permission while the app was in the background.
  Future<void> _tryUpgradeToHealth() async {
    try {
      final hasPerms = await _health.hasPermissions(_healthTypes, permissions: _healthPerms);
      if (hasPerms != true) return;
      _stepSub?.cancel();
      _statusSub?.cancel();
      await _readFromHealthStore();
      await _readHistoryFromHealthStore();
      if (mounted) setState(() => _isUsingHealthPlatform = true);
    } catch (_) {}
  }

  // Read today's aggregate steps + calories from the health store.
  Future<void> _readFromHealthStore() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final steps = await _health.getTotalStepsInInterval(startOfDay, now) ?? 0;

      final calPoints = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      final calories = calPoints
          .fold<double>(0, (sum, p) => sum + (p.value as NumericHealthValue).numericValue.toDouble())
          .toInt();

      if (mounted) {
        setState(() { _todaySteps = steps; _todayCalories = calories; });
        ref.read(todayStepsProvider.notifier).state = steps;
      }

      if (ref.read(authProvider).isAuthenticated && steps > 0) {
        try {
          await ApiService().syncSteps(steps, calories.toDouble());
          await ApiService().saveDailySteps(_todayStr(), steps);
        } catch (_) {}
      }
    } catch (_) {}
  }

  // Read last 6 days of step history from the health store.
  Future<void> _readHistoryFromHealthStore() async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> history = [];
    for (int i = 1; i <= 6; i++) {
      try {
        final date = now.subtract(Duration(days: i));
        final start = DateTime(date.year, date.month, date.day);
        final end = start.add(const Duration(days: 1));
        final steps = await _health.getTotalStepsInInterval(start, end) ?? 0;
        if (steps > 0) {
          final dateStr = _dateStr(date);
          history.add({ 'dateStr': dateStr, 'steps': steps, 'minutes': (steps * 0.0084).toInt() });
          if (ref.read(authProvider).isAuthenticated) {
            try { await ApiService().saveDailySteps(dateStr, steps); } catch (_) {}
          }
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _history = history);
  }

  // Load persisted history from SharedPreferences into _history.
  Future<void> _loadLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefHistory) ?? [];
    _history = saved.map((s) {
      final parts = s.split('|');
      return {
        'dateStr': parts[0],
        'steps':   int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
        'minutes': int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
      };
    }).toList();
  }

  // Start the raw hardware pedometer (fallback when health platform unavailable).
  Future<void> _startPedometer() async {
    _statusSub = Pedometer.pedestrianStatusStream.listen(
      (PedestrianStatus event) { if (mounted) setState(() => _status = event.status); },
      onError: (_) {},
    );

    _stepSub = Pedometer.stepCountStream.listen(
      (StepCount event) async {
        final prefs = await SharedPreferences.getInstance();
        final today = _todayStr();
        final savedDate = prefs.getString(_prefBaselineDate);
        int baseline = prefs.getInt(_prefBaseline) ?? event.steps;
        int rebootOffset = prefs.getInt(_prefRebootOffset) ?? 0;

        if (savedDate != today) {
          if (savedDate != null) {
            final prevDaySteps = max(0, event.steps - baseline);
            if (prevDaySteps > 0) await _saveToHistory(savedDate, prevDaySteps);
            baseline = event.steps;
            rebootOffset = 0;
          } else {
            if (_recoveredTodaySteps > 0) {
              if (event.steps >= _recoveredTodaySteps) {
                baseline = event.steps - _recoveredTodaySteps;
                rebootOffset = 0;
              } else {
                baseline = event.steps;
                rebootOffset = _recoveredTodaySteps;
              }
            } else {
              baseline = event.steps;
              rebootOffset = 0;
            }
          }
          await prefs.setString(_prefBaselineDate, today);
          await prefs.setInt(_prefBaseline, baseline);
          await prefs.setInt(_prefRebootOffset, rebootOffset);
        } else if (event.steps < baseline) {
          rebootOffset += _todaySteps;
          baseline = event.steps;
          await prefs.setInt(_prefRebootOffset, rebootOffset);
          await prefs.setInt(_prefBaseline, baseline);
        }

        final newSteps = rebootOffset + max(0, event.steps - baseline).toInt();
        await prefs.setInt('step_today_count', newSteps);
        if (mounted) {
          setState(() => _todaySteps = newSteps);
          ref.read(todayStepsProvider.notifier).state = newSteps;
        }

        if (newSteps - _lastSyncedStepMark >= 100) {
          _lastSyncedStepMark = newSteps;
          _syncToBackend();
        }
      },
      onError: (e) { if (mounted) setState(() => _error = e.toString()); },
    );
  }

  // ─── Health permission — reconnect ─────────────────────────────────────────

  Future<void> _connectHealth() async {
    final granted = await _tryInitHealth();
    if (!granted) {
      // Permission permanently blocked — open the app's system settings page.
      // On Android 13+ this shows Health Connect permissions; on iOS, it shows
      // the Health privacy toggle the user must enable manually.
      openAppSettings();
    }
  }

  // ─── Persistence helpers ───────────────────────────────────────────────────

  Future<void> _saveToHistory(String dateStr, int steps) async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = (steps * 0.0084).toInt();
    final entry = '$dateStr|$steps|$minutes';
    final existing = prefs.getStringList(_prefHistory) ?? [];
    final updated = [entry, ...existing.where((e) => !e.startsWith(dateStr))].take(6).toList();
    await prefs.setStringList(_prefHistory, updated);
    if (mounted) {
      setState(() {
        _history = updated.map((s) {
          final parts = s.split('|');
          return {
            'dateStr': parts[0],
            'steps':   int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
            'minutes': int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
          };
        }).toList();
      });
    }
    if (ref.read(authProvider).isAuthenticated) {
      try { await ApiService().saveDailySteps(dateStr, steps); } catch (_) {}
    }
  }

  Future<void> _restoreHistoryFromBackend() async {
    if (!ref.read(authProvider).isAuthenticated) return;
    try {
      final remote = await ApiService().getDailyStepHistory();
      if (remote.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getStringList(_prefHistory) ?? [];
      final localDates = local.map((e) => e.split('|')[0]).toSet();
      final today = _todayStr();
      final merged = List<String>.from(local);
      for (final r in remote) {
        final dateStr = r['dateStr'] as String? ?? '';
        final steps = (r['steps'] as num?)?.toInt() ?? 0;
        if (dateStr == today && steps > 0) { _recoveredTodaySteps = steps; continue; }
        if (!localDates.contains(dateStr) && steps > 0) {
          merged.add('$dateStr|$steps|${(steps * 0.0084).toInt()}');
        }
      }
      merged.sort((a, b) => b.split('|')[0].compareTo(a.split('|')[0]));
      final trimmed = merged.take(6).toList();
      await prefs.setStringList(_prefHistory, trimmed);
      if (mounted) {
        setState(() {
          _history = trimmed.map((s) {
            final parts = s.split('|');
            return {
              'dateStr': parts[0],
              'steps':   int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
              'minutes': int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
            };
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _syncToBackend() async {
    if (_isUsingHealthPlatform || _todaySteps <= 0) return;
    final calories = _todaySteps * 0.0496;
    try {
      await ApiService().syncSteps(_todaySteps, calories);
      await ApiService().saveDailySteps(_todayStr(), _todaySteps);
    } catch (_) {}
  }

  String _dateStr(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _todayStr() => _dateStr(DateTime.now());

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) return _buildLockedState(context);
    if (_isInitializing) return _buildSkeleton();

    final goalSteps = ref.watch(progressProvider).stepsGoal;
    final stepsLeft = max(0, goalSteps - _todaySteps);
    final percentage = (_todaySteps / goalSteps).clamp(0.0, 1.0);
    final distanceKm = _todaySteps * 0.000773;
    final durationMin = (_todaySteps * 0.0084).toInt();
    final calories = _isUsingHealthPlatform && _todayCalories > 0
        ? _todayCalories
        : (_todaySteps * 0.0496).toInt();

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
      body: RefreshIndicator(
        color: AppTheme.figmaGreen,
        onRefresh: () async { await _initAll(); },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Health platform warning — shown when using pedometer fallback
              if (!_isUsingHealthPlatform && _error == null)
                _buildHealthWarningBanner(),

              // Permission / sensor error
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
                            _error == 'permanently_denied'
                                ? 'Motion permission blocked. Open Settings to enable step tracking.'
                                : _error!,
                            style: GoogleFonts.inter(
                                fontSize: AppFontSizes.bodySmall,
                                color: Colors.orange.shade700),
                          ),
                        ),
                        if (_error == 'permanently_denied') ...[
                          const SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () => openAppSettings(),
                            child: Text(
                              'Open',
                              style: GoogleFonts.inter(
                                fontSize: AppFontSizes.bodySmall,
                                fontWeight: AppFontWeights.bold,
                                color: Colors.orange.shade700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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
                  Expanded(child: _buildMetricTile(
                      icon: Icons.bolt_rounded,
                      iconColor: const Color(0xFFF5A623),
                      value: '$calories',
                      label: 'kcal')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildMetricTile(
                      icon: Icons.access_time_rounded,
                      iconColor: AppTheme.figmaGreen,
                      value: '$durationMin min',
                      label: 'active')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildMetricTile(
                      emoji: '👣',
                      value: _status == 'walking' ? 'Walking' : 'Stopped',
                      label: 'status')),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // ── 3. Step History Header ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Step history',
                      style: GoogleFonts.inter(
                          fontSize: AppFontSizes.bodyLarge,
                          fontWeight: AppFontWeights.bold,
                          color: AppTheme.figmaCharcoal)),
                  Text('Last 7 days',
                      style: GoogleFonts.inter(
                          fontSize: AppFontSizes.bodyMedium,
                          fontWeight: AppFontWeights.bold,
                          color: AppTheme.figmaGreen)),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── 4. Today row ────────────────────────────────────────
              _buildHistoryItem(
                dayLabel: DateTime.now().day.toString(),
                steps: _todaySteps,
                minutes: durationMin,
                maxSteps: max(goalSteps, _todaySteps),
                isToday: true,
              ),

              // ── 5. Historical rows ──────────────────────────────────
              for (final entry in _history)
                _buildHistoryItem(
                  dayLabel: (entry['dateStr'] as String)
                      .split('-')
                      .last
                      .replaceFirst(RegExp('^0'), ''),
                  steps: entry['steps'] as int,
                  minutes: entry['minutes'] as int,
                  maxSteps: max(goalSteps, entry['steps'] as int),
                ),

              const SizedBox(height: AppSpacing.xl),

              if (_todaySteps > 0) _buildTrendingCard(),
              if (_todaySteps == 0) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildNudgeBanner(),
              ],

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Health warning banner ─────────────────────────────────────────────────

  Widget _buildHealthWarningBanner() {
    final label = Platform.isIOS ? 'Apple Health' : 'Google Health';
    return Padding(
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
            Icon(Icons.favorite_border_rounded,
                color: Colors.orange.shade700, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Connect $label for accurate steps & calories from all your devices',
                style: GoogleFonts.inter(
                    fontSize: AppFontSizes.bodySmall,
                    color: Colors.orange.shade700),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: _connectHealth,
              child: Text(
                'Connect',
                style: GoogleFonts.inter(
                  fontSize: AppFontSizes.bodySmall,
                  fontWeight: AppFontWeights.bold,
                  color: Colors.orange.shade700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Skeleton ──────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    final grey = const Color(0xFFEEEEEE);
    final lightGrey = const Color(0xFFF5F5F5);
    Widget box(double w, double h, {double r = 12}) =>
        Container(width: w, height: h,
            decoration: BoxDecoration(color: grey, borderRadius: BorderRadius.circular(r)));
    Widget fill(double h, {double r = 12}) =>
        Container(height: h,
            decoration: BoxDecoration(color: grey, borderRadius: BorderRadius.circular(r)));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/home'),
          child: const Icon(Icons.arrow_back_rounded, color: AppTheme.figmaGreen),
        ),
        title: Text('Steps',
            style: GoogleFonts.inter(
                fontWeight: AppFontWeights.bold,
                color: AppTheme.figmaGreen,
                fontSize: AppFontSizes.h3)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(AppRadii.xxl)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(120, 16), const SizedBox(height: AppSpacing.lg),
                  box(160, 44, r: 8), const SizedBox(height: AppSpacing.sm),
                  box(200, 14, r: 6), const Spacer(), fill(10, r: 5),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(children: [
              Expanded(child: Container(height: 80, decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(AppRadii.xxl)))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Container(height: 80, decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(AppRadii.xxl)))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Container(height: 80, decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(AppRadii.xxl)))),
            ]),
            const SizedBox(height: AppSpacing.xxxl),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [box(100, 16), box(60, 14)]),
            const SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < 3; i++) ...[
              Row(children: [
                box(32, 40, r: 6),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fill(14, r: 6), const SizedBox(height: AppSpacing.xs), fill(10, r: 5),
                    ])),
              ]),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Locked State ──────────────────────────────────────────────────────────

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
        title: Text('Steps',
            style: GoogleFonts.inter(
                fontWeight: AppFontWeights.bold,
                color: AppTheme.figmaGreen,
                fontSize: AppFontSizes.h3)),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: AppTheme.figmaGreen.withAlpha(18),
                    shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppTheme.figmaGreen, size: 40),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Track Your Steps',
                  style: GoogleFonts.inter(
                      fontSize: AppFontSizes.h3,
                      fontWeight: AppFontWeights.bold,
                      color: AppTheme.figmaCharcoal)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Login or register to track your daily steps and reach your fitness goals.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: AppFontSizes.bodyLarge,
                    color: AppTheme.coolGray,
                    height: 1.5),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final redirect =
                        Uri.encodeComponent(GoRouterState.of(context).uri.toString());
                    context.go('/login?redirect=$redirect');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.figmaGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill)),
                    elevation: 0,
                  ),
                  child: Text('Login / Register',
                      style: GoogleFonts.inter(
                          fontSize: AppFontSizes.bodyLarge,
                          fontWeight: AppFontWeights.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Pedometer Card ────────────────────────────────────────────────────────

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
          borderRadius: BorderRadius.circular(AppRadii.xxl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Pedometer',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: AppFontWeights.bold)),
          const SizedBox(height: AppSpacing.sm),
          Text(_formatSteps(currentSteps),
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 44,
                  fontWeight: AppFontWeights.bold, height: 1.0)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            stepsLeft > 0
                ? '$stepsLeft steps left to reach today\'s goal'
                : 'Daily goal reached! 🎉',
            style: GoogleFonts.inter(
                color: Colors.white.withAlpha(200),
                fontSize: AppFontSizes.bodyMedium),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Daily Goal (Walking + Movement)',
              style: GoogleFonts.inter(
                  color: Colors.white.withAlpha(200),
                  fontSize: AppFontSizes.bodyMedium)),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final fillWidth = (totalWidth * percentage).clamp(0.0, totalWidth);
            const badgeWidth = 30.0;
            final badgeLeft =
                (fillWidth - badgeWidth / 2).clamp(0.0, totalWidth - badgeWidth);
            return SizedBox(
              height: 36,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.white.withAlpha(50),
                          color: Colors.white,
                          minHeight: 10),
                    ),
                  ),
                  Positioned(
                    left: badgeLeft, top: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: badgeWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadii.sm)),
                          child: Text('$pctInt%',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: AppTheme.figmaGreen,
                                  fontSize: AppFontSizes.bodySmall,
                                  fontWeight: AppFontWeights.bold)),
                        ),
                        CustomPaint(
                            size: const Size(8, 5),
                            painter: _DownTrianglePainter(Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Goal 10,000',
                  style: GoogleFonts.inter(
                      color: Colors.white.withAlpha(180),
                      fontSize: AppFontSizes.bodyMedium)),
              Text('${distanceKm.toStringAsFixed(1)} kms Walked today',
                  style: GoogleFonts.inter(
                      color: Colors.white.withAlpha(180),
                      fontSize: AppFontSizes.bodyMedium)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Metric Tile ───────────────────────────────────────────────────────────

  Widget _buildMetricTile({
    String? emoji,
    IconData? icon,
    Color? iconColor,
    required String value,
    String? label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
          color: AppTheme.figmaBgGray,
          borderRadius: BorderRadius.circular(AppRadii.xxl)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 24))
          else if (icon != null)
            Icon(icon, color: iconColor ?? AppTheme.figmaGreen, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: AppFontWeights.bold,
                  color: AppTheme.figmaCharcoal)),
          if (label != null) ...[
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 10, color: AppTheme.figmaMutedGray)),
          ],
        ],
      ),
    );
  }

  // ─── History Row ───────────────────────────────────────────────────────────

  Widget _buildHistoryItem({
    required String dayLabel,
    required int steps,
    required int minutes,
    required int maxSteps,
    bool isToday = false,
  }) {
    final progress = (steps / maxSteps).clamp(0.0, 1.0);
    final bool goalReached = steps >= ref.read(progressProvider).stepsGoal;
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
                Text(dayLabel,
                    style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodyLarge,
                        fontWeight: AppFontWeights.bold,
                        color: AppTheme.figmaCharcoal)),
                if (isToday)
                  Text('Today',
                      style: GoogleFonts.inter(
                          fontSize: 9,
                          color: AppTheme.figmaGreen,
                          fontWeight: AppFontWeights.semiBold)),
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
                    Text('${_formatSteps(steps)} steps',
                        style: GoogleFonts.inter(
                            fontSize: AppFontSizes.bodyLarge,
                            fontWeight: AppFontWeights.bold,
                            color: AppTheme.figmaCharcoal)),
                    Text('$minutes min',
                        style: GoogleFonts.inter(
                            fontSize: AppFontSizes.bodyMedium,
                            fontWeight: AppFontWeights.semiBold,
                            color: AppTheme.figmaGreen)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppTheme.lightGray,
                      color: goalReached ? AppTheme.accentGold : AppTheme.figmaGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Trending Card ─────────────────────────────────────────────────────────

  Widget _buildTrendingCard() {
    final historySteps = _history.map((e) => e['steps'] as int).toList();
    final historyAvg = historySteps.isEmpty
        ? 0
        : historySteps.fold(0, (a, b) => a + b) ~/ historySteps.length;
    final String emoji;
    final String message;
    final Color bgColor;
    if (historySteps.isEmpty) {
      emoji = '🚀'; message = "Great start! Keep walking to build your streak";
      bgColor = const Color(0xFFFFF8E0);
    } else if (_todaySteps >= historyAvg) {
      emoji = '📈'; message = "You're walking more than usual — keep it up!";
      bgColor = const Color(0xFFFFF8E0);
    } else {
      emoji = '💪'; message = "You're a bit below your usual pace — let's go!";
      bgColor = const Color(0xFFFFEEEE);
    }
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(AppRadii.xl)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message,
                style: GoogleFonts.inter(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: AppFontWeights.semiBold,
                    color: AppTheme.figmaCharcoal)),
          ),
        ],
      ),
    );
  }

  // ─── Nudge Banner ──────────────────────────────────────────────────────────

  Widget _buildNudgeBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF2E7D52), Color(0xFF4CAF7A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(AppRadii.xl)),
            child: const Center(child: Text('🚶', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No steps yet today',
                    style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodyLarge,
                        fontWeight: AppFontWeights.bold,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text('A short walk goes a long way. Start moving!',
                    style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodySmall,
                        color: Colors.white.withAlpha(210))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

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
  bool shouldRepaint(_DownTrianglePainter old) => old.color != color;
}
