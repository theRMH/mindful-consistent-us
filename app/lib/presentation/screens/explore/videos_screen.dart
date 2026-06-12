import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/free_videos_provider.dart';

final videoCategoryProvider = StateProvider<String>((ref) => 'Yoga');

class VideosScreen extends ConsumerWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(authProvider).user == null;
    final fvState = ref.watch(freeVideosProvider);
    final activeCategory = ref.watch(videoCategoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: fvState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : isGuest
                      ? _buildGuestContent(context, fvState.videos)
                      : _buildRegisteredContent(context, ref, fvState.videos, activeCategory),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Text(
            'Videos',
            style: GoogleFonts.inter(
              color: AppTheme.figmaGreen,
              fontSize: 20,
              fontWeight: AppFontWeights.bold,
            ),
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
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: AppTheme.figmaGreen,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Text(
              '30 days Yoga Course',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: AppFontSizes.bodyMedium,
                fontWeight: AppFontWeights.semiBold,
              ),
            ),
          ),
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
          ...videos.map((video) => Padding(
                padding: const EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.xl),
                child: _buildFreeVideoCard(
                  context,
                  video: video,
                  onTap: () => _showRegisterPrompt(context),
                ),
              )),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // ─── Registered Content ───────────────────────────────────────────────────

  Widget _buildRegisteredContent(
    BuildContext context,
    WidgetRef ref,
    List<FreeVideoModel> videos,
    String activeCategory,
  ) {
    final filtered = videos
        .where((v) =>
            activeCategory == 'Yoga'
                ? (v.category ?? '').toLowerCase().contains('yoga')
                : !(v.category ?? '').toLowerCase().contains('yoga'))
        .toList();

    final display = filtered.isNotEmpty ? filtered : videos;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Expanded(
                  child: _buildCategoryChip(
                    ref, 'Yoga', 'Mind • Flexibility • Strength',
                    activeCategory == 'Yoga',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildCategoryChip(
                    ref, 'General Workout', 'Strength • Mobility • Cardio',
                    activeCategory == 'General Workout',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Free Sessions',
                  style: GoogleFonts.inter(
                    fontSize: AppFontSizes.h3,
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
                  for (int i = 0; i < display.length; i++) ...[
                    _buildSessionTile(context, display[i], i, display.length),
                    if (i < display.length - 1)
                      const Divider(height: 1, color: Color(0xFFF0F0F0), indent: 72),
                  ],
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

          // View Free Videos button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: GestureDetector(
              onTap: () => context.push('/free-videos'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppTheme.figmaGreen,
                  borderRadius: BorderRadius.circular(AppRadii.xxl),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_circle_outline_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View Free Videos',
                            style: GoogleFonts.inter(
                              fontSize: AppFontSizes.bodyLarge,
                              fontWeight: AppFontWeights.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Watch anytime, no program needed',
                            style: GoogleFonts.inter(
                              fontSize: AppFontSizes.bodyMedium,
                              color: Colors.white.withAlpha(178),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
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
            // Status circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppTheme.lightGray, width: 2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
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
      WidgetRef ref, String label, String subtext, bool isActive) {
    return GestureDetector(
      onTap: () => ref.read(videoCategoryProvider.notifier).state = label,
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
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 200,
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.figmaGreen,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
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

  void _showRegisterPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(Icons.lock_outline_rounded,
                color: AppTheme.figmaGreen, size: 48),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Create a free account to watch',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppFontSizes.h3,
                fontWeight: AppFontWeights.bold,
                color: AppTheme.figmaCharcoal,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sign up for free and unlock all videos,\nprograms, and tracking features.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppFontSizes.bodyMedium,
                color: AppTheme.coolGray,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.figmaGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Sign Up for Free',
                  style: GoogleFonts.inter(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/login');
              },
              child: Text(
                'Already have an account? Log In',
                style: GoogleFonts.inter(
                  color: AppTheme.figmaGreen,
                  fontWeight: AppFontWeights.bold,
                  fontSize: AppFontSizes.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
