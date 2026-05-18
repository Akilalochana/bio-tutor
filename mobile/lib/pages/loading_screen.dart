import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:bio_teacher_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../services/gemma_service.dart';
import '../services/rag_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  // ───────────────── COLORS ─────────────────
  static const Color _navy = Color(0xFF081120);
  static const Color _navyLight = Color(0xFF12203D);
  static const Color _amber = Color(0xFFF5A623);
  static const Color _cyan = Color(0xFF00E5FF);
  static const Color _white = Colors.white;

  // ───────────────── STATE ─────────────────
  String _status = 'Starting...';
  bool _error = false;
  String _errorDetail = '';
  int _downloadProgress = 0;
  bool _isDownloading = false;

  final RagService _rag = RagService();

  static const String _modelFileName = 'gemma-4-E2B-it.litertlm';

  static const String _modelUrl =
      'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm';

  // ───────────────── BACKGROUND IMAGES ─────────────────
  final List<String> _bgImages = [
    'assets/images/gemma4_learn1.jpeg',
    'assets/images/gemma4_learn2.jpeg',
    'assets/images/gemma4_learn3.jpeg',
    'assets/images/gemma4_learn4.jpeg',
    'assets/images/gemma4_learn5.jpeg',
    'assets/images/gemma4_learn6.jpeg',
    'assets/images/gemma4_learn7.jpeg',
    'assets/images/gemma4_learn8.jpeg',
  ];

  int _currentBg = 0;

  // ───────────────── CONTROLLERS ─────────────────
  late final AnimationController _pulseCtrl;
  late final AnimationController _dotCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _zoomCtrl;
  late final AnimationController _dnaGlowCtrl;

  late final Animation<double> _pulseAnim;
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  late final PageController _bgController;

  Timer? _bgTimer;

  // ───────────────── INIT ─────────────────
  @override
  void initState() {
    super.initState();

    // Icon pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Loading dots
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dot1 = _makeStepAnim(0.0, 0.33);
    _dot2 = _makeStepAnim(0.33, 0.66);
    _dot3 = _makeStepAnim(0.66, 1.0);

    // Floating particles
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Background zoom
    _zoomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    // Icon glow
    _dnaGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Background slider
    _bgController = PageController();

    _bgTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_bgController.hasClients) return;

      _currentBg++;

      if (_currentBg >= _bgImages.length) {
        _currentBg = 0;
      }

      _bgController.animateToPage(
        _currentBg,
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeInOut,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  // ───────────────── DOT ANIMATION ─────────────────
  Animation<double> _makeStepAnim(double begin, double end) {
    return TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.3),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _dotCtrl,
        curve: Interval(begin, end, curve: Curves.easeInOut),
      ),
    );
  }

  // ───────────────── MODEL PATH ─────────────────
  Future<String> _getModelPath() async {
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      return '$userProfile\\Downloads\\$_modelFileName';
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      return p.join(docsDir.path, _modelFileName);
    }
  }

  // ───────────────── INITIALIZE ─────────────────
  Future<void> _initialize() async {
    try {
      setState(() => _status = '📚 Loading Biology DB ...');
      await _rag.load();

      setState(() => _status = '🔍 Searching for Model file...');

      final modelPath = await _getModelPath();
      final modelFile = File(modelPath);

      final modelExists = modelFile.existsSync();

      if (!modelExists) {
        if (Platform.isWindows) {
          setState(() {
            _error = true;
            _errorDetail = modelPath;
            _status = '❌ Model file not found!';
          });
          return;
        }

        setState(() {
          _isDownloading = true;
          _status = 'Downloading Model...\n(~2GB)';
        });

        await FlutterGemma.installModel(
          modelType: ModelType.gemma4,
        ).fromNetwork(_modelUrl).withProgress((progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
              _status = 'Downloading... $progress%';
            });
          }
        }).install();

        setState(() {
          _isDownloading = false;
          _status = '✅ Download complete';
        });
      }

      setState(() => _status = 'Loading Gemma 4...');
      await GemmaService.initialize(modelPath);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(rag: _rag),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _error = true;
        _status = '❌ Error occurred';
        _errorDetail = e.toString();
      });
    }
  }

  // ───────────────── DISPOSE ─────────────────
  @override
  void dispose() {
    _pulseCtrl.dispose();
    _dotCtrl.dispose();
    _particleCtrl.dispose();
    _zoomCtrl.dispose();
    _dnaGlowCtrl.dispose();

    _bgTimer?.cancel();
    _bgController.dispose();

    super.dispose();
  }

  // ───────────────── UI ─────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: Stack(
        children: [
          // ───────────────── BACKGROUND SLIDER ─────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _zoomCtrl,
              builder: (context, child) {
                final zoom = 1 + (_zoomCtrl.value * 0.12);

                return Transform.scale(
                  scale: zoom,
                  child: child,
                );
              },
              child: PageView.builder(
                controller: _bgController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _bgImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // IMAGE
                      Image.asset(
                        _bgImages[index],
                        fit: BoxFit.cover,
                      ),

                      // BLUR TRANSITION
                      BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 2.5,
                          sigmaY: 2.5,
                        ),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),

                      // DARK OVERLAY — lightened (0.58 → 0.28)
                      Container(
                        color: Colors.black.withOpacity(0.28),
                      ),

                      // NAVY GRADIENT — lightened
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _navy.withOpacity(0.25),
                              Colors.black.withOpacity(0.48),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ───────────────── PARALLAX SHAPES ─────────────────
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) {
                return Transform.translate(
                  offset: Offset(
                    math.sin(_particleCtrl.value * 2 * math.pi) * 18,
                    0,
                  ),
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _cyan.withOpacity(0.08),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: -100,
            left: -70,
            child: AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) {
                return Transform.translate(
                  offset: Offset(
                    -math.sin(_particleCtrl.value * 2 * math.pi) * 20,
                    0,
                  ),
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _amber.withOpacity(0.08),
                    ),
                  ),
                );
              },
            ),
          ),

          // ───────────────── FLOATING PARTICLES ─────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _particleCtrl,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ParticlePainter(_particleCtrl.value),
                  );
                },
              ),
            ),
          ),

          // ───────────────── CONTENT ─────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 34,
                vertical: 24,
              ),
              child: Column(
                children: [
                  // ───────────────── TOP LABELS ─────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'v4.0.2',
                        style: TextStyle(
                          color: _white.withOpacity(0.45),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'Offline AI',
                        style: TextStyle(
                          color: _white.withOpacity(0.45),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  

                 

                  const SizedBox(height: 26),

                  // ───────────────── TITLES ─────────────────
                  const Text(
                    'ජීව විද්‍යාව',
                    style: TextStyle(
                      color: _white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [_amber, _cyan],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Bio Tutor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'AI powered Advanced Level Biology learning assistant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _white.withOpacity(0.72),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 70),

                  // ───────────────── DOWNLOAD / LOADING ─────────────────
                  if (!_error) ...[
                    if (_isDownloading) ...[
                      Text(
                        '$_downloadProgress%',
                        style: const TextStyle(
                          color: _amber,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: LinearProgressIndicator(
                          value: _downloadProgress / 100,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(_amber),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _AnimatedDot(animation: _dot1, color: _amber),
                          const SizedBox(width: 8),
                          _AnimatedDot(animation: _dot2, color: _cyan),
                          const SizedBox(width: 8),
                          _AnimatedDot(animation: _dot3, color: _amber),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],

                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  ],

                  // ───────────────── ERROR ─────────────────
                  if (_error) ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 46,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _status,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = false;
                          _errorDetail = '';
                          _downloadProgress = 0;
                          _isDownloading = false;
                        });

                        _initialize();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _amber,
                        foregroundColor: _navy,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],

                  const Spacer(),

                  // ───────────────── FOOTER ─────────────────
                  Text(
                    'POWERED BY GEMMA 4',
                    style: TextStyle(
                      color: _white.withOpacity(0.45),
                      letterSpacing: 2,
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────── ANIMATED DOT ─────────────────
class _AnimatedDot extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _AnimatedDot({
    required this.animation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Opacity(
          opacity: animation.value,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ───────────────── STATIC DNA PAINTER ─────────────────
class _StaticDnaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintStrand = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00E5FF),
          const Color(0xFFF5A623),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintGlow = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final paintRung = Paint()
      ..color = Colors.white.withOpacity(0.30)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    final path2 = Path();

    const steps = 80;
    final cx = size.width / 2;
    final amp = size.width * 0.28;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final y = size.height * t;
      final x1 = cx - amp * math.sin(t * 2 * math.pi);
      final x2 = cx + amp * math.sin(t * 2 * math.pi);

      if (i == 0) {
        path1.moveTo(x1, y);
        path2.moveTo(x2, y);
      } else {
        path1.lineTo(x1, y);
        path2.lineTo(x2, y);
      }
    }

    // Glow
    canvas.drawPath(path1, paintGlow);
    canvas.drawPath(path2, paintGlow);

    // Strands
    canvas.drawPath(path1, paintStrand);
    canvas.drawPath(path2, paintStrand);

    // Rungs (cross bars)
    for (int i = 1; i <= 7; i++) {
      final t = i / 8.0;
      final y = size.height * t;
      final x1 = cx - amp * math.sin(t * 2 * math.pi);
      final x2 = cx + amp * math.sin(t * 2 * math.pi);

      // Rung glow
      canvas.drawLine(
        Offset(x1, y),
        Offset(x2, y),
        Paint()
          ..color = const Color(0xFF00E5FF).withOpacity(0.15)
          ..strokeWidth = 5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      canvas.drawLine(Offset(x1, y), Offset(x2, y), paintRung);

      // Small dots at ends
      canvas.drawCircle(
        Offset(x1, y),
        2.2,
        Paint()..color = const Color(0xFFF5A623).withOpacity(0.85),
      );
      canvas.drawCircle(
        Offset(x2, y),
        2.2,
        Paint()..color = const Color(0xFF00E5FF).withOpacity(0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ───────────────── PARTICLE PAINTER ─────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 40; i++) {
      final x = (i * 97.0 + progress * 200) % size.width;

      final y = ((i * 53.0) +
              math.sin(progress * 2 * math.pi + i) * 60) %
          size.height;

      final radius = (i % 4) + 1.5;

      paint.color = i.isEven
          ? const Color(0xFFF5A623).withOpacity(0.18)
          : const Color(0xFF00E5FF).withOpacity(0.18);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}