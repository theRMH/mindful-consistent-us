import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../providers/progress_provider.dart';
import '../../../core/config/theme.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final int dayNumber;
  final String youtubeVideoId;
  final String videoTitle;

  const VideoPlayerScreen({
    super.key,
    required this.courseId,
    required this.dayNumber,
    required this.youtubeVideoId,
    required this.videoTitle,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isCompletedLogged = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
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
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }

    // Auto-complete if they watched 80%+ of the video
    if (_isPlayerReady && mounted && !_isCompletedLogged) {
      final duration = _controller.metadata.duration;
      final currentPosition = _controller.value.position;
      if (duration.inSeconds > 0) {
        final double ratio = currentPosition.inSeconds / duration.inSeconds;
        if (ratio >= 0.8) {
          _completeSessionAutomatically();
        }
      }
    }
  }

  void _completeSessionAutomatically() {
    _isCompletedLogged = true;
    ref.read(progressProvider.notifier).markDayComplete(widget.dayNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Progress saved! Day ${widget.dayNumber} completed.'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _markCompleteManually() {
    if (!_isCompletedLogged) {
      _isCompletedLogged = true;
      ref.read(progressProvider.notifier).markDayComplete(widget.dayNumber);
    }
    
    // Redirect if course is completed
    if (widget.dayNumber == 30) {
      context.go('/course_completed');
    } else {
      context.pop();
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.primaryGreen,
        progressColors: const ProgressBarColors(
          playedColor: AppTheme.primaryGreen,
          handleColor: AppTheme.accentGold,
        ),
        onReady: () {
          setState(() {
            _isPlayerReady = true;
          });
        },
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: AppTheme.backgroundCream,
        appBar: AppBar(
          title: Text(widget.videoTitle),
          backgroundColor: AppTheme.backgroundCream,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Player container
              player,
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day ${widget.dayNumber} Practice Session',
                      style: const TextStyle(
                        color: AppTheme.coolGray,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.videoTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Maintain focus, sync your breath with movement, and hold postures gracefully. Keep practicing daily to build consistency.',
                      style: TextStyle(
                        color: AppTheme.coolGray,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Mark Complete Button
                    ElevatedButton.icon(
                      onPressed: _markCompleteManually,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text(
                        'Complete Session & Back',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
