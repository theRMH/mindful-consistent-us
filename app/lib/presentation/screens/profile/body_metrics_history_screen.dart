import 'dart:math';
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
  String _chartMetric = 'weightKg'; // which metric the chart shows

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
                        await context.push(
                          '/body-metrics?skip=true&redirect=/body-metrics-history',
                        );
                        _refresh();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              color: AppTheme.figmaGreen,
                              size: 16,
                            ),
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
                      color: AppTheme.figmaGreen,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _buildEmptyState();
                }
                final records = snapshot.data ?? [];
                if (records.isEmpty) {
                  return _buildEmptyState();
                }

                final typed = records
                    .map((r) => r as Map<String, dynamic>)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    _buildMotivationCard(typed),
                    const SizedBox(height: 20),

                    // Progress chart (only if ≥ 2 entries with data)
                    if (_hasChartData(typed, _chartMetric)) ...[
                      _buildChart(typed),
                      const SizedBox(height: 20),
                    ],

                    // History cards
                    ...typed.asMap().entries.map((e) {
                      final record = e.value;
                      final prev = e.key < typed.length - 1
                          ? typed[e.key + 1]
                          : null;
                      return Dismissible(
                        key: ValueKey(record['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text('Delete entry?'),
                                  content: const Text(
                                    'This measurement record will be permanently removed.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Color(0xFFFF5252),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (_) async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await ApiService().deleteBodyMetrics(
                              record['id'] as String,
                            );
                          } catch (_) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Failed to delete entry'),
                              ),
                            );
                            _refresh();
                          }
                        },
                        child: _buildCard(record, e.key == 0, prev),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Chart ───────────────────────────────────────────────────────────────

  static const _chartOptions = [
    ('weightKg', 'Weight', 'kg'),
    ('waistIn', 'Waist', 'in'),
    ('hipIn', 'Hip', 'in'),
  ];

  bool _hasChartData(List<Map<String, dynamic>> records, String key) {
    final vals = records
        .map((r) => _toDouble(r[key]))
        .where((v) => v != null)
        .toList();
    return vals.length >= 2;
  }

  Widget _buildChart(List<Map<String, dynamic>> records) {
    // Pick the label/unit for the active metric
    final opt = _chartOptions.firstWhere(
      (o) => o.$1 == _chartMetric,
      orElse: () => _chartOptions[0],
    );

    // Records are newest-first; chart shows oldest→newest
    final chronological = records.reversed.toList();
    final values = chronological
        .map((r) => _toDouble(r[_chartMetric]))
        .toList();
    final metricValues = values.whereType<double>().toList();
    final firstValue = metricValues.isNotEmpty ? metricValues.first : null;
    final latestValue = metricValues.isNotEmpty ? metricValues.last : null;
    final change = firstValue != null && latestValue != null
        ? latestValue - firstValue
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${opt.$2} Progress',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                    if (change != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _chartChangeLabel(opt.$1, opt.$2, change, opt.$3),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isPositiveChange(opt.$1, change)
                              ? AppTheme.figmaGreen
                              : AppTheme.figmaMutedGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Metric selector chips
              Row(
                children: _chartOptions.map((o) {
                  final active = o.$1 == _chartMetric;
                  // Only show chip if there are ≥2 data points for that metric
                  if (!_hasChartData(records, o.$1)) return const SizedBox();
                  return GestureDetector(
                    onTap: () => setState(() => _chartMetric = o.$1),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.figmaGreen
                            : AppTheme.figmaGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        o.$2,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: active ? Colors.white : AppTheme.figmaGreen,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _LinechartPainter(values: values),
              size: const Size(double.infinity, 120),
            ),
          ),
          const SizedBox(height: 8),
          // X-axis date labels (first and last)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _shortDate(chronological.first['recordedAt'] as String?),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.coolGray,
                ),
              ),
              if (chronological.length > 2)
                Text(
                  '${chronological.length} entries',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.coolGray,
                  ),
                ),
              Text(
                _shortDate(chronological.last['recordedAt'] as String?),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.coolGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard(List<Map<String, dynamic>> records) {
    final insight = _buildInsight(records);
    final latest = records.first;
    final entries = records.length;
    final latestWeight = _num(latest['weightKg']);
    final latestWaist = _num(latest['waistIn']);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFFFF5), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.figmaGreen.withAlpha(35)),
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.figmaGreen.withAlpha(18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppTheme.figmaGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      insight.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        color: AppTheme.figmaMutedGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryPill(
                Icons.timeline_rounded,
                '$entries',
                entries == 1 ? 'entry' : 'entries',
              ),
              const SizedBox(width: 10),
              _summaryPill(
                Icons.monitor_weight_outlined,
                latestWeight ?? '—',
                latestWeight == null ? 'weight' : 'kg now',
              ),
              const SizedBox(width: 10),
              _summaryPill(
                Icons.straighten_rounded,
                latestWaist ?? '—',
                latestWaist == null ? 'waist' : 'in waist',
              ),
            ],
          ),
          if (insight.detail != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(210),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                insight.detail!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: AppTheme.figmaGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryPill(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8F3EC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppTheme.figmaGreen),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.figmaCharcoal,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.coolGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────

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
            'Tap "+ Add Entry" above to record\nyour first body metrics snapshot.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.coolGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── History Card ─────────────────────────────────────────────────────────

  Widget _buildCard(
    Map<String, dynamic> record,
    bool isLatest,
    Map<String, dynamic>? previous,
  ) {
    final date = DateTime.tryParse(record['recordedAt'] as String? ?? '');
    final dateLabel = date != null ? _formatDate(date) : '—';
    final courseTitle = record['courseTitle'] as String?;

    // Count filled fields (excluding name, courseId, id, recordedAt)
    final metricKeys = ['age', 'heightCm', 'weightKg', 'waistIn', 'hipIn'];
    final filledCount = metricKeys.where((k) => record[k] != null).length;
    final totalCount = metricKeys.length;
    final isPartial = filledCount > 0 && filledCount < totalCount;

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
          // Date row + Latest badge
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
              Row(
                children: [
                  if (isPartial)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$filledCount/$totalCount fields',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  if (isLatest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
          _buildMetricsGrid(record, previous),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> r, Map<String, dynamic>? prev) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _metric(
          'Age',
          r['age']?.toString(),
          'yrs',
          delta: _intDelta(r['age'], prev?['age']),
        ),
        _metric(
          'Height',
          _num(r['heightCm']),
          'cm',
          delta: _numDelta(r['heightCm'], prev?['heightCm']),
        ),
        _metric(
          'Weight',
          _num(r['weightKg']),
          'kg',
          delta: _numDelta(r['weightKg'], prev?['weightKg']),
        ),
        _metric(
          'Waist',
          _num(r['waistIn']),
          'in',
          delta: _numDelta(r['waistIn'], prev?['waistIn']),
        ),
        _metric(
          'Hip',
          _num(r['hipIn']),
          'in',
          delta: _numDelta(r['hipIn'], prev?['hipIn']),
        ),
      ],
    );
  }

  Widget _metric(String label, String? value, String unit, {_Delta? delta}) {
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
                fontSize: 17,
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
        if (delta != null && value != null)
          Row(
            children: [
              Icon(
                delta.isDown
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 10,
                color: delta.color,
              ),
              const SizedBox(width: 1),
              Text(
                delta.label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: delta.color,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ─── Delta helpers ────────────────────────────────────────────────────────

  _Delta? _numDelta(dynamic curr, dynamic prev) {
    final c = _toDouble(curr);
    final p = _toDouble(prev);
    if (c == null || p == null) return null;
    final diff = c - p;
    if (diff == 0) return null;
    return _Delta(
      label: diff.abs().toStringAsFixed(1),
      isDown: diff < 0,
      // weight/waist going down = good (green); height going down = neutral
      color: diff < 0 ? AppTheme.figmaGreen : const Color(0xFFE65100),
    );
  }

  _Delta? _intDelta(dynamic curr, dynamic prev) {
    if (curr == null || prev == null) return null;
    final c = curr is int ? curr : int.tryParse(curr.toString());
    final p = prev is int ? prev : int.tryParse(prev.toString());
    if (c == null || p == null) return null;
    final diff = c - p;
    if (diff == 0) return null;
    return _Delta(
      label: '${diff.abs()}',
      isDown: diff < 0,
      color: AppTheme.coolGray,
    );
  }

  _Insight _buildInsight(List<Map<String, dynamic>> records) {
    if (records.length < 2) {
      return const _Insight(
        title: 'Your baseline is saved',
        subtitle:
            'Add another entry after a few sessions to see your change over time.',
        detail:
            'Tiny checkpoints make progress visible. Future you will love this breadcrumb trail.',
      );
    }

    final latest = records.first;
    final first = records.last;
    final candidates = <_MetricChange?>[
      _metricChange('weightKg', 'weight', 'kg', latest, first),
      _metricChange('waistIn', 'waist', 'in', latest, first),
      _metricChange('hipIn', 'hip', 'in', latest, first),
    ].whereType<_MetricChange>().toList();

    if (candidates.isEmpty) {
      return _Insight(
        title: '${records.length} check-ins logged',
        subtitle: 'You are building a clearer picture of your body and habits.',
        detail:
            'Keep adding entries consistently — the graph gets more useful with every snapshot.',
      );
    }

    final positive =
        candidates.where((c) => _isPositiveChange(c.key, c.change)).toList()
          ..sort((a, b) => b.change.abs().compareTo(a.change.abs()));
    final strongest = positive.isNotEmpty
        ? positive.first
        : (candidates..sort((a, b) => b.change.abs().compareTo(a.change.abs())))
              .first;
    final amount = strongest.change.abs().toStringAsFixed(1);

    if (positive.isNotEmpty) {
      return _Insight(
        title: 'You are moving in the right direction',
        subtitle:
            'Your ${strongest.label} is down $amount ${strongest.unit} from your first entry.',
        detail:
            'That is the quiet magic of showing up: small choices becoming visible progress.',
      );
    }

    return _Insight(
      title: 'Your journey is being measured',
      subtitle:
          '${records.length} entries give you a real trend, not just a guess.',
      detail:
          'Bodies fluctuate. The win is that you are paying attention and staying in the practice.',
    );
  }

  _MetricChange? _metricChange(
    String key,
    String label,
    String unit,
    Map<String, dynamic> latest,
    Map<String, dynamic> first,
  ) {
    final latestValue = _toDouble(latest[key]);
    final firstValue = _toDouble(first[key]);
    if (latestValue == null || firstValue == null) return null;
    final change = latestValue - firstValue;
    if (change.abs() < 0.05) return null;
    return _MetricChange(key: key, label: label, unit: unit, change: change);
  }

  bool _isPositiveChange(String key, double change) {
    if (key == 'weightKg' || key == 'waistIn' || key == 'hipIn') {
      return change < 0;
    }
    return change.abs() > 0.05;
  }

  String _chartChangeLabel(
    String key,
    String label,
    double change,
    String unit,
  ) {
    if (change.abs() < 0.05) return 'No major change yet — consistency first.';
    final direction = change < 0 ? 'down' : 'up';
    final amount = change.abs().toStringAsFixed(1);
    final tone = _isPositiveChange(key, change) ? 'Nice' : 'Tracked';
    return '$tone: $label is $direction $amount $unit since your first entry';
  }

  // ─── Utility ─────────────────────────────────────────────────────────────

  String? _num(dynamic val) {
    if (val == null) return null;
    final n = val is num ? val.toDouble() : double.tryParse(val.toString());
    if (n == null) return null;
    return n == n.truncateToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(1);
  }

  double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _shortDate(String? iso) {
    final d = iso != null ? DateTime.tryParse(iso) : null;
    if (d == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

// ─── Delta model ─────────────────────────────────────────────────────────────

class _Delta {
  final String label;
  final bool isDown;
  final Color color;
  const _Delta({
    required this.label,
    required this.isDown,
    required this.color,
  });
}

class _Insight {
  final String title;
  final String subtitle;
  final String? detail;

  const _Insight({required this.title, required this.subtitle, this.detail});
}

class _MetricChange {
  final String key;
  final String label;
  final String unit;
  final double change;

  const _MetricChange({
    required this.key,
    required this.label,
    required this.unit,
    required this.change,
  });
}

// ─── Chart painter ───────────────────────────────────────────────────────────

class _LinechartPainter extends CustomPainter {
  final List<double?> values;

  const _LinechartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    // Only plot non-null values, evenly spaced — avoids 2-segment "two waves" bug
    final nonNull = values.whereType<double>().toList();
    if (nonNull.length < 2) return;

    final minV = nonNull.reduce(min);
    final maxV = nonNull.reduce(max);
    final range = (maxV - minV).abs();
    final padV = range < 0.01 ? 1.0 : range * 0.15;
    final lo = minV - padV;
    final hi = maxV + padV;

    // Evenly space all non-null points across the full width
    final points = <Offset>[];
    for (int i = 0; i < nonNull.length; i++) {
      final x = size.width * i / (nonNull.length - 1);
      final y = size.height - (size.height * (nonNull[i] - lo) / (hi - lo));
      points.add(Offset(x, y.clamp(0.0, size.height)));
    }

    // Gradient fill
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.figmaGreen.withAlpha(60),
            AppTheme.figmaGreen.withAlpha(0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw single continuous line
    final linePaint = Paint()
      ..color = AppTheme.figmaGreen
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw dots
    final dotPaint = Paint()..color = AppTheme.figmaGreen;
    final dotBg = Paint()..color = Colors.white;
    for (final p in points) {
      canvas.drawCircle(p, 5, dotBg);
      canvas.drawCircle(p, 3.5, dotPaint);
    }

    // Value labels on first and last dot
    _drawLabel(canvas, points.first, nonNull.first, size);
    if (points.length > 1) _drawLabel(canvas, points.last, nonNull.last, size);
  }

  void _drawLabel(Canvas canvas, Offset p, double value, Size size) {
    final text = value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.figmaGreen,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Position above the dot, clamped to canvas bounds
    double dx = p.dx - tp.width / 2;
    double dy = p.dy - 18;
    dx = dx.clamp(0, size.width - tp.width);
    dy = dy.clamp(0, size.height - tp.height);
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_LinechartPainter old) => old.values != values;
}
