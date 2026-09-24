import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/features/games/blamieren_oder_kassieren/blamieren_questions_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads at least 20 bundled questions with unique ids', () async {
    final questions = await const BlamierenQuestionsRepository()
        .loadQuestions();
    expect(questions.length, greaterThanOrEqualTo(20));
    expect(
      questions.map((question) => question.id).toSet(),
      hasLength(questions.length),
    );
    expect(
      questions.every(
        (question) =>
            question.question.isNotEmpty && question.answer.isNotEmpty,
      ),
      isTrue,
    );
  });

  test('parses optional category and explanation', () async {
    final repository = BlamierenQuestionsRepository(
      assetBundle: _StringAssetBundle(
        jsonEncode([
          {
            'id': 'one',
            'question': 'Frage?',
            'answer': 'Antwort',
            'category': 'Wissen',
            'explanation': 'Erklärung',
          },
        ]),
      ),
    );
    final questions = await repository.loadQuestions();
    expect(questions.single.category, 'Wissen');
    expect(questions.single.explanation, 'Erklärung');
  });

  test('rejects malformed question data', () {
    final repository = BlamierenQuestionsRepository(
      assetBundle: _StringAssetBundle('[{"id":"x"}]'),
    );
    expect(repository.loadQuestions(), throwsA(isA<FormatException>()));
  });
}

class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this.contents);
  final String contents;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(contents));
    return ByteData.sublistView(bytes);
  }
}
