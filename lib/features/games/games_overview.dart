import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'estimation/estimation_game_screen.dart';
import 'blamieren_oder_kassieren/blamieren_oder_kassieren_screen.dart';
import 'memory_items/memory_items_screen.dart';
import 'models/game_definition.dart';
import 'stop_the_time/stop_the_time_screen.dart';
import 'who_is_it/who_is_it_screen.dart';

class GamesOverview extends StatelessWidget {
  const GamesOverview({super.key});

  static final List<GameDefinition> games = <GameDefinition>[
    GameDefinition(
      id: 'blamieren_oder_kassieren',
      title: 'Blamieren oder Kassieren',
      description: 'Wissensfragen im klassischen Buzzer-Duell.',
      category: 'Wissen',
      icon: Icons.quiz_outlined,
      screenBuilder: (_) => const BlamierenOderKassierenScreen(),
    ),
    GameDefinition(
      id: 'estimation',
      title: 'Schätzfragen',
      description: 'Wer liegt näher an der richtigen Antwort?',
      category: 'Schätzen • Wissen',
      icon: Icons.calculate_rounded,
      screenBuilder: (_) => const EstimationGameScreen(),
    ),
    GameDefinition(
      id: 'who_is_it',
      title: 'Wer ist das?',
      description:
          'Erkenne die Person, bevor das Bild vollständig sichtbar ist.',
      category: 'Personen • Erkennen',
      icon: Icons.person_search_rounded,
      screenBuilder: (_) => const WhoIsItScreen(),
    ),
    GameDefinition(
      id: 'memory_items',
      title: 'Dinge merken',
      description: 'Präge dir so viele Gegenstände wie möglich ein.',
      category: 'Gedächtnis',
      icon: Icons.visibility,
      screenBuilder: (_) => const MemoryItemsScreen(),
    ),
    GameDefinition(
      id: 'stop_the_time',
      title: 'Stop die Zeit',
      description: 'Stoppe möglichst genau bei 10,00 Sekunden.',
      category: 'Zeitgefühl',
      icon: Icons.timer_outlined,
      screenBuilder: (_) => const StopTheTimeScreen(),
    ),
    GameDefinition(
      id: 'songless',
      title: 'Songless',
      description: 'Öffne Songless im Browser.',
      category: 'Musik',
      icon: Icons.music_note_rounded,
      externalUri: Uri.parse('https://lessgames.com/songless'),
    ),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: CustomScrollView(
          key: const PageStorageKey<String>('games-overview'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spiele',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Wähle ein Spiel aus',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 480,
                  mainAxisExtent: 176,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) => _GameCard(
                  game: games[index],
                  onPressed: () {
                    final game = games[index];
                    if (game.externalUri case final uri?) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else if (game.screenBuilder case final builder?) {
                      Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: builder));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onPressed});

  final GameDefinition game;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(16),
        backgroundColor: colors.surfaceContainerHigh,
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.primary.withValues(alpha: 0.34)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.primary.withValues(alpha: 0.34)),
            ),
            child: Icon(game.icon, color: colors.primary, size: 34),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  game.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Text(
                  game.category.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: colors.primary, size: 32),
        ],
      ),
    );
  }
}
