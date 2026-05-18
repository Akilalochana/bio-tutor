import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  static const Color _navy  = Color(0xFF1A2657);
  static const Color _green = Color(0xFF27AE60);
  static const Color _amber = Color(0xFFF5A623);
  static const Color _bg    = Color(0xFFF0F2F5);

  // Mock 49-day activity data (0.0 = none, 1.0 = full)
  static final List<double> _activity = List.generate(49, (i) {
    final rng = math.Random(i * 7);
    return rng.nextDouble();
  });

  // Mock accuracy trend (last 7 days)
  static final List<double> _trend = [76, 78, 80, 79, 82, 83, 84]
      .map((v) => v / 100)
      .toList();

  static final List<Map<String, dynamic>> _units = [
    {'name': 'Introduction to Biology', 'progress': 1.0, 'color': _green},
    {'name': 'Chemical Basis of Life', 'progress': 0.65, 'color': _amber},
    {'name': 'Cellular Structure', 'progress': 0.12, 'color': Colors.redAccent},
    {'name': 'Evolution & Genetics', 'progress': 0.0, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('ANALYTICS',
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('පුගතිය',
              style: TextStyle(
                  color: _navy, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),

          // Activity Grid
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ACTIVITY · LAST 49 DAYS',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600)),
                    Row(children: [
                      const Icon(Icons.local_fire_department,
                          color: _amber, size: 14),
                      const SizedBox(width: 4),
                      Text('14d streak',
                          style: const TextStyle(
                              color: _amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ],
                ),
                const SizedBox(height: 12),
                _ActivityGrid(activity: _activity),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Less',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 10)),
                    const SizedBox(width: 4),
                    for (double op in [0.15, 0.35, 0.55, 0.8, 1.0])
                      Container(
                        width: 10, height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _navy.withOpacity(op),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    const SizedBox(width: 4),
                    Text('More',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Accuracy Trend
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ACCURACY TREND',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600)),
                    Text('+12% this week',
                        style: const TextStyle(
                            color: _green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('84%',
                    style: TextStyle(
                        color: _navy,
                        fontSize: 32,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: CustomPaint(
                    painter: _TrendPainter(data: _trend),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Unit Mastery
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UNIT MASTERY',
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                ..._units.map((u) => _UnitProgress(
                      name: u['name'] as String,
                      progress: u['progress'] as double,
                      color: u['color'] as Color,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: child,
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  final List<double> activity;
  const _ActivityGrid({required this.activity});

  @override
  Widget build(BuildContext context) {
    const cols = 7;
    const rows = 7;
    return SizedBox(
      height: rows * 14.0,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
        ),
        itemCount: cols * rows,
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A2657).withOpacity(
                i < activity.length ? activity[i] * 0.9 + 0.05 : 0.05),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> data;
  const _TrendPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final min = data.reduce(math.min);
    final max = data.reduce(math.max);
    final range = (max - min).clamp(0.01, 1.0);

    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - (data[i] - min) / range * size.height * 0.8 - size.height * 0.1;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF27AE60).withOpacity(0.2),
              const Color(0xFF27AE60).withOpacity(0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill);

    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF27AE60)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // Amber dot at end
    final lastX = size.width;
    final lastY = size.height -
        (data.last - min) / range * size.height * 0.8 -
        size.height * 0.1;
    canvas.drawCircle(Offset(lastX, lastY), 5,
        Paint()..color = const Color(0xFFF5A623));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _UnitProgress extends StatelessWidget {
  final String name;
  final double progress;
  final Color color;
  const _UnitProgress(
      {required this.name, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: Color(0xFF1A2657),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text('${(progress * 100).toInt()}%',
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}