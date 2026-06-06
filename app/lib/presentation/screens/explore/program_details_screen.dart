import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ProgramDetailsScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  final String? courseTitle;
  final String? courseImagePath;

  const ProgramDetailsScreen({
    super.key,
    this.showBackButton = true,
    this.courseTitle,
    this.courseImagePath,
  });

  @override
  ConsumerState<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends ConsumerState<ProgramDetailsScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bool isGuest = authState.user == null;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final int sessionCount = _isExpanded ? 30 : 5;

    // Use params passed in, or fall back to defaults
    final String title = widget.courseTitle ?? '30 Days Yoga Course';
    final String imagePath = widget.courseImagePath ?? 'assets/course_30_days.png';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8), // Figma cream background

      // ── Floating Enroll Now button (guests only) ──────────────────────────
      floatingActionButton: isGuest
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.push('/cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A859),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: const Color(0xFF00A859).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Row(
                    children: const [
                      // Left play icon inside a subtle circle
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Enroll Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Stack(
        children: [
          // 1. Scrollable Page Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            // Extra bottom padding so content isn't hidden behind the FAB
            padding: EdgeInsets.only(bottom: isGuest ? 80 : 0),
            child: Stack(
              children: [
                // Top Course Image
                Image.asset(
                  imagePath,
                  height: 360,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 360,
                    width: double.infinity,
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(Icons.self_improvement,
                        color: Color(0xFF00A859), size: 80),
                  ),
                ),
                
                // Overlapping details sheet starting at Y = 280 (overlaps bottom 80px of image)
                Column(
                  children: [
                    const SizedBox(height: 280),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60.0), // Rounded top details section to start!
                          topRight: Radius.circular(60.0),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Centered Title - dynamic
                          Center(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00A859),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3. Green Course Tags Pill Container (Height 39)
                          Container(
                            height: 39,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A859),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Tag 1: 30 days
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        '30 days',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Divider
                                Container(
                                  width: 1,
                                  height: 16,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                // Tag 2: Beginner
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.bar_chart_rounded, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Beginner',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Divider
                                Container(
                                  width: 1,
                                  height: 16,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                // Tag 3: 15m /day
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.access_time_rounded, size: 13, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        '15m /day',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 4. Description Section
                          const Text(
                            'About this program',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16, // Matches Figma 16px!
                              fontWeight: FontWeight.w600,
                              color: Colors.black, // Matches Figma Black!
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Wake up your body and mind with this 21-day mobility routine. Designed to improve your flexibility, reduce morning stiffness, and start your day with renewed energy and focus.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12, // Matches Figma 12px!
                              height: 1.45,
                              color: Color(0xFF5B5B5B), // Matches Figma Grey!
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 5. Instructor Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFC8D6CE)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Avatar Image
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage('assets/avatar_priya.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Text details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Deepa',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'Certified Yoga Instructor',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      Text(
                                        '8+ Years of Experience',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF00A859),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Circular chevron right action button
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xFFC8D6CE)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 4,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF00A859),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 6. Sessions header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Sessions',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15, // Matches Figma 15px!
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF231F20), // Charcoal color!
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 7. Sessions Outline List (Days 1 - 30 dynamically depending on isExpanded)
                          Column(
                            children: List.generate(sessionCount, (index) {
                              final int dayNumber = index + 1;
                              final String dayStr = dayNumber.toString().padLeft(2, '0');
                              return SessionDayTile(
                                index: dayStr,
                                title: 'Day $dayNumber',
                                subtitle: '5 Deep Sessions',
                                duration: '20Mins',
                                isGuest: isGuest,
                                onTap: () {
                                  if (isGuest) {
                                    context.go('/login');
                                  } else {
                                    context.push('/course/30-days-yoga');
                                  }
                                },
                              );
                            }),
                          ),

                          // 8. View All button at the bottom of Day 5
                          if (!_isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded = true;
                                    });
                                  },
                                  child: const Text(
                                    'View All',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00A859), // Figma Green
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 9. Fixed Back Button floating at the top left
          if (widget.showBackButton)
            Positioned(
              top: statusBarHeight + 12,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    if (isGuest) {
                      context.go('/unregistered');
                    } else {
                      context.go('/home');
                    }
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

}

class SessionDayTile extends StatefulWidget {
  final String index;
  final String title;
  final String subtitle;
  final String duration;
  final bool isGuest;
  final VoidCallback onTap;

  const SessionDayTile({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.isGuest,
    required this.onTap,
  });

  @override
  State<SessionDayTile> createState() => _SessionDayTileState();
}

class _SessionDayTileState extends State<SessionDayTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Dynamic sub-sessions listing matching the screenshot exactly
    final List<Map<String, String>> subSessions = [
      {'title': 'Asanas', 'duration': '10 mins'},
      {'title': 'Pranayama', 'duration': '20 mins'},
      {'title': 'Kriya', 'duration': '35 mins'},
      {'title': 'Pranayama', 'duration': '20 mins'},
      {'title': 'Kriya', 'duration': '35 mins'},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded ? const Color(0xFFE2E8F0) : const Color(0xFFC8D6CE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Becomes a green card when expanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isExpanded ? const Color(0xFF00A859) : Colors.white,
              borderRadius: _isExpanded 
                  ? BorderRadius.circular(16) 
                  : BorderRadius.circular(20),
              boxShadow: _isExpanded ? [
                BoxShadow(
                  color: const Color(0xFF00A859).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ] : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: _isExpanded 
                    ? BorderRadius.circular(16) 
                    : BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // Index Badge
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1.5,
                            color: _isExpanded ? Colors.white.withOpacity(0.6) : const Color(0xFF00A859),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.index,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: _isExpanded ? Colors.white : const Color(0xFF00A859),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                color: _isExpanded ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: _isExpanded ? Colors.white.withOpacity(0.8) : const Color(0xFF00A859),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: _isExpanded ? Colors.white.withOpacity(0.6) : Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 11,
                                  color: _isExpanded ? Colors.white.withOpacity(0.8) : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.duration,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: _isExpanded ? Colors.white.withOpacity(0.8) : const Color(0xFF757B79),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Dropdown chevron button (Styled with circle outline matching reference)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isExpanded ? Colors.white : const Color(0xFF00A859),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: _isExpanded ? Colors.white : const Color(0xFF00A859),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sub-sessions (only shown if expanded)
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: List.generate(subSessions.length, (subIndex) {
                  final session = subSessions[subIndex];
                  
                  // Choose icon painter based on session index/type
                  CustomPainter iconPainter;
                  String description = '';
                  if (subIndex == 0) {
                    iconPainter = const AsanaIconPainter(color: Color(0xFF00A859));
                    description = 'Build Strength & Flexibility';
                  } else if (subIndex == 1 || subIndex == 3) {
                    iconPainter = const LungsIconPainter(color: Color(0xFF00A859));
                    description = 'Breath. Calm. Energize.';
                  } else {
                    iconPainter = const KriyaIconPainter(color: Color(0xFF00A859));
                    description = 'Activate & Strengthen';
                  }

                  return InkWell(
                    onTap: widget.onTap,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          // Left: Light Green Circle with Custom Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CustomPaint(
                                  painter: iconPainter,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Middle: Text Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session['title']!,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  session['duration']!,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00A859),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right: Green Circular Play Button
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00A859),
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Color(0xFF00A859),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Custom sub-sessions outline painters

class AsanaIconPainter extends CustomPainter {
  final Color color;
  const AsanaIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final double w = size.width;
    final double h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.65, h * 0.25), w * 0.08, paint);
    
    // Spine
    final spine = Path();
    spine.moveTo(w * 0.65, h * 0.33);
    spine.quadraticBezierTo(w * 0.50, h * 0.35, w * 0.40, h * 0.50);
    canvas.drawPath(spine, paint);

    // Arm
    canvas.drawLine(Offset(w * 0.58, h * 0.35), Offset(w * 0.35, h * 0.60), paint);

    // Legs
    final leg = Path();
    leg.moveTo(w * 0.40, h * 0.50);
    leg.lineTo(w * 0.75, h * 0.75);
    leg.moveTo(w * 0.40, h * 0.50);
    leg.lineTo(w * 0.25, h * 0.75);
    leg.lineTo(w * 0.45, h * 0.75);
    canvas.drawPath(leg, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LungsIconPainter extends CustomPainter {
  final Color color;
  const LungsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    canvas.drawLine(Offset(cx, h * 0.2), Offset(cx, h * 0.45), paint);
    canvas.drawLine(Offset(cx, h * 0.45), Offset(w * 0.38, h * 0.55), paint);
    canvas.drawLine(Offset(cx, h * 0.45), Offset(w * 0.62, h * 0.55), paint);

    final leftLobe = Path();
    leftLobe.moveTo(cx - 2, h * 0.38);
    leftLobe.quadraticBezierTo(w * 0.20, h * 0.35, w * 0.18, h * 0.60);
    leftLobe.quadraticBezierTo(w * 0.20, h * 0.80, w * 0.42, h * 0.78);
    leftLobe.quadraticBezierTo(w * 0.45, h * 0.65, cx - 2, h * 0.45);
    canvas.drawPath(leftLobe, paint);

    final rightLobe = Path();
    rightLobe.moveTo(cx + 2, h * 0.38);
    rightLobe.quadraticBezierTo(w * 0.80, h * 0.35, w * 0.82, h * 0.60);
    rightLobe.quadraticBezierTo(w * 0.80, h * 0.80, w * 0.58, h * 0.78);
    rightLobe.quadraticBezierTo(w * 0.55, h * 0.65, cx + 2, h * 0.45);
    canvas.drawPath(rightLobe, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KriyaIconPainter extends CustomPainter {
  final Color color;
  const KriyaIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    canvas.drawCircle(Offset(cx, h * 0.35), w * 0.08, paint);

    final body = Path();
    body.moveTo(cx, h * 0.43);
    body.lineTo(cx, h * 0.65);
    body.moveTo(cx - w * 0.20, h * 0.75);
    body.quadraticBezierTo(cx, h * 0.78, cx + w * 0.20, h * 0.75);
    body.quadraticBezierTo(cx, h * 0.62, cx - w * 0.20, h * 0.75);
    canvas.drawPath(body, paint);

    canvas.drawLine(Offset(cx - w * 0.08, h * 0.48), Offset(cx - w * 0.16, h * 0.65), paint);
    canvas.drawLine(Offset(cx + w * 0.08, h * 0.48), Offset(cx + w * 0.16, h * 0.65), paint);

    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, h * 0.35), width: w * 0.32, height: h * 0.32),
      -3.14159 * 0.8,
      3.14159 * 0.6,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, h * 0.35), width: w * 0.48, height: h * 0.48),
      -3.14159 * 0.8,
      3.14159 * 0.6,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
