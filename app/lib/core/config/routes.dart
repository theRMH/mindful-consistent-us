import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/explore/unregistered_home_screen.dart';
import '../../presentation/screens/explore/explore_screen.dart';
import '../../presentation/screens/my_courses/day_list_screen.dart';
import '../../presentation/screens/my_courses/programs_completed_screen.dart';

// Root navigation key
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  static GoRouter get router {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/unregistered', // Default entry point (Figma Unregistered User Dashboard)
      routes: [
        // 1. Guest/Unregistered landing page
        GoRoute(
          path: '/unregistered',
          builder: (context, state) => const UnregisteredHomeScreen(),
        ),
        
        // 2. Authentication Flow
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // 3. Main Registered User Navigation Shell (Persistent Bottom Navigation Bar)
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return AppNavigationShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/active_programs',
              builder: (context, state) => const ActiveProgramsScreen(),
            ),
            GoRoute(
              path: '/completed_programs',
              builder: (context, state) => const CompletedProgramsScreen(),
            ),
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen(),
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
          builder: (context, state) => const ProgramsCompletedScreen(),
        ),
      ],
    );
  }
}

// Reusable Navigation Shell containing the BottomNavigationBar
class AppNavigationShell extends StatelessWidget {
  final Widget child;

  const AppNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Determine active index based on route path
    final String location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    if (location == '/home') {
      currentIndex = 0;
    } else if (location == '/active_programs') {
      currentIndex = 1;
    } else if (location == '/completed_programs') {
      currentIndex = 2;
    } else if (location == '/explore') {
      currentIndex = 3;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/active_programs');
              break;
            case 2:
              context.go('/completed_programs');
              break;
            case 3:
              context.go('/explore');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle),
            label: 'Active',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
        ],
      ),
    );
  }
}

// Quick Placeholder Screens to allow compilation
class ActiveProgramsScreen extends StatelessWidget {
  const ActiveProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Active Programs Screen")),
    );
  }
}

class CompletedProgramsScreen extends StatelessWidget {
  const CompletedProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Completed Programs Screen")),
    );
  }
}
