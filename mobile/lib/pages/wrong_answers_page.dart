import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/gemma_service.dart';
import '../services/rag_service.dart';

class WrongAnswersPage extends StatefulWidget {
  final List<Map<String, dynamic>> wrongQuestions;
  final RagService rag;

  const WrongAnswersPage({
    super.key,
    required this.wrongQuestions,
    required this.rag,
  });

  @override
  State<WrongAnswersPage> createState() => _WrongAnswersPageState();
}

class _WrongAnswersPageState extends State<WrongAnswersPage> {
  static const Color _navy  = Color(0xFF1A2657);
  static const Color _amber = Color(0xFFF5A623);
  static const Color _bg    = Color(0xFFF0F2F5);
  static const Color _green = Color(0xFF27AE60);
  static const Color _red   = Color(0xFFE74C3C);

  // ── State per question ──
  int _currentIndex = 0;
  final Map<int, String> _aiOutput  = {};
  final Map<int, bool>   _loading   = {};
  bool _explanationRequested = false;

  QuestionModel get _q =>
      (widget.wrongQuestions[_currentIndex]['question'] as QuestionModel);
  String get _userAns =>
      widget.wrongQuestions[_currentIndex]['userAnswer'] as String;

  // ── Fetch AI explanation for current index ──
  Future<void> _getExplanation() async {
    if (_aiOutput.containsKey(_currentIndex)) return;
    if (!GemmaService.isReady) {
      setState(() => _aiOutput[_currentIndex] = 'Gemma model එක load වී නොමැත.');
      return;
    }

    setState(() {
      _loading[_currentIndex] = true;
      _explanationRequested = true;
    });

    final ctx        = widget.rag.retrieve(_q.question);
    final studentAns = _q.options[_userAns] ?? _userAns;

    final stream = GemmaService.explainAsTeacher(
      question:      _q.question,
      studentAnswer: studentAns,
      correctAnswer: _q.correctText,
      context:       ctx,
    );

    await for (final token in stream) {
      if (!mounted) break;
      setState(() => _aiOutput[_currentIndex] =
          (_aiOutput[_currentIndex] ?? '') + token);
    }
    if (mounted) setState(() => _loading[_currentIndex] = false);
  }

