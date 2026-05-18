import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResultsPage extends StatefulWidget {
  final int correct;
  final int total;
  final String timeElapsed; // e.g. "08:42"
  final int xpEarned;
  final VoidCallback onRestart;
  final VoidCallback onReviewWrong;

  const ResultsPage({
    super.key,
    required this.correct,
    required this.total,
    required this.timeElapsed,
    required this.xpEarned,
    required this.onRestart,
    required this.onReviewWrong,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with TickerProviderStateMixin {
  static const Color _navy  = Color(0xFF1A2657);
  static const Color _green = Color(0xFF27AE60);
  static const Color _amber = Color(0xFFF5A623);
  static const Color _bg    = Color(0xFFF0F2F5);

  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;
  late AnimationController _confettiCtrl;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.4,
        color: [
          const Color(0xFFF5A623),
          const Color(0xFF27AE60),
          const Color(0xFF1A2657),
          const Color(0xFF4285F4),
          Colors.pinkAccent,
        ][rng.nextInt(5)],
        size: 4 + rng.nextDouble() * 6,
        speed: 0.002 + rng.nextDouble() * 0.003,
      ));
    }

    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic);
    _ringCtrl.forward();

    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  double get _accuracy => widget.correct / widget.total;
  int get _wrong => widget.total - widget.correct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(_particles, _confettiCtrl.value),
                child: const SizedBox.expand(),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // ── Quiz Complete label ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: _amber, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text('QUIZ COMPLETE',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Title ──
                  const Text('විශිෂ්ට!',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      )),
                  const SizedBox(height: 4),
                  Text('Excellent work, Ravindu',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 14)),

                  const SizedBox(height: 36),

                  // ── Ring ──
                  AnimatedBuilder(
                    animation: _ringAnim,
                    builder: (_, __) => SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: _RingPainter(
                          progress: _ringAnim.value * _accuracy,
                          color: _green,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${widget.correct}',
                                      style: const TextStyle(
                                        color: _navy,
                                        fontSize: 44,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/${widget.total}',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${(_accuracy * 100).toStringAsFixed(0)}% ACCURACY',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Stats grid ──
                  Row(
                    children: [
                      _StatBox(label: 'CORRECT', value: '${widget.correct}',
                          color: _green),
                      const SizedBox(width: 12),
                      _StatBox(label: 'WRONG', value: '$_wrong',
                          color: Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatBox(label: 'TIME', value: widget.timeElapsed,
                          color: _navy),
                      const SizedBox(width: 12),
                      _StatBox(
                          label: 'XP EARNED',
                          value: '+${widget.xpEarned}',
                          color: _amber,
                          bold: true),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onReviewWrong,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('වැරදි පිළිතුරු',
                              style: TextStyle(
                                  color: Color(0xFF1A2657),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onRestart,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('නැවත පටන් ගනිමු'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_outlined,
                            size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Text('Share result',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;
  const _StatBox(
      {required this.label,
      required this.value,
      required this.color,
      this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: bold ? 22 : 28,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 10;

    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..color = Colors.grey.shade200
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress;
}

class _Particle {
  final double x;
  double y;
  final Color color;
  final double size;
  final double speed;
  _Particle(
      {required this.x,
      required this.y,
      required this.color,
      required this.size,
      required this.speed});
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ConfettiPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dy = (p.y + t * p.speed * 60) % 1.2;
      final paint = Paint()..color = p.color.withOpacity(0.7);
      canvas.drawCircle(
          Offset(p.x * size.width, dy * size.height), p.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}