import 'package:flutter/material.dart';
import '../services/rag_service.dart';
import 'test_quiz_page.dart';
import 'progress_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final RagService rag;
  final String userName;
  final String userEmail;

  const HomePage({
    super.key,
    required this.rag,
    this.userName = 'Guest',
    this.userEmail = '',
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _bg      = Color(0xFFF0F2F5);
  static const Color _navy    = Color(0xFF1A2657);
  static const Color _amber   = Color(0xFFF5A623);
  static const Color _white   = Colors.white;
  static const Color _textSub = Color(0xFF8A96A8);

  int _selectedTab     = 0;
  int _selectedMCQCount = 20; // Default: 20

  // ── MCQ options: 3 for testing, then real counts ──
  static const List<int> _mcqOptions = [3, 20, 30, 50];

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  final List<Map<String, dynamic>> _units = [
    {
      'unit': '01', 'title': 'Introduction to\nBiology',
      'sinhala': 'ජීව විද්‍යාව හැඳිනීම',
      'questions': 42, 'progress': 1.0, 'progressLabel': '100%', 'navy': true,
    },
    {
      'unit': '02', 'title': 'Chemical Basis\nof Life',
      'sinhala': 'රාසායනික සඳහාම',
      'questions': 58, 'progress': 0.65, 'progressLabel': '65%', 'navy': false,
    },
    {
      'unit': '03', 'title': 'Cellular Structure',
      'sinhala': 'සෛල විඥානය',
      'questions': 71, 'progress': 0.12, 'progressLabel': '12%', 'navy': false,
    },
    {
      'unit': '04', 'title': 'Evolution &\nGenetics',
      'sinhala': 'පරිණාමය',
      'questions': 96, 'progress': 0.0, 'progressLabel': '0%', 'navy': false,
    },
  ];

  // ── Navigate to quiz with selected count ──
  void _startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestQuizPage(
          rag: widget.rag,
          mcqCount: _selectedMCQCount,
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 28),

              // ── MCQ Count Selector Section ──
              _buildMcqSelectorSection(),
              const SizedBox(height: 20),

              // ── Learning Units ──
              _buildSectionLabel(),
              const SizedBox(height: 12),
              _buildUnitsGrid(),
            ],
          ),
        ),

        // ── Floating "Start Quiz" button ──
