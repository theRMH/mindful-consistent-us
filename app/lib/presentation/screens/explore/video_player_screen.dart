import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/progress_provider.dart';
import '../../../core/config/theme.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final int dayNumber;
  final String? videoId;
  final String videoSource; // 'youtube' | 'bunny'
  final String youtubeVideoId;
  final String? bunnyVideoId;
  final String? bunnyLibraryId;
  final String videoTitle;

  const VideoPlayerScreen({
    super.key,
    required this.courseId,
    required this.dayNumber,
    this.videoId,
    this.videoSource = 'youtube',
    required this.youtubeVideoId,
    this.bunnyVideoId,
    this.bunnyLibraryId,
    required this.videoTitle,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  // YouTube
  YoutubePlayerController? _ytController;
  bool _isPlayerReady = false;

  // BunnyNet
  WebViewController? _webController;

  bool _isCompletedLogged = false;

  bool get _isYoutube => widget.videoSource == 'youtube';

  @override
  void initState() {
    super.initState();
    _lockLandscape();

    if (_isYoutube) {
      _ytController = YoutubePlayerController(
        initialVideoId: widget.youtubeVideoId,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      )..addListener(_ytListener);
    } else {
      final bunnyUrl =
          'https://iframe.mediadelivery.net/embed/'
          '${widget.bunnyLibraryId}/${widget.bunnyVideoId}'
          '?autoplay=true&loop=false&muted=false&preload=true&responsive=true';
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadRequest(Uri.parse(bunnyUrl));
    }
  }

  void _lockLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restorePortrait() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void _ytListener() {
    if (_isPlayerReady && mounted && !_ytController!.value.isFullScreen) {
      setState(() {});
    }
    if (_isPlayerReady && mounted && !_isCompletedLogged) {
      final duration = _ytController!.metadata.duration;
      final position = _ytController!.value.position;
      if (duration.inSeconds > 0 &&
          position.inSeconds / duration.inSeconds >= 0.8) {
        _completeSession();
      }
    }
  }

  void _completeSession() {
    if (_isCompletedLogged) return;
    _isCompletedLogged = true;
    ref
        .read(progressProvider.notifier)
        .markDayComplete(
          widget.dayNumber,
          courseId: widget.courseId,
          videoId: widget.videoId,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Progress saved! Day ${widget.dayNumber} completed.'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _markCompleteAndBack() {
    _completeSession();
    _restorePortrait();
    if (widget.dayNumber == 30) {
      context.go('/course_completed');
    } else {
      context.pop();
    }
  }

  @override
  void deactivate() {
    _ytController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _restorePortrait();
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isYoutube ? _buildYoutubePlayer() : _buildBunnyPlayer();
  }

  Widget _buildYoutubePlayer() {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {},
      player: YoutubePlayer(
        controller: _ytController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.figmaGreen,
        progressColors: const ProgressBarColors(
          playedColor: AppTheme.figmaGreen,
          handleColor: AppTheme.figmaGreen,
        ),
        onReady: () => setState(() => _isPlayerReady = true),
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.figmaGreen,
            ),
            onPressed: () {
              _restorePortrait();
              context.pop();
            },
          ),
          title: Text(
            widget.videoTitle,
            style: GoogleFonts.inter(
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaCharcoal,
              fontSize: AppFontSizes.bodyLarge,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.figmaLightBorder),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              player,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: _buildVideoInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBunnyPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          WebViewWidget(controller: _webController!),

          // Back button overlay
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  _restorePortrait();
                  context.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // Complete button overlay at bottom
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: _markCompleteAndBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  'Complete Session & Back',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppTheme.figmaGreen.withAlpha(20),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            'Day ${widget.dayNumber} · Practice Session',
            style: GoogleFonts.inter(
              color: AppTheme.figmaGreen,
              fontSize: AppFontSizes.bodySmall + 1,
              fontWeight: AppFontWeights.semiBold,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          widget.videoTitle,
          style: GoogleFonts.inter(
            fontSize: AppFontSizes.h3,
            fontWeight: AppFontWeights.bold,
            color: AppTheme.figmaCharcoal,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Container(height: 1, color: AppTheme.figmaLightBorder),

        const SizedBox(height: AppSpacing.md),

        Text(
          'Maintain focus, sync your breath with movement, and hold postures gracefully. Keep practicing daily to build consistency.',
          style: GoogleFonts.inter(
            color: AppTheme.figmaMutedGray,
            fontSize: AppFontSizes.bodyLarge,
            height: 1.5,
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _markCompleteAndBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.figmaGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Complete Session',
                  style: GoogleFonts.inter(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: AppFontWeights.semiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
