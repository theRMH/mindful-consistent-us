import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/api_service.dart';
import '../../providers/courses_provider.dart';

// 20 distinct avatar background colors
const List<Color> _avatarPalette = [
  Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFFFF5722),
  Color(0xFF9C27B0), Color(0xFFFF9800), Color(0xFF00BCD4),
  Color(0xFFE91E63), Color(0xFF3F51B5), Color(0xFF009688),
  Color(0xFFF44336), Color(0xFF8BC34A), Color(0xFF673AB7),
  Color(0xFFFFC107), Color(0xFF795548), Color(0xFF607D8B),
  Color(0xFF1976D2), Color(0xFF388E3C), Color(0xFFD32F2F),
  Color(0xFF7B1FA2), Color(0xFFE64A19),
];

class CommunityLeaderboardScreen extends ConsumerStatefulWidget {
  const CommunityLeaderboardScreen({super.key});

  @override
  ConsumerState<CommunityLeaderboardScreen> createState() =>
      _CommunityLeaderboardScreenState();
}

class _CommunityLeaderboardScreenState
    extends ConsumerState<CommunityLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _allTimeFuture;
  Future<Map<String, dynamic>>? _groupFuture;
  String? _selectedGroupCourseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allTimeFuture = ApiService().getLeaderboard();

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _initGroupTab();
      }
    });
  }

  void _initGroupTab() {
    final courses = ref.read(coursesProvider).activeCourses;
    if (courses.isEmpty) return;
    final courseId = _selectedGroupCourseId ?? courses.first.id;
    _selectedGroupCourseId ??= courseId;
    if (_groupFuture == null) {
      setState(() {
        _groupFuture = ApiService().getLeaderboard(courseId: courseId);
      });
    }
  }

  void _loadGroupForCourse(String courseId) {
    setState(() {
      _selectedGroupCourseId = courseId;
      _groupFuture = ApiService().getLeaderboard(courseId: courseId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 0),
            decoration: const BoxDecoration(
              color: AppTheme.figmaGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppTheme.figmaGreen,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Community Leaderboard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Earn points by watching videos, keeping streaks & hitting step goals.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withAlpha(210),
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withAlpha(150),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 14),
                  tabs: const [
                    Tab(text: 'All Time'),
                    Tab(text: 'Your Group'),
                  ],
                ),
              ],
            ),
          ),

          // Tab Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(_allTimeFuture, isGroup: false),
                _buildGroupTab(),
              ],
            ),
          ),

          // Points formula footer
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF0F8F1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.figmaGreen.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      color: AppTheme.figmaGreen, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppTheme.coolGray, height: 1.6),
                      children: const [
                        TextSpan(
                          text: 'How points work:  ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '50 pts watch ≥1 video  ·  '),
                        TextSpan(text: '30 pts all videos done  ·  '),
                        TextSpan(text: '10 pts × streak  ·  '),
                        TextSpan(text: '25 pts steps goal reached'),
                      ],
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

  Widget _buildGroupTab() {
    final activeCourses = ref.watch(coursesProvider).activeCourses;

    if (activeCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group_outlined,
                size: 56,
                color: AppTheme.figmaGreen.withAlpha(80),
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Program',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.figmaCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enroll in a program to see how you rank against others on the same journey.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.coolGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/programs?tab=explore'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.figmaGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Browse Programs',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final selectedId = _selectedGroupCourseId ?? activeCourses.first.id;
    _groupFuture ??= ApiService().getLeaderboard(courseId: selectedId);

    return Column(
      children: [
        // Course filter chips
        if (activeCourses.length > 1)
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: activeCourses.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final course = activeCourses[i];
                final isSelected = course.id == selectedId;
                return GestureDetector(
                  onTap: () => _loadGroupForCourse(course.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.figmaGreen
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.figmaGreen
                            : const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Text(
                      course.title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.coolGray,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          const SizedBox(height: 12),

        Expanded(
          child: _buildLeaderboardTab(_groupFuture!, isGroup: true),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab(
      Future<Map<String, dynamic>> future, {required bool isGroup}) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.figmaGreen),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load leaderboard',
              style: GoogleFonts.inter(color: AppTheme.coolGray),
            ),
          );
        }

        final data = snapshot.data!;
        final entries = (data['entries'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        final userRank = data['userRank'] as int?;
        final currentUserEntry =
            entries.where((e) => e['isCurrentUser'] == true).firstOrNull;

        if (entries.isEmpty) {
          return Center(
            child: Text(
              isGroup
                  ? 'No one else in your group yet. Keep going!'
                  : 'No entries yet. Complete a session to appear here!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.coolGray,
                fontSize: 14,
              ),
            ),
          );
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            if (entries.length >= 3) _buildPodium(entries),
            const SizedBox(height: 16),
            ...List.generate(entries.length, (i) => _buildRow(entries[i], i)),
            if (currentUserEntry == null &&
                userRank != null &&
                userRank > 10) ...[
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 8),
              _buildMyRankBanner(userRank),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> entries) {
    final top3 = entries.take(3).toList();
    final order = [top3[1], top3[0], top3[2]];
    final orderIndex = [1, 0, 2];
    final heights = [80.0, 110.0, 60.0];
    final medalColors = [
      const Color(0xFFC0C0C0),
      const Color(0xFFFFD700),
      const Color(0xFFCD7F32),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final e = order[i];
        final entryIndex = orderIndex[i];
        final rank = e['rank'] as int;
        final isFirst = rank == 1;
        final name = _displayName(e['name']);
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(
                name,
                e['avatarUrl'] as String?,
                size: isFirst ? 56 : 44,
                border: medalColors[i],
                colorIndex: entryIndex,
              ),
              const SizedBox(height: 6),
              Text(
                name.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.figmaCharcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${e['score']?.toStringAsFixed(0) ?? '0'} pts',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.figmaGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: heights[i],
                width: double.infinity,
                decoration: BoxDecoration(
                  color: i == 1
                      ? AppTheme.figmaGreen
                      : AppTheme.figmaGreen.withAlpha(60 + i * 20),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: i == 1
                          ? Colors.white
                          : AppTheme.figmaGreen.withAlpha(220),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRow(Map<String, dynamic> e, int listIndex) {
    final isCurrentUser = e['isCurrentUser'] as bool? ?? false;
    final rank = e['rank'] as int? ?? 0;
    final score = (e['score'] as num?)?.toDouble() ?? 0;
    final streak = e['streak'] as int? ?? 0;
    final daysCompleted = e['daysCompleted'] as int? ?? 0;
    final name = _displayName(e['name']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            isCurrentUser ? AppTheme.figmaGreen.withAlpha(15) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(
                color: AppTheme.figmaGreen.withAlpha(100), width: 1.5)
            : Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rank <= 3
                    ? AppTheme.figmaGreen
                    : AppTheme.figmaMutedGray,
              ),
            ),
          ),
          _buildAvatar(
            name,
            e['avatarUrl'] as String?,
            size: 38,
            colorIndex: listIndex,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name + (isCurrentUser ? ' (You)' : ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.figmaCharcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$daysCompleted days · 🔥 $streak streak',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.coolGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${score.toStringAsFixed(0)} pts',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.figmaGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankBanner(int rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.figmaGreen.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.figmaGreen.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded,
              color: AppTheme.figmaGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your rank: #$rank',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.figmaCharcoal,
              ),
            ),
          ),
          Text(
            'Keep going!',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.figmaGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? url,
      {double size = 38, Color? border, int colorIndex = 0}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final bgColor = _avatarPalette[colorIndex % _avatarPalette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor.withAlpha(40),
        border: border != null ? Border.all(color: border, width: 2) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, trace) => _initials(initial, size, bgColor),
              )
            : _initials(initial, size, bgColor),
      ),
    );
  }

  Widget _initials(String letter, double size, Color bgColor) {
    return Container(
      alignment: Alignment.center,
      color: bgColor.withAlpha(40),
      child: Text(
        letter,
        style: GoogleFonts.inter(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: bgColor,
        ),
      ),
    );
  }

  String _displayName(dynamic raw) {
    final s = raw?.toString().trim() ?? '';
    return s.isNotEmpty ? s : 'Anonymous';
  }
}
