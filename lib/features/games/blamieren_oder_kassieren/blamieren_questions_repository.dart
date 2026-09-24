import 'dart:convert';

import 'package:flutter/services.dart';

import 'blamieren_question.dart';

class BlamierenQuestionsRepository {
  const BlamierenQuestionsRepository({this.assetBundle});

  static const assetPath =
      'assets/games/blamieren_oder_kassieren/questions.json';
  final AssetBundle? assetBundle;

  Future<List<BlamierenQuestion>> loadQuestions() async {
    final source = await (assetBundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! List<Object?>) {
      throw const FormatException('Die Fragendatei muss eine Liste enthalten.');
    }
    final questions = decoded
        .map((entry) {
          if (entry is! Map<String, Object?>) {
            throw const FormatException('Jede Frage muss ein Objekt sein.');
          }
          return BlamierenQuestion.fromJson(entry);
        })
        .toList(growable: false);
    if (questions.isEmpty) {
      throw const FormatException('Die Fragendatei ist leer.');
    }
    return questions;
  }
}
