import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/features/games/estimation/estimate_questions_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EstimateQuestionsRepository', () {
    test('loads the bundled question collection', () async {
      final questions = await const EstimateQuestionsRepository()
          .loadQuestions();

      expect(questions, hasLength(20));
      expect(questions.map((question) => question.id).toSet(), hasLength(20));
    });

    test('parses valid questions and optional explanations', () async {
      final repository = EstimateQuestionsRepository(
        assetBundle: _StringAssetBundle(
          jsonEncode([
            {
              'id': 'moon',
              'question': 'Wie weit ist der Mond entfernt?',
              'answer': 'ca. 384.400 km',
              'explanation': 'Die Entfernung schwankt.',
            },
            {
              'id': 'hearts',
              'question': 'Wie viele Herzen hat ein Oktopus?',
              'answer': '3 Herzen',
            },
          ]),
        ),
      );

      final questions = await repository.loadQuestions();

      expect(questions, hasLength(2));
      expect(questions.first.id, 'moon');
      expect(questions.first.answer, 'ca. 384.400 km');
      expect(questions.first.explanation, 'Die Entfernung schwankt.');
      expect(questions.last.explanation, isNull);
    });

    test('rejects missing required values', () {
      final repository = EstimateQuestionsRepository(
        assetBundle: _StringAssetBundle(
          jsonEncode([
            {'id': 'invalid', 'question': '', 'answer': '42'},
          ]),
        ),
      );

      expect(repository.loadQuestions(), throwsA(isA<FormatException>()));
    });

    test('rejects an empty question list', () {
      final repository = EstimateQuestionsRepository(
        assetBundle: _StringAssetBundle('[]'),
      );

      expect(repository.loadQuestions(), throwsA(isA<FormatException>()));
    });
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
