import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/api_service.dart';

final _notificationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) {
  return ApiService().getNotifications();
});

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(_notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_rounded, color: AppTheme.figmaGreen),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontWeight: AppFontWeights.bold,
            color: AppTheme.figmaGreen,
            fontSize: AppFontSizes.h3,
          ),
        ),
        centerTitle: false,
      ),
      body: notifAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.figmaGreen),
        ),
        error: (e, _) => _buildEmpty(
          context,
          icon: Icons.wifi_off_rounded,
          message: 'Could not load notifications.\nCheck your connection and try again.',
          showRetry: true,
          onRetry: () => ref.invalidate(_notificationsProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmpty(
              context,
              icon: Icons.notifications_none_rounded,
              message: 'No notifications yet.\nCheck back later for updates!',
            );
          }
          return RefreshIndicator(
            color: AppTheme.figmaGreen,
            onRefresh: () async => ref.invalidate(_notificationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = notifications[index] as Map<String, dynamic>;
                return _NotificationCard(
                  notification: n,
                  onTap: () => _openNotification(context, ref, n),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openNotification(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> n,
  ) async {
    // Mark as read
    try {
      await ApiService().markNotificationRead(n['id'] as String);
      ref.invalidate(_notificationsProvider);
    } catch (_) {}

    final type = n['type'] as String? ?? 'announcement';
    final redirectUrl = n['redirectUrl'] as String?;

    if (!context.mounted) return;

    if (type == 'announcement' || (redirectUrl == null)) {
      // Show full detail sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        builder: (_) => _NotificationDetailSheet(notification: n),
      );
    } else {
      // Redirect deep link
      context.push(redirectUrl);
    }
  }

  Widget _buildEmpty(
    BuildContext context, {
    required IconData icon,
    required String message,
    bool showRetry = false,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.figmaGreen.withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.figmaGreen, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppFontSizes.bodyLarge,
                color: AppTheme.coolGray,
                height: 1.5,
              ),
            ),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    color: AppTheme.figmaGreen,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = notification['title'] as String? ?? '';
    final body = notification['body'] as String? ?? '';
    final type = notification['type'] as String? ?? 'announcement';
    final isRead = notification['isRead'] as bool? ?? false;
    final sentAtRaw = notification['sentAt'] as String?;
    final sentAt = sentAtRaw != null ? DateTime.tryParse(sentAtRaw) : null;

    final typeIcon = _iconForType(type);
    final timeLabel = sentAt != null ? _timeAgo(sentAt) : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppTheme.figmaGreen.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? const Color(0xFFEEEEEE)
                : AppTheme.figmaGreen.withAlpha(50),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.figmaGreen.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(typeIcon, color: AppTheme.figmaGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: AppFontSizes.bodyLarge,
                            fontWeight: isRead
                                ? AppFontWeights.semiBold
                                : AppFontWeights.bold,
                            color: AppTheme.figmaCharcoal,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.figmaGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: AppFontSizes.bodyMedium,
                      color: AppTheme.coolGray,
                      height: 1.4,
                    ),
                  ),
                  if (timeLabel.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      timeLabel,
                      style: GoogleFonts.inter(
                        fontSize: AppFontSizes.bodySmall,
                        color: AppTheme.coolGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'daily_reminder':
        return Icons.alarm_rounded;
      case 'streak_reminder':
        return Icons.local_fire_department_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationDetailSheet({required this.notification});

  @override
  Widget build(BuildContext context) {
    final title = notification['title'] as String? ?? '';
    final body = notification['body'] as String? ?? '';
    final redirectUrl = notification['redirectUrl'] as String?;
    final sentAtRaw = notification['sentAt'] as String?;
    final sentAt = sentAtRaw != null ? DateTime.tryParse(sentAtRaw) : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (sentAt != null)
            Text(
              '${sentAt.day}/${sentAt.month}/${sentAt.year}',
              style: GoogleFonts.inter(
                fontSize: AppFontSizes.bodySmall,
                color: AppTheme.coolGray,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.h3,
              fontWeight: AppFontWeights.bold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodyLarge,
              color: AppTheme.coolGray,
              height: 1.6,
            ),
          ),
          if (redirectUrl != null) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(redirectUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.figmaGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Go to Programs',
                  style: GoogleFonts.inter(
                    fontWeight: AppFontWeights.bold,
                    fontSize: AppFontSizes.bodyLarge,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
