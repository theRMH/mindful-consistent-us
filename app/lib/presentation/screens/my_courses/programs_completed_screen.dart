import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';

class ProgramsCompletedScreen extends StatelessWidget {
  const ProgramsCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Celebration Badge Illustration
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Success Messages
              Text(
                'Congratulations!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.darkTeal,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You have successfully completed the 30-Day Yoga Journey! Your commitment is inspiring.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.coolGray,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // Achievement Details List Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.lightGray),
                ),
                child: Column(
                  children: [
                    _buildCompletedRow(context, 'Program Name', '30-Day Yoga Course'),
                    const Divider(height: 24),
                    _buildCompletedRow(context, 'Duration', '30 Days Complete'),
                    const Divider(height: 24),
                    _buildCompletedRow(context, 'Status', '100% Completed'),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Back to Home Button
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.coolGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkSlate,
              ),
        ),
      ],
    );
  }
}
