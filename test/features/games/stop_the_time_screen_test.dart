import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/features/games/games_overview.dart';
import 'package:soundboard/features/games/stop_the_time/stop_the_time_screen.dart';
import 'package:soundboard/theme/app_theme.dart';

void main() {
  testWidgets('is listed and can be opened from the shared game cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const GamesOverview()),
    );

    expect(find.text('Stop die Zeit'), findsOneWidget);
    expect(
      find.text('Stoppe möglichst genau bei 10,00 Sekunden.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Stop die Zeit'));
    await tester.pumpAndSettle();
    expect(find.text('10,00 s'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('hides elapsed time while running and shows rounded result', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const StopTheTimeScreen()),
    );

    await tester.tap(find.text('START'));
    await tester.pump();
    expect(find.text('STOPP'), findsOneWidget);
    expect(find.textContaining(' s'), findsOneWidget); // Only the target.
    expect(find.text('0,01 s'), findsNothing);

    await tester.tap(find.text('STOPP'));
    await tester.pump();

    final resultFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != '10,00 s' &&
          RegExp(r'^\d+,\d{2} s$').hasMatch(widget.data ?? ''),
    );
    expect(resultFinder, findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            RegExp(r'^(Perfekt!|\d+,\d{2} s zu (früh|spät))$')
                .hasMatch(widget.data ?? ''),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('179999'), findsNothing);
  });

  test('formats durations to two comma-separated decimal places', () {
    expect(
      StopTheTimeScreen.formatDuration(const Duration(microseconds: 179999)),
      '0,18 s',
    );
    expect(
      StopTheTimeScreen.formatDuration(const Duration(milliseconds: 10370)),
      '10,37 s',
    );
  });

  testWidgets(
    'retry returns to ready without starting and back disposes round',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StopTheTimeScreen(),
                  ),
                ),
                child: const Text('Open game'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open game'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('START'));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.tap(find.text('STOPP'));
      await tester.pump();
      await tester.tap(find.text('Nochmal'));
      await tester.pump();
      expect(find.text('START'), findsOneWidget);
      expect(find.text('STOPP'), findsNothing);

      await tester.tap(find.text('START'));
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Open game'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('layout fits portrait and tablet landscape', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const StopTheTimeScreen()),
    );
    for (final size in [const Size(390, 844), const Size(1280, 800)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pump();
      await tester.tap(find.text('START'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('STOPP'));
      await tester.pump();
      await tester.tap(find.text('Nochmal'));
      await tester.pump();
    }
    await tester.binding.setSurfaceSize(null);
  });
}
