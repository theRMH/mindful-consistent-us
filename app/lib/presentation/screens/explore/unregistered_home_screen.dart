import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../providers/courses_provider.dart';
import '../../providers/free_videos_provider.dart';
import '../../providers/community_moments_provider.dart';

class UnregisteredHomeScreen extends ConsumerWidget {
  const UnregisteredHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesState = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Header Banner ─────────────────────────────────
              _buildHeader(context),

              const SizedBox(height: AppSpacing.xxl),

              // ── 2. Explore Programs ───────────────────────────────
              _buildSectionHeader(context, 'Explore Programs'),
              const SizedBox(height: AppSpacing.md),

              if (coursesState.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (coursesState.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Could not load courses',
                        style: GoogleFonts.inter(
                          color: AppTheme.figmaCharcoal,
                          fontWeight: AppFontWeights.bold,
                          fontSize: AppFontSizes.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        coursesState.error!,
                        style: GoogleFonts.inter(
                          color: Colors.red.shade700,
                          fontSize: AppFontSizes.bodySmall,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onTap: () => ref.read(coursesProvider.notifier).refresh(),
                        child: Text(
                          'Tap to retry',
                          style: GoogleFonts.inter(
                            color: AppTheme.figmaGreen,
                            fontWeight: AppFontWeights.bold,
                            fontSize: AppFontSizes.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (coursesState.allCourses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'No courses available yet.',
                    style: GoogleFonts.inter(
                      color: AppTheme.figmaMutedGray,
                      fontSize: AppFontSizes.bodyMedium,
                    ),
                  ),
                )
              else
                ...coursesState.allCourses.take(3).map((course) {
                  final imagePath = course.thumbnailUrl?.isNotEmpty == true
                      ? course.thumbnailUrl!
                      : (course.category == 'yoga'
                          ? 'assets/course_30_days.png'
                          : 'assets/course_48_days.png');
                  final price = '₹${course.priceInr.toStringAsFixed(0)}';
                  final days = '${course.totalDays} days';
                  final level = course.category == 'yoga' ? 'Yoga' : 'Workout';
                  final duration = '${course.totalDays}d course';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: _buildCourseCard(
                      context,
                      title: course.title,
                      price: price,
                      days: days,
                      level: level,
                      duration: duration,
                      imagePath: imagePath,
                    ),
                  );
                }),

              const SizedBox(height: AppSpacing.xxl),

              // ── 3. Free Videos ────────────────────────────────────
              _buildSectionHeader(context, 'Free Videos'),
              const SizedBox(height: AppSpacing.md),

              Builder(builder: (context) {
                final fvState = ref.watch(freeVideosProvider);
                if (fvState.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final videos = fvState.videos.take(2).toList();
                if (videos.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.xxl),

              // ── 4. Community Moments ──────────────────────────────
              Builder(builder: (context) {
                final moments = ref.watch(communityMomentsProvider).moments;
                if (moments.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community Moments',
                            style: GoogleFonts.inter(
                              color: AppTheme.figmaGreen,
                              fontSize: AppFontSizes.h3,
                              fontWeight: AppFontWeights.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Real people. Real Progress. Real Inspiration.',
                            style: GoogleFonts.inter(
                              color: AppTheme.coolGray,
                              fontSize: AppFontSizes.bodyMedium,
                              fontWeight: AppFontWeights.regular,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...moments.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildQuoteCard(
                        context,
                        quote: m.quote,
                        name: m.name,
                        photoPath: m.photoUrl ?? 'assets/community_priya.png',
                        avatarPath: m.avatarUrl ?? 'assets/avatar_priya.png',
                        streakDays: m.streakDays,
                      ),
                    )),
                  ],
                );
              }),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header Banner ────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 130),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/unregistered-header_bg.png'),
          fit: BoxFit.contain,
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
            // Top row: greeting + streak badge + profile
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
                      'User 👋',
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
                            '0',
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

                const SizedBox(width: AppSpacing.sm),

                // Profile icon with green online dot
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: const Color(0xFFE8EDE9)),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    // Green online dot
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.figmaGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
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


  // ─── Section Header ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppTheme.figmaCharcoal,
              fontSize: AppFontSizes.h3,
              fontWeight: AppFontWeights.bold,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/login'),
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
    );
  }

  // ─── Course Card ──────────────────────────────────────────────────────────

  Widget _buildCourseCard(
    BuildContext context, {
    required String title,
    required String price,
    required String days,
    required String level,
    required String duration,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () => context.push('/program_details', extra: {
        'title': title,
        'imagePath': imagePath,
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Container(
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
              // Image: padded + rounded corners inside the card
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  child: Stack(
                    children: [
                      Image.asset(
                        imagePath,
                        height: 185,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          height: 185,
                          color: AppTheme.lightGray,
                          child: const Center(
                            child: Icon(Icons.image_outlined,
                                size: 48, color: AppTheme.coolGray),
                          ),
                        ),
                      ),
                      // Price badge
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
                            borderRadius:
                                BorderRadius.circular(AppRadii.xl),
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
                    // Title
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
                          // Days
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 13, color: AppTheme.coolGray),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  days,
                                  style: GoogleFonts.inter(
                                    color: AppTheme.coolGray,
                                    fontSize: AppFontSizes.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: AppTheme.coolGray.withAlpha(60),
                          ),
                          // Level
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
                          // Divider
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: AppTheme.coolGray.withAlpha(60),
                          ),
                          // Duration
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

                    // View Details
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: GoogleFonts.inter(
                            color: AppTheme.figmaGreen,
                            fontWeight: AppFontWeights.semiBold,
                            fontSize: AppFontSizes.bodyMedium,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppTheme.figmaGreen,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Free Video Item ──────────────────────────────────────────────────────

  Widget _buildFreeVideoItem(
    BuildContext context, {
    required String title,
    required String category,
    required String duration,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () => context.go('/login'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail — 16:9 landscape rectangle
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
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                      color: AppTheme.lightGray,
                      child: const Center(
                        child: Icon(Icons.play_circle_outline,
                            size: 32, color: AppTheme.coolGray),
                      ),
                    ),
                  ),
                  // Play button
                  Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.figmaGreen.withAlpha(220),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    right: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(153),
                        borderRadius:
                            BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Text(
                        duration,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: AppFontSizes.bodySmall,
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
              fontSize: AppFontSizes.bodyMedium,
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            category,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodySmall + 1,
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Community Quote Card ─────────────────────────────────────────────────

  Widget _buildQuoteCard(
    BuildContext context, {
    required String quote,
    required String name,
    required String photoPath,
    required String avatarPath,
    int streakDays = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
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
            // Photo + quote row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo with padding + rounded corners
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: Image.asset(
                      photoPath,
                      width: 100,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        width: 100,
                        height: 110,
                        color: AppTheme.lightGray,
                        child: const Icon(Icons.person_outline,
                            color: AppTheme.coolGray),
                      ),
                    ),
                  ),
                ),
                // Quote text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xs, AppSpacing.md, AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            height: 0.8,
                            color: AppTheme.figmaCharcoal,
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          quote,
                          style: GoogleFonts.inter(
                            fontSize: AppFontSizes.bodyMedium,
                            height: 1.45,
                            color: AppTheme.figmaCharcoal,
                            fontWeight: AppFontWeights.regular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom: avatar + name + streak
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage(avatarPath),
                    backgroundColor: AppTheme.lightGray,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: AppFontSizes.bodyMedium,
                      fontWeight: AppFontWeights.bold,
                      color: AppTheme.figmaCharcoal,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs + 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE),
                      borderRadius:
                          BorderRadius.circular(AppRadii.xl),
                      border: Border.all(
                          color: const Color(0xFFC2E0CE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥',
                            style: TextStyle(fontSize: 11)),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '$streakDays Days Streak',
                          style: GoogleFonts.inter(
                            color: AppTheme.figmaGreen,
                            fontSize: AppFontSizes.bodySmall,
                            fontWeight: AppFontWeights.semiBold,
                          ),
                        ),
                      ],
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
