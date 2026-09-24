class BlamierenQuestion {
  const BlamierenQuestion({
    required this.id,
    required this.question,
    required this.answer,
    this.explanation,
    this.category,
  });

  factory BlamierenQuestion.fromJson(Map<String, Object?> json) {
    String requiredText(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('"$key" fehlt oder ist leer.');
      }
      return value.trim();
    }

    String? optionalText(String key) {
      final value = json[key];
      if (value != null && value is! String) {
        throw FormatException('"$key" muss ein Text sein.');
      }
      final text = (value as String?)?.trim();
      return text == null || text.isEmpty ? null : text;
    }

    return BlamierenQuestion(
      id: requiredText('id'),
      question: requiredText('question'),
      answer: requiredText('answer'),
      explanation: optionalText('explanation'),
      category: optionalText('category'),
    );
  }

  final String id;
  final String question;
  final String answer;
  final String? explanation;
  final String? category;
}
