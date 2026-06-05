import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/theme.dart';

class ProgramsCompletedScreen extends StatelessWidget {
  const ProgramsCompletedScreen({super.key});

  Future<bool> _submitFeedback(int rating, String comment) async {
    try {
      final client = HttpClient();
      // Configure request
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/feedback');
      final request = await client.postUrl(uri);
      
      request.headers.contentType = ContentType.json;
      request.headers.set('Authorization', 'Bearer mock-user-123');
      
      final payload = {
        'targetType': 'course',
        'rating': rating,
        'comment': comment,
      };
      
      request.write(jsonEncode(payload));
      final response = await request.close();
      
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        int selectedRating = 5;
        final commentController = TextEditingController();
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Enjoyed the Course?',
                style: TextStyle(
                  color: AppTheme.darkTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Rate your experience and let us know your thoughts to help us improve.',
                      style: TextStyle(color: AppTheme.coolGray, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    
                    // Star Rating selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isSelected = starValue <= selectedRating;
                        return IconButton(
                          icon: Icon(
                            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                            color: isSelected ? Colors.amber : AppTheme.lightGray,
                            size: 40,
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    selectedRating = starValue;
                                  });
                                },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    
                    // Comment input
                    TextFormField(
                      controller: commentController,
                      enabled: !isSubmitting,
                      maxLines: 3,
                      style: const TextStyle(color: AppTheme.darkSlate, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Write an optional review...',
                        hintStyle: const TextStyle(color: AppTheme.coolGray),
                        filled: true,
                        fillColor: AppTheme.lightGray.withOpacity(0.3),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.lightGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.darkTeal),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.coolGray, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() {
                            isSubmitting = true;
                          });
                          final success = await _submitFeedback(
                            selectedRating,
                            commentController.text,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(dialogContext);
                          
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thank you for your review!'),
                                backgroundColor: AppTheme.darkTeal,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to submit feedback. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
              
              // Share Feedback Button
              OutlinedButton(
                onPressed: () => _showFeedbackDialog(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.darkTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Share Your Feedback',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkTeal),
                ),
              ),
              const SizedBox(height: 12),
              
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