  void _goNext() {
    if (_currentIndex < widget.wrongQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _explanationRequested = false;
      });
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _explanationRequested = false;
      });
    }
  }

  // ── Source badge: "AL 2019 · Q14" ──
  Widget _buildSourceBadge() {
    // Try to get question number from model; fallback to index+1
    final year     = _q.year;
    final qNum     = _q.questionNumber; // add this field if not present — see note
    final yearStr  = year > 0 ? 'A/L $year' : 'A/L Paper';
    final qNumStr  = qNum > 0 ? ' · Q$qNum' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _navy.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 12, color: _navy),
          const SizedBox(width: 5),
          Text(
            '$yearStr$qNumStr',
            style: const TextStyle(
              color: _navy,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.wrongQuestions.length;
    if (total == 0) {
      return Scaffold(
        backgroundColor: _bg,
        body: const Center(child: Text('වැරදි පිළිතුරු නොමැත!')),
      );
    }

    final hasAI      = _aiOutput.containsKey(_currentIndex);
    final isLoading  = _loading[_currentIndex] ?? false;
    final isFirst    = _currentIndex == 0;
    final isLast     = _currentIndex == total - 1;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            _buildTopBar(total),

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Question source info ──
                    Row(
                      children: [
                        _buildSourceBadge(),
                        const SizedBox(width: 8),
                        _DiffBadge(unit: _q.unit),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Question card ──
                    _buildQuestionCard(),
                    const SizedBox(height: 12),

                    // ── Answer chips ──
                    _buildAnswerRow(),
                    const SizedBox(height: 16),

                    // ── All options (read-only, highlighted) ──
                    ..._q.options.entries.map((e) => _OptionTile(
                          label:       e.key,
                          text:        e.value,
                          userAnswer:  _userAns,
                          correctAnswer: _q.correctAnswer,
                        )),
                    const SizedBox(height: 16),

                    // ── AI explanation toggle ──
                    _buildAIToggle(),
                    const SizedBox(height: 8),

                    // ── AI output ──
                    if (_explanationRequested) _buildAIOutput(hasAI, isLoading),
                  ],
                ),
              ),
            ),

            // ── Bottom navigation ──
            _buildBottomNav(isFirst, isLast),
          ],
        ),
      ),
    );
  }

  // ── Top bar ──
  Widget _buildTopBar(int total) {
    final progress = ((_currentIndex + 1) / total).clamp(0.0, 1.0);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: _navy),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('වැරදි පිළිතුරු සමාලෝචනය',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        )),
                    Text('WRONG ANSWERS REVIEW',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 9,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
              // Counter badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentIndex + 1} / $total',
                  style: const TextStyle(
                    color: _red,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(_red),
            ),
          ),
        ],
      ),
    );
  }

  // ── Question card ──
  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        _q.question,
        style: const TextStyle(
          color: _navy,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
    );
  }

  // ── Your answer vs correct answer ──
  Widget _buildAnswerRow() {
    final userText    = _q.options[_userAns] ?? _userAns;
    final correctText = _q.correctText;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _red.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.cancel_rounded, color: _red, size: 13),
                  const SizedBox(width: 4),
                  Text('ඔබගේ පිළිතුර',
                      style: TextStyle(
                          color: _red,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ]),
                const SizedBox(height: 4),
                Text('$_userAns. $userText',
                    style: const TextStyle(
                        color: _red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _green.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      color: _green, size: 13),
                  const SizedBox(width: 4),
                  Text('නිවැරදි පිළිතුර',
                      style: TextStyle(
                          color: _green,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ]),
                const SizedBox(height: 4),
                Text('${_q.correctAnswer}. $correctText',
                    style: const TextStyle(
                        color: _green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── AI explanation toggle button ──
  Widget _buildAIToggle() {
    return GestureDetector(
      onTap: _getExplanation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _explanationRequested
              ? const Color(0xFFEDF7F0)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _explanationRequested
                ? _green.withOpacity(0.35)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            // GEMMA badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text('GEMMA 4',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: 7),
            // ON-DEVICE dot
            Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: _green, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _explanationRequested
                    ? 'AI explanation (if needed)'
                    : 'Get an AI explanation (if needed)',
                style: TextStyle(
                  color: _explanationRequested ? _green : _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!_explanationRequested)
              const Icon(Icons.auto_awesome_rounded,
                  color: _amber, size: 18),
            if (_explanationRequested)
              const Icon(Icons.check_circle_rounded,
                  color: _green, size: 18),
          ],
        ),
      ),
    );
  }

  // ── AI output box ──
  Widget _buildAIOutput(bool hasAI, bool isLoading) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: !hasAI && isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                        color: _green, strokeWidth: 2),
                    SizedBox(height: 10),
                    Text('ගුරුතුමා සිතනවා...',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.school_rounded,
                        color: _green, size: 16),
                    const SizedBox(width: 6),
                    const Text('Gemma4 explanation',
                        style: TextStyle(
                          color: _green,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        )),
                    const Spacer(),
                    if (isLoading)
                      const SizedBox(
                        width: 12, height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _green),
                      ),
                  ],
                ),
                const Divider(height: 16),
                SelectableText(
                  _aiOutput[_currentIndex] ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.75),
                ),
              ],
            ),
    );
  }

  // ── Bottom nav: prev / next ──
  Widget _buildBottomNav(bool isFirst, bool isLast) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          // Prev button
          GestureDetector(
            onTap: isFirst ? null : _goPrev,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isFirst ? Colors.grey.shade100 : _navy.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFirst
                      ? Colors.grey.shade200
                      : _navy.withOpacity(0.2),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isFirst ? Colors.grey.shade400 : _navy,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Next / Done button
          Expanded(
            child: GestureDetector(
              onTap: isLast ? () => Navigator.pop(context) : _goNext,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isLast ? _green : _navy,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (isLast ? _green : _navy).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLast ? 'සම්පූර්ණයි!' : 'ඊළඟ ප්‍රශ්නය',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
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

// ── Option Tile (read-only, shows correct/wrong highlight) ──
class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final String userAnswer;
  final String correctAnswer;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.userAnswer,
    required this.correctAnswer,
  });

  static const Color _navy  = Color(0xFF1A2657);
  static const Color _green = Color(0xFF27AE60);
  static const Color _red   = Color(0xFFE74C3C);

  bool get _isCorrect => label == correctAnswer;
  bool get _isUserWrong => label == userAnswer && label != correctAnswer;

  Color get _bg {
    if (_isCorrect) return const Color(0xFFEDF7F0);
    if (_isUserWrong) return const Color(0xFFFEEEEE);
    return Colors.white;
  }

  Color get _border {
    if (_isCorrect) return _green;
    if (_isUserWrong) return _red;
    return Colors.grey.shade200;
  }

  Color get _labelBg {
    if (_isCorrect) return _green;
    if (_isUserWrong) return _red;
    return Colors.grey.shade100;
  }

  Color get _labelText {
    if (_isCorrect || _isUserWrong) return Colors.white;
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration:
                BoxDecoration(color: _labelBg, shape: BoxShape.circle),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      color: _labelText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                  color: _isCorrect
                      ? _green
                      : (_isUserWrong ? _red : _navy),
                  fontSize: 14,
                  fontWeight: _isCorrect || _isUserWrong
                      ? FontWeight.w600
                      : FontWeight.w400,
                  height: 1.4,
                )),
          ),
          if (_isCorrect)
            const Icon(Icons.check_circle_rounded, color: _green, size: 20),
          if (_isUserWrong)
            const Icon(Icons.cancel_rounded, color: _red, size: 20),
        ],
      ),
    );
  }
}

// ── Difficulty Badge ──
class _DiffBadge extends StatelessWidget {
  final String unit;
  const _DiffBadge({required this.unit});

  @override
  Widget build(BuildContext context) {
    final label = int.tryParse(unit) != null && int.parse(unit) <= 2
        ? 'MEDIUM'
        : 'HARD';
    final color =
        label == 'MEDIUM' ? const Color(0xFFF5A623) : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}