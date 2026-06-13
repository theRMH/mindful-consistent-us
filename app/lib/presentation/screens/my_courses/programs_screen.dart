import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/progress_provider.dart';

class ProgramsScreen extends ConsumerStatefulWidget {
  final String initialTab;

  const ProgramsScreen({
    super.key,
    required this.initialTab,
  });

  @override
  ConsumerState<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ProgramsScreen> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    // Unregistered users always land on explore
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      _activeTab = 'explore';
    }
  }

  @override
  void didUpdateWidget(ProgramsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() => _activeTab = widget.initialTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            _buildHeader(progressState.currentStreak),
            const SizedBox(height: AppSpacing.lg),

            // ── Tab Selector ─────────────────────────────────────────
            _buildTabSelector(),
            const SizedBox(height: AppSpacing.sm),

            // ── Tab Body ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: _buildTabContent(progressState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(int streak) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 130),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/unreg_header_bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Programs',
                style: GoogleFonts.inter(
                  color: AppTheme.figmaGreen,
                  fontSize: 20,
                  fontWeight: AppFontWeights.bold,
                ),
              ),
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
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Daily discipline. Lasting transformation.',
            style: GoogleFonts.inter(
              color: AppTheme.figmaMutedGray,
              fontSize: 9.5,
              fontWeight: AppFontWeights.regular,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab Selector ─────────────────────────────────────────────────────────

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
            _buildTabButton('active', 'Active'),
            _buildTabButton('completed', 'Completed'),
            _buildTabButton('explore', 'Explore'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabKey, String label) {
    final bool isSelected = _activeTab == tabKey;
    final Color contentColor = isSelected ? Colors.white : AppTheme.figmaMutedGray;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tabKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.figmaGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabIcon(tabKey, isSelected),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: contentColor,
                  fontSize: 11.0,
                  fontWeight: isSelected ? AppFontWeights.bold : AppFontWeights.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabIcon(String tabKey, bool isSelected) {
    final Color color = isSelected ? Colors.white : AppTheme.figmaMutedGray;

    if (tabKey == 'active') {
      return Image.asset(
        'assets/active_icon.png',
        width: 16,
        height: 16,
        color: color,
        fit: BoxFit.contain,
      );
    } else if (tabKey == 'completed') {
      return Icon(
        Icons.check_circle_outline_rounded,
        size: 16,
        color: color,
      );
    } else {
      return Icon(
        Icons.explore_outlined,
        size: 16,
        color: color,
      );
    }
  }

  // ─── Tab Content ──────────────────────────────────────────────────────────

  Widget _buildTabContent(ProgressState progressState) {
    final isGuest = !ref.watch(authProvider).isAuthenticated;
    if (isGuest && _activeTab != 'explore') {
      return _buildLockedState(context);
    }

    final coursesState = ref.watch(coursesProvider);

    if (coursesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (coursesState.error != null) {
      return Center(
        child: Text(
          'Could not load courses.\n${coursesState.error}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppTheme.coolGray, fontSize: 13),
        ),
      );
    }

    if (_activeTab == 'active') {
      return _buildActiveOrCompletedList(coursesState, progressState, isCompleted: false);
    } else if (_activeTab == 'completed') {
      return _buildActiveOrCompletedList(coursesState, progressState, isCompleted: true);
    } else {
      return _buildExploreList(coursesState);
    }
  }

  Widget _buildLockedState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.figmaGreen.withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline_rounded,
                size: 36, color: AppTheme.figmaGreen),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Login to see your programs',
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: AppFontWeights.bold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Track your progress and stay consistent',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodyMedium,
              color: AppTheme.figmaMutedGray,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
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
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
            ),
            child: Text(
              'Login / Register',
              style: GoogleFonts.inter(
                fontWeight: AppFontWeights.bold,
                fontSize: AppFontSizes.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Active / Completed list (shared layout) ───────────────────────────────

  Widget _buildActiveOrCompletedList(
    CoursesState coursesState,
    ProgressState progressState, {
    required bool isCompleted,
  }) {
    final courses = isCompleted
        ? coursesState.activeCourses.where((c) {
            final comp = c.id == progressState.activeCourseId
                ? progressState.completedDays.length
                : 0;
            return comp >= c.totalDays;
          }).toList()
        : coursesState.activeCourses;

    if (courses.isEmpty) {
      return Center(
        child: Text(
          isCompleted ? 'No completed programs yet.' : 'No active programs.\nExplore to enroll!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppTheme.coolGray, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final int comp = course.id == progressState.activeCourseId
            ? progressState.completedDays.length
            : 0;
        final double prog = course.totalDays > 0 ? comp / course.totalDays : 0.0;
        final String imagePath = _thumbnailPath(course);

        return _buildActiveCourseCard(
          context,
          title: course.title,
          imagePath: imagePath,
          completed: comp,
          total: course.totalDays,
          progress: prog,
          onTap: () => context.push('/program_details', extra: {
            'courseId': course.id,
            'title': course.title,
            'imagePath': imagePath,
          }),
        );
      },
    );
  }

  Widget _buildActiveCourseCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required int completed,
    required int total,
    required double progress,
    required VoidCallback onTap,
  }) {
    final String pct = '${(progress * 100).round()}%';
    const double pinW = 12;
    const double pinH = 16;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              child: _buildCourseImage(imagePath, width: 95, height: 115),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: AppFontWeights.bold,
                      color: AppTheme.figmaCharcoal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$completed of $total Days',
                    style: GoogleFonts.inter(
                      fontSize: AppFontSizes.bodyMedium,
                      color: AppTheme.coolGray,
                    ),
                  ),
                  const SizedBox(height: pinH + AppSpacing.sm),
                  // Progress bar with teardrop percentage pin
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double pinLeft =
                          (progress * constraints.maxWidth - pinW / 5)
                              .clamp(0.0, constraints.maxWidth - pinW);
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppTheme.coolGray,
                              color: AppTheme.figmaGreen,
                              minHeight: 6,
                            ),
                          ),
                          Positioned(
                            left: pinLeft,
                            top: -(pinH + 2),
                            child: SizedBox(
                              width: pinW,
                              height: pinH,
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    size: Size(pinW, pinH),
                                    painter: _LocationPinPainter(),
                                  ),
                                  Positioned(
                                    top: 1,
                                    height: 10,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Text(
                                        pct,
                                        style: GoogleFonts.inter(
                                          color: AppTheme.figmaMutedGray,
                                          fontSize: 4.5,
                                          fontWeight: AppFontWeights.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.figmaGreen,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: Text(
                          'In Progress',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.0,
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Course',
                              style: GoogleFonts.inter(
                                color: AppTheme.figmaMutedGray,
                                fontSize: 11.0,
                                fontWeight: AppFontWeights.semiBold,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 13, color: AppTheme.figmaMutedGray),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _thumbnailPath(CourseModel course) {
    if (course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty) {
      return course.thumbnailUrl!;
    }
    return course.category == 'yoga'
        ? 'assets/course_30_days.png'
        : 'assets/course_48_days.png';
  }

  Widget _buildCourseImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    final fallback = Container(
      width: width, height: height,
      color: AppTheme.lightGray,
      child: const Icon(Icons.spa_rounded, color: AppTheme.figmaGreen),
    );
    if (path.startsWith('http')) {
      return Image.network(path, width: width, height: height, fit: fit,
          errorBuilder: (_, _, _) => fallback);
    }
    return Image.asset(path, width: width, height: height, fit: fit,
        errorBuilder: (_, _, _) => fallback);
  }

  // ─── Explore list ──────────────────────────────────────────────────────────

  Widget _buildExploreList(CoursesState coursesState) {
    final courses = coursesState.exploreCourses;

    if (courses.isEmpty) {
      return Center(
        child: Text(
          'No new programs available.',
          style: GoogleFonts.inter(color: AppTheme.coolGray, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final imagePath = _thumbnailPath(course);
        final categoryLabel = course.category == 'yoga' ? 'Yoga' : 'Workout';
        final price = '₹${course.priceInr.toStringAsFixed(0)}';

        return _buildExploreCourseCard(
          context,
          title: course.title,
          imagePath: imagePath,
          days: course.totalDays,
          level: categoryLabel,
          duration: '${course.totalDays}d course',
          price: price,
          onTap: () => context.push('/program_details', extra: {
            'courseId': course.id,
            'title': course.title,
            'imagePath': imagePath,
          }),
          onEnroll: () => ref.read(coursesProvider.notifier).enroll(course.id),
        );
      },
    );
  }

  Widget _buildExploreCourseCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required int days,
    required String level,
    required String duration,
    required String price,
    required VoidCallback onTap,
    VoidCallback? onEnroll,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image: padded + rounded corners + price badge
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.xl),
                child: Stack(
                  children: [
                    _buildCourseImage(imagePath, height: 185, width: double.infinity),
                    Positioned(
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.figmaGreen,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                        ),
                        child: Text(
                          price,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: AppFontWeights.bold,
                            fontSize: AppFontSizes.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Card body
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: AppFontWeights.bold,
                      color: AppTheme.figmaGreen,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Stats row — evenly distributed
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 13, color: AppTheme.coolGray),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '$days days',
                                style: GoogleFonts.inter(
                                  color: AppTheme.coolGray,
                                  fontSize: AppFontSizes.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: AppTheme.coolGray.withAlpha(60),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart_rounded,
                                  size: 15, color: AppTheme.coolGray),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                level,
                                style: GoogleFonts.inter(
                                  color: AppTheme.coolGray,
                                  fontSize: AppFontSizes.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: AppTheme.coolGray.withAlpha(60),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 13, color: AppTheme.coolGray),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                duration,
                                style: GoogleFonts.inter(
                                  color: AppTheme.coolGray,
                                  fontSize: AppFontSizes.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: onTap,
                        child: Text(
                          'View Details',
                          style: GoogleFonts.inter(
                            color: AppTheme.figmaGreen,
                            fontWeight: AppFontWeights.semiBold,
                            fontSize: AppFontSizes.bodyMedium,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (onEnroll != null)
                        GestureDetector(
                          onTap: onEnroll,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.figmaGreen,
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                            ),
                            child: Text(
                              'Enroll',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: AppFontWeights.bold,
                                fontSize: AppFontSizes.bodyMedium,
                              ),
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppTheme.figmaGreen, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = w / 2;
    final r = w / 2 - 1.0;

    // Paint for solid green triangle pointer tip
    final greenFillPaint = Paint()
      ..color = AppTheme.figmaGreen
      ..style = PaintingStyle.fill;

    // Paint for white circle fill
    final whiteFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Paint for green circle outline
    final greenStrokePaint = Paint()
      ..color = AppTheme.figmaGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw the solid green triangle tip at the bottom.
    // The top corners of the triangle are on the circle at y = 9.0.
    // Bottom tip is at the very bottom (cx, h)
    final trianglePath = Path()
      ..moveTo(cx - 2.5, 9.0)
      ..lineTo(cx + 2.5, 9.0)
      ..lineTo(cx, h)
      ..close();
    canvas.drawPath(trianglePath, greenFillPaint);

    // Draw the white circle head (covers the top portion of the triangle)
    canvas.drawCircle(Offset(cx, cy), r, whiteFillPaint);

    // Draw the green circle outline
    canvas.drawCircle(Offset(cx, cy), r, greenStrokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
