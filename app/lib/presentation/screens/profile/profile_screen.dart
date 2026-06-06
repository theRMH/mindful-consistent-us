import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../core/config/theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userProfile = authState.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.backgroundCream,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              userProfile?.fullName ?? 'User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTeal,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              userProfile?.phone ?? '',
              style: const TextStyle(color: AppTheme.coolGray, fontSize: 14),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/unregistered');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
