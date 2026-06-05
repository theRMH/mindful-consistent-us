import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Video/Header Mock
            Container(
              height: 200,
              width: double.infinity,
              color: AppTheme.darkTeal,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                  Positioned(
                    bottom: 16,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: AppTheme.accentGold,
                      child: const Text(
                        'PREVIEW',
                        style: TextStyle(
                          color: AppTheme.darkSlate,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    '30 Days Yoga Course',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                        ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Tags Row
                  const Row(
                    children: [
                      TextTag(label: '30 days'),
                      SizedBox(width: 8),
                      TextTag(label: 'Beginner'),
                      SizedBox(width: 8),
                      TextTag(label: '15m /day'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'About this program',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wake up your body and mind with this 21-day mobility routine. Designed to improve your flexibility, reduce morning stiffness, and start your day with renewed energy and focus.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.coolGray,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Instructor Profile
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.lightGray),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.primaryGreen,
                          child: Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deepa',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                              ),
                              const Text(
                                'Certified Yoga Instructor',
                                style: TextStyle(color: AppTheme.coolGray, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '8+ Years of Experience',
                                style: TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sessions List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sessions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'View All',
                          style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Session Tiles
                  _buildSessionTile(
                    context,
                    index: '01',
                    title: 'Day 1: Initial Alignment',
                    subtitle: '5 Deep Sessions',
                    duration: '20Mins',
                    courseId: '30-days-yoga',
                  ),
                  _buildSessionTile(
                    context,
                    index: '02',
                    title: 'Day 2: Flexible Spine',
                    subtitle: '4 Deep Sessions',
                    duration: '15Mins',
                    courseId: '30-days-yoga',
                  ),
                  _buildSessionTile(
                    context,
                    index: '03',
                    title: 'Day 3: Core Mobility',
                    subtitle: '6 Deep Sessions',
                    duration: '25Mins',
                    courseId: '30-days-yoga',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(
    BuildContext context, {
    required String index,
    required String title,
    required String subtitle,
    required String duration,
    required String courseId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: ListTile(
        onTap: () => context.go('/course/$courseId'),
        leading: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppTheme.lightGray,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              index,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkSlate,
          ),
        ),
        subtitle: Text(
          '$subtitle • $duration',
          style: const TextStyle(color: AppTheme.coolGray, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.coolGray,
        ),
      ),
    );
  }
}

class TextTag extends StatelessWidget {
  final String label;
  const TextTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.coolGray,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
