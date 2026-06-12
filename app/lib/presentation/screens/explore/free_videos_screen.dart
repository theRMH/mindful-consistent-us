import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../providers/free_videos_provider.dart';

class FreeVideosScreen extends ConsumerWidget {
  const FreeVideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(freeVideosProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_rounded, color: AppTheme.figmaGreen),
        ),
        title: Text(
          'Free Videos',
          style: GoogleFonts.inter(
            fontWeight: AppFontWeights.bold,
            color: AppTheme.figmaGreen,
            fontSize: AppFontSizes.h3,
          ),
        ),
        centerTitle: false,
      ),
      body: () {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.videos.isEmpty) {
          return Center(
            child: Text(
              'No free videos available yet.',
              style: GoogleFonts.inter(color: AppTheme.figmaMutedGray),
            ),
          );
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Watch anytime, no program needed.',
                style: GoogleFonts.inter(
                  fontSize: AppFontSizes.bodyLarge,
                  color: AppTheme.figmaMutedGray,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ...state.videos.map((video) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: _buildVideoCard(context, video),
                  )),
            ],
          ),
        );
      }(),
    );
  }

  Widget _buildVideoCard(BuildContext context, dynamic video) {
    final title = video.title as String;
    final category = (video.category as String?) ?? '';
    final duration = video.durationLabel as String;
    final imagePath = (video.thumbnailUrl as String?)?.isNotEmpty == true
        ? video.thumbnailUrl as String
        : 'assets/video_morning_flow.png';
    final youtubeVideoId = video.youtubeVideoId as String?;

    return GestureDetector(
      onTap: () {
        if (youtubeVideoId != null && youtubeVideoId.isNotEmpty) {
          context.push('/play', extra: {
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
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
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
                      duration,
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
            title,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: AppFontWeights.bold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            category,
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
