import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/api_service.dart';

class BodyMetricsHistoryScreen extends StatefulWidget {
  const BodyMetricsHistoryScreen({super.key});

  @override
  State<BodyMetricsHistoryScreen> createState() =>
      _BodyMetricsHistoryScreenState();
}

class _BodyMetricsHistoryScreenState extends State<BodyMetricsHistoryScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getBodyMetrics();
  }

  void _refresh() {
    setState(() {
      _future = ApiService().getBodyMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
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
                    ),
                    GestureDetector(
                      onTap: () async {
                        await context.push('/body-metrics?skip=true&redirect=/body-metrics-history');
                        _refresh();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                color: AppTheme.figmaGreen, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Add Entry',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.figmaGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Personal Details',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your body metrics over time. Track changes across courses.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withAlpha(210),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.figmaGreen),
                  );
                }
                if (snapshot.hasError) {
                  return _buildEmptyState();
                }
                final records = snapshot.data ?? [];
                if (records.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  itemCount: records.length,
                  itemBuilder: (context, index) =>
                      _buildCard(records[index] as Map<String, dynamic>, index == 0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.figmaGreen.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monitor_weight_outlined,
              color: AppTheme.figmaGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Measurements Yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first body metrics snapshot\nto start tracking progress.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.coolGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () async {
              await context.push('/body-metrics?skip=true&redirect=/body-metrics-history');
              _refresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.figmaGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              'Add First Entry',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> record, bool isLatest) {
    final date = DateTime.tryParse(record['recordedAt'] as String? ?? '');
    final dateLabel = date != null ? _formatDate(date) : '—';
    final courseTitle = record['courseTitle'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isLatest
            ? Border.all(color: AppTheme.figmaGreen.withAlpha(80), width: 1.5)
            : Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.figmaCharcoal,
                ),
              ),
              if (isLatest)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.figmaGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Latest',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.figmaGreen,
                    ),
                  ),
                ),
            ],
          ),
          if (courseTitle != null) ...[
            const SizedBox(height: 4),
            Text(
              courseTitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.figmaGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),
          _buildMetricsGrid(record),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> r) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: [
        _metric('Age', r['age']?.toString(), 'yrs'),
        _metric('Height', _num(r['heightCm']), 'cm'),
        _metric('Weight', _num(r['weightKg']), 'kg'),
        _metric('Waist', _num(r['waistIn']), 'in'),
        _metric('Hip', _num(r['hipIn']), 'in'),
      ],
    );
  }

  Widget _metric(String label, String? value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppTheme.coolGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value ?? '—',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.figmaCharcoal,
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.coolGray,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String? _num(dynamic val) {
    if (val == null) return null;
    final n = val is num ? val.toDouble() : double.tryParse(val.toString());
    if (n == null) return null;
    return n == n.truncateToDouble() ? n.toInt().toString() : n.toString();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