Positioned(
  bottom: 82,
  left: 20,
  right: 20,
  child: GestureDetector(
    onTap: _startQuiz,
    child: Container(
      height: 54,
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_selectedMCQCount MCQ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'ප්‍රශ්නාවලිය ආරම්භ කරන්න',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 14,
          ),
        ],
      ),
    ),
  ),
),
      ],
    );
  }

  Widget _currentPage() {
    switch (_selectedTab) {
      case 0: return _buildHomeBody();
      case 1: return const ProgressPage();
      case 2: return const HistoryPage();
      case 3: return ProfilePage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        profileImage: 'assets/images/image.png',
        onSignOut: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage(rag: widget.rag)),
          );
        },
      );
      default: return _buildHomeBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            _currentPage(),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    final initials = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'G';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student :  ${widget.userName}',
                  style: const TextStyle(
                      color: _textSub, fontSize: 12, letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(_greeting,
                  style: const TextStyle(
                      color: _navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const Text('🔥', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text('14',
                style: TextStyle(
                    color: _amber, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
        const SizedBox(width: 10),
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: _navy,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/image.png',
              fit: BoxFit.cover,
              width: 38,
              height: 38,
              errorBuilder: (_, __, ___) => Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Stats Row ──
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'TODAY', value: '42 MCQs', valueSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(
            label: 'ACCURACY',
            value: '84%',
            valueColor: const Color(0xFF27AE60),
            valueSize: 26)),
      ],
    );
  }

  // ── MCQ Count Selector (3 / 20 / 30 / 50) ──
  Widget _buildMcqSelectorSection() {
    // label, subtitle, icon per count
    Map<int, _McqMeta> meta = {
      3:  _McqMeta('ටෙස්ට්',   'Test · ~2 min',   Icons.science_rounded,              const Color(0xFF9B59B6)),
      20: _McqMeta('කෙටි',    'Short · ~15 min',  Icons.bolt_rounded,                 _amber),
      30: _McqMeta('මධ්‍යම',  'Medium · ~25 min', Icons.local_fire_department_rounded, const Color(0xFFE67E22)),
      50: _McqMeta('සම්පූර්ණ','Full · ~45 min',   Icons.emoji_events_rounded,          const Color(0xFF27AE60)),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                  color: _amber,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ප්‍රශ්න ගණන තෝරන්න',
                style: TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· SELECT MCQ COUNT',
                style: TextStyle(
                  color: _textSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 option cards in a row
          Row(
            children: _mcqOptions.asMap().entries.map((entry) {
              final idx     = entry.key;
              final count   = entry.value;
              final selected = _selectedMCQCount == count;
              final m        = meta[count]!;
              final isLast   = idx == _mcqOptions.length - 1;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMCQCount = count),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: isLast ? 0 : 7),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 6),
                    decoration: BoxDecoration(
                      color: selected ? _navy : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? _navy : Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: _navy.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          m.icon,
                          color: selected ? m.accent : _textSub,
                          size: 18,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$count',
                          style: TextStyle(
                            color: selected ? _white : _navy,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          m.label,
                          style: TextStyle(
                            color: selected ? _white : _navy,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.sub,
                          style: TextStyle(
                            color: selected ? Colors.white54 : _textSub,
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Section Label ──
  Widget _buildSectionLabel() {
    return Row(children: [
      Text('ඉගෙනීමේ ඒකක',
          style: TextStyle(
              color: _textSub,
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600)),
      const SizedBox(width: 8),
      Container(height: 1, width: 4, color: _textSub),
      const SizedBox(width: 6),
      Text('LEARNING UNITS',
          style: TextStyle(
              color: _textSub,
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600)),
    ]);
  }

  // ── Units Grid ──
  Widget _buildUnitsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: _units.map((u) => _UnitCard(unit: u)).toList(),
    );
  }

  // ── Bottom Nav ──
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'HOME'},
      {'icon': Icons.bar_chart_rounded, 'label': 'PROGRESS'},
      {'icon': Icons.history_rounded, 'label': 'HISTORY'},
      {'icon': Icons.person_outline_rounded, 'label': 'PROFILE'},
    ];

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(items[i]['icon'] as IconData,
                      color: selected ? _navy : Colors.grey.shade400,
                      size: 22),
                  const SizedBox(height: 3),
                  Text(items[i]['label'] as String,
                      style: TextStyle(
                          color: selected ? _navy : Colors.grey.shade400,
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  if (selected)
                    Container(
                        width: 4, height: 4,
                        decoration: BoxDecoration(
                            color: _amber, shape: BoxShape.circle))
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── MCQ option metadata ──
class _McqMeta {
  final String label;
  final String sub;
  final IconData icon;
  final Color accent;
  const _McqMeta(this.label, this.sub, this.icon, this.accent);
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final double valueSize;
  const _StatCard(
      {required this.label,
      required this.value,
      this.valueColor,
      this.valueSize = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
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
                  color: valueColor ?? const Color(0xFF1A2657),
                  fontSize: valueSize,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Unit Card ──
class _UnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  const _UnitCard({required this.unit});

  @override
  Widget build(BuildContext context) {
    final isNavy    = unit['navy'] as bool;
    final progress  = unit['progress'] as double;
    final bg        = isNavy ? const Color(0xFF1A2657) : Colors.white;
    final textC     = isNavy ? Colors.white : const Color(0xFF1A2657);
    final subC      = isNavy ? Colors.white54 : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isNavy ? Colors.transparent : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isNavy ? 0.15 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('UNIT ${unit['unit']}',
                  style: TextStyle(
                      color: subC,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              _ProgressRing(progress: progress, isNavy: isNavy),
            ],
          ),
          const SizedBox(height: 10),
          Text(unit['title'] as String,
              style: TextStyle(
                  color: textC,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3)),
          const SizedBox(height: 4),
          Text(unit['sinhala'] as String,
              style: TextStyle(color: subC, fontSize: 11)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${unit['questions']} Qs',
                  style: TextStyle(color: subC, fontSize: 11)),
              Text(unit['progressLabel'] as String,
                  style: TextStyle(
                      color: progress == 1.0
                          ? const Color(0xFFF5A623)
                          : (isNavy ? Colors.white70 : Colors.grey.shade400),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Progress Ring ──
class _ProgressRing extends StatelessWidget {
  final double progress;
  final bool isNavy;
  const _ProgressRing({required this.progress, required this.isNavy});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28, height: 28,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          ringColor: progress == 1.0
              ? const Color(0xFFF5A623)
              : (isNavy ? Colors.white38 : Colors.grey.shade200),
          progressColor: progress == 1.0
              ? const Color(0xFFF5A623)
              : (isNavy ? Colors.white : const Color(0xFF27AE60)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color progressColor;
  const _RingPainter(
      {required this.progress,
      required this.ringColor,
      required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2 - 2;
    final p  = Paint()
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap  = StrokeCap.round;

    p.color = ringColor;
    canvas.drawCircle(Offset(cx, cy), r, p);

    if (progress > 0) {
      p.color = progressColor;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -1.5707963,
        2 * 3.14159265 * progress,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}