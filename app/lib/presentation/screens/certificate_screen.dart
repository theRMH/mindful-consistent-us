import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../../core/config/theme.dart';
import '../providers/auth_provider.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  final String courseTitle;
  final int totalDays;
  final DateTime completionDate;

  const CertificateScreen({
    super.key,
    required this.courseTitle,
    required this.totalDays,
    required this.completionDate,
  });

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isDownloading = false;

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _download() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: 'ConsistentUs_Certificate',
      );
      if (!mounted) return;
      final ok = result['isSuccess'] == true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Certificate saved to your gallery!'
            : 'Could not save. Please try again.'),
        backgroundColor: ok ? AppTheme.figmaGreen : Colors.red,
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save certificate.'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userName = (user?.fullName ?? '').isNotEmpty
        ? user!.fullName
        : user?.phone ?? 'Participant';
    final dateStr = _formatDate(widget.completionDate);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Your Certificate',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: AspectRatio(
                    aspectRatio: 297 / 210,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        return Stack(
                          children: [
                            // Background image
                            Positioned.fill(
                              child: Image.asset(
                                'assets/certificate_bg.jpg',
                                fit: BoxFit.fill,
                              ),
                            ),

                            // Days number (left ribbon area)
                            Positioned(
                              left: w * 0.02,
                              top: h * 0.50,
                              width: w * 0.15,
                              child: Text(
                                '${widget.totalDays}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  color: const Color(0xFF0D3B28),
                                  fontSize: h * 0.105,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // User name (cursive, center)
                            Positioned(
                              left: w * 0.24,
                              top: h * 0.49,
                              width: w * 0.52,
                              child: Text(
                                userName,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dancingScript(
                                  color: const Color(0xFF0D3B28),
                                  fontSize: h * 0.072,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Course name
                            Positioned(
                              left: w * 0.26,
                              top: h * 0.635,
                              width: w * 0.48,
                              child: Text(
                                widget.courseTitle,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF0D3B28),
                                  fontSize: h * 0.036,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Date
                            Positioned(
                              left: w * 0.12,
                              top: h * 0.81,
                              width: w * 0.20,
                              child: Text(
                                dateStr,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF0D3B28),
                                  fontSize: h * 0.028,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _download,
                icon: _isDownloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(
                  _isDownloading ? 'Saving...' : 'Download Certificate',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.figmaGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
