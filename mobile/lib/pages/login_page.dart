import 'dart:math' as math;
import 'package:bio_teacher_app/pages/home_page.dart';
import 'package:bio_teacher_app/services/rag_service.dart';
import 'package:flutter/material.dart';

// ── Replace this import with your actual home/quiz page ──
// import 'test_quiz_page.dart';

class LoginPage extends StatefulWidget {
  final RagService rag;           // ← add
  const LoginPage({super.key, required this.rag});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _bg       = Color(0xFFF0F2F5);
  static const Color _navy     = Color(0xFF1A2657);
  static const Color _amber    = Color(0xFFB8964E);
  static const Color _white    = Colors.white;
  static const Color _textDark = Color(0xFF1A2657);
  static const Color _textSub  = Color(0xFF8A96A8);
  static const Color _green    = Color(0xFF4CAF50);

  bool _isGoogleLoading = false;
  bool _isGuestLoading  = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In — coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF1A2657),
      ),
    );
  }

  Future<void> _handleGuestSignIn() async {
    setState(() => _isGuestLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isGuestLoading = false);
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => HomePage(
        rag: widget.rag,   // ← LoginPage ෙකේ rag pass කරන්නත් ඕන
        userName: 'Guest',
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 72),

                      // DNA App Icon
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: _navy,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: _navy.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 46,
                            height: 56,
                            child: CustomPaint(
                              painter: _DnaIconPainter(color: _amber),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'නැවත සාදරයෙන් පිළිගනිමු',
                        style: TextStyle(color: _textSub, fontSize: 14),
                      ),

                      const SizedBox(height: 44),

                      // Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Google Button
                            _NavyButton(
                              isLoading: _isGoogleLoading,
                              onTap: _handleGoogleSignIn,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                 
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Image.asset(
                                        'assets/images/images-removebg-preview.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // OR divider
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('හෝ  •  OR',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade400,
                                          letterSpacing: 0.5)),
                                ),
                                Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Guest Button
                            _OutlineButton(
                              isLoading: _isGuestLoading,
                              onTap: _handleGuestSignIn,
                              label: 'Continue as Guest',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'By continuing you agree to our Terms of Service and\nPrivacy Policy. Your data stays on device.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom badge
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: _green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ON-DEVICE  •  NO DATA COLLECTED',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavyButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final Widget child;
  const _NavyButton({required this.isLoading, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2657),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A2657).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : child,
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final String label;
  const _OutlineButton({required this.isLoading, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A2657)))
              : Text(label,
                  style: const TextStyle(
                    color: Color(0xFF1A2657),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
        ),
      ),
    );
  }
}

class _DnaIconPainter extends CustomPainter {
  final Color color;
  const _DnaIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strand = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dot = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final p1 = Path();
    final p2 = Path();
    for (int i = 0; i <= 80; i++) {
      final t = i / 80;
      final a = t * 2 * math.pi;
      final x1 = w / 2 + (w * 0.38) * math.sin(a);
      final x2 = w / 2 + (w * 0.38) * math.sin(a + math.pi);
      final y = h * t;
      if (i == 0) { p1.moveTo(x1, y); p2.moveTo(x2, y); }
      else { p1.lineTo(x1, y); p2.lineTo(x2, y); }
    }
    canvas.drawPath(p1, strand);
    canvas.drawPath(p2, strand);

    for (int i = 1; i <= 4; i++) {
      final t = i / 5.0;
      final a = t * 2 * math.pi;
      final x1 = w / 2 + (w * 0.38) * math.sin(a);
      final x2 = w / 2 + (w * 0.38) * math.sin(a + math.pi);
      final y = h * t;
      canvas.drawLine(Offset(x1, y), Offset(x2, y),
          Paint()..color = color.withOpacity(0.3)..strokeWidth = 1.5);
      canvas.drawCircle(Offset(x1, y), 2.5, dot);
      canvas.drawCircle(Offset(x2, y), 2.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}