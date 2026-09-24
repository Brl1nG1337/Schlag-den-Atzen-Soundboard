class AudioTrack {
  const AudioTrack({required this.assetPath, required this.title});

  factory AudioTrack.fromAssetPath(String assetPath) {
    final fileName = assetPath.split('/').last;
    final words = fileName
        .replaceFirst(RegExp(r'\.[^.]+$'), '')
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'));
    final normalisedTitle = words
        .where((word) => word.isNotEmpty)
        .map(_capitalise)
        .join(' ');
    final title = normalisedTitle.replaceFirstMapped(
      RegExp(r'^Music (\d+)\b'),
      (match) => 'Music #${match.group(1)}',
    );
    return AudioTrack(
      assetPath: assetPath,
      title: title.isEmpty ? fileName : title,
    );
  }

  final String assetPath;
  final String title;

  static String _capitalise(String word) => word.isEmpty
      ? word
      : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
}
