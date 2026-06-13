import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/progress_provider.dart';
import '../../providers/courses_provider.dart';
import '../../../core/config/theme.dart';
import '../../../data/models/course_model.dart';

import '../../providers/course_detail_provider.dart';

class DayListScreen extends ConsumerStatefulWidget {
  final String courseId;

  const DayListScreen({super.key, required this.courseId});

  @override
  ConsumerState<DayListScreen> createState() => _DayListScreenState();
}

class _DayListScreenState extends ConsumerState<DayListScreen> {
  int? _expandedDay;

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final progressState = ref.watch(progressProvider);
    final coursesState = ref.watch(coursesProvider);

    final enrollment = coursesState.enrollmentForCourse(widget.courseId);
    final enrolledAt = enrollment?.enrolledAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundCream,
        elevation: 0,
        title: courseAsync.when(
          data: (d) => Text(
            d.title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkTeal,
              fontSize: 20,
            ),
          ),
          loading: () => Text(
            'Loading...',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkTeal,
              fontSize: 20,
            ),
          ),
          error: (_, _) => Text(
            'Course',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkTeal,
              fontSize: 20,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/programs?tab=active'),
        ),
      ),
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load course: $err',
              style: GoogleFonts.inter(color: AppTheme.coolGray),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (courseDetail) =>
            _buildContent(context, courseDetail, progressState, enrolledAt),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CourseDetail courseDetail,
    ProgressState progress,
    DateTime enrolledAt,
  ) {
    final completedCount = progress.completedDays.length;
    final totalDays = courseDetail.totalDays;

    return Column(
      children: [
        // Course progress header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Program',
                      style: GoogleFonts.inter(
                        color: AppTheme.coolGray,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      courseDetail.title,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCount of $totalDays Days Completed',
                      style: GoogleFonts.inter(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: totalDays > 0 ? completedCount / totalDays : 0,
                  strokeWidth: 6,
                  backgroundColor: AppTheme.lightGray,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Day list
        Expanded(
          child: courseDetail.days.isEmpty
              ? Center(
                  child: Text(
                    'No days found for this course.',
                    style: GoogleFonts.inter(
                      color: AppTheme.coolGray,
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: courseDetail.days.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final day = courseDetail.days[index];
                    final enrolledDate = DateTime(
                      enrolledAt.year,
                      enrolledAt.month,
                      enrolledAt.day,
                    );
                    final today = DateTime.now();
                    final todayDate = DateTime(
                      today.year,
                      today.month,
                      today.day,
                    );
                    final unlockDate = enrolledDate.add(
                      Duration(days: day.dayNumber - 1),
                    );
                    final isUnlocked = !todayDate.isBefore(unlockDate);
                    final isCompleted = progress.completedDays.contains(
                      day.dayNumber,
                    );
                    final isToday = unlockDate == todayDate;
                    final isExpanded = _expandedDay == day.dayNumber;

                    return _buildDayCard(
                      context,
                      day: day,
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      isToday: isToday,
                      isExpanded: isExpanded,
                      unlockDate: unlockDate,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDayCard(
    BuildContext context, {
    required CourseDayModel day,
    required bool isUnlocked,
    required bool isCompleted,
    required bool isToday,
    required bool isExpanded,
    required DateTime unlockDate,
  }) {
    Color cardBg = Colors.white;
    Color borderCol = const Color(0xFFF1F3F5);

    if (isToday && isUnlocked && !isCompleted) {
      cardBg = AppTheme.primaryGreen.withAlpha(8);
      borderCol = AppTheme.primaryGreen.withAlpha(76);
    }

    final totalDuration = day.videos.fold<int>(
      0,
      (sum, v) => sum + v.durationSeconds,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderCol,
          width: (isToday && isUnlocked && !isCompleted) ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day header row
          InkWell(
            onTap: isUnlocked
                ? () => setState(() {
                    _expandedDay = isExpanded ? null : day.dayNumber;
                  })
                : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // State circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.primaryGreen
                          : (!isUnlocked
                                ? AppTheme.lightGray
                                : AppTheme.primaryGreen.withAlpha(25)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : (!isUnlocked
                                ? Icons.lock_outline_rounded
                                : Icons.play_arrow_rounded),
                      color: isCompleted
                          ? Colors.white
                          : (!isUnlocked
                                ? AppTheme.coolGray
                                : AppTheme.primaryGreen),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.title != null && day.title!.isNotEmpty
                              ? 'Day ${day.dayNumber}: ${day.title}'
                              : 'Day ${day.dayNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: !isUnlocked
                                ? AppTheme.coolGray
                                : AppTheme.darkSlate,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _daySubtitle(
                            isCompleted,
                            isToday,
                            isUnlocked,
                            unlockDate,
                            videoCount: day.videos.length,
                            totalSeconds: totalDuration,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isCompleted
                                ? AppTheme.primaryGreen
                                : (isToday && isUnlocked
                                      ? AppTheme.accentGold
                                      : AppTheme.coolGray),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chevron or lock
                  if (isUnlocked)
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.coolGray,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),

          // Expanded video list
          if (isExpanded && day.videos.isNotEmpty)
            _buildVideoList(context, day),
        ],
      ),
    );
  }

  String _daySubtitle(
    bool isCompleted,
    bool isToday,
    bool isUnlocked,
    DateTime unlockDate, {
    required int videoCount,
    required int totalSeconds,
  }) {
    if (isCompleted) return 'Completed';
    if (!isUnlocked) {
      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return 'Unlocks ${unlockDate.day} ${months[unlockDate.month]}';
    }
    if (isToday) return 'Today\'s practice';
    final parts = <String>[];
    if (videoCount > 0) {
      parts.add('$videoCount video${videoCount > 1 ? 's' : ''}');
    }
    if (totalSeconds > 0) parts.add('${(totalSeconds / 60).round()}m');
    return parts.isNotEmpty ? parts.join(' · ') : 'Available';
  }

  Widget _buildVideoList(BuildContext context, CourseDayModel day) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F5)),
        ...day.videos.asMap().entries.map((entry) {
          final index = entry.key;
          final video = entry.value;
          final isLast = index == day.videos.length - 1;
          return _buildVideoTile(context, video, day, isLast: isLast);
        }),
      ],
    );
  }

  Widget _buildVideoTile(
    BuildContext context,
    VideoModel video,
    CourseDayModel day, {
    required bool isLast,
  }) {
    final isYoga = video.category == 'yoga';
    final durationText = video.durationSeconds > 0
        ? '${(video.durationSeconds / 60).round()}m'
        : '';

    return InkWell(
      onTap: () => _playVideo(context, video, day),
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isYoga
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                isYoga ? 'assets/icon_asana.png' : 'assets/icon_kriya.png',
                width: 20,
                height: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Title + duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkSlate,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (durationText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      durationText,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.coolGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Play button
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppTheme.primaryGreen,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playVideo(BuildContext context, VideoModel video, CourseDayModel day) {
    context.push(
      '/play',
      extra: {
        'courseId': widget.courseId,
        'dayNumber': day.dayNumber,
        'videoId': video.id,
        'videoSource': video.videoSource,
        'youtubeVideoId': video.youtubeVideoId ?? '',
        'bunnyVideoId': video.bunnyVideoId,
        'bunnyLibraryId': video.bunnyLibraryId,
        'videoTitle': video.title,
      },
    );
  }
}
