import 'package:flutter/material.dart';

import '../models/audio_track.dart';

class SoundButton extends StatelessWidget {
  const SoundButton({super.key, required this.track, required this.onPressed});
  final AudioTrack track;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(20),
        backgroundColor: colors.surfaceContainerHigh,
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.primary.withValues(alpha: 0.34)),
        textStyle: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Row(
        children: [
          Icon(Icons.play_arrow_rounded, size: 30, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              track.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
