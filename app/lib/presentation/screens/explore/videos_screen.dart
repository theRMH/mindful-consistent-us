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

bool _isNetworkPath(String path) =>
    path.startsWith('http://') || path.startsWith('https://');

String _courseCountLabel(List<dynamic> courses, String category) {
  final n = courses.where((c) => c.category == category).length;
  return '$n ${n == 1 ? 'Course' : 'Courses'}';
}

String _categoryLabel(String? category) =>
    category == 'general_exercise' ? 'General Workout' : 'Yoga';

String _categoryValue(String label) =>
    label == 'General Workout' ? 'general_exercise' : 'yoga';

class VideosScreen extends ConsumerWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(authProvider).user == null;
    final fvState = ref.watch(freeVideosProvider);
    final progressState = ref.watch(progressProvider);
    final streak = progressState.currentStreak;
    final coursesState = ref.watch(coursesProvider);
    final bool hasEnrolledCourses = coursesState.activeCourses.isNotEmpty;

    // Track the currently viewing course
    final viewingCourseId =
        ref.watch(viewingCourseIdProvider) ?? progressState.activeCourseId;

    String headerTitle = '';
    if (viewingCourseId != null) {
      final matches = coursesState.activeCourses.where(
        (c) => c.id == viewingCourseId,
      );
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
            _buildHeader(
              context,
              ref,
              streak,
              headerTitle,
              coursesState.activeCourses,
              isGuest,
            ),
            if (!isGuest && hasEnrolledCourses) ...[
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCategoryChip(
                        ref,
                        'Yoga',
                        _courseCountLabel(coursesState.activeCourses, 'yoga'),
                        ref.watch(videoCategoryProvider) == 'Yoga',
                        coursesState.activeCourses,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildCategoryChip(
                        ref,
                        'General Workout',
                        _courseCountLabel(coursesState.activeCourses, 'general_exercise'),
                        ref.watch(videoCategoryProvider) == 'General Workout',
                        coursesState.activeCourses,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            Expanded(
              child: isGuest
                  ? (fvState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildGuestContent(context, fvState.videos))
                  : hasEnrolledCourses
                  ? _buildRegisteredContent(
                      context,
                      ref,
                      viewingCourseId,
                      fvState.videos.isNotEmpty &&
                              fvState.videos.first.youtubeVideoId != null
                          ? fvState.videos.first.youtubeVideoId!
                          : 'dJMOsV_2nXI',
                    )
                  : _buildLoggedInNoCourseContent(context, fvState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    int streak,
    String headerTitle,
    List<CourseModel> activeCourses,
    bool isGuest,
  ) {
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
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
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
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
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
          if (!isGuest && activeCourses.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () {
                if (activeCourses.isNotEmpty) {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (ctx) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Select Active Course',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...activeCourses.map(
                              (c) => ListTile(
                                title: Text(c.title),
                                onTap: () {
                                  ref
                                      .read(viewingCourseIdProvider.notifier)
                                      .state = c
                                      .id;
                                  if (c.category != null &&
                                      c.category!.isNotEmpty) {
                                    ref
                                        .read(videoCategoryProvider.notifier)
                                        .state = _categoryLabel(
                                      c.category,
                                    );
                                  }
                                  Navigator.pop(ctx);
                                },
                              ),
                            ),
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
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
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
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Guest Content ────────────────────────────────────────────────────────

  Widget _buildGuestContent(BuildContext context, List<FreeVideoModel> videos) {
    if (videos.isEmpty) {
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
          ...videos.map(
            (video) => Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
              ),
              child: _buildFreeVideoCard(
                context,
                video: video,
                onTap: () => showLoginPrompt(context),
              ),
            ),
          ),
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
    final match = coursesState.activeCourses.where(
      (c) => c.id == viewingCourseId,
    );
    if (match.isNotEmpty) {
      category = match.first.category ?? 'yoga';
    }

    final String imagePath = category == 'yoga'
        ? 'assets/icon_asana.png'
        : 'assets/icon_kriya.png';

    return courseAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading course details: $e')),
      data: (courseDetail) {
        final enrollment = coursesState.enrollmentForCourse(viewingCourseId);
        final enrolledAt = enrollment?.enrolledAt ?? DateTime.now();
        final enrolledDate = DateTime(
          enrolledAt.year,
          enrolledAt.month,
          enrolledAt.day,
        );
        final now = DateTime.now();
        final todayDate = DateTime(now.year, now.month, now.day);
        final todayDayNumber = todayDate.difference(enrolledDate).inDays + 1;
        final todayDays = courseDetail.days.where(
          (day) => day.dayNumber == todayDayNumber,
        );
        final todayDay = todayDays.isNotEmpty ? todayDays.first : null;
        final selectedCategory = _categoryValue(
          ref.watch(videoCategoryProvider),
        );
        final todayVideos = todayDay == null
            ? <VideoModel>[]
            : todayDay.videos
                  .where(
                    (video) => (video.category ?? 'yoga') == selectedCategory,
                  )
                  .toList();

        if (todayDay == null || todayVideos.isEmpty) {
          return Center(
            child: Text(
              todayDay == null
                  ? 'No sessions unlocked for today.'
                  : 'No ${ref.watch(videoCategoryProvider)} sessions today.',
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
                    children: todayVideos
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildTodaySessionTile(
                            context,
                            todayDay,
                            entry.value,
                            viewingCourseId,
                            imagePath,
                            entry.key,
                            todayVideos.length,
                            progressState.completedVideoIds.contains(
                              entry.value.id,
                            ),
                            fallbackVideoId,
                          ),
                        )
                        .toList(),
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
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
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
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
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
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
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

  // ignore: unused_element
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
                    border: Border.all(
                      color: AppTheme.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                if (index < total - 1)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFE0E0E0),
                    ),
                  ),
                if (index == total - 1) const Spacer(),
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
                  final video = day.videos.isNotEmpty ? day.videos.first : null;
                  context.push(
                    '/play',
                    extra: {
                      'courseId': courseId,
                      'dayNumber': day.dayNumber,
                      'videoId': video?.id,
                      'videoSource': video?.videoSource ?? 'youtube',
                      'youtubeVideoId':
                          video?.youtubeVideoId ?? fallbackVideoId,
                      'bunnyVideoId': video?.bunnyVideoId,
                      'bunnyLibraryId': video?.bunnyLibraryId,
                      'videoTitle': video?.title ?? day.title,
                    },
                  );
                },
                child: Row(
                  children: [
                    // Thumbnail — shows tick when completed
                    if (isCompleted)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.figmaGreen,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    else
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
                              color: isCompleted
                                  ? AppTheme.primaryGreen
                                  : AppTheme.coolGray,
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
                        border: Border.all(
                          color: AppTheme.figmaGreen,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppTheme.figmaGreen,
                        size: 18,
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

  Widget _buildTodaySessionTile(
    BuildContext context,
    CourseDayModel day,
    VideoModel video,
    String courseId,
    String imagePath,
    int index,
    int total,
    bool isCompleted,
    String fallbackVideoId,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: index < total - 1 ? 18.0 : 0.0),
      child: GestureDetector(
        onTap: () {
          context.push(
            '/play',
            extra: {
              'courseId': courseId,
              'dayNumber': day.dayNumber,
              'videoId': video.id,
              'videoSource': video.videoSource,
              'youtubeVideoId': video.youtubeVideoId ?? fallbackVideoId,
              'bunnyVideoId': video.bunnyVideoId,
              'bunnyLibraryId': video.bunnyLibraryId,
              'videoTitle': video.title,
            },
          );
        },
        child: Row(
          children: [
            if (isCompleted)
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.figmaGreen,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              )
            else
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
                    video.title,
                    style: GoogleFonts.inter(
                      fontWeight: AppFontWeights.bold,
                      color: AppTheme.figmaCharcoal,
                      fontSize: AppFontSizes.bodyLarge,
                    ),
                  ),
                  Text(
                    '${video.durationSeconds ~/ 60} mins • ${isCompleted ? 'Completed' : 'Today'}',
                    style: GoogleFonts.inter(
                      color: isCompleted
                          ? AppTheme.primaryGreen
                          : AppTheme.coolGray,
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
                color: isCompleted ? AppTheme.figmaGreen : Colors.transparent,
                border: isCompleted
                    ? null
                    : Border.all(color: AppTheme.figmaGreen, width: 1.5),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
                color: isCompleted ? Colors.white : AppTheme.figmaGreen,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
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
        final hasPlayableSource = video.videoSource == 'youtube'
            ? (video.youtubeVideoId?.isNotEmpty ?? false)
            : ((video.bunnyVideoId?.isNotEmpty ?? false) &&
                  (video.bunnyLibraryId?.isNotEmpty ?? false));
        if (hasPlayableSource) {
          context.push(
            '/play',
            extra: {
              'courseId': 'free',
              'dayNumber': 1,
              'videoSource': video.videoSource,
              'youtubeVideoId': video.youtubeVideoId ?? '',
              'bunnyVideoId': video.bunnyVideoId,
              'bunnyLibraryId': video.bunnyLibraryId,
              'videoTitle': video.title,
            },
          );
        }
      },
      borderRadius: BorderRadius.vertical(
        top: index == 0 ? const Radius.circular(AppRadii.xxl) : Radius.zero,
        bottom: index == total - 1
            ? const Radius.circular(AppRadii.xxl)
            : Radius.zero,
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
                child: _isNetworkPath(imagePath)
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.self_improvement_rounded,
                          color: AppTheme.figmaGreen,
                          size: 24,
                        ),
                      )
                    : Image.asset(
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
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppTheme.figmaGreen,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    WidgetRef ref,
    String label,
    String subtext,
    bool isActive,
    List<CourseModel> activeCourses,
  ) {
    final isYoga = label == 'Yoga';
    final categorySubtitle = isYoga
        ? 'Mind • Flexibility • Strength'
        : 'Strength • Mobility • Cardio';

    return GestureDetector(
      onTap: () {
        ref.read(videoCategoryProvider.notifier).state = label;
        final matches = activeCourses.where(
          (c) => _categoryLabel(c.category) == label,
        );
        if (matches.isNotEmpty) {
          ref.read(viewingCourseIdProvider.notifier).state = matches.first.id;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? const [Color(0xFF019948), Color(0xFF0A5C2E)]
                : const [Color(0xFFFFF8EE), Color(0xFFF5ECD8)],
          ),
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          border: isActive
              ? null
              : Border.all(color: const Color(0xFFD4B88A), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colors.white.withAlpha(40)
                    : const Color(0xFFEDD9C0),
              ),
              child: Icon(
                isYoga
                    ? Icons.self_improvement_rounded
                    : Icons.directions_run_rounded,
                color: isActive ? Colors.white : AppTheme.brown,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: isActive ? Colors.white : AppTheme.figmaCharcoal,
                      fontWeight: AppFontWeights.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    categorySubtitle,
                    style: GoogleFonts.inter(
                      color: isActive
                          ? Colors.white.withAlpha(178)
                          : AppTheme.brown,
                      fontSize: 10,
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

  // ─── Logged-in, no purchased courses ─────────────────────────────────────

  Widget _buildLoggedInNoCourseContent(
    BuildContext context,
    FreeVideosState fvState,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Purchase course box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: _buildPurchaseCourseBox(context),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Free videos
          if (fvState.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (fvState.videos.isNotEmpty) ...[
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
            ...fvState.videos.map(
              (video) => Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xl,
                ),
                child: _buildFreeVideoCard(
                  context,
                  video: video,
                  onTap: () {
                    final hasPlayableSource = video.videoSource == 'youtube'
                        ? (video.youtubeVideoId?.isNotEmpty ?? false)
                        : ((video.bunnyVideoId?.isNotEmpty ?? false) &&
                              (video.bunnyLibraryId?.isNotEmpty ?? false));
                    if (hasPlayableSource) {
                      context.push(
                        '/play',
                        extra: {
                          'courseId': 'free',
                          'dayNumber': 1,
                          'videoSource': video.videoSource,
                          'youtubeVideoId': video.youtubeVideoId ?? '',
                          'bunnyVideoId': video.bunnyVideoId,
                          'bunnyLibraryId': video.bunnyLibraryId,
                          'videoTitle': video.title,
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildPurchaseCourseBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF2),
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: const Color(0xFFD4EAC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.figmaGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Your Program',
                      style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodyLarge,
                        fontWeight: AppFontWeights.bold,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                    Text(
                      'Enroll in a course to access daily sessions',
                      style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodyMedium,
                        color: AppTheme.figmaMutedGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/programs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.figmaGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              child: Text(
                'Browse Programs',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
            ),
          ),
        ],
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
                  _isNetworkPath(imagePath)
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppTheme.lightGray,
                            child: const Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: AppTheme.coolGray,
                            ),
                          ),
                        )
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppTheme.lightGray,
                            child: const Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: AppTheme.coolGray,
                            ),
                          ),
                        ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppTheme.figmaGreen
                              : AppTheme.figmaGreen,
                          border: isCompleted
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
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
