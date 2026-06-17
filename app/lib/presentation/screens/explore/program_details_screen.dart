import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/course_detail_provider.dart';
import '../../widgets/login_prompt.dart';
import '../../../core/config/theme.dart';
import '../../../data/models/course_model.dart';

bool _isNetworkPath(String path) =>
    path.startsWith('http://') || path.startsWith('https://');

class ProgramDetailsScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  final String? courseTitle;
  final String? courseImagePath;
  final String? courseId;

  const ProgramDetailsScreen({
    super.key,
    this.showBackButton = true,
    this.courseTitle,
    this.courseImagePath,
    this.courseId,
  });

  @override
  ConsumerState<ProgramDetailsScreen> createState() =>
      _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends ConsumerState<ProgramDetailsScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bool isGuest = authState.user == null;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final String title = widget.courseTitle ?? '30 Days Yoga Course';
    final String imagePath =
        widget.courseImagePath ?? 'assets/course_30_days.png';
    final courseId = widget.courseId ?? '30-days-yoga';

    final coursesState = ref.watch(coursesProvider);
    final progressState = ref.watch(progressProvider);
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final courseDetail = courseAsync.valueOrNull;
    final List<CourseDayModel> courseDays = courseDetail?.days ?? [];
    final List<CourseDayModel> visibleDays = courseDays
        .where((day) => day.videos.isNotEmpty)
        .toList();
    final List<CourseDayModel> displayedDays = _isExpanded
        ? visibleDays
        : visibleDays.take(5).toList();
    final completedVideoIds = progressState.completedVideoIds;
    final bool isEnrolled = coursesState.enrolledCourseIds.contains(courseId);
    final bool isEnrollLoading = coursesState.isLoading;
    final enrollment = coursesState.enrollmentForCourse(courseId);
    final totalDays = courseDays.isNotEmpty ? courseDays.length : 30;
    final difficulty = courseDetail?.difficulty ?? 'Beginner';
    final avgDailyMins = courseDetail?.avgDailyMins ?? 30;
    // Calendar day from enrollment date
    final enrolledAt = (enrollment?.enrolledAt ?? DateTime.now()).toLocal();
    final enrolledDate = DateTime(enrolledAt.year, enrolledAt.month, enrolledAt.day);
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final calendarDayNumber = todayDate.difference(enrolledDate).inDays + 1;
    // Active day: which day to watch next — use calendar day, not completedDays count
    final todayDayNumber = calendarDayNumber.clamp(1, totalDays);
    final courseExpired = isEnrolled && calendarDayNumber > totalDays;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,

      // Floating Action Button for guests (Login) and logged-in users (Enroll only)
      floatingActionButton: (!isGuest && isEnrolled)
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isEnrollLoading
                      ? null
                      : () {
                          if (isGuest) {
                            showLoginPrompt(context);
                          } else {
                            context.push('/cart?courseId=$courseId');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: AppTheme.primaryGreen.withAlpha(102),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: isEnrollLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white24,
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Enroll Now',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Stack(
        children: [
          // 1. Scrollable Page Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: isGuest ? 90 : 20),
            child: Stack(
              children: [
                // Top Image
                Image.asset(
                  imagePath,
                  height: 360,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 360,
                    width: double.infinity,
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(
                      Icons.self_improvement,
                      color: AppTheme.primaryGreen,
                      size: 80,
                    ),
                  ),
                ),

                // Overlapping details card
                Column(
                  children: [
                    const SizedBox(height: 280),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          topRight: Radius.circular(50.0),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 28.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Centered Title
                          Center(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Green Tags Pill
                          Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$totalDays days',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 18,
                                  color: Colors.white.withAlpha(76),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.bar_chart_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        difficulty,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 18,
                                  color: Colors.white.withAlpha(76),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${avgDailyMins}m /day',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Description Section
                          Text(
                            'About this program',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.figmaCharcoal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            courseDetail?.description?.isNotEmpty == true
                                ? courseDetail!.description!
                                : 'A structured program designed to build strength, improve flexibility, and create a lasting daily practice.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.45,
                              color: const Color(0xFF5B5B5B),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Instructor Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x02000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/avatar_priya.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Deepa',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.darkSlate,
                                        ),
                                      ),
                                      Text(
                                        'Certified Yoga Instructor',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.figmaGreen,
                                        ),
                                      ),
                                      Text(
                                        '8+ Years of Experience',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.coolGray,
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
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppTheme.figmaGreen.withAlpha(76),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      color: AppTheme.figmaGreen,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Sessions Header & View All Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sessions',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.figmaCharcoal,
                                ),
                              ),
                              if (!_isExpanded &&
                                  visibleDays.length > displayedDays.length)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isExpanded = true;
                                    });
                                  },
                                  child: Text(
                                    'View All',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.figmaCharcoal,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Sessions Outline List
                          courseAsync.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : displayedDays.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Text(
                                    'No sessions available yet.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppTheme.coolGray,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: displayedDays.map((dayModel) {
                                    final int dayNumber = dayModel.dayNumber;
                                    final isDayCompleted = progressState.completedDays.contains(dayNumber);
                                    final isPlayable =
                                        isEnrolled && !courseExpired && dayNumber == todayDayNumber;
                                    final isMissed = isEnrolled && !courseExpired &&
                                        !isDayCompleted && dayNumber < calendarDayNumber &&
                                        dayNumber != todayDayNumber;
                                    final String dayStr = dayNumber
                                        .toString()
                                        .padLeft(2, '0');
                                    final dayVideos = dayModel.videos;
                                    final totalSecs = dayVideos.fold<int>(
                                      0,
                                      (sum, v) => sum + v.durationSeconds,
                                    );
                                    return SessionDayTile(
                                      index: dayStr,
                                      title: dayModel.title?.isNotEmpty == true
                                          ? dayModel.title!
                                          : 'Day $dayNumber',
                                      subtitle:
                                          '${dayVideos.length} ${dayVideos.length == 1 ? 'Session' : 'Sessions'}',
                                      duration: totalSecs > 0
                                          ? '${(totalSecs / 60).round()} Mins'
                                          : '',
                                      isGuest: isGuest,
                                      isEnrolled: isEnrolled,
                                      isPlayable: isPlayable,
                                      isMissed: isMissed,
                                      courseId: courseId,
                                      isCompleted: isDayCompleted,
                                      videos: dayVideos,
                                      completedVideoIds: completedVideoIds,
                                      onTap: () {
                                        if (isGuest) {
                                          showLoginPrompt(context);
                                        } else {
                                          context.push('/course/$courseId');
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Fixed Back Button
          if (widget.showBackButton)
            Positioned(
              top: statusBarHeight + 12,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    if (isGuest) {
                      context.go('/unregistered');
                    } else {
                      context.go('/home');
                    }
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withAlpha(102),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SessionDayTile extends StatefulWidget {
  final String index;
  final String title;
  final String subtitle;
  final String duration;
  final bool isGuest;
  final bool isEnrolled;
  final bool isPlayable;
  final bool isMissed;
  final String courseId;
  final bool isCompleted;
  final List<VideoModel> videos;
  final List<String> completedVideoIds;
  final VoidCallback onTap;

  const SessionDayTile({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.isGuest,
    required this.isEnrolled,
    required this.isPlayable,
    this.isMissed = false,
    required this.courseId,
    required this.isCompleted,
    this.videos = const [],
    this.completedVideoIds = const [],
    required this.onTap,
  });

  @override
  State<SessionDayTile> createState() => _SessionDayTileState();
}

class _SessionDayTileState extends State<SessionDayTile> {
  bool _isExpanded = false;

  // LEFT icon: tick if done, lock if locked, thumbnail otherwise.
  Widget _buildSessionStatusIcon({
    required String iconPath,
    required bool isCompleted,
    required bool isLocked,
  }) {
    if (isCompleted) {
      return Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppTheme.figmaGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
      );
    }

    if (isLocked) {
      return Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEBEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock_outline_rounded, color: Color(0xFFE57373), size: 22),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: _isNetworkPath(iconPath)
            ? Image.network(
                iconPath,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.self_improvement_rounded,
                  color: AppTheme.figmaGreen,
                  size: 24,
                ),
              )
            : Image.asset(
                iconPath,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.self_improvement_rounded,
                  color: AppTheme.figmaGreen,
                  size: 24,
                ),
              ),
      ),
    );
  }

  // RIGHT play button: green solid when active, grey outlined otherwise.
  Widget _buildPlayButton({required bool isActive}) {
    if (isActive) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.figmaGreen,
        ),
        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
      );
    }
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.coolGray, width: 1.0),
      ),
      child: const Icon(Icons.play_arrow_rounded, color: AppTheme.coolGray, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> subSessions = [
      {'title': 'Asanas', 'duration': '10 mins'},
      {'title': 'Pranayama', 'duration': '20 mins'},
      {'title': 'Kriya', 'duration': '35 mins'},
      {'title': 'Pranayama', 'duration': '20 mins'},
      {'title': 'Kriya', 'duration': '35 mins'},
    ];
    final useRealVideos = widget.videos.isNotEmpty;

    // Compute header totals from actual rendered sessions
    final int sessionCount = useRealVideos
        ? widget.videos.length
        : subSessions.length;
    final int totalMins = useRealVideos
        ? widget.videos.fold<int>(
            0, (sum, v) => sum + v.durationSeconds ~/ 60)
        : subSessions.fold<int>(0, (sum, s) {
            final n = int.tryParse(
                  s['duration']!.replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0;
            return sum + n;
          });
    final headerSubtitle =
        '$sessionCount ${sessionCount == 1 ? 'Session' : 'Sessions'}';
    final headerDuration = totalMins > 0 ? '$totalMins Mins' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isMissed ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isMissed
              ? const Color(0xFFFFCDD2)
              : (_isExpanded ? const Color(0xFFE2E8F0) : const Color(0xFFC8D6CE)),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isExpanded ? AppTheme.figmaGreen : Colors.white,
              borderRadius: _isExpanded
                  ? BorderRadius.circular(16)
                  : BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: _isExpanded
                    ? BorderRadius.circular(16)
                    : BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // Index Badge — shows tick when day is completed
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isCompleted && !_isExpanded
                              ? AppTheme.figmaGreen
                              : Colors.transparent,
                          border: Border.all(
                            width: 1.5,
                            color: _isExpanded
                                ? Colors.white.withAlpha(153)
                                : AppTheme.figmaGreen,
                          ),
                        ),
                        child: Center(
                          child: widget.isCompleted && !_isExpanded
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : Text(
                                  widget.index,
                                  style: GoogleFonts.inter(
                                    color: _isExpanded
                                        ? Colors.white
                                        : AppTheme.figmaGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: _isExpanded
                                    ? Colors.white
                                    : AppTheme.darkSlate,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  headerSubtitle,
                                  style: GoogleFonts.inter(
                                    color: _isExpanded
                                        ? Colors.white.withAlpha(204)
                                        : AppTheme.figmaGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                                if (headerDuration.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.access_time_outlined,
                                    size: 11,
                                    color: _isExpanded
                                        ? Colors.white.withAlpha(204)
                                        : AppTheme.coolGray,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    headerDuration,
                                    style: GoogleFonts.inter(
                                      color: _isExpanded
                                          ? Colors.white.withAlpha(204)
                                          : AppTheme.coolGray,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Dropdown chevron
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isExpanded
                                ? Colors.white
                                : AppTheme.figmaGreen,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: _isExpanded
                                ? Colors.white
                                : AppTheme.figmaGreen,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sub-sessions
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: useRealVideos
                    ? List.generate(widget.videos.length, (subIndex) {
                        final video = widget.videos[subIndex];
                        final isVideoCompleted = widget.completedVideoIds.contains(video.id);
                        final iconPath = video.thumbnailUrl?.isNotEmpty == true
                            ? video.thumbnailUrl!
                            : 'assets/icon_asana.png';
                        return InkWell(
                          onTap: () {
                            if (widget.isGuest) {
                              widget.onTap();
                            } else if (!widget.isEnrolled) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enroll to view sessions')),
                              );
                            } else if (!widget.isPlayable) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('This session is locked today')),
                              );
                            } else {
                              context.push(
                                '/play',
                                extra: {
                                  'courseId': widget.courseId,
                                  'dayNumber': int.tryParse(widget.index) ?? 1,
                                  'videoId': video.id,
                                  'videoSource': video.videoSource,
                                  'youtubeVideoId': video.youtubeVideoId ?? '',
                                  'bunnyVideoId': video.bunnyVideoId,
                                  'bunnyLibraryId': video.bunnyLibraryId,
                                  'videoTitle': video.title,
                                },
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              children: [
                                // LEFT: tick if done, lock if locked, thumbnail if active
                                _buildSessionStatusIcon(
                                  iconPath: iconPath,
                                  isCompleted: isVideoCompleted,
                                  isLocked: widget.isEnrolled && !widget.isPlayable,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.darkSlate,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        () {
                                          final dur = video.durationSeconds > 0
                                              ? '${video.durationSeconds ~/ 60} mins'
                                              : '';
                                          final status = isVideoCompleted
                                              ? 'Completed'
                                              : (widget.isPlayable ? 'Up Next' : '');
                                          if (dur.isEmpty) return status;
                                          if (status.isEmpty) return dur;
                                          return '$dur • $status';
                                        }(),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isVideoCompleted
                                              ? AppTheme.figmaGreen
                                              : (widget.isPlayable
                                                  ? const Color(0xFFE67E22)
                                                  : AppTheme.coolGray),
                                        ),
                                      ),
                                      if (video.description != null &&
                                          video.description!.isNotEmpty) ...[
                                        const SizedBox(height: 1),
                                        Text(
                                          video.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: AppTheme.coolGray,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // RIGHT: always play button; green if active, grey otherwise
                                _buildPlayButton(isActive: widget.isPlayable && !isVideoCompleted),
                              ],
                            ),
                          ),
                        );
                      })
                    : List.generate(subSessions.length, (subIndex) {
                        final session = subSessions[subIndex];

                        String iconPath = '';
                        String description = '';
                        if (subIndex == 0) {
                          iconPath = 'assets/icon_asana.png';
                          description = 'Build Strength & Flexibility';
                        } else if (subIndex == 1 || subIndex == 3) {
                          iconPath = 'assets/icon_lungs.png';
                          description = 'Breath. Calm. Energize.';
                        } else {
                          iconPath = 'assets/icon_kriya.png';
                          description = 'Activate & Strengthen';
                        }

                        return InkWell(
                          onTap: () {
                            if (widget.isGuest) {
                              widget.onTap();
                            } else if (!widget.isEnrolled) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enroll to view sessions',
                                  ),
                                ),
                              );
                            } else {
                              context.push(
                                '/play',
                                extra: {
                                  'courseId': widget.courseId,
                                  'dayNumber': int.tryParse(widget.index) ?? 1,
                                  'videoTitle': session['title'],
                                },
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      iconPath,
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session['title']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.darkSlate,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        session['duration']!,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.figmaGreen,
                                        ),
                                      ),
                                      if (description.isNotEmpty) ...[
                                        const SizedBox(height: 1),
                                        Text(
                                          description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: AppTheme.coolGray,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.figmaGreen,
                                      width: 1.0,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.figmaGreen,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        color: AppTheme.figmaGreen,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Custom Icon Painters
class AsanaIconPainter extends CustomPainter {
  final Color color;
  const AsanaIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final double w = size.width;
    final double h = size.height;

    canvas.drawCircle(Offset(w * 0.65, h * 0.25), w * 0.08, paint);

    final spine = Path();
    spine.moveTo(w * 0.65, h * 0.33);
    spine.quadraticBezierTo(w * 0.50, h * 0.35, w * 0.40, h * 0.50);
    canvas.drawPath(spine, paint);

    canvas.drawLine(
      Offset(w * 0.58, h * 0.35),
      Offset(w * 0.35, h * 0.60),
      paint,
    );

    final leg = Path();
    leg.moveTo(w * 0.40, h * 0.50);
    leg.lineTo(w * 0.75, h * 0.75);
    leg.moveTo(w * 0.40, h * 0.50);
    leg.lineTo(w * 0.25, h * 0.75);
    leg.lineTo(w * 0.45, h * 0.75);
    canvas.drawPath(leg, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LungsIconPainter extends CustomPainter {
  final Color color;
  const LungsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    canvas.drawLine(Offset(cx, h * 0.2), Offset(cx, h * 0.45), paint);
    canvas.drawLine(Offset(cx, h * 0.45), Offset(w * 0.38, h * 0.55), paint);
    canvas.drawLine(Offset(cx, h * 0.45), Offset(w * 0.62, h * 0.55), paint);

    final leftLobe = Path();
    leftLobe.moveTo(cx - 2, h * 0.38);
    leftLobe.quadraticBezierTo(w * 0.20, h * 0.35, w * 0.18, h * 0.60);
    leftLobe.quadraticBezierTo(w * 0.20, h * 0.80, w * 0.42, h * 0.78);
    leftLobe.quadraticBezierTo(w * 0.45, h * 0.65, cx - 2, h * 0.45);
    canvas.drawPath(leftLobe, paint);

    final rightLobe = Path();
    rightLobe.moveTo(cx + 2, h * 0.38);
    rightLobe.quadraticBezierTo(w * 0.80, h * 0.35, w * 0.82, h * 0.60);
    rightLobe.quadraticBezierTo(w * 0.80, h * 0.80, w * 0.58, h * 0.78);
    rightLobe.quadraticBezierTo(w * 0.55, h * 0.65, cx + 2, h * 0.45);
    canvas.drawPath(rightLobe, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KriyaIconPainter extends CustomPainter {
  final Color color;
  const KriyaIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    canvas.drawCircle(Offset(cx, h * 0.35), w * 0.08, paint);

    final body = Path();
    body.moveTo(cx, h * 0.43);
    body.lineTo(cx, h * 0.65);
    body.moveTo(cx - w * 0.20, h * 0.75);
    body.quadraticBezierTo(cx, h * 0.78, cx + w * 0.20, h * 0.75);
    body.quadraticBezierTo(cx, h * 0.62, cx - w * 0.20, h * 0.75);
    canvas.drawPath(body, paint);

    canvas.drawLine(
      Offset(cx - w * 0.08, h * 0.48),
      Offset(cx - w * 0.16, h * 0.65),
      paint,
    );
    canvas.drawLine(
      Offset(cx + w * 0.08, h * 0.48),
      Offset(cx + w * 0.16, h * 0.65),
      paint,
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, h * 0.35),
        width: w * 0.32,
        height: h * 0.32,
      ),
      -3.14159 * 0.8,
      3.14159 * 0.6,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, h * 0.35),
        width: w * 0.48,
        height: h * 0.48,
      ),
      -3.14159 * 0.8,
      3.14159 * 0.6,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
