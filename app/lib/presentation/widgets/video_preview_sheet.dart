import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/config/theme.dart';

/// Shows a half-screen bottom sheet preview of a video.
/// The user can watch it inline (portrait) or tap "Watch Full Screen"
/// to push to the full-screen landscape player at /play.
void showVideoPreview(BuildContext context, Map<String, dynamic> extra) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VideoPreviewSheet(extra: extra),
  );
}

class _VideoPreviewSheet extends StatefulWidget {
  final Map<String, dynamic> extra;
  const _VideoPreviewSheet({required this.extra});

  @override
  State<_VideoPreviewSheet> createState() => _VideoPreviewSheetState();
}

class _VideoPreviewSheetState extends State<_VideoPreviewSheet> {
  YoutubePlayerController? _ytController;

  String get _videoSource => widget.extra['videoSource'] as String? ?? 'youtube';
  String get _youtubeVideoId => widget.extra['youtubeVideoId'] as String? ?? '';
  String get _videoTitle => widget.extra['videoTitle'] as String? ?? '';
  String? get _thumbnailUrl => widget.extra['thumbnailUrl'] as String?;

  bool get _isYoutube => _videoSource == 'youtube' && _youtubeVideoId.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isYoutube) {
      _ytController = YoutubePlayerController(
        initialVideoId: _youtubeVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  void _openFullScreen() {
    Navigator.of(context).pop();
    context.push('/play', extra: widget.extra);
  }

  Future<void> _openCastSettings() async {
    if (Platform.isAndroid) {
      const channel = MethodChannel('com.consistentus/cast');
      await channel.invokeMethod('openCastSettings');
    } else {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Screen Mirroring',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                '1. Swipe down from the top-right corner to open Control Center\n'
                '2. Tap "Screen Mirroring"\n'
                '3. Select your Apple TV or AirPlay device',
                style: GoogleFonts.inter(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Player or thumbnail
              _isYoutube
                  ? YoutubePlayer(
                      controller: _ytController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: AppTheme.figmaGreen,
                      progressColors: const ProgressBarColors(
                        playedColor: AppTheme.figmaGreen,
                        handleColor: AppTheme.figmaGreen,
                      ),
                    )
                  : _buildThumbnail(),

              // Scrollable info below
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with cast button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _videoTitle,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.figmaCharcoal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _openCastSettings,
                            icon: const Icon(Icons.cast, color: AppTheme.figmaGreen),
                            tooltip: 'Cast / Screen Mirror',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Maintain focus, sync your breath with movement, and hold postures gracefully. Keep practicing daily to build consistency.',
                        style: GoogleFonts.inter(
                          color: AppTheme.figmaMutedGray,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Watch Full Screen button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _openFullScreen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.figmaGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                            ),
                          ),
                          icon: const Icon(Icons.fullscreen_rounded, size: 22),
                          label: Text(
                            'Watch Full Screen',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThumbnail() {
    final Widget placeholder = Container(
      height: 200,
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.play_circle_outline, color: Colors.white, size: 60),
      ),
    );
    if (_thumbnailUrl != null && _thumbnailUrl!.isNotEmpty) {
      return Image.network(
        _thumbnailUrl!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, st) => placeholder,
      );
    }
    return placeholder;
  }
}
