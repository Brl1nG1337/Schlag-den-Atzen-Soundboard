import 'dart:ui';

import 'package:flutter/material.dart';

import 'who_is_it_entry.dart';
import 'who_is_it_repository.dart';

enum _GamePhase { ready, playing, finished }

class WhoIsItScreen extends StatefulWidget {
  const WhoIsItScreen({super.key, this.repository = const WhoIsItRepository()});

  final WhoIsItRepository repository;

  @override
  State<WhoIsItScreen> createState() => _WhoIsItScreenState();
}

class _WhoIsItScreenState extends State<WhoIsItScreen> {
  static const _blurLevels = <double>[30, 20, 12, 6, 0];

  late Future<List<WhoIsItEntry>> _peopleFuture;
  List<WhoIsItEntry> _people = const [];
  var _phase = _GamePhase.ready;
  var _currentIndex = 0;
  var _revealLevel = 0;
  var _answerRevealed = false;
  var _shuffleEnabled = true;

  @override
  void initState() {
    super.initState();
    _peopleFuture = widget.repository.loadPeople();
  }

  void _retryLoading() {
    setState(() {
      _phase = _GamePhase.ready;
      _peopleFuture = widget.repository.loadPeople();
    });
  }

  void _startGame(List<WhoIsItEntry> sourcePeople) {
    final people = List<WhoIsItEntry>.of(sourcePeople);
    if (_shuffleEnabled) people.shuffle();
    setState(() {
      _people = people;
      _currentIndex = 0;
      _resetPersonState();
      _phase = _GamePhase.playing;
    });
  }

  void _resetPersonState() {
    _revealLevel = 0;
    _answerRevealed = false;
  }

  void _showPreviousPerson() {
    if (_currentIndex == 0) return;
    setState(() {
      _currentIndex--;
      _resetPersonState();
    });
  }

  void _showNextPerson() {
    setState(() {
      if (_currentIndex == _people.length - 1) {
        _phase = _GamePhase.finished;
      } else {
        _currentIndex++;
        _resetPersonState();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Wer ist das?'), centerTitle: false),
    body: SafeArea(
      top: false,
      child: FutureBuilder<List<WhoIsItEntry>>(
        future: _peopleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _LoadError(onRetry: _retryLoading);
          }

          final sourcePeople = snapshot.data!;
          return switch (_phase) {
            _GamePhase.ready => _ScrollableCenteredBody(
              child: _buildReady(context, sourcePeople),
            ),
            _GamePhase.playing => _buildGame(context),
            _GamePhase.finished => _ScrollableCenteredBody(
              child: _buildFinished(context, sourcePeople),
            ),
          };
        },
      ),
    ),
  );

  Widget _buildReady(BuildContext context, List<WhoIsItEntry> sourcePeople) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Eyebrow(text: '${sourcePeople.length} PERSONEN VERFÜGBAR'),
        const SizedBox(height: 14),
        Text(
          'Wer ist das?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Erkenne die Person so früh wie möglich.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        _SurfaceCard(
          child: Column(
            children: [
              Icon(
                Icons.person_search_rounded,
                size: 62,
                color: colors.primary,
              ),
              const SizedBox(height: 18),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Zufällige Reihenfolge'),
                secondary: const Icon(Icons.shuffle_rounded),
                value: _shuffleEnabled,
                onChanged: (value) => setState(() => _shuffleEnabled = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: 'Spiel starten',
          icon: Icons.play_arrow_rounded,
          onPressed: () => _startGame(sourcePeople),
        ),
      ],
    );
  }

  Widget _buildGame(BuildContext context) {
    final person = _people[_currentIndex];
    return LayoutBuilder(
      builder: (context, constraints) {
        final useWideLayout =
            constraints.maxWidth >= 840 &&
            constraints.maxWidth > constraints.maxHeight;
        final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 18.0;
        final image = _PersonImage(
          person: person,
          blurSigma: _blurLevels[_revealLevel],
        );
        final controls = _buildControls(
          context,
          person,
          showProgress: useWideLayout,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: useWideLayout
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: image),
                        const SizedBox(width: 28),
                        Expanded(flex: 5, child: controls),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PersonProgress(
                          current: _currentIndex + 1,
                          total: _people.length,
                        ),
                        const SizedBox(height: 16),
                        image,
                        const SizedBox(height: 22),
                        controls,
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(
    BuildContext context,
    WhoIsItEntry person, {
    required bool showProgress,
  }) {
    final isFullyVisible = _revealLevel == _blurLevels.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showProgress) ...[
          _PersonProgress(current: _currentIndex + 1, total: _people.length),
          const SizedBox(height: 18),
        ],
        _RevealIndicator(
          level: _revealLevel + 1,
          totalLevels: _blurLevels.length,
        ),
        const SizedBox(height: 16),
        _PrimaryButton(
          label: isFullyVisible ? 'Vollständig sichtbar' : 'Mehr zeigen',
          icon: isFullyVisible
              ? Icons.visibility_rounded
              : Icons.blur_off_rounded,
          onPressed: isFullyVisible
              ? null
              : () => setState(() => _revealLevel++),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: isFullyVisible
              ? null
              : () => setState(() => _revealLevel = _blurLevels.length - 1),
          icon: const Icon(Icons.image_rounded),
          label: const Text('Bild aufdecken'),
          style: _outlinedButtonStyle(context),
        ),
        const SizedBox(height: 18),
        if (_answerRevealed)
          _SolutionCard(person: person)
        else
          OutlinedButton.icon(
            onPressed: () => setState(() => _answerRevealed = true),
            icon: const Icon(Icons.badge_rounded),
            label: const Text('Lösung anzeigen'),
            style: _outlinedButtonStyle(context),
          ),
        if (_answerRevealed) ...[
          const SizedBox(height: 18),
          _PrimaryButton(
            label: _currentIndex == _people.length - 1
                ? 'Spiel beenden'
                : 'Nächste Person',
            icon: _currentIndex == _people.length - 1
                ? Icons.flag_rounded
                : Icons.arrow_forward_rounded,
            onPressed: _showNextPerson,
          ),
        ],
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _currentIndex == 0 ? null : _showPreviousPerson,
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Zurück'),
          style: _outlinedButtonStyle(context),
        ),
      ],
    );
  }

