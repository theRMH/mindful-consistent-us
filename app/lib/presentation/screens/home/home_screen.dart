import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/config/theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/progress_provider.dart';
import '../explore/videos_screen.dart' show videoCategoryProvider;

const List<String> _funnyLeaderNames = [
  'GrapplingTiger', 'FastestCheetah', 'ZoningZebra',
  'BlazePhoenix', 'IronCondor', 'SwiftFalcon',
  'NinjaPanda', 'FierceLynx', 'RoaringLion', 'StealthWolf',
  'FlashingHawk', 'MightyBison', 'GlidingEagle', 'SprintingHorse', 'FuriousBear',
];

// Tracks which active course the user has selected on the home screen.
// Null means "use the API's activeCourseId" (default). Set to a courseId
// when the user picks a different course from the dropdown.
final selectedHomeCourseIdProvider = StateProvider<String?>((ref) => null);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final progressState = ref.watch(progressProvider);
    final coursesState = ref.watch(coursesProvider);
    final selectedCourseId = ref.watch(selectedHomeCourseIdProvider);

    // Once courses finish loading, redirect to explore if no active purchase
    ref.listen<CoursesState>(coursesProvider, (prev, next) {
      if (!next.isLoading && !next.hasActiveCourse) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/unregistered');
        });
      }
    });

    if (!coursesState.isLoading && !coursesState.hasActiveCourse) {
      return const Scaffold(backgroundColor: Colors.white, body: SizedBox.shrink());
    }

    final userProfile = authState.user;
    final userName = (userProfile?.fullName ?? '').trim().isNotEmpty
        ? userProfile!.fullName.trim()
        : 'User';

    final activeCourses = coursesState.activeCourses;

    // Resolve active course: user's explicit pick → API's activeCourseId → first enrolled
    CourseModel? activeCourse;
    if (selectedCourseId != null) {
      final match = activeCourses.where((c) => c.id == selectedCourseId);
      activeCourse = match.isEmpty ? null : match.first;
    }
    if (activeCourse == null) {
      final apiCourseId = progressState.activeCourseId;
      if (apiCourseId != null) {
        final match = coursesState.allCourses.where((c) => c.id == apiCourseId);
        activeCourse = match.isEmpty ? null : match.first;
      }
    }
    activeCourse ??= activeCourses.isNotEmpty ? activeCourses.first : null;

    // Expiry check — used to swap progress banner for completion banner
    bool courseExpired = false;
    int daysSinceCompletion = 0;
    if (activeCourse != null) {
      final enrollment = coursesState.enrollmentForCourse(activeCourse.id);
      if (enrollment != null) {
        final enrolledAt = enrollment.enrolledAt.toLocal();
        final enrolledDate = DateTime(enrolledAt.year, enrolledAt.month, enrolledAt.day);
        final now = DateTime.now();
        final todayDate = DateTime(now.year, now.month, now.day);
        final calendarDayNumber = todayDate.difference(enrolledDate).inDays + 1;
        courseExpired = calendarDayNumber > activeCourse.totalDays;
        if (courseExpired) {
          daysSinceCompletion = calendarDayNumber - activeCourse.totalDays;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Scrollable body with pull-to-refresh ──────────────
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.figmaGreen,
                onRefresh: () async {
                  await Future.wait([
                    ref.read(progressProvider.notifier).refreshFromApi(),
                    ref.read(coursesProvider.notifier).refresh(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              // ── 1. Header ─────────────────────────────────────────
              _buildHeader(context, ref, userName, progressState.currentStreak),

              // ── 2. Today's Journey Banner ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: courseExpired && activeCourse != null
                    ? _buildCompletedCourseBanner(context, activeCourse, daysSinceCompletion)
                    : _buildActiveCourseBanner(context, ref, progressState, activeCourse, activeCourses: activeCourses, isLoading: coursesState.isLoading),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── 3. Today's Plan ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildTodaysPlan(context, ref, progressState, activeCourse),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── 4. This Week Progress ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildWeeklyActivityCard(context, progressState, activeCourse),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── 5. Steps Today ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GestureDetector(
                  onTap: () => context.go('/steps'),
                  child: _buildStepsTodayCard(context, ref, progressState),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── 6. You're on a roll ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildStreakBanner(context, progressState.currentStreak),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── 7. Community Leaderboard ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildLeaderboardCard(context, ref, progressState),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── 8. Points permalink ───────────────────────────────
              GestureDetector(
                onTap: () => _showPointsExplanation(context),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: '💡  '),
                        TextSpan(
                          text: 'How are points calculated?',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.figmaGreen,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.figmaGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final initials = userName.trim().isNotEmpty
        ? userName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar — logo left, bell + avatar right
          Row(
            children: [
              Image.asset('assets/logo.png', height: 28),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'ConsistentUs',
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  fontWeight: AppFontWeights.bold,
                  color: AppTheme.figmaGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Bell
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: const Color(0xFFE8EDE9)),
                ),
                child: const Icon(Icons.notifications_outlined,
                    size: 18, color: AppTheme.figmaCharcoal),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Avatar circle with initials
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.figmaGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: AppFontWeights.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Greeting row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $userName 👋',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: AppFontWeights.bold,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stay consistent. See the change.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.figmaMutedGray,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: const Color(0xFFE8EDE9)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
                  ],
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
                            color: AppTheme.figmaCharcoal,
                            fontSize: 16,
                            fontWeight: AppFontWeights.bold,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'Day Streak',
                          style: GoogleFonts.inter(
                            color: AppTheme.coolGray,
                            fontSize: 8,
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
        ],
      ),
    );
  }

  // ─── Course Completion Banner (shown when enrolled course has expired) ────────


  Widget _buildCompletedCourseBanner(
      BuildContext context, CourseModel course, int daysSinceCompletion) {
    final daysAgoText = daysSinceCompletion <= 1
        ? 'just now'
        : '$daysSinceCompletion days ago';
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B6B3B), Color(0xFF2A8050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Congratulations!',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFD0DF5A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You completed ${course.title}!',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3C31),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFF2F552B), width: 1),
                ),
                child: Text(
                  daysAgoText,
                  style: GoogleFonts.inter(
                    color: Colors.white.withAlpha(200),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/programs?tab=explore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.figmaGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
              child: Text(
                'Browse Next Program',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.figmaGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _courseAssetPath(CourseModel course) {
    final title = course.title.toLowerCase();
    if (title.contains('30')) return 'assets/course_30_days.png';
    if (title.contains('48')) return 'assets/course_48_days.png';
    return null;
  }

  Widget _courseImageFallback(CourseModel course) {
    final assetPath = _courseAssetPath(course);
    if (assetPath != null) {
      return ClipOval(
        child: Image.asset(assetPath, width: 72, height: 72, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(48, 48),
          painter: YogaSilhouettePainter(color: Colors.white),
        ),
      ),
    );
  }

  // ─── Course Picker Bottom Sheet ───────────────────────────────────────────

  void _showCoursePicker(BuildContext context, WidgetRef ref, List<CourseModel> courses, CourseModel? current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Switch Course',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A3C20))),
            ),
            const Divider(height: 1),
            ...courses.map((course) {
              final isSelected = course.id == current?.id;
              return ListTile(
                onTap: () {
                  ref.read(selectedHomeCourseIdProvider.notifier).state = course.id;
                  Navigator.of(context).pop();
                },
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.figmaGreen : const Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.spa_rounded, size: 18,
                      color: isSelected ? Colors.white : const Color(0xFF888888)),
                ),
                title: Text(course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.figmaGreen : const Color(0xFF333333))),
                subtitle: Text('${course.totalDays} days',
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF888888))),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.figmaGreen, size: 20)
                    : null,
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Active Course Progress Banner ────────────────────────────────────────

  Widget _buildActiveCourseBanner(BuildContext context, WidgetRef ref, ProgressState ps, CourseModel? activeCourse, {List<CourseModel> activeCourses = const [], bool isLoading = false}) {
    if (activeCourse == null) {
      if (isLoading) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.figmaGreen,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.figmaGreen,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.spa_rounded, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text('Today\'s Journey',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('No active course',
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xs),
            Text('Choose a program to begin your journey.',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: () => context.go('/programs?tab=explore'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.xl),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      color: Colors.white.withAlpha(40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Explore Programs',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                    Positioned.fill(child: CustomPaint(painter: _LeafPatternPainter())),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final completedCount = ps.completedDays.length;
    final totalDays = activeCourse.totalDays;
    final progress = totalDays > 0 ? (completedCount / totalDays).clamp(0.0, 1.0) : 0.0;
    final progressPct = (progress * 100).toInt();
    final currentDay = (ps.currentDay ?? completedCount + 1).clamp(1, totalDays);

    String subtitle = 'Keep going, you\'re doing great!';
    if (completedCount >= totalDays) {
      subtitle = 'All days complete — amazing work!';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.figmaGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top label row
          Row(
            children: [
              const Icon(Icons.spa_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 5),
              Text('Today\'s Journey',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
              const Spacer(),
              GestureDetector(
                onTap: activeCourses.length > 1
                    ? () => _showCoursePicker(context, ref, activeCourses, activeCourse)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8C830),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          activeCourse.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1A3C20),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (activeCourses.length > 1) ...[
                        const SizedBox(width: 3),
                        const Icon(Icons.expand_more_rounded, size: 13, color: Color(0xFF1A3C20)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Day counter row with yoga illustration placeholder
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Day $currentDay ',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'of $totalDays',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: AppSpacing.md),
                    // Progress bar + %
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withAlpha(50),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF90EE90)),
                              minHeight: 7,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('$progressPct%',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Course thumbnail
              ClipOval(
                child: activeCourse.thumbnailUrl != null && activeCourse.thumbnailUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: activeCourse.thumbnailUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 72,
                          height: 72,
                          color: Colors.white.withAlpha(30),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _courseImageFallback(activeCourse),
                      )
                    : _courseImageFallback(activeCourse),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // CTA button — same style as unregistered home
          GestureDetector(
            onTap: () => context.go('/programs'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    color: const Color(0xFFE8C830),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue Today\'s Session',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1A3C20),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Color(0xFF1A3C20), size: 16),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LeafPatternPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────

  // ─── Today's Plan ────────────────────────────────────────────────────────

  Widget _buildTodaysPlan(BuildContext context, WidgetRef ref, ProgressState ps, CourseModel? activeCourse) {
    // Today is done only if the last entry in weeklyActivity (today) has points
    final todayVal = ps.weeklyActivity.isNotEmpty
        ? (ps.weeklyActivity.last['val'] as int? ?? 0)
        : 0;
    final yogaDone = todayVal > 0;
    final workoutDone = todayVal >= 80; // full day complete (50 watch + 30 complete)
    final liveSteps = ref.watch(todayStepsProvider);
    final cached = ref.watch(todayStepsCachedProvider).valueOrNull ?? 0;
    final steps = liveSteps > 0 ? liveSteps : cached;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
            child: Row(
              children: [
                Text('Today\'s Plan',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: AppFontWeights.bold, color: AppTheme.figmaCharcoal)),
                const Spacer(),
                GestureDetector(
                  onTap: () => activeCourse != null
                      ? context.push('/program_details', extra: {
                          'courseId': activeCourse.id,
                          'title': activeCourse.title,
                          'imagePath': null,
                          'fromExplore': false,
                        })
                      : context.go('/programs'),
                  child: Text('View Full Plan',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppTheme.figmaGreen, fontWeight: AppFontWeights.semiBold)),
                ),
                const Icon(Icons.chevron_right_rounded, size: 14, color: AppTheme.figmaGreen),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPlanRow(
            icon: Icons.self_improvement_rounded,
            iconBg: AppTheme.figmaGreen,
            title: 'Yoga Session',
            subtitle: '20 min · Flexibility',
            isDone: yogaDone,
            onTap: () {
              ref.read(videoCategoryProvider.notifier).state = 'Yoga';
              context.go('/videos');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
          _buildPlanRow(
            icon: Icons.fitness_center_rounded,
            iconBg: const Color(0xFFE8A000),
            title: 'General Workout',
            subtitle: '20 min · Energy',
            isDone: workoutDone,
            onTap: () {
              ref.read(videoCategoryProvider.notifier).state = 'General Workout';
              context.go('/videos');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
          _buildPlanRow(
            icon: Icons.directions_walk_rounded,
            iconBg: AppTheme.figmaGreen,
            title: 'Walking Goal',
            subtitle: '8,000 steps',
            isDone: false,
            trailingText: '${_formatSteps(steps)} / 10,000',
            trailingColor: AppTheme.figmaGreen,
            onTap: () => context.go('/steps'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildPlanRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool isDone,
    String? trailingText,
    Color? trailingColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: AppFontWeights.semiBold,
                          color: AppTheme.figmaCharcoal)),
                  Text(subtitle,
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.figmaMutedGray)),
                ],
              ),
            ),
            if (trailingText != null)
              Text(trailingText,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: AppFontWeights.bold,
                      color: trailingColor ?? AppTheme.figmaCharcoal))
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppTheme.figmaGreen : Colors.transparent,
                  border: isDone ? null : Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  // ─── Streak motivational banner ───────────────────────────────────────────

  Widget _buildStreakBanner(BuildContext context, int streak) {
    if (streak < 1) return const SizedBox.shrink();
    final message = streak >= 7
        ? 'Unstoppable! Keep the fire alive!'
        : streak >= 3
            ? 'Amazing consistency, keep going!'
            : 'Great start — don\'t break it!';
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFF9A00), Color(0xFFFFCC00)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: const [
          BoxShadow(color: Color(0x33FF6B00), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Subtle flame pattern
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.12,
              child: Text('🔥', style: const TextStyle(fontSize: 64)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
            child: Row(
              children: [
                // Big flame icon circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("You're on a roll!",
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [const Shadow(color: Color(0x44000000), blurRadius: 4)])),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$streak',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: ' day${streak == 1 ? '' : 's'} streak',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withAlpha(220),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(message,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withAlpha(200))),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Week stat chip ───────────────────────────────────────────────────────

  Widget _buildWeekStatChip(IconData icon, String value, String label, Color bg, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: AppFontWeights.bold, color: iconColor)),
                Text(label,
                    style: GoogleFonts.inter(fontSize: 9, color: iconColor.withAlpha(180))),
              ],
            ),
          ],
        ),
      ),
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
      BuildContext context, ProgressState ps, CourseModel? activeCourse) {
    final data = ps.weeklyActivity;
    final goalPct = activeCourse != null && activeCourse.totalDays > 0
        ? ((ps.completedDays.length + ps.stepsGoalDays) / (activeCourse.totalDays * 2) * 100).toInt().clamp(0, 100)
        : 0;
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
                'This Week Progress',
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
          const SizedBox(height: AppSpacing.md),
          // 3-stat chips row
          Row(
            children: [
              _buildWeekStatChip(Icons.timer_outlined, '${ps.mindfulMins}', 'Minutes',
                  const Color(0xFFE6F4EA), const Color(0xFF137333)),
              const SizedBox(width: AppSpacing.sm),
              _buildWeekStatChip(Icons.check_circle_outline_rounded, '${ps.completedSessionsToday}', 'Sessions',
                  const Color(0xFFE4F3ED), const Color(0xFF007A4D)),
              const SizedBox(width: AppSpacing.sm),
              _buildWeekStatChip(Icons.track_changes_rounded, '$goalPct%', 'Goal',
                  const Color(0xFFE8E5F7), const Color(0xFF5E35B1)),
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
    if (ps.isLoading && ps.leaderboard.isEmpty) {
      return Shimmer.fromColors(
        baseColor: const Color(0xFFE8E8E8),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.xxl),
          ),
        ),
      );
    }
    final leaderboard = ps.leaderboard;
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
        : authUser?.phone ?? '';

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
                child: CachedNetworkImage(
                  imageUrl: resolveAvatarUrl(avatarUrl, name),
                  fit: BoxFit.cover,
                  errorWidget: (ctx, url, err) => Center(child: avatarChild),
                ),
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

void _showPointsExplanation(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _PointsExplanationSheet(),
  );
}

class _PointsExplanationSheet extends StatelessWidget {
  const _PointsExplanationSheet();

  @override
  Widget build(BuildContext context) {
    const items = [
      (emoji: '📹', action: 'Watch at least 1 video today', pts: '+50 pts'),
      (emoji: '✅', action: 'Complete all videos for the day', pts: '+10 pts'),
      (emoji: '🔥', action: 'Streak bonus (per streak day)', pts: '+10 pts'),
      (emoji: '👟', action: 'Walk at least 5,000 steps', pts: '+10 pts'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.figmaGreen.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How Points are Calculated',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.figmaCharcoal,
                    ),
                  ),
                  Text(
                    'Earn points through daily activity',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.coolGray,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Point rows
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Center(
                          child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.action,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.figmaCharcoal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.figmaGreen.withAlpha(18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.pts,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.figmaGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 8),

          // Streak explanation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'What is a streak? Each consecutive day you watch at least 1 video counts as +1 streak day. Miss a day and your streak resets to 0.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.5,
                      color: const Color(0xFF7B5800),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Footer note
          Text(
            'Points are updated after each completed session.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.coolGray,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
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
  static const double _minItemW = 44.0;
  double _currentItemW = _minItemW;

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
    final target = (widget.currentDay - 1) * _currentItemW + _currentItemW / 2 - vp / 2;
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
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final availW = constraints.maxWidth;
          final fitsInRow = widget.totalDays * _minItemW <= availW;
          _currentItemW = fitsInRow ? availW / widget.totalDays : _minItemW;
          final items = List.generate(widget.totalDays, (i) => _buildItem(i + 1, _currentItemW));
          if (fitsInRow) {
            return Row(children: items);
          }
          return SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: Row(children: items),
          );
        },
      ),
    );
  }

  Widget _buildItem(int dayNum, double itemW) {
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
      width: itemW,
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

// Leaf pattern painter (shared with unregistered home CTA buttons)
class _LeafPatternPainter extends CustomPainter {
  const _LeafPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x22FFFFFF)..style = PaintingStyle.fill;
    void drawLeaf(double cx, double cy, double w, double h, double angle) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, -h / 2)
        ..quadraticBezierTo(w / 2, 0, 0, h / 2)
        ..quadraticBezierTo(-w / 2, 0, 0, -h / 2)
        ..close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
    drawLeaf(size.width * 0.08, size.height * 0.3, 14, 28, -0.6);
    drawLeaf(size.width * 0.15, size.height * 0.75, 10, 20, 0.4);
    drawLeaf(size.width * 0.82, size.height * 0.25, 16, 32, 0.8);
    drawLeaf(size.width * 0.90, size.height * 0.7, 10, 22, -0.3);
    drawLeaf(size.width * 0.55, size.height * 0.15, 8, 18, 1.1);
    drawLeaf(size.width * 0.70, size.height * 0.85, 12, 24, -1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
