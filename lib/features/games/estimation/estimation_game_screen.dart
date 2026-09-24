import 'package:flutter/material.dart';

import 'estimate_question.dart';
import 'estimate_questions_repository.dart';

enum _GamePhase { ready, playing, finished }

class EstimationGameScreen extends StatefulWidget {
  const EstimationGameScreen({
    super.key,
    this.repository = const EstimateQuestionsRepository(),
  });

  final EstimateQuestionsRepository repository;

  @override
  State<EstimationGameScreen> createState() => _EstimationGameScreenState();
}

class _EstimationGameScreenState extends State<EstimationGameScreen> {
  late Future<List<EstimateQuestion>> _questionsFuture;
  List<EstimateQuestion> _questions = const [];
  var _phase = _GamePhase.ready;
  var _currentQuestionIndex = 0;
  var _answerRevealed = false;
  var _shuffleEnabled = true;

  @override
  void initState() {
    super.initState();
    _questionsFuture = widget.repository.loadQuestions();
  }

  void _retryLoading() {
    setState(() {
      _phase = _GamePhase.ready;
      _questionsFuture = widget.repository.loadQuestions();
    });
  }

  void _startGame(List<EstimateQuestion> sourceQuestions) {
    final questions = List<EstimateQuestion>.of(sourceQuestions);
    if (_shuffleEnabled) questions.shuffle();
    setState(() {
      _questions = questions;
      _currentQuestionIndex = 0;
      _answerRevealed = false;
      _phase = _GamePhase.playing;
    });
  }

  void _showPreviousQuestion() {
    if (_currentQuestionIndex == 0) return;
    setState(() {
      _currentQuestionIndex--;
      _answerRevealed = false;
    });
  }

  void _showNextQuestion() {
    setState(() {
      if (_currentQuestionIndex == _questions.length - 1) {
        _phase = _GamePhase.finished;
      } else {
        _currentQuestionIndex++;
        _answerRevealed = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Schätzfragen'), centerTitle: false),
    body: SafeArea(
      top: false,
      child: FutureBuilder<List<EstimateQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _LoadError(onRetry: _retryLoading);
          }

          final sourceQuestions = snapshot.data!;
          final content = switch (_phase) {
            _GamePhase.ready => _buildReady(context, sourceQuestions),
            _GamePhase.playing => _buildQuestion(context),
            _GamePhase.finished => _buildFinished(context, sourceQuestions),
          };
          return _ResponsiveGameBody(child: content);
        },
      ),
    ),
  );

  Widget _buildReady(
    BuildContext context,
    List<EstimateQuestion> sourceQuestions,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Eyebrow(text: '${sourceQuestions.length} FRAGEN'),
        const SizedBox(height: 14),
        Text(
          'Bereit?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 28),
        _SurfaceCard(
          child: Column(
            children: [
              Icon(Icons.calculate_rounded, size: 58, color: colors.primary),
              const SizedBox(height: 20),
              Text(
                'Zeige die Fragen nacheinander und decke die richtige Antwort '
                'erst auf, nachdem beide Spieler geschätzt haben.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(height: 1.45, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
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
          onPressed: () => _startGame(sourceQuestions),
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final colors = Theme.of(context).colorScheme;
    final questionFontSize = MediaQuery.sizeOf(context).width >= 600
        ? 36.0
        : 30.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Eyebrow(
          text: 'FRAGE ${_currentQuestionIndex + 1} VON ${_questions.length}',
        ),
        const SizedBox(height: 16),
        _SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 180),
            child: Center(
              child: Text(
                question.question,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: questionFontSize,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        if (_answerRevealed) ...[
          _SurfaceCard(
            borderColor: colors.primary.withValues(alpha: 0.62),
            child: Column(
              children: [
                const _Eyebrow(text: 'RICHTIGE ANTWORT'),
                const SizedBox(height: 14),
                Text(
                  question.answer,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (question.explanation case final explanation?) ...[
                  const SizedBox(height: 14),
                  Text(
                    explanation,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
        ] else ...[
          const SizedBox(height: 28),
        ],
        if (!_answerRevealed)
          _PrimaryButton(
            label: 'Antwort anzeigen',
            icon: Icons.visibility_rounded,
            onPressed: () => setState(() => _answerRevealed = true),
          )
        else
          _PrimaryButton(
            label: _currentQuestionIndex == _questions.length - 1
                ? 'Spiel beenden'
                : 'Nächste Frage',
            icon: _currentQuestionIndex == _questions.length - 1
                ? Icons.flag_rounded
                : Icons.arrow_forward_rounded,
            onPressed: _showNextQuestion,
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _currentQuestionIndex == 0 ? null : _showPreviousQuestion,
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Zurück'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinished(
    BuildContext context,
    List<EstimateQuestion> sourceQuestions,
  ) {
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
          'Alle Schätzfragen wurden gespielt.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        _PrimaryButton(
          label: 'Nochmal spielen',
          icon: Icons.replay_rounded,
          onPressed: () => _startGame(sourceQuestions),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('Zur Spieleübersicht'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveGameBody extends StatelessWidget {
  const _ResponsiveGameBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Center(
      child: SizedBox(
        width: constraints.maxWidth.clamp(0, 840).toDouble(),
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
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
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
      child: Padding(padding: padding, child: child),
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
  final VoidCallback onPressed;

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
              'Fragen konnten nicht geladen werden.',
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
