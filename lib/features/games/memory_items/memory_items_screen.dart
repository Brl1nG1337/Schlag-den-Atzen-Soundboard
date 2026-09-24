import 'dart:async';

import 'package:flutter/material.dart';

enum MemoryItemsGamePhase { ready, running, finished }

class MemoryItemsScreen extends StatefulWidget {
  const MemoryItemsScreen({super.key});

  @override
  State<MemoryItemsScreen> createState() => _MemoryItemsScreenState();
}

class _MemoryItemsScreenState extends State<MemoryItemsScreen> {
  static const _duration = Duration(seconds: 30);

  MemoryItemsGamePhase _phase = MemoryItemsGamePhase.ready;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _countdownTimer;
  Timer? _finishTimer;
  int _remainingSeconds = 30;

  void _startGame() {
    _countdownTimer?.cancel();
    _finishTimer?.cancel();
    _stopwatch
      ..reset()
      ..start();

    setState(() {
      _remainingSeconds = 30;
      _phase = MemoryItemsGamePhase.running;
    });

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final remaining =
          (_duration - _stopwatch.elapsed).inMilliseconds /
          Duration.millisecondsPerSecond;
      if (remaining <= 0) return;
      final seconds = remaining.ceil();
      if (seconds != _remainingSeconds && mounted) {
        setState(() => _remainingSeconds = seconds);
      }
    });
    _finishTimer = Timer(_duration, _finishGame);
  }

  void _finishGame() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _finishTimer = null;
    _stopwatch.stop();
    if (!mounted) return;
    setState(() {
      _remainingSeconds = 0;
      _phase = MemoryItemsGamePhase.finished;
    });
  }

  void _returnToReady() {
    _countdownTimer?.cancel();
    _finishTimer?.cancel();
    _countdownTimer = null;
    _finishTimer = null;
    _stopwatch
      ..stop()
      ..reset();
    setState(() {
      _remainingSeconds = 30;
      _phase = MemoryItemsGamePhase.ready;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _finishTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Dinge merken')),
    body: SafeArea(
      top: false,
      child: switch (_phase) {
        MemoryItemsGamePhase.ready => _buildReady(context),
        MemoryItemsGamePhase.running => _buildRunning(context),
        MemoryItemsGamePhase.finished => _buildFinished(context),
      },
    ),
  );

  Widget _buildReady(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.visibility,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Dinge merken',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                Text(
                  'Du hast 30 Sekunden Zeit, dir so viele Gegenstände wie '
                  'möglich einzuprägen.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nach 30 Sekunden verschwindet das Bild automatisch.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start'),
                  style: _primaryButtonStyle(context),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildRunning(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/games/memory_items/items.png',
            fit: BoxFit.contain,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface
                  .withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                '$_remainingSeconds',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildFinished(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.timer_off_rounded,
              size: 76,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 22),
            Text(
              'Zeit vorbei!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              'Das Bild wurde ausgeblendet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _returnToReady,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Nochmal'),
              style: _primaryButtonStyle(context),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Zur Spieleübersicht'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  ButtonStyle _primaryButtonStyle(BuildContext context) =>
      FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        textStyle: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
}
