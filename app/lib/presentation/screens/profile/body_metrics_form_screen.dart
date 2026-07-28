import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';

class BodyMetricsFormScreen extends ConsumerStatefulWidget {
  final bool isSkippable;
  final String? courseId;
  final String redirectPath;

  const BodyMetricsFormScreen({
    super.key,
    this.isSkippable = true,
    this.courseId,
    required this.redirectPath,
  });

  @override
  ConsumerState<BodyMetricsFormScreen> createState() =>
      _BodyMetricsFormScreenState();
}

class _BodyMetricsFormScreenState
    extends ConsumerState<BodyMetricsFormScreen> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;
  int? _storedAge;

  @override
  void initState() {
    super.initState();
    _loadPreviousMetrics();
  }

  Future<void> _loadPreviousMetrics() async {
    try {
      final records = await ApiService().getBodyMetrics();
      if (records.isNotEmpty && mounted) {
        final latest = records.first as Map<String, dynamic>;
        final heightCm = latest['heightCm'];
        if (heightCm != null) {
          final h = heightCm.toString();
          _heightController.text = h.endsWith('.0') ? h.replaceAll('.0', '') : h;
        }
        final age = latest['age'];
        if (age != null) {
          final recordedAt = latest['recordedAt'] as String?;
          final recordingDate = recordedAt != null ? DateTime.tryParse(recordedAt) : null;
          final yearsElapsed = recordingDate != null
              ? (DateTime.now().difference(recordingDate).inDays / 365.25).floor()
              : 0;
          _storedAge = (age as num).toInt() + yearsElapsed;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }

  bool get _allFilled {
    final ageOk = _storedAge != null || _ageController.text.trim().isNotEmpty;
    return ageOk &&
        _heightController.text.trim().isNotEmpty &&
        _weightController.text.trim().isNotEmpty &&
        _waistController.text.trim().isNotEmpty &&
        _hipController.text.trim().isNotEmpty;
  }

  Future<void> _save() async {
    if (!widget.isSkippable && !_allFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all measurements to continue'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ApiService().saveBodyMetrics(
        courseId: widget.courseId,
        name: ref.read(authProvider).user?.fullName,
        age: _storedAge ?? int.tryParse(_ageController.text.trim()),
        heightCm: double.tryParse(_heightController.text.trim()),
        weightKg: double.tryParse(_weightController.text.trim()),
        waistIn: double.tryParse(_waistController.text.trim()),
        hipIn: double.tryParse(_hipController.text.trim()),
      );
      if (mounted) context.go(widget.redirectPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _skip() => context.go(widget.redirectPath);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 28),
            decoration: const BoxDecoration(
              color: AppTheme.figmaGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.isSkippable)
                      GestureDetector(
                        onTap: _skip,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppTheme.figmaGreen,
                            size: 28,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Body Metrics',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isSkippable
                      ? 'Track your fitness journey — you can update this anytime.'
                      : 'Required before purchasing. Helps us personalise your experience.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withAlpha(210),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ── Form ─────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (_storedAge == null) ...[
                        Expanded(
                          child: _buildField(
                            controller: _ageController,
                            label: 'Age',
                            hint: 'e.g. 28',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: _buildField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          hint: 'e.g. 165',
                          icon: Icons.height_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          hint: 'e.g. 62',
                          icon: Icons.monitor_weight_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          controller: _waistController,
                          label: 'Waist (in)',
                          hint: 'e.g. 30',
                          icon: Icons.straighten_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _hipController,
                            label: 'Hip (in)',
                            hint: 'e.g. 36',
                            icon: Icons.straighten_rounded,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.figmaGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save & Continue',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  if (widget.isSkippable) ...[
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip for now',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.coolGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.figmaCharcoal,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5EFE6)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.figmaCharcoal,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: AppTheme.figmaMutedGray,
                fontSize: 12,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: AppTheme.figmaGreen, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
