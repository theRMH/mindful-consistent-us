import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/progress_provider.dart';
import '../../../core/config/theme.dart';

class ActiveProgramsScreen extends ConsumerWidget {
  const ActiveProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider);

    // List of active courses
    final List<Map<String, dynamic>> activeCourses = [
      {
        'title': '30 Days Yoga Course',
        'imagePath': 'assets/course_30_days.png',
        'completed': progressState.completedDays.length,
        'total': 30,
        'level': 'Beginner',
      },
      {
        'title': '48 Days Yoga Course',
        'imagePath': 'assets/course_48_days.png',
        'completed': 0,
        'total': 48,
        'level': 'Advanced',
      }
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Active Programs'),
        backgroundColor: AppTheme.backgroundCream,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: activeCourses.length,
        itemBuilder: (context, index) {
          final course = activeCourses[index];
          final double progressPercent = course['completed'] / course['total'];

          return GestureDetector(
            onTap: () {
              // Navigate to details page with matching name and image
              context.push(
                '/program_details',
                extra: {
                  'title': course['title'],
                  'imagePath': course['imagePath'],
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.lightGray),
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
                  // Image
                  Image.asset(
                    course['imagePath'],
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: AppTheme.lightGray,
                      child: const Icon(Icons.spa, color: AppTheme.primaryGreen, size: 40),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              course['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGray,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'In Progress',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Progress bar
                        LinearProgressIndicator(
                          value: progressPercent,
                          backgroundColor: AppTheme.lightGray,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 8),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${course['completed']} of ${course['total']} Days Completed',
                              style: const TextStyle(
                                color: AppTheme.coolGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              course['level'],
                              style: const TextStyle(
                                color: AppTheme.coolGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
