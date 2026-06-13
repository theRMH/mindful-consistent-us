import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/free_videos_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/login_prompt.dart';
import '../../providers/course_detail_provider.dart';
import '../../providers/courses_provider.dart';

final videoCategoryProvider = StateProvider<String>((ref) => 'Yoga');
final viewingCourseIdProvider = StateProvider<String?>((ref) => null);

class VideosScreen extends ConsumerWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(authProvider).user == null;
    final fvState = ref.watch(freeVideosProvider);
    final progressState = ref.watch(progressProvider);
    final streak = progressState.currentStreak;
    final coursesState = ref.watch(coursesProvider);

    // Track the currently viewing course
    final viewingCourseId = ref.watch(viewingCourseIdProvider) ?? progressState.activeCourseId;
    
    String headerTitle = 'No Active Course';
    if (viewingCourseId != null) {
      final matches = coursesState.activeCourses.where((c) => c.id == viewingCourseId);
      if (matches.isNotEmpty) {
        headerTitle = matches.first.title;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, streak, headerTitle, coursesState.activeCourses),
            const SizedBox(height: AppSpacing.lg),
            // Category Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCategoryChip(
                      ref,
                      'Yoga',
                      '3 Courses',
                      ref.watch(videoCategoryProvider) == 'Yoga',
                      coursesState.activeCourses,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildCategoryChip(
                      ref,
                      'General Workout',
                      '2 Courses',
                      ref.watch(videoCategoryProvider) == 'General Workout',
                      coursesState.activeCourses,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: isGuest
                  ? (fvState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildGuestContent(context, fvState.videos, ref.watch(videoCategoryProvider)))
                  : _buildRegisteredContent(context, ref, viewingCourseId, fvState.videos.isNotEmpty && fvState.videos.first.youtubeVideoId != null ? fvState.videos.first.youtubeVideoId! : 'dJMOsV_2nXI'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, int streak, String headerTitle, List<CourseModel> activeCourses) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/unreg_header_bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Videos',
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
            'Show up for yourself, Every single day.',
            style: GoogleFonts.inter(
              color: AppTheme.figmaMutedGray,
              fontSize: 9.5,
              fontWeight: AppFontWeights.regular,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () {
              if (activeCourses.isNotEmpty) {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (ctx) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          Text('Select Active Course', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ...activeCourses.map((c) => ListTile(
                            title: Text(c.title),
                            onTap: () {
                              ref.read(viewingCourseIdProvider.notifier).state = c.id;
                              if (c.category != null && c.category!.isNotEmpty) {
                                ref.read(videoCategoryProvider.notifier).state = c.category!;
                              }
                              Navigator.pop(ctx);
                            },
                          )),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: AppTheme.figmaGreen,
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    headerTitle,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: AppFontSizes.bodyMedium,
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Guest Content ────────────────────────────────────────────────────────

  Widget _buildGuestContent(BuildContext context, List<FreeVideoModel> videos, String activeCategory) {
    final filtered = videos.where((v) => (v.category ?? 'Yoga').toLowerCase() == activeCategory.toLowerCase()).toList();
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No free videos available yet.',
          style: GoogleFonts.inter(color: AppTheme.figmaMutedGray),
        ),
      );
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Free Videos',
              style: GoogleFonts.inter(
                fontSize: AppFontSizes.h3,
                fontWeight: AppFontWeights.bold,
                color: AppTheme.figmaCharcoal,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...filtered.map((video) => Padding(
                padding: const EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.xl),
                child: _buildFreeVideoCard(
                  context,
                  video: video,
                  onTap: () => showLoginPrompt(context),
                ),
              )),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildRegisteredContent(
    BuildContext context,
    WidgetRef ref,
    String? viewingCourseId,
    String fallbackVideoId,
  ) {
    if (viewingCourseId == null) {
      return Center(
        child: Text(
          'No active course selected.',
          style: GoogleFonts.inter(color: AppTheme.figmaMutedGray),
        ),
      );
    }

    final courseAsync = ref.watch(courseDetailProvider(viewingCourseId));
    final progressState = ref.watch(progressProvider);
    final coursesState = ref.watch(coursesProvider);
    
    String category = 'yoga';
    final match = coursesState.activeCourses.where((c) => c.id == viewingCourseId);
    if (match.isNotEmpty) {
      category = match.first.category ?? 'yoga';
    }
    
    final String imagePath = category == 'yoga' ? 'assets/icon_asana.png' : 'assets/icon_kriya.png';

    return courseAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading course details: $e')),
      data: (courseDetail) {
        if (courseDetail.days.isEmpty) {
          return Center(
            child: Text(
              'No sessions available.',
              style: GoogleFonts.inter(color: AppTheme.figmaMutedGray),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Sessions',
                      style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodyLarge,
                        fontWeight: AppFontWeights.bold,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                    Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: AppFontWeights.bold,
                        color: AppTheme.figmaCharcoal,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Container(
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
                      for (int i = 0; i < courseDetail.days.length; i++)
                        _buildTimelineTile(
                          context,
                          ref,
                          courseDetail.days[i],
                          viewingCourseId,
                          imagePath,
                          i,
                          courseDetail.days.length,
                          progressState.completedDays.contains(courseDetail.days[i].dayNumber),
                          fallbackVideoId,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Keep Going card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5FAF2),
                    borderRadius: BorderRadius.circular(AppRadii.xxl),
                    border: Border.all(color: const Color(0xFFD4EAC8)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppTheme.darkTeal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keep Going!',
                              style: GoogleFonts.inter(
                                fontSize: AppFontSizes.bodyLarge,
                                fontWeight: AppFontWeights.bold,
                                color: AppTheme.figmaCharcoal,
                              ),
                            ),
                            Text(
                              'Consistency is the key\nto transformation. 🌱',
                              style: GoogleFonts.inter(
                                fontSize: AppFontSizes.bodyMedium,
                                color: AppTheme.figmaMutedGray,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/bg_leaf.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox(width: 60),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Just starting button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => context.push('/free-videos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppTheme.primaryGreen.withAlpha(76),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Just starting? Watch the guidelines',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineTile(
    BuildContext context,
    WidgetRef ref,
    CourseDayModel day,
    String courseId,
    String imagePath,
    int index,
    int total,
    bool isCompleted,
    String fallbackVideoId,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left timeline column
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppTheme.primaryGreen : Colors.white,
                    border: Border.all(color: AppTheme.primaryGreen, width: 1.5),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                      : null,
                ),
                if (index < total - 1)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFE0E0E0),
                    ),
                  ),
                if (index == total - 1)
                  const Spacer(),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: index < total - 1 ? 24.0 : 0.0),
              child: GestureDetector(
                onTap: () {
                  ref.read(progressProvider.notifier).markDayComplete(day.dayNumber, courseId: courseId);
                  context.push('/play', extra: {
                    'courseId': courseId,
                    'dayNumber': day.dayNumber,
                    'youtubeVideoId': (day.videos.isNotEmpty && day.videos.first.youtubeVideoId != null) ? day.videos.first.youtubeVideoId : fallbackVideoId,
                    'videoTitle': day.videos.isNotEmpty ? day.videos.first.title : day.title,
                  });
                },
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.self_improvement_rounded,
                              color: AppTheme.figmaGreen,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.title ?? 'Day ${day.dayNumber}',
                            style: GoogleFonts.inter(
                              fontWeight: AppFontWeights.bold,
                              color: AppTheme.figmaCharcoal,
                              fontSize: AppFontSizes.bodyLarge,
                            ),
                          ),
                          Text(
                            '${day.videos.isNotEmpty ? day.videos.first.durationSeconds ~/ 60 : 15} mins • ${isCompleted ? 'Completed' : 'Up Next'}',
                            style: GoogleFonts.inter(
                              color: isCompleted ? AppTheme.primaryGreen : AppTheme.coolGray,
                              fontWeight: AppFontWeights.semiBold,
                              fontSize: AppFontSizes.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.figmaGreen, width: 1.5),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: AppTheme.figmaGreen, size: 18),
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



  Widget _buildSessionTile(
    BuildContext context,
    FreeVideoModel video,
    int index,
    int total,
  ) {
    final imagePath = video.thumbnailUrl?.isNotEmpty == true
        ? video.thumbnailUrl!
        : 'assets/video_morning_flow.png';

    return InkWell(
      onTap: () {
        if (video.youtubeVideoId != null && video.youtubeVideoId!.isNotEmpty) {
          context.push('/play', extra: {
            'courseId': 'free',
            'dayNumber': 1,
            'youtubeVideoId': video.youtubeVideoId,
            'videoTitle': video.title,
          });
        }
      },
      borderRadius: BorderRadius.vertical(
        top: index == 0 ? const Radius.circular(AppRadii.xxl) : Radius.zero,
        bottom: index == total - 1 ? const Radius.circular(AppRadii.xxl) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Thumbnail circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.self_improvement_rounded,
                    color: AppTheme.figmaGreen,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: GoogleFonts.inter(
                      fontWeight: AppFontWeights.bold,
                      color: AppTheme.figmaCharcoal,
                      fontSize: AppFontSizes.bodyLarge,
                    ),
                  ),
                  Text(
                    '${video.durationLabel} • ${video.category ?? ''}',
                    style: GoogleFonts.inter(
                      color: AppTheme.coolGray,
                      fontWeight: AppFontWeights.semiBold,
                      fontSize: AppFontSizes.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.figmaGreen, width: 1.5),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: AppTheme.figmaGreen, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
      WidgetRef ref, String label, String subtext, bool isActive, List<CourseModel> activeCourses) {
    return GestureDetector(
      onTap: () {
        ref.read(videoCategoryProvider.notifier).state = label;
        // Find if there's an active course matching this category
        final matches = activeCourses.where((c) => (c.category ?? 'Yoga').toLowerCase() == label.toLowerCase());
        if (matches.isNotEmpty) {
          ref.read(viewingCourseIdProvider.notifier).state = matches.first.id;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.figmaGreen : Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          border: Border.all(
            color: isActive ? AppTheme.figmaGreen : const Color(0xFFE0E0E0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.self_improvement_rounded : Icons.fitness_center_rounded,
              color: isActive ? Colors.white : AppTheme.brown,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white : AppTheme.figmaCharcoal,
                fontWeight: AppFontWeights.bold,
                fontSize: AppFontSizes.bodyLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtext,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white.withAlpha(178) : AppTheme.coolGray,
                fontSize: AppFontSizes.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeVideoCard(
    BuildContext context, {
    required FreeVideoModel video,
    required VoidCallback onTap,
    bool isCompleted = false,
  }) {
    final imagePath = video.thumbnailUrl?.isNotEmpty == true
        ? video.thumbnailUrl!
        : 'assets/video_morning_flow.png';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppTheme.lightGray,
                      child: const Icon(Icons.play_circle_outline,
                          size: 48, color: AppTheme.coolGray),
                    ),
                  ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppTheme.figmaGreen : AppTheme.figmaGreen,
                        border: isCompleted ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                      child: Icon(isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(153),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(
                      video.durationLabel,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: AppFontSizes.bodySmall,
                        fontWeight: AppFontWeights.bold,
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
            video.title,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: AppFontWeights.bold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            video.category ?? '',
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodyMedium,
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaGreen,
            ),
          ),
        ],
      ),
    );
  }

}
