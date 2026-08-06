import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/free_videos_provider.dart';
import '../../providers/community_moments_provider.dart';
import '../../widgets/login_prompt.dart';
import '../../widgets/video_preview_sheet.dart';

// Placeholder woman photo — replace with real asset once available

class UnregisteredHomeScreen extends ConsumerStatefulWidget {
  const UnregisteredHomeScreen({super.key});

  @override
  ConsumerState<UnregisteredHomeScreen> createState() =>
      _UnregisteredHomeScreenState();
}

class _UnregisteredHomeScreenState extends ConsumerState<UnregisteredHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesState = ref.watch(coursesProvider);
    final fvState = ref.watch(freeVideosProvider);
    final cmState = ref.watch(communityMomentsProvider);
    final authState = ref.watch(authProvider);

    ref.listen<CoursesState>(coursesProvider, (prev, next) {
      if (!next.isLoading && next.hasActiveCourse && authState.isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/home');
        });
      }
    });

    final isLoading =
        coursesState.isLoading || fvState.isLoading || cmState.isLoading;

    if (isLoading) {
      return _withExitGuard(
        Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: ScaleTransition(
              scale: _scale,
              child: Image.asset('assets/logo.png', width: 96, height: 96),
            ),
          ),
        ),
      );
    }

    return _withExitGuard(
      Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. App Bar ────────────────────────────────────────
                _buildAppBar(context),

                // ── 2. Hero + Buttons (all inside one block) ──────────
                _buildHeroWithButtons(context),

                const SizedBox(height: AppSpacing.lg),

                // ── 3. How It Works ───────────────────────────────────
                _buildHowItWorks(context),

                const SizedBox(height: AppSpacing.lg),

                // ── 4. Recommended Program ────────────────────────────
                if (coursesState.allCourses.isNotEmpty) ...[
                  _buildRecommended(context, coursesState),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // ── 5. Why Section ────────────────────────────────────
                _buildWhySection(context),

                const SizedBox(height: AppSpacing.lg),

                // ── 6. Free Videos ────────────────────────────────────
                Builder(builder: (context) {
                  final videos = fvState.videos.take(2).toList();
                  if (videos.isEmpty) return const SizedBox.shrink();
                  return _buildFreeVideos(context, videos);
                }),

                const SizedBox(height: AppSpacing.xxl),

                // ── 7. Social Proof ───────────────────────────────────
                Builder(builder: (context) {
                  final moments = cmState.moments;
                  if (moments.isEmpty) return const SizedBox.shrink();
                  return _buildSocialProof(context, moments);
                }),

                const SizedBox(height: AppSpacing.lg),

                // ── 8. Bottom CTA ─────────────────────────────────────
                _buildBottomCta(context),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Exit guard ───────────────────────────────────────────────────────────

  Widget _withExitGuard(Widget child) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Press back again to exit')),
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: child,
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Row(
        children: [
          // Logo + wordmark — left aligned
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
          // Bell icon — same style as registered home streak badge container
          GestureDetector(
            onTap: () => showLoginPrompt(context),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: const Color(0xFFE8EDE9)),
              ),
              child: const Icon(Icons.notifications_outlined,
                  size: 18, color: AppTheme.figmaCharcoal),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero + Buttons (all inside bg image) ─────────────────────────────────

  Widget _buildHeroWithButtons(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Full-width bg image
        SizedBox(
          width: double.infinity,
          height: 320,
          child: Image.asset(
            'assets/hero_banner.png',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
        ),

        // Left white gradient — covers ~65% width
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white,
                  Colors.white,
                  Color(0xF5FFFFFF),
                  Color(0xAAFFFFFF),
                  Colors.transparent,
                ],
                stops: [0.0, 0.40, 0.55, 0.68, 1.0],
              ),
            ),
          ),
        ),

        // Bottom white gradient — fades image into white for buttons
        Positioned(
          left: 0, right: 0, bottom: 0,
          height: 130,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.white, Colors.transparent],
              ),
            ),
          ),
        ),

        // All content — text + chips + buttons
        Positioned(
          left: 0, right: 0, top: 0, bottom: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Headline — serif style via fontWeight + letterSpacing
                Text(
                  'What would you like\nto improve today?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: AppFontWeights.bold,
                    color: AppTheme.darkTeal,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // 2-line description
                SizedBox(
                  width: screenW * 0.56,
                  child: Text(
                    'Build a routine that helps you feel calmer, stronger and more consistent.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.figmaMutedGray,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 4 chips — single horizontal row
                Row(
                  children: const [
                    Expanded(child: _GoalChip(icon: Icons.bolt_outlined,         label: 'Feel More\nEnergetic')),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(child: _GoalChip(icon: Icons.spa_outlined,           label: 'Reduce\nStress')),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(child: _GoalChip(icon: Icons.directions_run_outlined, label: 'Improve\nFlexibility')),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(child: _GoalChip(icon: Icons.track_changes_outlined,  label: 'Build\nConsistency')),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Primary button — leaf pattern overlay
                GestureDetector(
                  onTap: () => context.go('/programs?tab=explore'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          color: AppTheme.figmaGreen,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Find My Wellness Plan',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: AppFontWeights.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 16),
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
                const SizedBox(height: AppSpacing.sm),

                // Secondary button
                GestureDetector(
                  onTap: () => context.go('/videos'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      border:
                          Border.all(color: AppTheme.figmaGreen, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Watch How It Works',
                          style: GoogleFonts.inter(
                            color: AppTheme.figmaGreen,
                            fontWeight: AppFontWeights.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(Icons.play_arrow_rounded,
                            color: AppTheme.figmaGreen, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── How It Works ─────────────────────────────────────────────────────────

  Widget _buildHowItWorks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg, horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDE6),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Column(
          children: [
            Text(
              'How ConsistenUs works',
              style: GoogleFonts.inter(
                color: AppTheme.figmaGreen,
                fontSize: 13,
                fontWeight: AppFontWeights.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _HowItWorksStep(
                    number: 1,
                    icon: Icons.eco_outlined,
                    label: 'Choose\nyour goal'),
                _HowItWorksStep(
                    number: 2,
                    icon: Icons.calendar_month_outlined,
                    label: 'Follow daily\nguidance'),
                _HowItWorksStep(
                    number: 3,
                    icon: Icons.bar_chart_rounded,
                    label: 'Track your\nconsistency'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Recommended Program ──────────────────────────────────────────────────

  Widget _buildRecommended(BuildContext context, CoursesState coursesState) {
    final course = coursesState.allCourses.first;
    final imagePath = course.thumbnailUrl?.isNotEmpty == true
        ? course.thumbnailUrl!
        : (course.category == 'yoga'
            ? 'assets/course_30_days.png'
            : 'assets/course_48_days.png');
    final currency = ref.read(authProvider).user?.currency ?? 'INR';
    final price = currency == 'USD' && course.priceUsd != null
        ? '\$${course.priceUsd!.toStringAsFixed(0)}'
        : '₹${course.priceInr.toStringAsFixed(0)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Recommended for you',
                style: GoogleFonts.inter(
                  color: AppTheme.figmaGreen,
                  fontSize: 15,
                  fontWeight: AppFontWeights.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DC),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                child: Text(
                  'Best for beginners',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8B5A00),
                    fontSize: 10,
                    fontWeight: AppFontWeights.semiBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => context.push(
              '/program_details',
              extra: {
                'courseId': course.id,
                'title': course.title,
                'imagePath': imagePath,
                'fromExplore': true,
              },
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: const Color(0xFFEDE8DF)),
              ),
              child: SizedBox(
                height: 120,
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadii.xl),
                      bottomLeft: Radius.circular(AppRadii.xl),
                    ),
                    child: Image.asset(
                      imagePath,
                      width: 110,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(
                        width: 110,
                        height: 120,
                        color: AppTheme.lightGray,
                        child: const Icon(Icons.image_outlined,
                            color: AppTheme.coolGray, size: 28),
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: AppFontWeights.bold,
                                  color: AppTheme.figmaCharcoal,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                course.description?.isNotEmpty == true
                                    ? course.description!
                                    : 'A simple way to begin your wellness routine.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.figmaMutedGray,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Button on left
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.xl),
                                  border: Border.all(
                                      color: AppTheme.figmaGreen, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View Program',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.figmaGreen,
                                        fontSize: 10,
                                        fontWeight: AppFontWeights.semiBold,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.play_arrow_rounded,
                                        color: AppTheme.figmaGreen, size: 12),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Price on right
                              Text(
                                price,
                                style: GoogleFonts.inter(
                                  color: AppTheme.figmaGreen,
                                  fontWeight: AppFontWeights.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Why Section ──────────────────────────────────────────────────────────

  Widget _buildWhySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Text(
            'Why women start with ConsistenUs',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppTheme.figmaGreen,
              fontSize: 15,
              fontWeight: AppFontWeights.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: const [
              Expanded(
                  child: _WhyTile(
                      icon: Icons.access_time_rounded,
                      label: 'Short guided\nsessions')),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: _WhyTile(
                      icon: Icons.event_available_outlined,
                      label: 'Simple daily\nroutine')),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: _WhyTile(
                      icon: Icons.group_rounded,
                      label: 'Community\nsupport')),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Free Videos ─────────────────────────────────────────────────────────

  Widget _buildFreeVideos(BuildContext context, List<dynamic> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Try a free session',
                style: GoogleFonts.inter(
                  color: AppTheme.figmaGreen,
                  fontSize: 15,
                  fontWeight: AppFontWeights.bold,
                ),
              ),
              GestureDetector(
                onTap: () => showLoginPrompt(context),
                child: Text(
                  'See All',
                  style: GoogleFonts.inter(
                    color: AppTheme.figmaCharcoal,
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              for (int i = 0; i < videos.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildFreeVideoItem(
                    context,
                    title: videos[i].title,
                    category: videos[i].category ?? '',
                    duration: videos[i].durationLabel,
                    imagePath: videos[i].thumbnailUrl?.isNotEmpty == true
                        ? videos[i].thumbnailUrl!
                        : 'assets/video_morning_flow.png',
                    youtubeVideoId: videos[i].youtubeVideoId,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreeVideoItem(
    BuildContext context, {
    required String title,
    required String category,
    required String duration,
    required String imagePath,
    String? youtubeVideoId,
  }) {
    return GestureDetector(
      onTap: () {
        if (youtubeVideoId != null && youtubeVideoId.isNotEmpty) {
          showVideoPreview(context, {
            'courseId': 'free',
            'dayNumber': 1,
            'youtubeVideoId': youtubeVideoId,
            'videoTitle': title,
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      color: AppTheme.lightGray,
                      child: const Center(
                        child: Icon(Icons.play_circle_outline,
                            size: 28, color: AppTheme.coolGray),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.figmaGreen.withAlpha(220),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(153),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Text(
                        duration,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: AppFontWeights.semiBold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            category,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Social Proof ─────────────────────────────────────────────────────────

  Widget _buildSocialProof(BuildContext context, List<dynamic> moments) {
    final m = moments.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real progress. Real people.',
            style: GoogleFonts.inter(
              color: AppTheme.figmaGreen,
              fontSize: 15,
              fontWeight: AppFontWeights.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Testimonial card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: const Color(0xFFF0F0F0)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                      resolveAvatarUrl(m.avatarUrl, m.name ?? '')),
                  backgroundColor: AppTheme.lightGray,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '”${m.quote}”',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.figmaCharcoal,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '– ${m.name}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: AppFontWeights.semiBold,
                          color: AppTheme.figmaCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Community stat card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDE6),
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC2E0CE), width: 1.5),
                  ),
                  child: const Icon(Icons.group_rounded,
                      color: AppTheme.figmaGreen, size: 26),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Women building healthier routines together.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.figmaCharcoal,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom CTA ───────────────────────────────────────────────────────────

  Widget _buildBottomCta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7EC),
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          border: Border.all(color: const Color(0xFFD4EAC8)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.25,
                child:
                    Image.asset('assets/bg_leaf.png', width: 64, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.25,
                child: Transform.flip(
                  flipX: true,
                  child: Image.asset('assets/bg_leaf.png',
                      width: 64, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    'Your routine does not need to be perfect.\nIt just needs a beginning.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: AppFontWeights.bold,
                      color: AppTheme.figmaCharcoal,
                      height: 1.45,
                    ),
                  ),
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
                            color: AppTheme.figmaGreen,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start My Journey',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: AppFontWeights.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 16),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Goal Chip ────────────────────────────────────────────────────────────────

// ─── Leaf Pattern Painter ────────────────────────────────────────────────────

class _LeafPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.fill;

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

    // Scatter leaves across the button
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

class _GoalChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GoalChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: const Color(0xFFD4EAC8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.figmaGreen, size: 18),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 8.5,
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaCharcoal,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── How It Works Step ────────────────────────────────────────────────────────

class _HowItWorksStep extends StatelessWidget {
  final int number;
  final IconData icon;
  final String label;
  const _HowItWorksStep(
      {required this.number, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD0DDD0), width: 1.5),
              ),
              child: Icon(icon, color: AppTheme.figmaGreen, size: 22),
            ),
            Positioned(
              top: -3,
              left: -3,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppTheme.figmaGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: AppFontWeights.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.figmaCharcoal,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// ─── Why Tile ─────────────────────────────────────────────────────────────────

class _WhyTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _WhyTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDE6),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: const Color(0xFFD4DAD2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.figmaGreen, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.figmaCharcoal,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
