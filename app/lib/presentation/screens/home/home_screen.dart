import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/progress_provider.dart';
import '../explore/videos_screen.dart';

const List<String> _funnyLeaderNames = [
  'GrapplingTiger', 'FastestCheetah', 'ZoningZebra',
  'BlazePhoenix', 'IronCondor', 'SwiftFalcon',
  'NinjaPanda', 'FierceLynx', 'RoaringLion', 'StealthWolf',
  'FlashingHawk', 'MightyBison', 'GlidingEagle', 'SprintingHorse', 'FuriousBear',
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final progressState = ref.watch(progressProvider);
    final coursesState = ref.watch(coursesProvider);
    final userProfile = authState.user;
    final userName = (userProfile?.fullName ?? '').isNotEmpty
        ? userProfile!.fullName
        : userProfile?.email.split('@').first ?? 'Friend';

    // Resolve active course: prefer the one matching activeCourseId, else first enrolled
    CourseModel? activeCourse;
    final activeCourseId = progressState.activeCourseId;
    if (activeCourseId != null) {
      final match = coursesState.allCourses.where((c) => c.id == activeCourseId);
      activeCourse = match.isEmpty ? null : match.first;
    }
    activeCourse ??= coursesState.activeCourses.isNotEmpty
        ? coursesState.activeCourses.first
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Header Banner (fixed, does not scroll) ─────────
            _buildHeader(context, ref, userName, progressState.currentStreak),

            // ── Scrollable body with pull-to-refresh ──────────────
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.figmaGreen,
                onRefresh: () async {
                  await ref.read(progressProvider.notifier).refreshFromApi();
                  ref.invalidate(homeLeaderboardProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              const SizedBox(height: AppSpacing.lg),

              // ── 2. Active Course Progress Banner ──────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: _buildActiveCourseBanner(context, ref, progressState, activeCourse),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── 3. Stats Row ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: _buildStatsRow(context, ref, progressState, activeCourse),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── 4. Yoga / General Workout Action Cards ─────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2EBE5), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x04000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Yoga Card (Square Box)
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(videoCategoryProvider.notifier).state = 'Yoga';
                              context.go('/videos');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F9F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 38,
                                    child: Center(
                                      child: CustomPaint(
                                        size: const Size(38, 38),
                                        painter: YogaSilhouettePainter(
                                          color: AppTheme.figmaGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Yoga',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.figmaGreen,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppTheme.figmaGreen,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Go to Yoga',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.chevron_right_rounded,
                                              color: AppTheme.figmaGreen,
                                              size: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Flexibility • Mobility • Mind ',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: AppTheme.figmaMutedGray,
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // General Exercise Card (Square Box)
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(videoCategoryProvider.notifier).state = 'General Workout';
                              context.go('/videos');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 38,
                                    child: Center(
                                      child: CustomPaint(
                                        size: const Size(42, 26),
                                        painter: DumbbellPainter(
                                          color: AppTheme.brown,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'General Exercise',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.brown,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppTheme.brown,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Go to Workouts',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.chevron_right_rounded,
                                              color: AppTheme.brown,
                                              size: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Strength • Energy • Vitality',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: AppTheme.figmaMutedGray,
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── 5. Steps Today Card ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: GestureDetector(
                  onTap: () => context.go('/steps'),
                  child: _buildStepsTodayCard(context, ref, progressState),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── 6. Weekly Activity ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: _buildWeeklyActivityCard(context, progressState.weeklyActivity),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── 7. Community Leaderboard ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: _buildLeaderboardCard(context, ref, progressState),
              ),

              const SizedBox(height: AppSpacing.xxxl),
                    ],       // inner Column children
                  ),         // inner Column
                ),           // SingleChildScrollView
              ),             // RefreshIndicator
            ),               // Expanded
          ],                 // outer Column children
        ),                   // outer Column
      ),                     // SafeArea
    );                       // Scaffold
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, WidgetRef ref, String userName, int streak) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 130),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home_header_bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Greeting text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vanakkam',
                      style: GoogleFonts.inter(
                        color: AppTheme.figmaMutedGray,
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: AppFontWeights.regular,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '$userName 👋',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: AppFontWeights.bold,
                        color: AppTheme.darkTeal,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Streak badge — fire + number stacked with "Day Streak" label
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    border: Border.all(color: const Color(0xFFE8EDE9)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: AppSpacing.xs),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$streak',
                            style: GoogleFonts.inter(
                              color: AppTheme.darkTeal,
                              fontSize: AppFontSizes.bodyLarge,
                              fontWeight: AppFontWeights.bold,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'Day Streak',
                            style: GoogleFonts.inter(
                              color: AppTheme.coolGray,
                              fontSize: 8,
                              fontWeight: AppFontWeights.regular,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Subtitle
            Text(
              'Daily discipline. Lasting transformation.',
              style: GoogleFonts.inter(
                color: AppTheme.figmaGreen,
                fontSize: 9.5,
                fontWeight: AppFontWeights.semiBold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Active Course Progress Banner ────────────────────────────────────────

  Widget _buildActiveCourseBanner(BuildContext context, WidgetRef ref, ProgressState ps, CourseModel? activeCourse) {
    final completedCount = ps.completedDays.length;
    final totalDays = activeCourse?.totalDays ?? 30;
    final progress = totalDays > 0 ? (completedCount / totalDays).clamp(0.0, 1.0) : 0.0;
    final progressPct = (progress * 100).toInt();
    final currentDay = (ps.currentDay ?? completedCount + 1).clamp(1, totalDays);
    final courseTitle = activeCourse?.title ?? 'No Active Course';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.figmaGreen,
        borderRadius: BorderRadius.circular(24), // visually match mockups (borders round!)
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align to top right
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFF5FAFD),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Show up for yourself, Every single day.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFD0DF5A),
                        fontSize: 10.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3C31),
                  borderRadius: BorderRadius.circular(100), // pill shape matching screenshot
                  border: Border.all(color: const Color(0xFF2F552B), width: 1),
                ),
                child: Text(
                  'Day $currentDay of $totalDays',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF5FAFD),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Day strip
          _DayStrip(
            completedDays: ps.completedDays,
            currentDay: currentDay,
            totalDays: totalDays,
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0E3C31),
              borderRadius: BorderRadius.circular(100), // pill shape matching screenshot
              border: Border.all(color: const Color(0xFF2F552B), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "$completedCount of $totalDays Days Completed",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF038A44), Color(0xFF72B942)],
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$progressPct%',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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

  // ─── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context, WidgetRef ref, ProgressState ps, CourseModel? activeCourse) {
    final liveSteps = ref.watch(todayStepsProvider);
    final cachedSteps = ref.watch(todayStepsCachedProvider).valueOrNull ?? 0;
    final todaySteps = liveSteps > 0 ? liveSteps : cachedSteps;
    final goalPct = activeCourse != null && activeCourse.totalDays > 0
        ? ((ps.completedDays.length + ps.stepsGoalDays) / (activeCourse.totalDays * 2) * 100).toInt().clamp(0, 100)
        : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EBE5), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.timer_outlined,
              value: '${ps.mindfulMins}',
              label: 'Mins',
              bgColor: const Color(0xFFE6F4EA),
              iconColor: const Color(0xFF137333),
            ),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_outline_rounded,
              value: '${ps.completedSessionsToday}',
              label: 'Sessions',
              bgColor: const Color(0xFFE4F3ED),
              iconColor: const Color(0xFF007A4D),
            ),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.local_fire_department_rounded,
              value: (todaySteps * 0.04).toStringAsFixed(0),
              label: 'Calories',
              bgColor: const Color(0xFFFFECE5),
              iconColor: const Color(0xFFFF6D00),
            ),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.track_changes_rounded,
              value: '$goalPct%',
              label: 'Goal',
              bgColor: const Color(0xFFE8E5F7),
              iconColor: const Color(0xFF5E35B1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 11),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.figmaCharcoal,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: AppTheme.figmaMutedGray,
                    fontWeight: FontWeight.normal,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFE2EBE5),
    );
  }

  // ─── Steps Today ──────────────────────────────────────────────────────────

  String _formatSteps(int steps) {
    final s = steps.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Widget _buildStepsTodayCard(BuildContext context, WidgetRef ref, ProgressState ps) {
    final liveSteps = ref.watch(todayStepsProvider);
    final cached = ref.watch(todayStepsCachedProvider).valueOrNull ?? 0;
    final steps = liveSteps > 0 ? liveSteps : cached;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.figmaGreen,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_walk_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Steps Today',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: AppFontWeights.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/steps'),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatSteps(steps),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: AppFontWeights.bold,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'of 10,000 steps goal',
                    style: GoogleFonts.inter(
                      color: Colors.white.withAlpha(178),
                      fontSize: AppFontSizes.bodyMedium,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          color: Colors.white, size: 16),
                      Text(
                        '${(steps * 0.0008).toStringAsFixed(1)} km',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Distance',
                    style: GoogleFonts.inter(
                      color: Colors.white.withAlpha(178),
                      fontSize: AppFontSizes.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: LinearProgressIndicator(
                  value: (steps / ref.watch(progressProvider).stepsGoal).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withAlpha(60),
                  color: Colors.white,
                  minHeight: 7,
                ),
              ),
              const Positioned(
                right: 0,
                top: -10,
                child: Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Weekly Activity ───────────────────────────────────────────────────────

  Widget _buildWeeklyActivityCard(
      BuildContext context, List<Map<String, dynamic>> data) {
    final allEmpty = data.every((d) => (d['val'] as int) == 0);
    final maxVal = data.fold<int>(
        1, (m, d) => ((d['val'] as int) > m ? d['val'] as int : m));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Activity',
                style: GoogleFonts.inter(
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: AppFontWeights.bold,
                  color: AppTheme.figmaCharcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This Week',
                      style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: AppFontWeights.semiBold,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14, color: AppTheme.figmaCharcoal),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 150,
            child: allEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            size: 36, color: AppTheme.lightGray),
                        const SizedBox(height: 8),
                        Text(
                          'No activity this week',
                          style: GoogleFonts.inter(
                            fontSize: AppFontSizes.bodyMedium,
                            color: AppTheme.coolGray,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((d) {
                      final val = d['val'] as int;
                      final label = d['label'] as String;
                      final heightRatio = val > 0 ? (val / maxVal).clamp(0.05, 1.0) : 0.0;
                      final isHighlight = val == maxVal && val > 0;
                      return _buildBar(label, val, heightRatio, isHighlight);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int value, double heightRatio, bool isHighlight) {
    if (value == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.inter(fontSize: AppFontSizes.bodySmall, color: AppTheme.coolGray, fontWeight: FontWeight.w500)),
        ],
      );
    }
    final String valText =
        value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}K' : '$value';
    final double barH = (heightRatio * 80).clamp(10.0, 80.0);
    const double emojiD = 28.0;
    const double barW = 24.0;

    final Color barTop = isHighlight
        ? const Color(0xFF4CAF50)
        : const Color(0xFFB2DFDB);
    final Color barBottom = isHighlight
        ? AppTheme.figmaGreen
        : const Color(0xFF81C784);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value label
        if (isHighlight)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.figmaGreen,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(
              valText,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        else
          Text(
            valText,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppTheme.coolGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 4),

        // Emoji sits on top of bar using a Stack
        SizedBox(
          width: emojiD,
          height: barH + emojiD,
          child: Stack(
            children: [
              // Gradient bar body (starts at half emoji height)
              Positioned(
                top: emojiD / 2,
                left: (emojiD - barW) / 2,
                right: (emojiD - barW) / 2,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [barTop, barBottom],
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
              ),
              // Emoji circle cap
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: emojiD,
                  height: emojiD,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isHighlight
                        ? AppTheme.figmaGreen
                        : const Color(0xFF81C784),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isHighlight ? '😍' : '😊',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppFontSizes.bodySmall,
            color: AppTheme.coolGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Community Leaderboard ─────────────────────────────────────────────────

  String _resolveLeaderName(LeaderboardUser? user, int rankIndex, String authName) {
    if (user == null) return _funnyLeaderNames[rankIndex % _funnyLeaderNames.length];
    if (user.name.isNotEmpty) return user.name;
    if (user.isCurrentUser && authName.isNotEmpty) return authName;
    return _funnyLeaderNames[rankIndex % _funnyLeaderNames.length];
  }

  Widget _buildLeaderboardCard(BuildContext context, WidgetRef ref, ProgressState ps) {
    final liveAsync = ref.watch(homeLeaderboardProvider);
    final leaderboard = liveAsync.valueOrNull ?? ps.leaderboard;
    final rank1 = leaderboard.isNotEmpty ? leaderboard[0] : null;
    final rank2 = leaderboard.length > 1 ? leaderboard[1] : null;
    final rank3 = leaderboard.length > 2 ? leaderboard[2] : null;
    final currentUser = leaderboard.where((e) => e.isCurrentUser).isEmpty
        ? null
        : leaderboard.firstWhere((e) => e.isCurrentUser);
    final myRank = currentUser?.rank ?? ps.userRank;
    final myScore = currentUser?.score;

    final authUser = ref.read(authProvider).user;
    final authName = (authUser?.fullName ?? '').isNotEmpty
        ? authUser?.fullName ?? ''
        : (authUser?.email ?? '').split('@')[0];

    final name1 = _resolveLeaderName(rank1, 0, authName);
    final name2 = _resolveLeaderName(rank2, 1, authName);
    final name3 = _resolveLeaderName(rank3, 2, authName);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Community Leaderboard',
                style: GoogleFonts.inter(
                  fontSize: AppFontSizes.bodyMedium,
                  fontWeight: AppFontWeights.bold,
                  color: AppTheme.figmaCharcoal,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/community-leaderboard'),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodySmall,
                        fontWeight: AppFontWeights.semiBold,
                        color: AppTheme.figmaGreen,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 12, color: AppTheme.figmaGreen),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          leaderboard.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No leaderboard data yet',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppTheme.coolGray),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildLeaderItem(
                      rank: rank2 != null ? '${rank2.rank}' : '-',
                      name: name2,
                      avatarUrl: rank2?.avatarUrl ?? '',
                      pts: rank2 != null ? '${rank2.score} pts' : '',
                      streak: rank2?.streak ?? 0,
                      medal: '🥈',
                      avatarColor: const Color(0xFF78909C),
                      isCenter: false,
                    ),
                    _buildLeaderItem(
                      rank: rank1 != null ? '${rank1.rank}' : '-',
                      name: name1,
                      avatarUrl: rank1?.avatarUrl ?? '',
                      pts: rank1 != null ? '${rank1.score} pts' : '',
                      streak: rank1?.streak ?? 0,
                      medal: '🥇',
                      avatarColor: const Color(0xFFF59E0B),
                      isCenter: true,
                    ),
                    _buildLeaderItem(
                      rank: rank3 != null ? '${rank3.rank}' : '-',
                      name: name3,
                      avatarUrl: rank3?.avatarUrl ?? '',
                      pts: rank3 != null ? '${rank3.score} pts' : '',
                      streak: rank3?.streak ?? 0,
                      medal: '🥉',
                      avatarColor: const Color(0xFF8D6E63),
                      isCenter: false,
                    ),
                  ],
                ),
          const SizedBox(height: AppSpacing.md),
          // Your rank
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D52), AppTheme.figmaGreen],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.figmaGreen.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Rank',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withAlpha(180),
                        fontWeight: AppFontWeights.medium,
                      ),
                    ),
                    Text(
                      myScore != null ? '$myScore pts' : 'No score yet',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withAlpha(60),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  myRank != null ? '#$myRank' : '–',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: AppFontWeights.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderItem({
    required String rank,
    required String name,
    required String avatarUrl,
    required String pts,
    required String medal,
    required bool isCenter,
    required Color avatarColor,
    required int streak,
  }) {
    final double avatarR = isCenter ? 28 : 22;
    final double podiumH = isCenter ? 36 : (rank == '2' ? 22 : 14);
    final Color rankBadgeColor = rank == '1'
        ? const Color(0xFFFFD700)
        : rank == '2'
            ? const Color(0xFFB0BEC5)
            : const Color(0xFFBF8970);
    final String displayName = name;
    final String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : rank;

    Widget avatarChild = Text(
      initial,
      style: GoogleFonts.inter(
        color: avatarColor,
        fontWeight: AppFontWeights.bold,
        fontSize: isCenter ? 18 : 14,
      ),
    );

    return Column(
      children: [
        Text(medal, style: TextStyle(fontSize: isCenter ? 28 : 22)),
        const SizedBox(height: 4),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarR * 2,
              height: avatarR * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor.withAlpha(35),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(avatarR),
                child: avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(child: avatarChild),
                      )
                    : Center(child: avatarChild),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rankBadgeColor,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    rank,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: isCenter ? 80 : 64,
          child: Text(
            displayName,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodySmall,
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaCharcoal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          pts,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: AppFontWeights.semiBold,
            color: avatarColor,
          ),
        ),
        if (streak > 0)
          Text(
            '🔥 $streak',
            style: GoogleFonts.inter(fontSize: 9, color: AppTheme.coolGray),
          ),
        const SizedBox(height: 6),
        Container(
          width: isCenter ? 72 : 56,
          height: podiumH,
          decoration: BoxDecoration(
            color: avatarColor.withAlpha(isCenter ? 180 : 120),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Scrollable Day Strip ─────────────────────────────────────────────────────

class _DayStrip extends StatefulWidget {
  final List<int> completedDays;
  final int currentDay;
  final int totalDays;

  const _DayStrip({
    required this.completedDays,
    required this.currentDay,
    required this.totalDays,
  });

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  final _scroll = ScrollController();
  static const double _itemW = 44.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centreCurrentDay());
  }

  @override
  void didUpdateWidget(_DayStrip old) {
    super.didUpdateWidget(old);
    if (old.currentDay != widget.currentDay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centreCurrentDay());
    }
  }

  void _centreCurrentDay() {
    if (!_scroll.hasClients) return;
    final vp = _scroll.position.viewportDimension;
    final target = (widget.currentDay - 1) * _itemW + _itemW / 2 - vp / 2;
    _scroll.jumpTo(target.clamp(0.0, _scroll.position.maxScrollExtent));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(widget.totalDays, (i) => _buildItem(i + 1)),
        ),
      ),
    );
  }

  Widget _buildItem(int dayNum) {
    final isCompleted = widget.completedDays.contains(dayNum);
    final isCurrentDay = dayNum == widget.currentDay;
    final isMissed = !isCompleted && !isCurrentDay && dayNum < widget.currentDay;
    final isFirst = dayNum == 1;
    final isLast = dayNum == widget.totalDays;

    Widget circle;
    if (isCurrentDay) {
      circle = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(36, 36),
            painter: GradientCirclePainter(
              colors: const [Color(0xFF038A44), Color(0xFF72B942)],
              strokeWidth: 2,
            ),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '$dayNum',
                    style: GoogleFonts.inter(
                      color: AppTheme.figmaGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -4,
            child: CustomPaint(size: const Size(8, 6), painter: TrianglePointerPainter()),
          ),
        ],
      );
    } else if (isCompleted) {
      circle = Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE8F5E9),
          border: Border.all(color: const Color(0xFF81C784), width: 1.5),
        ),
        child: Center(
          child: Text(
            '$dayNum',
            style: GoogleFonts.inter(
              color: AppTheme.figmaGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    } else if (isMissed) {
      circle = Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFEBEE),
          border: Border.all(color: const Color(0xFFEF9A9A), width: 1.5),
        ),
        child: Center(
          child: Text(
            '$dayNum',
            style: GoogleFonts.inter(
              color: const Color(0xFFE53935),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    } else {
      circle = Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0E3C31),
        ),
        child: const Center(
          child: Icon(Icons.lock_outline_rounded, size: 12, color: Colors.white),
        ),
      );
    }

    return SizedBox(
      width: _itemW,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connector lines — centred via Column so they always sit mid-strip
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isFirst ? Colors.transparent : Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isLast ? Colors.transparent : Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          circle,
        ],
      ),
    );
  }
}

