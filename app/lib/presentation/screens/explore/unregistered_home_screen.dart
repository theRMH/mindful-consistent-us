import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnregisteredHomeScreen extends StatelessWidget {
  const UnregisteredHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8), // Extremely light cream/off-white background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Curved Header Banner
              Container(
                width: double.infinity,
                height: 150,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Programs',
                      style: TextStyle(
                        color: Color(0xFF00A859), // Figma green
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Daily discipline. Lasting transformation.',
                      style: TextStyle(
                        color: Color(0xFF6B7280), // Figma grey
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 2 Days Streak tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A859),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🔥 2 Days Streak',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Explore Programs Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Explore Programs',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFF00A859),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 30 Days Yoga Course Card
              _buildCourseCard(
                context,
                title: '30 Days Yoga Course',
                price: '₹699',
                days: '30 days',
                level: 'Beginner',
                duration: '15m /day',
                imagePath: 'assets/course_30_days.png',
              ),

              const SizedBox(height: 12),

              // 48 Days Yoga Course Card
              _buildCourseCard(
                context,
                title: '48 Days Yoga Course',
                price: '₹899',
                days: '48 days',
                level: 'Advanced',
                duration: '30m /day',
                imagePath: 'assets/course_48_days.png',
              ),

              const SizedBox(height: 28),

              // 3. Free Videos Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Free Videos',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFF00A859),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Horizontal Free Videos list
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFreeVideoItem(
                      title: '5-min Morning Flow',
                      category: 'Daily Energy',
                      duration: '8:15',
                      imagePath: 'assets/video_morning_flow.png',
                    ),
                    const SizedBox(width: 14),
                    _buildFreeVideoItem(
                      title: 'Deep Sleep Prep',
                      category: 'Restorative',
                      duration: '10:30',
                      imagePath: 'assets/video_sleep_prep.png',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 4. Community Moments Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Moments',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Real people. Real Progress. real Inspiration.',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Testimonial Quote Card 1
              _buildQuoteCard(
                context,
                quote: 'This 15 mins of yoga every day changed the way I start my mornings',
                name: 'Priya S',
                photoPath: 'assets/community_priya.png',
                avatarPath: 'assets/avatar_priya.png',
              ),

              const SizedBox(height: 14),

              // Testimonial Quote Card 2
              _buildQuoteCard(
                context,
                quote: 'I feel Stronger, calmer and more focused than even before',
                name: 'Rohit K',
                photoPath: 'assets/community_rohit.png',
                avatarPath: 'assets/avatar_rohit.png',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // 5. Guest Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Program selected
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00A859),
        unselectedItemColor: const Color(0xFF94A3B8),
        onTap: (index) {
          if (index != 1) {
            context.go('/login'); // Redirect to login if user clicks any other tab
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.grid_view_rounded, color: Color(0xFF00A859)),
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
            ),
            label: 'Program',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline_rounded),
            activeIcon: Icon(Icons.play_circle_filled_rounded),
            label: 'Videos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk_rounded),
            activeIcon: Icon(Icons.directions_walk_rounded),
            label: 'Steps',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context, {
    required String title,
    required String price,
    required String days,
    required String level,
    required String duration,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () => context.go('/login'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Thumbnail Image with Price overlay
              Stack(
                children: [
                  Image.asset(
                    imagePath,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A859), // Green badge
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A859),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Course Tags Row
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          days,
                          style: TextStyle(color: Colors.grey[600], fontSize: 11.5),
                        ),
                        const SizedBox(width: 10),
                        Text('|', style: TextStyle(color: Colors.grey[300])),
                        const SizedBox(width: 10),
                        Icon(Icons.bar_chart_rounded, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          level,
                          style: TextStyle(color: Colors.grey[600], fontSize: 11.5),
                        ),
                        const SizedBox(width: 10),
                        Text('|', style: TextStyle(color: Colors.grey[300])),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time_rounded, size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(color: Colors.grey[600], fontSize: 11.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    const SizedBox(height: 10),
                    // Footer Action Row
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            color: Color(0xFF00A859),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF00A859),
                          size: 16,
                        ),
                      ],
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

  Widget _buildFreeVideoItem({
    required String title,
    required String category,
    required String duration,
    required String imagePath,
  }) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 100,
                  width: 180,
                  fit: BoxFit.cover,
                ),
                // Overlay Play Button
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Duration Badge
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          // Subtitle
          Text(
            category,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A859),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context, {
    required String quote,
    required String name,
    required String photoPath,
    required String avatarPath,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Quote content Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    photoPath,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                // Quote text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '“',
                        style: TextStyle(
                          fontSize: 32,
                          height: 0.8,
                          color: Color(0xFFD1D5DB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        quote,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: Color(0xFF374151),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 8),
            // User details row
            Row(
              children: [
                // Avatar Profile Pic
                CircleAvatar(
                  radius: 12,
                  backgroundImage: AssetImage(avatarPath),
                ),
                const SizedBox(width: 8),
                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                // Streak badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Subtle light grey badge background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '🔥 2 Days Streak',
                        style: TextStyle(
                          color: Color(0xFF00A859),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
