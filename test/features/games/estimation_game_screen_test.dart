import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/features/games/estimation/estimate_questions_repository.dart';
import 'package:soundboard/features/games/estimation/estimation_game_screen.dart';
import 'package:soundboard/theme/app_theme.dart';

void main() {
  testWidgets('hides the answer again when changing questions', (tester) async {
    final repository = EstimateQuestionsRepository(
      assetBundle: _StringAssetBundle(
        jsonEncode([
          {
            'id': 'first',
            'question': 'Erste Testfrage?',
            'answer': 'Erste Testantwort',
          },
          {
            'id': 'second',
            'question': 'Zweite Testfrage?',
            'answer': 'Zweite Testantwort',
          },
        ]),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: EstimationGameScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bereit?'), findsOneWidget);
    await tester.tap(find.text('Zufällige Reihenfolge'));
    await tester.pump();
    await tester.ensureVisible(find.text('Spiel starten'));
    await tester.tap(find.text('Spiel starten'));
    await tester.pumpAndSettle();

    expect(find.text('Erste Testfrage?'), findsOneWidget);
    expect(find.text('Erste Testantwort'), findsNothing);

    await tester.ensureVisible(find.text('Antwort anzeigen'));
    await tester.tap(find.text('Antwort anzeigen'));
    await tester.pumpAndSettle();
    expect(find.text('Erste Testantwort'), findsOneWidget);

    await tester.ensureVisible(find.text('Nächste Frage'));
    await tester.tap(find.text('Nächste Frage'));
    await tester.pumpAndSettle();
    expect(find.text('Zweite Testfrage?'), findsOneWidget);
    expect(find.text('Zweite Testantwort'), findsNothing);

    await tester.ensureVisible(find.text('Zurück'));
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('Erste Testfrage?'), findsOneWidget);
    expect(find.text('Erste Testantwort'), findsNothing);

    await tester.ensureVisible(find.text('Antwort anzeigen'));
    await tester.tap(find.text('Antwort anzeigen'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Nächste Frage'));
    await tester.tap(find.text('Nächste Frage'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Antwort anzeigen'));
    await tester.tap(find.text('Antwort anzeigen'));
    await tester.pumpAndSettle();

    expect(find.text('Spiel beenden'), findsOneWidget);
    await tester.ensureVisible(find.text('Spiel beenden'));
    await tester.tap(find.text('Spiel beenden'));
    await tester.pumpAndSettle();
    expect(find.text('Fertig!'), findsOneWidget);

    await tester.ensureVisible(find.text('Nochmal spielen'));
    await tester.tap(find.text('Nochmal spielen'));
    await tester.pumpAndSettle();
    expect(find.text('FRAGE 1 VON 2'), findsOneWidget);
    expect(find.text('Erste Testfrage?'), findsOneWidget);
    expect(find.text('Erste Testantwort'), findsNothing);
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