  Widget _buildFinished(BuildContext context, List<WhoIsItEntry> sourcePeople) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle_rounded, size: 82, color: colors.primary),
        const SizedBox(height: 22),
        Text(
          'Fertig!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(
          'Alle Personen wurden gespielt.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        _PrimaryButton(
          label: 'Nochmal spielen',
          icon: Icons.replay_rounded,
          onPressed: () => _startGame(sourcePeople),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('Zur Spieleübersicht'),
          style: _outlinedButtonStyle(context),
        ),
      ],
    );
  }
}

ButtonStyle _outlinedButtonStyle(BuildContext context) =>
    OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );

class _PersonImage extends StatelessWidget {
  const _PersonImage({required this.person, required this.blurSigma});

  final WhoIsItEntry person;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            border: Border.all(color: colors.primary.withValues(alpha: 0.32)),
            borderRadius: BorderRadius.circular(26),
          ),
          child: _RevealableAssetImage(
            assetPath: person.imageAsset,
            blurSigma: blurSigma,
          ),
        ),
      ),
    );
  }
}

class _RevealableAssetImage extends StatefulWidget {
  const _RevealableAssetImage({
    required this.assetPath,
    required this.blurSigma,
  });

  final String assetPath;
  final double blurSigma;

  @override
  State<_RevealableAssetImage> createState() => _RevealableAssetImageState();
}

class _RevealableAssetImageState extends State<_RevealableAssetImage> {
  var _loadFailed = false;

  @override
  void didUpdateWidget(covariant _RevealableAssetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) _loadFailed = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) return _MissingImage(assetPath: widget.assetPath);

    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: widget.blurSigma,
        sigmaY: widget.blurSigma,
        tileMode: TileMode.decal,
      ),
      child: Image.asset(
        widget.assetPath,
        key: ValueKey(widget.assetPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _loadFailed = true);
          });
          return const SizedBox.expand();
        },
      ),
    );
  }
}

class _MissingImage extends StatelessWidget {
  const _MissingImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHigh,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 58,
                color: colors.primary,
              ),
              const SizedBox(height: 14),
              Text(
                'Bild konnte nicht geladen werden.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                assetPath,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  const _SolutionCard({required this.person});

  final WhoIsItEntry person;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _SurfaceCard(
      borderColor: colors.primary.withValues(alpha: 0.62),
      child: Column(
        children: [
          const _Eyebrow(text: 'GESUCHTE PERSON'),
          const SizedBox(height: 12),
          Text(
            person.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: colors.primary, fontWeight: FontWeight.w900),
          ),
          if (person.hint case final hint?) ...[
            const SizedBox(height: 12),
            Text(
              'Hinweis: $hint',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: colors.onSurfaceVariant, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonProgress extends StatelessWidget {
  const _PersonProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) =>
      _Eyebrow(text: 'PERSON $current VON $total');
}

class _RevealIndicator extends StatelessWidget {
  const _RevealIndicator({required this.level, required this.totalLevels});

  final int level;
  final int totalLevels;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Sichtbarkeit: Stufe $level von $totalLevels',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: level / totalLevels,
        minHeight: 8,
        borderRadius: BorderRadius.circular(8),
      ),
    ],
  );
}

class _ScrollableCenteredBody extends StatelessWidget {
  const _ScrollableCenteredBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Center(
      child: SizedBox(
        width: constraints.maxWidth.clamp(0, 720).toDouble(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth >= 600 ? 32 : 18,
                vertical: 24,
              ),
              sliver: SliverFillRemaining(hasScrollBody: false, child: child),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: borderColor ?? colors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(58),
      textStyle: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56),
            const SizedBox(height: 18),
            Text(
              'Personen konnten nicht geladen werden.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    ),
  );
}