// Custom Painter for Goal Ring (kept for potential future use)
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

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final progressPaint = Paint()
      ..color = ringColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      2 * pi * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(GoalRingPainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}

// Custom Painter for active day gradient border
class GradientCirclePainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;

  GradientCirclePainter({required this.colors, this.strokeWidth = 1.5});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: colors,
      ).createShader(rect);

    canvas.drawArc(rect, 0, 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for active day downward-pointing pointer
class TrianglePointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Yoga silhouette icon
class YogaSilhouettePainter extends CustomPainter {
  final Color color;
  YogaSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Hair bun
    canvas.drawCircle(Offset(cx, h * 0.22), h * 0.045, paint);

    // Head (oval)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.31), width: h * 0.12, height: h * 0.14),
      paint,
    );

    final path = Path();

    // Torso (neck down to waist)
    path.moveTo(cx - h * 0.04, h * 0.38); // left neck
    path.quadraticBezierTo(cx - h * 0.1, h * 0.42, cx - h * 0.12, h * 0.48); // left shoulder
    
    // Left arm raising up
    path.quadraticBezierTo(cx - h * 0.22, h * 0.32, cx - h * 0.32, h * 0.12); // left arm outer curve
    path.quadraticBezierTo(cx - h * 0.28, h * 0.10, cx - h * 0.26, h * 0.12); // left finger tip
    path.quadraticBezierTo(cx - h * 0.18, h * 0.34, cx - h * 0.08, h * 0.46); // left arm inner curve to torso
    
    // Left waist
    path.lineTo(cx - h * 0.08, h * 0.65);
    
    // Left leg (lotus position)
    path.quadraticBezierTo(cx - h * 0.25, h * 0.65, cx - h * 0.32, h * 0.72); // outer thigh
    path.quadraticBezierTo(cx - h * 0.35, h * 0.80, cx - h * 0.25, h * 0.82); // outer knee
    path.quadraticBezierTo(cx, h * 0.84, cx + h * 0.25, h * 0.82); // bottom base line
    
    // Right leg (lotus position)
    path.quadraticBezierTo(cx + h * 0.35, h * 0.80, cx + h * 0.32, h * 0.72); // outer knee
    path.quadraticBezierTo(cx + h * 0.25, h * 0.65, cx + h * 0.08, h * 0.65); // outer thigh
    
    // Right waist
    path.lineTo(cx + h * 0.08, h * 0.46);

    // Right arm raising up
    path.quadraticBezierTo(cx + h * 0.18, h * 0.34, cx + h * 0.26, h * 0.12); // right arm inner curve
    path.quadraticBezierTo(cx + h * 0.28, h * 0.10, cx + h * 0.32, h * 0.12); // right finger tip
    path.quadraticBezierTo(cx + h * 0.22, h * 0.32, cx + h * 0.12, h * 0.48); // right arm outer curve
    
    path.quadraticBezierTo(cx + h * 0.1, h * 0.42, cx + h * 0.04, h * 0.38); // right neck
    path.close();

    canvas.drawPath(path, paint);

    // Add a small lotus seat curve at the bottom
    final seatPath = Path()
      ..moveTo(cx - h * 0.2, h * 0.80)
      ..quadraticBezierTo(cx, h * 0.85, cx + h * 0.2, h * 0.80)
      ..quadraticBezierTo(cx, h * 0.78, cx - h * 0.2, h * 0.80)
      ..close();
    canvas.drawPath(seatPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Dumbbell icon
class DumbbellPainter extends CustomPainter {
  final Color color;
  DumbbellPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    final cy = h / 2;
    final cx = w / 2;

    // Center bar/handle
    final barWidth = w * 0.45;
    final barHeight = h * 0.12;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: barWidth, height: barHeight),
        Radius.circular(barHeight / 2),
      ),
      paint,
    );

    // Plates heights and widths
    final plateWidth = w * 0.07;
    final innerHeight = h * 0.7;
    final middleHeight = h * 0.55;
    final outerHeight = h * 0.4;

    final gap = w * 0.02; // gap between plates

    // Left side plates
    // 1. Inner plate (closest to center)
    final leftInnerX = cx - barWidth / 2 - plateWidth / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(leftInnerX, cy), width: plateWidth, height: innerHeight),
        Radius.circular(plateWidth / 2),
      ),
      paint,
    );

    // 2. Middle plate
    final leftMiddleX = leftInnerX - plateWidth - gap;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(leftMiddleX, cy), width: plateWidth, height: middleHeight),
        Radius.circular(plateWidth / 2),
      ),
      paint,
    );

    // 3. Outer plate
    final leftOuterX = leftMiddleX - plateWidth - gap;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(leftOuterX, cy), width: plateWidth, height: outerHeight),
        Radius.circular(plateWidth / 2),
      ),
      paint,
    );

    // Right side plates
    // 1. Inner plate (closest to center)
    final rightInnerX = cx + barWidth / 2 + plateWidth / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(rightInnerX, cy), width: plateWidth, height: innerHeight),
        Radius.circular(plateWidth / 2),
      ),
      paint,
    );

    // 2. Middle plate
    final rightMiddleX = rightInnerX + plateWidth + gap;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(rightMiddleX, cy), width: plateWidth, height: middleHeight),
        Radius.circular(plateWidth / 2),
      ),
      paint,
    );

    // 3. Outer plate
    final rightOuterX = rightMiddleX + plateWidth + gap;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(rightOuterX, cy), width: plateWidth, height: outerHeight),
        Radius.circular(plateWidth / 2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
