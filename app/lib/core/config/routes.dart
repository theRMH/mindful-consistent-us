import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/analytics_service.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/courses_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/explore/unregistered_home_screen.dart';
import '../../presentation/screens/explore/program_details_screen.dart';
import '../../presentation/screens/explore/video_player_screen.dart';
import '../../presentation/screens/explore/videos_screen.dart';
import '../../presentation/screens/explore/free_videos_screen.dart';
import '../../presentation/screens/explore/steps_screen.dart';
import '../../presentation/screens/my_courses/day_list_screen.dart';
import '../../presentation/screens/my_courses/programs_completed_screen.dart';
import '../../presentation/screens/my_courses/programs_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/body_metrics_form_screen.dart';
import '../../presentation/screens/profile/body_metrics_history_screen.dart';
import '../../presentation/screens/profile/community_leaderboard_screen.dart';
import '../../presentation/screens/profile/notification_preferences_screen.dart';
import '../../presentation/screens/profile/notification_center_screen.dart';
import '../../presentation/screens/profile/help_support_screen.dart';
import '../../presentation/screens/profile/subscription_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/cart/thank_you_screen.dart';
import '../../presentation/screens/certificate_screen.dart';

// Root navigation key
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  static String _initialLocation() {
    try {
      if (FirebaseAuth.instance.currentUser != null) return '/home';
    } catch (_) {}
    return '/unregistered';
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: _initialLocation(),
    observers: [AnalyticsService().observer],
    routes: [
      // 1. Authentication Flow
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return LoginScreen(redirect: redirect);
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return SignupScreen(redirect: redirect);
        },
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          final mode = state.uri.queryParameters['mode'] ?? 'register';
          final redirect = state.uri.queryParameters['redirect'];
          final name = state.uri.queryParameters['name'];
          return OTPScreen(phone: phone, mode: mode, redirect: redirect, name: name);
        },
      ),

      // 3. Main Registered User Navigation Shell (Persistent Bottom Navigation Bar)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/unregistered',
            builder: (context, state) => const UnregisteredHomeScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/programs',
            builder: (context, state) {
              final tab = state.uri.queryParameters['tab'] ?? 'active';
              return ProgramsScreen(initialTab: tab);
            },
          ),
          GoRoute(
            path: '/videos',
            builder: (context, state) => const VideosScreen(),
          ),
          GoRoute(
            path: '/steps',
            builder: (context, state) => const StepsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // 4. Course Detail and Day List Screen
      GoRoute(
        path: '/course/:courseId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          return DayListScreen(courseId: courseId);
        },
      ),

      // 5. Course Completion Success Celebration Screen
      GoRoute(
        path: '/course_completed',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          return ProgramsCompletedScreen(courseId: courseId);
        },
      ),

      GoRoute(
        path: '/program_details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final title = extra?['title'] as String?;
          final imagePath = extra?['imagePath'] as String?;
          final courseId = extra?['courseId'] as String?;
          return ProgramDetailsScreen(
            courseId: courseId,
            courseTitle: title,
            courseImagePath: imagePath,
            showBackButton: true,
          );
        },
      ),

      // 7. Video Player Screen
      GoRoute(
        path: '/play',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final courseId = extra?['courseId'] as String? ?? '';
          final dayNumber = extra?['dayNumber'] as int? ?? 1;
          final totalDays = extra?['totalDays'] as int? ?? 30;
          final videoId = extra?['videoId'] as String?;
          final videoSource = extra?['videoSource'] as String? ?? 'youtube';
          final youtubeVideoId = extra?['youtubeVideoId'] as String? ?? '';
          final bunnyVideoId = extra?['bunnyVideoId'] as String?;
          final bunnyLibraryId = extra?['bunnyLibraryId'] as String?;
          final videoTitle = extra?['videoTitle'] as String? ?? 'Yoga Session';
          return VideoPlayerScreen(
            courseId: courseId,
            dayNumber: dayNumber,
            totalDays: totalDays,
            videoId: videoId,
            videoSource: videoSource,
            youtubeVideoId: youtubeVideoId,
            bunnyVideoId: bunnyVideoId,
            bunnyLibraryId: bunnyLibraryId,
            videoTitle: videoTitle,
          );
        },
      ),

      // 8. Cart Screen
      GoRoute(
        path: '/cart',
        builder: (context, state) {
          final courseId =
              state.uri.queryParameters['courseId'] ?? '';
          return CartScreen(courseId: courseId);
        },
      ),

      // 9. Thank You Screen
      GoRoute(
        path: '/thank-you',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ThankYouScreen(
            courseId: extra?['courseId'] as String?,
            courseTitle: extra?['courseTitle'] as String?,
            amountPaid: extra?['amountPaid'] as int?,
            whatsappLink: extra?['whatsappLink'] as String?,
          );
        },
      ),

      // 10. Free Videos (accessible by registered users, no bottom nav)
      GoRoute(
        path: '/free-videos',
        builder: (context, state) => const FreeVideosScreen(),
      ),

      // 11. Body Metrics Form
      GoRoute(
        path: '/body-metrics',
        builder: (context, state) {
          final isSkippable =
              state.uri.queryParameters['skip'] != 'false';
          final courseId = state.uri.queryParameters['courseId'];
          final redirect =
              state.uri.queryParameters['redirect'] ?? '/home';
          return BodyMetricsFormScreen(
            isSkippable: isSkippable,
            courseId: courseId,
            redirectPath: redirect,
          );
        },
      ),

      // 12. Body Metrics History (Personal Details)
      GoRoute(
        path: '/body-metrics-history',
        builder: (context, state) => const BodyMetricsHistoryScreen(),
      ),

      // 13. Community Leaderboard
      GoRoute(
        path: '/community-leaderboard',
        builder: (context, state) => const CommunityLeaderboardScreen(),
      ),

      // 14. Notification Preferences
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),

      // 15. Subscription & Plans
      GoRoute(
        path: '/subscriptions',
        builder: (context, state) => const SubscriptionScreen(),
      ),

      // 16. Notification Centre (inbox of all received notifications)
      GoRoute(
        path: '/notification-center',
        builder: (context, state) => const NotificationCenterScreen(),
      ),

      // 17. Help & Support (content managed via admin panel)
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpSupportScreen(),
      ),

      // 18. Certificate download screen
      GoRoute(
        path: '/certificate',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final courseTitle = extra?['courseTitle'] as String? ?? '';
          final totalDays = extra?['totalDays'] as int? ?? 30;
          final dateStr = extra?['completionDate'] as String?;
          final completionDate = dateStr != null
              ? DateTime.tryParse(dateStr) ?? DateTime.now()
              : DateTime.now();
          return CertificateScreen(
            courseTitle: courseTitle,
            totalDays: totalDays,
            completionDate: completionDate,
          );
        },
      ),
    ],
  );
}

