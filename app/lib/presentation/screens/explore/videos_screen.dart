import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  // Data model for free videos
  static const List<Map<String, String>> _freeVideos = [
    {
      'title': '5-min Morning Flow',
      'category': 'Daily Energy',
      'duration': '8:15',
      'imagePath': 'assets/video_morning_flow.png',
    },
    {
      'title': 'Deep Sleep Prep',
      'category': 'Restorative',
      'duration': '5:20',
      'imagePath': 'assets/video_sleep_prep.png',
    },
    {
      'title': 'Desk Neck Relief',
      'category': 'Corporate Zen',
      'duration': '12:45',
      'imagePath': 'assets/video_neck_relief.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Banner
            _buildHeaderBanner(),

            const SizedBox(height: 20),

            // 2. Scrollable video list
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Free Videos" section label
                    const Text(
                      'Free Videos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Video cards
                    ..._freeVideos.map(
                      (video) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildVideoCard(
                          context,
                          title: video['title']!,
                          category: video['category']!,
                          duration: video['duration']!,
                          imagePath: video['imagePath']!,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Nav
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ─── Header Banner ──────────────────────────────────────────────────────────
  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('assets/unreg_header_bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Videos',
            style: TextStyle(
              color: Color(0xFF00A859),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          const Text(
            'Show up for yourself, Every single day.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          // Course badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF00A859),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '30 days Yoga Course',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Video Card ─────────────────────────────────────────────────────────────
  Widget _buildVideoCard(
    BuildContext context, {
    required String title,
    required String category,
    required String duration,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () {
        // For unregistered users, tapping a video nudges them to register
        _showRegisterPrompt(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width thumbnail with play button overlay and duration badge
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Thumbnail
                Image.asset(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    width: double.infinity,
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(
                      Icons.videocam_outlined,
                      size: 48,
                      color: Color(0xFF00A859),
                    ),
                  ),
                ),

                // Dark gradient overlay at bottom
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.15),
                        ],
                      ),
                    ),
                  ),
                ),

                // Green circular play button in center
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00A859),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4400A859),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                // Duration badge – bottom right
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 3),

          // Category tag in green
          Text(
            category,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00A859),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  // ─── Register Prompt ────────────────────────────────────────────────────────
  void _showRegisterPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF00A859),
                size: 44,
              ),
              const SizedBox(height: 14),
              const Text(
                'Create a free account to watch',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign up for free and unlock all videos,\nprograms, and tracking features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A859),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign Up for Free',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/login');
                },
                child: const Text(
                  'Already have an account? Log In',
                  style: TextStyle(
                    color: Color(0xFF00A859),
                    fontFamily: 'Inter',
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Bottom Navigation Bar ──────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // Videos tab selected
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00A859),
      unselectedItemColor: const Color(0xFF94A3B8),
      onTap: (index) {
        if (index == 0) {
          context.go('/unregistered');
        } else if (index == 1) {
          context.go('/explore');
        } else if (index == 2) {
          // Already on Videos
        } else {
          context.go('/login');
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: _buildActiveIcon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.grid_view_rounded),
          activeIcon: _buildActiveIcon(Icons.grid_view_rounded),
          label: 'Program',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.play_circle_outline_rounded),
          activeIcon: _buildActiveIcon(Icons.play_circle_filled_rounded),
          label: 'Videos',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.directions_walk_rounded),
          activeIcon: _buildActiveIcon(Icons.directions_walk_rounded),
          label: 'Steps',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline_rounded),
          activeIcon: _buildActiveIcon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildActiveIcon(IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF00A859)),
        const SizedBox(height: 2),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF00A859),
          ),
        ),
      ],
    );
  }
}
