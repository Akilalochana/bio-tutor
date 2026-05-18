import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/gemma_service.dart';
import '../services/rag_service.dart';
import 'results_page.dart';
import 'wrong_answers_page.dart';

class TestQuizPage extends StatefulWidget {
  final RagService rag;
  final int mcqCount;

  const TestQuizPage({super.key, required this.rag, required this.mcqCount});

  @override
  State<TestQuizPage> createState() => _TestQuizPageState();
}

class _TestQuizPageState extends State<TestQuizPage> {
  static const Color _navy  = Color(0xFF1A2657);
  static const Color _amber = Color(0xFFF5A623);
  static const Color _bg    = Color(0xFFF0F2F5);
  static const Color _green = Color(0xFF27AE60);
  static const Color _red   = Color(0xFFE74C3C);

  List<QuestionModel> _questions = [];

  int     _currentIndex   = 0;
  String? _selectedAnswer;
  bool    _submitted      = false;

  // AI state — only meaningful when answer is wrong (or user opts in for correct)
  String _aiOutput            = '';
  bool   _isGenerating        = false;
  bool   _aiDone              = false;
  bool   _correctAiRequested  = false; // user tapped optional AI on correct

  final ScrollController _scrollCtrl = ScrollController();

  late Timer _timer;
  int _secondsElapsed = 0;

  final List<Map<String, dynamic>> _wrongAnswers = [];
  int _correctCount = 0;

  QuestionModel get _question  => _questions[_currentIndex];
  int           get _total     => _questions.length;
  bool          get _isCorrect => _selectedAnswer == _question.correctAnswer;
  bool          get _isLast    => _currentIndex == _total - 1;

