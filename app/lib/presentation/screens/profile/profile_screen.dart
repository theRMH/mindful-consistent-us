import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/api_service.dart';

final _profileDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ApiService().getProfile();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(_profileDataProvider);
    final progressState = ref.watch(progressProvider);
    final authState = ref.watch(authProvider);

    final String fullName = profileAsync.when(
      data: (p) => (p['fullName'] as String?)?.trim().isNotEmpty == true
          ? p['fullName'] as String
          : authState.user?.fullName ?? 'User',
      loading: () => authState.user?.fullName ?? 'User',
      error: (_, _) => authState.user?.fullName ?? 'User',
    );
    final String? avatarUrl = profileAsync.when(
      data: (p) {
        final url = p['avatarUrl'] as String?;
        return (url != null && url.isNotEmpty) ? url : null;
      },
      loading: () => null,
      error: (_, _) => null,
    );
    final String handle = '@${fullName.toLowerCase().replaceAll(' ', '_')}';

    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Green header with avatar ───────────────────────────
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Green background
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24, topPad + 28, 24, 100),
                  decoration: const BoxDecoration(
                    color: AppTheme.figmaGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(72),
                      bottomRight: Radius.circular(72),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFFFD700), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child: avatarUrl != null
                              ? Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _buildInitialsCircle(fullName),
                                )
                              : _buildInitialsCircle(fullName),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        handle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating stats card
                Positioned(
                  bottom: -52,
                  left: 24,
                  right: 24,
                  child: _buildStatsCard(progressState),
                ),
              ],
            ),

            const SizedBox(height: 68), // space for floating card

            // ── 2. Menu options ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMenuCard(context, ref, authState.isAuthenticated),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsCircle(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: Colors.white.withAlpha(60),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ─── Stats Card ───────────────────────────────────────────────────────────

  Widget _buildStatsCard(ProgressState ps) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(14),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.calendar_month_outlined,
                iconColor: AppTheme.figmaGreen,
                value: '${ps.completedSessionsToday}',
                label: 'Sessions',
              ),
            ),
            const VerticalDivider(
                width: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: _buildStatItem(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF00BFA5),
                value: '${ps.mindfulMins}',
                label: 'Minutes',
              ),
            ),
            const VerticalDivider(
                width: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: _buildStatItem(
                useEmoji: true,
                emoji: '🔥',
                iconColor: Colors.orange,
                value: '${ps.currentStreak}',
                label: 'Day Streak',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    IconData? icon,
    bool useEmoji = false,
    String? emoji,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (useEmoji)
          Text(emoji!, style: const TextStyle(fontSize: 22))
        else
          Icon(icon!, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.figmaCharcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.coolGray,
          ),
        ),
      ],
    );
  }

  // ─── Menu List ────────────────────────────────────────────────────────────

  Widget _buildMenuCard(BuildContext context, WidgetRef ref, bool isAuthenticated) {
    return Column(
      children: [
        _buildMenuTile(
          icon: Icons.person_outline_rounded,
          iconBg: const Color(0xFFE8F4FB),
          iconColor: const Color(0xFF2196F3),
          title: 'Personal Details',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personal Details coming soon')),
          ),
        ),
        _buildMenuTile(
          icon: Icons.play_arrow_rounded,
          iconBg: const Color(0xFFF0EAF8),
          iconColor: const Color(0xFF9C27B0),
          title: 'Free Videos',
          onTap: () => context.go('/videos'),
        ),
        _buildMenuTile(
          icon: Icons.notifications_none_rounded,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFFF9800),
          title: 'Notifications & Reminders',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Notifications & Reminders coming soon')),
          ),
        ),
        _buildMenuTile(
          icon: Icons.credit_card_rounded,
          iconBg: const Color(0xFFE8F5EE),
          iconColor: AppTheme.figmaGreen,
          title: 'Subscription & Plans',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Subscription & Plans coming soon')),
          ),
        ),
        _buildMenuTile(
          icon: Icons.help_outline_rounded,
          iconBg: const Color(0xFFFCEEE8),
          iconColor: const Color(0xFFFF5722),
          title: 'Help & Support',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Help & Support coming soon')),
          ),
        ),
        if (isAuthenticated)
          _buildMenuTile(
            icon: Icons.logout_rounded,
            iconBg: const Color(0xFFFFEBEB),
            iconColor: const Color(0xFFED1E24),
            title: 'Logout',
            titleColor: const Color(0xFFED1E24),
            onTap: () => _showLogoutDialog(context, ref),
          )
        else
          _buildMenuTile(
            icon: Icons.login_rounded,
            iconBg: const Color(0xFFE8F4FB),
            iconColor: const Color(0xFF2196F3),
            title: 'Login',
            titleColor: const Color(0xFF2196F3),
            onTap: () {
              final redirect = Uri.encodeComponent(GoRouterState.of(context).uri.toString());
              context.go('/login?redirect=$redirect');
            },
          ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? AppTheme.figmaCharcoal,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: titleColor != null
                  ? titleColor.withAlpha(150)
                  : AppTheme.coolGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppTheme.figmaCharcoal,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.inter(
            color: AppTheme.coolGray,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.coolGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authProvider.notifier).logout();
              context.go('/unregistered');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFED1E24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
