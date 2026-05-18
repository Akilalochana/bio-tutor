class QuestionModel {
  final String question;
  final Map<String, String> options;
  final String correctAnswer;
  final String unit;
  final int year;
  final int questionNumber; // e.g. 14 from "AL_2019_Biology_MCQ_1_to_40.json"

  const QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.unit,
    required this.year,
    required this.questionNumber,
  });

  String get correctText => options[correctAnswer] ?? correctAnswer;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // Options: supports both {"A":"..","B":"..} and {"options":{"A":".."}}
    Map<String, String> opts = {};
    final raw = json['options'];
    if (raw is Map) {
      raw.forEach((k, v) => opts[k.toString()] = v.toString());
    }

    return QuestionModel(
      question:       json['question']        as String? ?? '',
      options:        opts,
      correctAnswer:  json['correct_answer']  as String? ??
                      json['correctAnswer']   as String? ?? '',
      unit:           json['unit']            as String? ?? '0',
      year:           (json['year']           as num?)?.toInt() ?? 0,
      // Support "question_number", "questionNumber", or "number" keys
      questionNumber: (json['question_number'] as num?)?.toInt() ??
                      (json['questionNumber']  as num?)?.toInt() ??
                      (json['number']          as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'question':        question,
        'options':         options,
        'correct_answer':  correctAnswer,
        'unit':            unit,
        'year':            year,
        'question_number': questionNumber,
      };
}