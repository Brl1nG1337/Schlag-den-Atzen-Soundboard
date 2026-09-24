import 'package:flutter/material.dart';

enum StopTheTimePhase { ready, running, result }

class StopTheTimeScreen extends StatefulWidget {
  const StopTheTimeScreen({super.key});

  static const Duration targetDuration = Duration(seconds: 10);

  static String formatDuration(Duration duration) {
    final centiseconds = (duration.inMicroseconds / 10000).round();
    final seconds = centiseconds ~/ 100;
    final fraction = (centiseconds % 100).toString().padLeft(2, '0');
    return '$seconds,$fraction s';
  }

  @override
  State<StopTheTimeScreen> createState() => _StopTheTimeScreenState();
}

class _StopTheTimeScreenState extends State<StopTheTimeScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  StopTheTimePhase _phase = StopTheTimePhase.ready;
  Duration? _result;

  void _start() {
    _stopwatch
      ..reset()
      ..start();
    setState(() {
      _result = null;
      _phase = StopTheTimePhase.running;
    });
  }

  void _stop() {
    if (_phase != StopTheTimePhase.running) return;
    _stopwatch.stop();
    setState(() {
      _result = Duration(microseconds: _stopwatch.elapsedMicroseconds);
      _phase = StopTheTimePhase.result;
    });
  }

  void _reset() {
    _stopwatch
      ..stop()
      ..reset();
    setState(() {
      _result = null;
      _phase = StopTheTimePhase.ready;
    });
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Stop die Zeit')),
    body: SafeArea(
      top: false,
      child: switch (_phase) {
        StopTheTimePhase.ready => _buildReady(context),
        StopTheTimePhase.running => _buildRunning(context),
        StopTheTimePhase.result => _buildResult(context),
      },
    ),
  );

  Widget _buildReady(BuildContext context) => _CenteredContent(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.timer_outlined, size: 72, color: _accent(context)),
        const SizedBox(height: 24),
        Text(
          StopTheTimeScreen.formatDuration(StopTheTimeScreen.targetDuration),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Versuche, die Zeit möglichst genau zu treffen – ohne die Uhr zu sehen.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Drücke START und danach STOPP, sobald du glaubst, dass 10 Sekunden vergangen sind.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('START'),
          style: _buttonStyle(context, height: 64),
        ),
      ],
    ),
  );

  Widget _buildRunning(BuildContext context) => _CenteredContent(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'STOPPE BEI',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          StopTheTimeScreen.formatDuration(StopTheTimeScreen.targetDuration),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: _accent(context),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 180,
          child: FilledButton(
            onPressed: _stop,
            style: _buttonStyle(context, height: 180).copyWith(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
              textStyle: WidgetStatePropertyAll(
                Theme.of(context).textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ),
            child: const Text('STOPP'),
          ),
        ),
      ],
    ),
  );

  Widget _buildResult(BuildContext context) {
    final result = _result!;
    final difference = result - StopTheTimeScreen.targetDuration;
    final absoluteDifference = Duration(
      microseconds: difference.inMicroseconds.abs(),
    );
    final feedback = difference == Duration.zero
        ? 'Perfekt!'
        : '${StopTheTimeScreen.formatDuration(absoluteDifference)} ${difference.isNegative ? 'zu früh' : 'zu spät'}';
    final colors = Theme.of(context).colorScheme;

    return _CenteredContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'DEINE ZEIT',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            StopTheTimeScreen.formatDuration(result),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 24),
          _ResultRow(
            label: 'Ziel',
            value: StopTheTimeScreen.formatDuration(
              StopTheTimeScreen.targetDuration,
            ),
          ),
          const SizedBox(height: 10),
          _ResultRow(label: 'Abweichung', value: feedback, emphasized: true),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Nochmal'),
            style: _buttonStyle(context, height: 60),
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
    );
  }

  Color _accent(BuildContext context) => Theme.of(context).colorScheme.primary;

  ButtonStyle _buttonStyle(BuildContext context, {required double height}) =>
      FilledButton.styleFrom(
        minimumSize: Size.fromHeight(height),
        textStyle: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      );
}

class _CenteredContent extends StatelessWidget {
  const _CenteredContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: emphasized ? colors.primary : colors.onSurface,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