// Reusable Navigation Shell containing the BottomNavigationBar
class AppNavigationShell extends ConsumerWidget {
  final Widget child;

  const AppNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine active index based on route path
    final String location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    if (location == '/home') {
      currentIndex = 0;
    } else if (location == '/unregistered') {
      currentIndex = 0;
    } else if (location.startsWith('/programs')) {
      currentIndex = 1;
    } else if (location == '/videos') {
      currentIndex = 2;
    } else if (location == '/steps') {
      currentIndex = 3;
    } else if (location == '/profile') {
      currentIndex = 4;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.coolGray,
        onTap: (index) {
          final authState = ref.read(authProvider);
          switch (index) {
            case 0:
              context.go(authState.isAuthenticated ? '/home' : '/unregistered');
              break;
            case 1:
              if (!authState.isAuthenticated) {
                context.go('/programs?tab=explore');
              } else {
                final coursesState = ref.read(coursesProvider);
                final tab = coursesState.activeCourses.isNotEmpty
                    ? 'active'
                    : 'explore';
                context.go('/programs?tab=$tab');
              }
              break;
            case 2:
              context.go('/videos');
              break;
            case 3:
              context.go('/steps');
              break;
            case 4:
              if (!authState.isAuthenticated) {
                context.push('/login?redirect=${Uri.encodeComponent('/profile')}');
              } else {
                context.go('/profile');
              }
              break;
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
      ),
    );
  }

  Widget _buildActiveIcon(IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryGreen),
        const SizedBox(height: 2),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }
}
