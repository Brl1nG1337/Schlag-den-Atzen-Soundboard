import 'package:flutter/material.dart';

import '../controllers/audio_player_controller.dart';
import '../features/games/games_overview.dart';
import '../models/audio_track.dart';
import '../services/audio_asset_service.dart';
import '../widgets/bottom_audio_player.dart';
import '../widgets/sound_button.dart';

class SoundboardScreen extends StatefulWidget {
  const SoundboardScreen({super.key});

  @override
  State<SoundboardScreen> createState() => _SoundboardScreenState();
}

class _SoundboardScreenState extends State<SoundboardScreen> {
  final _playerController = AudioPlayerController();
  late final Future<List<AudioTrack>> _tracks = AudioAssetService()
      .loadTracks();
  var _selectedIndex = 0;

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  Future<void> _playTrack(AudioTrack track) async {
    try {
      await _playerController.selectAndPlay(track);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('„${track.title}“ konnte nicht geladen werden.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: 96,
      title: Semantics(
        label: 'Schlag den Atzen Soundboard',
        header: true,
        child: Row(
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: 96,
                height: 72,
                child: ClipRect(
                  child: Transform.scale(
                    scale: 1.55,
                    child: Image.asset(
                      'assets/images/soundboard_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Schlag den Atzen\nSoundboard',
                maxLines: 2,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, height: 1.08),
              ),
            ),
          ],
        ),
      ),
    ),
    body: IndexedStack(
      index: _selectedIndex,
      children: [
        _SoundboardTab(
          tracks: _tracks,
          playerController: _playerController,
          onPlayTrack: _playTrack,
        ),
        const GamesOverview(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Soundboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.sports_esports_outlined),
          selectedIcon: Icon(Icons.sports_esports_rounded),
          label: 'Spiele',
        ),
      ],
    ),
  );
}

class _SoundboardTab extends StatelessWidget {
  const _SoundboardTab({
    required this.tracks,
    required this.playerController,
    required this.onPlayTrack,
  });

  final Future<List<AudioTrack>> tracks;
  final AudioPlayerController playerController;
  final ValueChanged<AudioTrack> onPlayTrack;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: FutureBuilder<List<AudioTrack>>(
          future: tracks,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const _MessageState(
                icon: Icons.error_outline_rounded,
                title: 'Sounds konnten nicht geladen werden',
                message: 'Prüfe die Dateien unter assets/audio/.',
              );
            }
            final tracks = snapshot.data ?? const <AudioTrack>[];
            if (tracks.isEmpty) {
              return const _MessageState(
                icon: Icons.library_music_outlined,
                title: 'Noch keine Sounds vorhanden',
                message: 'Lege MP3-Dateien unter\nassets/audio/ ab.',
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 700 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: tracks.length,
                  itemBuilder: (context, index) => SoundButton(
                    track: tracks[index],
                    onPressed: () => onPlayTrack(tracks[index]),
                  ),
                );
              },
            );
          },
        ),
      ),
      BottomAudioPlayer(controller: playerController),
    ],
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ),
  );
}
