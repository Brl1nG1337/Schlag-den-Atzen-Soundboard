import 'package:flutter/material.dart';

import '../controllers/audio_player_controller.dart';

class BottomAudioPlayer extends StatelessWidget {
  const BottomAudioPlayer({super.key, required this.controller});
  final AudioPlayerController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final hasTrack = controller.hasTrack;
      final duration = controller.duration ?? Duration.zero;
      final position = controller.position > duration
          ? duration
          : controller.position;
      final colors = Theme.of(context).colorScheme;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller.currentTrack?.title ?? 'Kein Track ausgewählt',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Row(
                    children: [
                      Text(_formatDuration(position)),
                      Expanded(
                        child: Slider(
                          value: duration.inMilliseconds == 0
                              ? 0
                              : position.inMilliseconds /
                                    duration.inMilliseconds,
                          onChanged: hasTrack && duration > Duration.zero
                              ? (value) => controller.seek(
                                  Duration(
                                    milliseconds:
                                        (duration.inMilliseconds * value)
                                            .round(),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Text(_formatDuration(duration)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Von vorne abspielen',
                        onPressed: hasTrack ? controller.restart : null,
                        icon: const Icon(Icons.skip_previous_rounded),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filled(
                        tooltip: controller.isPlaying
                            ? 'Pausieren'
                            : 'Abspielen',
                        iconSize: 30,
                        onPressed: hasTrack ? controller.togglePlayback : null,
                        icon: Icon(
                          controller.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filledTonal(
                        tooltip: 'Stopp',
                        onPressed: hasTrack ? controller.stop : null,
                        icon: const Icon(Icons.stop_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
