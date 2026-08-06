import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  String _period = 'week'; // 'week' | 'month' | 'all'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allTimeFuture = ApiService().getLeaderboard(period: _period);

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
        _groupFuture = ApiService().getLeaderboard(courseId: courseId, period: _period);
      });
    }
  }

  void _loadGroupForCourse(String courseId) {
    setState(() {
      _selectedGroupCourseId = courseId;
      _groupFuture = ApiService().getLeaderboard(courseId: courseId, period: _period);
    });
  }

  void _setPeriod(String period) {
    if (_period == period) return;
    setState(() {
      _period = period;
      _allTimeFuture = ApiService().getLeaderboard(period: period);
      if (_selectedGroupCourseId != null) {
        _groupFuture = ApiService().getLeaderboard(courseId: _selectedGroupCourseId, period: period);
      } else {
        _groupFuture = null; // will reload when tab switches
      }
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

          const SizedBox(height: 12),
          // Period filter pills
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPeriodPill('week', 'This Week'),
                const SizedBox(width: 8),
                _buildPeriodPill('month', 'This Month'),
                const SizedBox(width: 8),
                _buildPeriodPill('all', 'All Time'),
              ],
            ),
          ),
          const SizedBox(height: 8),

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

  Widget _buildPeriodPill(String value, String label) {
    final isSelected = _period == value;
    return GestureDetector(
      onTap: () => _setPeriod(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.figmaGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.figmaGreen : const Color(0xFFDDDDDD),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.coolGray,
          ),
        ),
      ),
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
        final outOfRankEntry = data['currentUserEntry'] != null
            ? data['currentUserEntry'] as Map<String, dynamic>
            : null;
        // Find user inside top-10
        final topUserEntry =
            entries.where((e) => e['isCurrentUser'] == true).firstOrNull;

        // Gap to the person just ahead (for motivational note)
        int? ptsToNext;
        if (outOfRankEntry != null && entries.isNotEmpty) {
          final userScore = (outOfRankEntry['score'] as num?)?.toDouble() ?? 0;
          final lastTopScore =
              (entries.last['score'] as num?)?.toDouble() ?? 0;
          final diff = (lastTopScore - userScore).ceil();
          if (diff > 0) ptsToNext = diff;
        }

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
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Motivational rank callout
            if (userRank != null) ...[
              const SizedBox(height: 12),
              _buildRankCallout(
                rank: userRank,
                ptsToNext: topUserEntry != null ? null : ptsToNext,
              ),
            ],
            const SizedBox(height: 16),
            if (entries.length >= 3) _buildPodium(entries),
            const SizedBox(height: 16),
            ...List.generate(entries.length, (i) => _buildRow(entries[i], i)),
            // User is outside top 10 â€” show separator + their full row
            if (outOfRankEntry != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '· · ·',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.coolGray,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
                ],
              ),
              const SizedBox(height: 4),
              _buildRow(outOfRankEntry, (outOfRankEntry['rank'] as int) - 1),
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
              if (isFirst)
                const Icon(Icons.workspace_premium_rounded, size: 22, color: Color(0xFFFFD700))
              else
                const SizedBox(height: 22),
              const SizedBox(height: 2),
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.figmaCharcoal,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.figmaGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$daysCompleted days · ',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.coolGray,
                      ),
                    ),
                    const Icon(Icons.local_fire_department_rounded,
                        size: 12, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text(
                      '$streak streak',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.coolGray,
                      ),
                    ),
                  ],
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

  Widget _buildRankCallout({required int rank, int? ptsToNext}) {
    final String label;
    if (rank == 1) {
      label = "You're #1 - incredible!";
    } else if (rank <= 3) {
      label = "You're #$rank - on the podium! Keep it up!";
    } else if (rank <= 10) {
      label = "You're #$rank - inside the top 10!";
    } else if (ptsToNext != null && ptsToNext > 0) {
      label = "You're #$rank · $ptsToNext pts to enter the top 10";
    } else {
      label = "You're #$rank - every session moves you up!";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.figmaGreen.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.figmaGreen.withAlpha(70)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppTheme.figmaGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.figmaCharcoal,
              ),
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
        child: CachedNetworkImage(
          imageUrl: resolveAvatarUrl(url, name),
          fit: BoxFit.cover,
          errorWidget: (ctx, u, err) => _initials(initial, size, bgColor),
        ),
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

