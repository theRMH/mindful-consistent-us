import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/theme.dart';

class ProgramsCompletedScreen extends StatelessWidget {
  const ProgramsCompletedScreen({super.key});

  Future<bool> _submitFeedback(int rating, String comment) async {
    try {
      final client = HttpClient();
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
      
      return response.statusCode == 201;
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
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Enjoyed the Course?',
                style: GoogleFonts.inter(
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
                    Text(
                      'Rate your experience and let us know your thoughts to help us improve.',
                      style: GoogleFonts.inter(color: AppTheme.coolGray, fontSize: 13),
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
                      style: GoogleFonts.inter(color: AppTheme.darkSlate, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Write an optional review...',
                        hintStyle: GoogleFonts.inter(color: AppTheme.coolGray),
                        filled: true,
                        fillColor: AppTheme.lightGray.withAlpha(76),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.lightGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
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
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: AppTheme.coolGray, fontWeight: FontWeight.bold),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
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
      backgroundColor: AppTheme.backgroundCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Celebration Badge
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
                style: GoogleFonts.inter(
                  color: AppTheme.darkTeal,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You have successfully completed the 30-Day Yoga Journey! Your commitment is inspiring.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.coolGray,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 40),

              // Achievement Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F3F5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x02000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildCompletedRow(context, 'Program Name', '30-Day Yoga Course'),
                    const Divider(height: 24, color: Color(0xFFF1F3F5)),
                    _buildCompletedRow(context, 'Duration', '30 Days Complete'),
                    const Divider(height: 24, color: Color(0xFFF1F3F5)),
                    _buildCompletedRow(context, 'Status', '100% Completed'),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Buttons
              OutlinedButton(
                onPressed: () => _showFeedbackDialog(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.darkTeal, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Share Your Feedback',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.darkTeal),
                ),
              ),
              const SizedBox(height: 12),
              
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
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
          style: GoogleFonts.inter(
            color: AppTheme.coolGray,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkSlate,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
