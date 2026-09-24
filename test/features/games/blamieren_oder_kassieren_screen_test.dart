import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/features/games/blamieren_oder_kassieren/blamieren_oder_kassieren_screen.dart';
import 'package:soundboard/features/games/blamieren_oder_kassieren/blamieren_questions_repository.dart';

void main() {
  testWidgets('reveals answer, resets it on next and supports previous', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: BlamierenOderKassierenScreen(
          repository: BlamierenQuestionsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zufällige Reihenfolge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spiel starten'));
    await tester.pumpAndSettle();

    expect(find.text('RICHTIGE ANTWORT'), findsNothing);
    await tester.tap(find.text('Antwort anzeigen'));
    await tester.pumpAndSettle();
    expect(find.text('RICHTIGE ANTWORT'), findsOneWidget);
    await tester.tap(find.text('Nächste Frage'));
    await tester.pumpAndSettle();
    expect(find.text('RICHTIGE ANTWORT'), findsNothing);
    await tester.tap(find.text('Antwort anzeigen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('RICHTIGE ANTWORT'), findsNothing);
  });
}
