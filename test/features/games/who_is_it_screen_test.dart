import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/features/games/who_is_it/who_is_it_repository.dart';
import 'package:soundboard/features/games/who_is_it/who_is_it_screen.dart';
import 'package:soundboard/theme/app_theme.dart';

void main() {
  testWidgets('supports one person and a missing image without crashing', (
    tester,
  ) async {
    final repository = WhoIsItRepository(
      assetBundle: _StringAssetBundle(
        jsonEncode([
          {
            'id': 'only_person',
            'name': 'Einzige Person',
            'imageAsset': 'assets/missing-person.jpg',
            'hint': 'Testhinweis',
          },
        ]),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: WhoIsItScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 PERSONEN VERFÜGBAR'), findsOneWidget);
    await tester.tap(find.text('Spiel starten'));
    await tester.pumpAndSettle();

    expect(find.text('PERSON 1 VON 1'), findsOneWidget);
    expect(find.text('Bild konnte nicht geladen werden.'), findsOneWidget);
    expect(find.text('Einzige Person'), findsNothing);

    await tester.ensureVisible(find.text('Bild aufdecken'));
    await tester.tap(find.text('Bild aufdecken'));
    await tester.pump();
    expect(find.text('Vollständig sichtbar'), findsOneWidget);
    expect(find.text('Einzige Person'), findsNothing);

    await tester.ensureVisible(find.text('Lösung anzeigen'));
    await tester.tap(find.text('Lösung anzeigen'));
    await tester.pumpAndSettle();
    expect(find.text('Einzige Person'), findsOneWidget);
    expect(find.text('Hinweis: Testhinweis'), findsOneWidget);
    expect(find.text('Spiel beenden'), findsOneWidget);

    await tester.ensureVisible(find.text('Spiel beenden'));
    await tester.tap(find.text('Spiel beenden'));
    await tester.pumpAndSettle();
    expect(find.text('Alle Personen wurden gespielt.'), findsOneWidget);

    await tester.ensureVisible(find.text('Nochmal spielen'));
    await tester.tap(find.text('Nochmal spielen'));
    await tester.pumpAndSettle();
    expect(find.text('PERSON 1 VON 1'), findsOneWidget);
    expect(find.text('Einzige Person'), findsNothing);
    expect(find.text('Sichtbarkeit: Stufe 1 von 5'), findsOneWidget);
  });

  testWidgets('shows a recoverable load error', (tester) async {
    final repository = WhoIsItRepository(
      assetBundle: _StringAssetBundle('invalid json'),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: WhoIsItScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personen konnten nicht geladen werden.'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
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
