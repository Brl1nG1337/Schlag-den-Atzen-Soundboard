class EstimateQuestion {
  const EstimateQuestion({
    required this.id,
    required this.question,
    required this.answer,
    this.explanation,
  });

  factory EstimateQuestion.fromJson(Map<String, Object?> json) {
    final id = _requiredString(json, 'id');
    final question = _requiredString(json, 'question');
    final answer = _requiredString(json, 'answer');
    final explanationValue = json['explanation'];

    if (explanationValue != null && explanationValue is! String) {
      throw const FormatException('"explanation" muss ein Text sein.');
    }

    final explanation = (explanationValue as String?)?.trim();
    return EstimateQuestion(
      id: id,
      question: question,
      answer: answer,
      explanation: explanation == null || explanation.isEmpty
          ? null
          : explanation,
    );
  }

  final String id;
  final String question;
  final String answer;
  final String? explanation;

  static String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('"$key" fehlt oder ist leer.');
    }
    return value.trim();
  }
}
