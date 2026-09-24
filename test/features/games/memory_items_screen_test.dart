import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/features/games/memory_items/memory_items_screen.dart';
import 'package:soundboard/theme/app_theme.dart';

void main() {
  testWidgets('shows the image for 30 seconds and retry returns to ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const MemoryItemsScreen()),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.byType(Image), findsNothing);

    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    await tester.pump(const Duration(seconds: 29));
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Zeit vorbei!'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(Image), findsNothing);
    expect(find.text('Zeit vorbei!'), findsOneWidget);

    await tester.tap(find.text('Nochmal'));
    await tester.pump();
    expect(find.text('Start'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('back closes the running game and cancels its timers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MemoryItemsScreen(),
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
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Open game'), findsOneWidget);
    await tester.pump(const Duration(seconds: 31));
    expect(find.text('Zeit vorbei!'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the image layout valid in portrait and landscape', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const MemoryItemsScreen()),
    );
    await tester.tap(find.text('Start'));
    await tester.pump();

    await tester.binding.setSurfaceSize(const Size(800, 1280));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}