  String get _timerLabel {
    final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _difficulty {
    if (_currentIndex < _total * 0.4) return 'EASY';
    if (_currentIndex < _total * 0.8) return 'MEDIUM';
    return 'HARD';
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadQuestions(widget.mcqCount);
  }

  Future<void> _loadQuestions(int count) async {
    final files = [
      'assets/papers/AL_2017_Biology_MCQ_1_to_40.json',
      'assets/papers/AL_2018_Biology_MCQ_1_to_40.json',
      'assets/papers/AL_2019_Biology_MCQ_1_to_40.json',
      'assets/papers/AL_2020_Biology_MCQ_1_to_40.json',
    ];

    final Map<int, List<QuestionModel>> byYear = {};
    for (final f in files) {
      try {
        final s    = await rootBundle.loadString(f);
        final data = jsonDecode(s) as List<dynamic>;
        final models = data
            .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (models.isNotEmpty) byYear[models.first.year] = models;
      } catch (_) {}
    }

    final years = byYear.keys.toList()..sort();
    if (years.isEmpty) return;

    final perYear  = count ~/ years.length;
    int remainder  = count % years.length;
    final selected = <QuestionModel>[];
    final rand     = Random();

    for (int i = 0; i < years.length; i++) {
      final list = List<QuestionModel>.from(byYear[years[i]]!);
      list.shuffle(rand);
      int n = perYear + (remainder > 0 ? 1 : 0);
      if (remainder > 0) remainder--;
      if (n > list.length) n = list.length;
      selected.addAll(list.take(n));
    }
    selected.shuffle(rand);

    if (mounted) {
      setState(() {
        _questions    = selected;
        _currentIndex = 0;
        _resetQuestionState();
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  void _resetQuestionState() {
    _selectedAnswer     = null;
    _submitted          = false;
    _aiOutput           = '';
    _isGenerating       = false;
    _aiDone             = false;
    _correctAiRequested = false;
  }

  
  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    setState(() => _submitted = true);

    if (_isCorrect) {
      _correctCount++;
      setState(() => _aiDone = true); // next button available immediately
    } else {
      _wrongAnswers.add({
        'question':   _question,
        'userAnswer': _selectedAnswer,
      });
      _getExplanation(); // auto-start AI for wrong answers
    }
  }

  // ── AI explanation via RAG + Gemma ──
  Future<void> _getExplanation() async {
    if (!GemmaService.isReady) {
      if (mounted) setState(() => _aiDone = true);
      return;
    }

    setState(() {
      _isGenerating = true;
      _aiOutput     = '';
    });

    final ctx        = widget.rag.retrieve(_question.question);
    final studentAns = _question.options[_selectedAnswer] ?? _selectedAnswer ?? '';

    try {
      final stream = GemmaService.explainAsTeacher(
        question:      _question.question,
        studentAnswer: studentAns,
        correctAnswer: _question.correctText,
        context:       ctx,
      );

      await for (final token in stream) {
        if (!mounted) return;
        setState(() => _aiOutput += token);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _aiDone       = true; // ✅ unlock next button
      });
    }
  }

  void _nextQuestion() {
    if (!_aiDone) return;

    if (_isLast) {
      _timer.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsPage(
            correct:     _correctCount,
            total:       _total,
            timeElapsed: _timerLabel,
            xpEarned:    _correctCount * 20,
            onRestart: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TestQuizPage(rag: widget.rag, mcqCount: widget.mcqCount),
                ),
              );
            },
            onReviewWrong: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WrongAnswersPage(
                    wrongQuestions: _wrongAnswers,
                    rag: widget.rag,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex++;
        _resetQuestionState();
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            if (_questions.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildQuestionMeta(),
                      const SizedBox(height: 12),
                      _buildQuestionCard(),
                      const SizedBox(height: 14),

                      // Options
                      ..._question.options.entries.map((e) => _OptionTile(
                            label:     e.key,
                            text:      e.value,
                            selected:  _selectedAnswer == e.key,
                            submitted: _submitted,
                            isCorrect: e.key == _question.correctAnswer,
                            onTap:     _submitted
                                ? null
                                : () => setState(() => _selectedAnswer = e.key),
                          )),

                      const SizedBox(height: 16),

                      // ── Post-submit ──
                      if (_submitted) ...[
                        if (_isCorrect) ...[
                          _buildCorrectBanner(),
                          const SizedBox(height: 12),
                          // Optional AI button — only if not yet requested
                          if (!_correctAiRequested)
                            _buildOptionalAIButton()
                          else
                            _buildAIBox(isCorrect: true),
                        ],
                        if (!_isCorrect) ...[
                          _buildWrongBanner(),
                          const SizedBox(height: 12),
                          _buildAIBox(isCorrect: false),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final progress = _total == 0
        ? 0.0
        : (_currentIndex + (_submitted ? 1 : 0)) / _total;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.close_rounded, size: 18, color: _navy),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(_navy),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _total == 0 ? '0/0' : '${_currentIndex + 1}/$_total',
            style: const TextStyle(
                color: _navy, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.timer_outlined, size: 13, color: _amber),
              const SizedBox(width: 4),
              Text(_timerLabel,
                  style: const TextStyle(
                      color: _amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionMeta() {
    final diffColor = _difficulty == 'HARD'
        ? Colors.redAccent
        : (_difficulty == 'MEDIUM' ? _amber : _green);

    return Row(
      children: [
        Text(
          'QUESTION ${_currentIndex + 1}  ·  ${_question.unit}',
          style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: diffColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(_difficulty,
              style: TextStyle(
                  color: diffColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
        ),
      ],
    );
  }

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
              offset: const Offset(0, 3))
        ],
      ),
      child: Text(
        _question.question,
        style: const TextStyle(
            color: _navy, fontSize: 15, fontWeight: FontWeight.w700, height: 1.5),
      ),
    );
  }

  // ── ✅ Correct banner ──
  Widget _buildCorrectBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: _green.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: _green, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('correct! 🎉',
                    style: TextStyle(
                        color: _green, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('${_question.correctAnswer}. ${_question.correctText}',
                    style: TextStyle(
                        color: _green.withOpacity(0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ❌ Wrong banner ──
  Widget _buildWrongBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: _red.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, color: _red, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('wrong!',
                    style: TextStyle(
                        color: _red, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('correct: ${_question.correctAnswer}. ${_question.correctText}',
                    style: const TextStyle(
                        color: _green, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Optional AI button (correct answers only) ──
  Widget _buildOptionalAIButton() {
    return GestureDetector(
      onTap: () {
        setState(() => _correctAiRequested = true);
        _getExplanation();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: _navy, borderRadius: BorderRadius.circular(5)),
              child: const Text('GEMMA 4',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: 8),
            Container(
                width: 6,
                height: 6,
                decoration:
                    const BoxDecoration(color: _green, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'AI explanation (if needed)',
                style: TextStyle(
                    color: _navy, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.auto_awesome_rounded, color: _amber, size: 17),
          ],
        ),
      ),
    );
  }

  // ── AI explanation box ──
  Widget _buildAIBox({required bool isCorrect}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isCorrect ? _green.withOpacity(0.25) : Colors.grey.shade200),
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
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isCorrect ? _green.withOpacity(0.07) : Colors.grey.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                      color: _navy, borderRadius: BorderRadius.circular(4)),
                  child: const Text('GEMMA 4',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ),
                const SizedBox(width: 6),
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: _green, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('AI explanation (if needed)',
                      style: TextStyle(
                          color: isCorrect ? _green : _navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
                if (_isGenerating)
                  const SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _green),
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: _aiOutput.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(children: [
                        CircularProgressIndicator(
                            color: _green, strokeWidth: 2),
                        SizedBox(height: 10),
                        Text('AI is thinking...',
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey)),
                      ]),
                    ),
                  )
                : SelectableText(
                    _aiOutput,
                    style: const TextStyle(fontSize: 14, height: 1.75),
                  ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: _submitted ? _nextButton() : _submitButton(),
    );
  }

  Widget _submitButton() {
    final can = _selectedAnswer != null;
    return GestureDetector(
      onTap: can ? _submitAnswer : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: can ? _navy : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
          boxShadow: can
              ? [BoxShadow(color: _navy.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Text('පිළිතුර ඉදිරිපත් කරන්න',
              style: TextStyle(
                  color: can ? Colors.white : Colors.grey.shade500,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _nextButton() {
    final waiting = !_aiDone && _isGenerating;
    final can     = _aiDone;

    return GestureDetector(
      onTap: can ? _nextQuestion : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 52,
        decoration: BoxDecoration(
          color: can ? _navy : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
          boxShadow: can
              ? [BoxShadow(color: _navy.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (waiting) ...[
                const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white60),
                ),
                const SizedBox(width: 8),
                Text('AI is thinking...',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ] else ...[
                Text(
                  _isLast ? 'View Results' : 'Next Question',
                  style: TextStyle(
                      color: can ? Colors.white : Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isLast ? Icons.bar_chart_rounded : Icons.arrow_forward_ios_rounded,
                  color: can ? Colors.white : Colors.grey.shade500,
                  size: 14,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
//  OPTION TILE
// ════════════════════════════════════════
class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool selected;
  final bool submitted;
  final bool isCorrect;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.submitted,
    required this.isCorrect,
    required this.onTap,
  });

  static const Color _navy  = Color(0xFF1A2657);
  static const Color _green = Color(0xFF27AE60);

  Color get _bg {
    if (!submitted) return selected ? const Color(0xFFEEF1FA) : Colors.white;
    if (isCorrect) return const Color(0xFFEDF7F0);
    if (selected && !isCorrect) return const Color(0xFFFEEEEE);
    return Colors.white;
  }

  Color get _border {
    if (!submitted) return selected ? _navy : Colors.grey.shade200;
    if (isCorrect) return _green;
    if (selected && !isCorrect) return Colors.redAccent;
    return Colors.grey.shade200;
  }

  Color get _labelBg {
    if (!submitted) return selected ? _navy : Colors.grey.shade100;
    if (isCorrect) return _green;
    if (selected && !isCorrect) return Colors.redAccent;
    return Colors.grey.shade100;
  }

  Color get _labelText {
    if (!submitted) return selected ? Colors.white : Colors.grey.shade600;
    if (isCorrect || (selected && !isCorrect)) return Colors.white;
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(color: _labelBg, shape: BoxShape.circle),
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
                      color: submitted && isCorrect
                          ? _green
                          : (submitted && selected && !isCorrect
                              ? Colors.redAccent
                              : _navy),
                      fontSize: 14,
                      fontWeight: submitted && isCorrect
                          ? FontWeight.w700
                          : FontWeight.w500,
                      height: 1.4)),
            ),
            if (submitted && isCorrect)
              const Icon(Icons.check_circle_rounded, color: _green, size: 20),
            if (submitted && selected && !isCorrect)
              const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
          ],
        ),
      ),
    );
  }
}