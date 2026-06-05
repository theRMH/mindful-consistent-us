import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';

class UnregisteredHomeScreen extends StatelessWidget {
  const UnregisteredHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindful'),
        actions: [
          IconButton(
            icon: const Icon(Icons.login_rounded, color: AppTheme.darkTeal),
            onPressed: () => context.go('/login'),
            tooltip: 'Log in',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Programs',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 32,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Daily discipline. Lasting transformation.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.coolGray,
                            ),
                      ),
                    ],
                  ),
                  // Guest streak representation pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: AppTheme.primaryGreen, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '2 Days Strak',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Explore header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore Programs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Course Card 1: 30 Days Course
              _buildCourseCard(
                context,
                title: '30 Days Yoga Course',
                price: '₹699',
                days: '30 days',
                level: 'Beginner',
                duration: '15m /day',
                imageRef: 'assets_placeholder_1',
              ),
              const SizedBox(height: 24),
              // Course Card 2: 48 Days Course
              _buildCourseCard(
                context,
                title: '48 Days Yoga Course',
                price: '₹899',
                days: '48 days',
                level: 'Advanced',
                duration: '15m /day',
                imageRef: 'assets_placeholder_2',
              ),
            ],
          ),
        ),
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
    required String imageRef,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkSlate.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Thumbnail Mock
          Container(
            height: 160,
            color: AppTheme.primaryGreen.withOpacity(0.08),
            child: const Center(
              child: Icon(
                Icons.self_improvement_rounded,
                size: 64,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              color: AppTheme.darkSlate,
                            ),
                      ),
                    ),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tags
                Row(
                  children: [
                    _buildTag(context, days),
                    const SizedBox(width: 8),
                    _buildTag(context, level),
                    const SizedBox(width: 8),
                    _buildTag(context, duration),
                  ],
                ),
                const SizedBox(height: 20),
                // View Details Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
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
