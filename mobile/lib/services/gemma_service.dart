import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaService {
  static InferenceModel? _model;
  static InferenceChat? _chat;
  static bool _initialized = false;

  static Future<void> initialize(String modelPath) async {
    if (_initialized) return;

    await FlutterGemma.installModel(
      modelType: ModelType.gemma4,
    ).fromFile(modelPath).install();

    // ✅ useLlmFfi, supportImage, maxNumImages — removed (0.14.0+ API)
    _model = await FlutterGemmaPlugin.instance.createModel(
      modelType: ModelType.gemma4,
      fileType: ModelFileType.litertlm,
      maxTokens: 4096,
      preferredBackend: PreferredBackend.gpu,
    );

    _initialized = true;
  }

  static bool get isReady => _initialized && _model != null;

  static Stream<String> explainAsTeacher({
    required String question,
    required String studentAnswer,
    required String correctAnswer,
    required String context,
  }) async* {
    if (_model == null) throw Exception('Model not initialized!');

    final trimmedContext =
        context.length > 1200 ? context.substring(0, 1200) : context;

    final prompt = '''
ඔබ ශ්‍රී ලාංකික A/L ජීව විද්‍යා ගුරුවරයෙකි. ඔබගේ එකම කාර්යය ලබා දී ඇති "📚 විෂය නිර්දේශ අන්තර්ගතය" මත පමණක් පදනම්ව MCQ ප්‍රශ්නය පැහැදිලි කිරීමයි.

========================
STRICT INSTRUCTIONS
========================
1. "📚 විෂය නිර්දේශ අන්තර්ගතය" තුළ සෘජුවම සඳහන් තොරතුරු පමණක් භාවිතා කරන්න.
2. 💡 පළමු කොටසේදී ශිෂ්‍යයා තෝරාගත් වැරදි පිළිතුර පිළිබඳව පමණක් අවධානය යොමු කරන්න.
3. Context එකේ නොමැතිනම්: "ශිෂ්‍යයාගේ පිළිතුර වැරදි වීමට හේතුව ලබා දී ඇති අන්තර්ගතයේ සෘජුව සඳහන් නොවේ."
4. තොරතුරු ප්‍රමාණවත් නොවේ නම්: "සමාවෙන්න, මෙම ප්‍රශ්නයට අදාළ ප්‍රමාණවත් තොරතුරු ලබා දී ඇති අන්තර්ගතයේ නොමැත."
5. සිංහලෙන් පමණක් පිළිතුරු දෙන්න.
6. සෑම ජීව විද්‍යාත්මක පාරිභාෂික වචනයක් සඳහාම ඉංග්‍රීසි වචනය වරහන් තුළ දක්වන්න. උදා: පටකය (Tissue).
7. LaTeX සංකේත භාවිතා නොකරන්න. ඊතල සඳහා '->' භාවිතා කරන්න.
8. කිසිදු හැඳින්වීමක් හෝ අවසාන වාක්‍ය ලියන්න එපා.

========================
📚 විෂය නිර්දේශ අන්තර්ගතය
========================
$trimmedContext

========================
❓ ප්‍රශ්නය: $question
🙋 ශිෂ්‍යයාගේ වැරදි පිළිතුර: $studentAnswer
✅ නිවැරදි පිළිතුර: $correctAnswer
========================

පහත ආකෘතියට පමණක් පිළිතුර ලබා දෙන්න:

1. 💡 ශිෂ්‍යයාගේ පිළිතුර වැරදි ඇයි?

2. 📖 නිවැරදි සිද්ධාන්තය

3. 🎯 අදාළ විෂය කරුණු

4. 🧠 මතක තබා ගැනීමේ ක්‍රමය
''';

    _chat = await _model!.createChat(
      temperature: 0.2,
      topK: 30,
      randomSeed: 42,
      modelType: ModelType.gemma4,
    );

    await _chat!.addQueryChunk(Message.text(text: prompt, isUser: true));

    await for (final response in _chat!.generateChatResponseAsync()) {
      if (response is TextResponse) {
        yield response.token;
      }
    }

    await _chat!.close();
    _chat = null;
  }

  static Future<void> dispose() async {
    await _chat?.close();
    await _model?.close();
    _chat = null;
    _model = null;
    _initialized = false;
  }
}