import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/models/audio_track.dart';

void main() {
  group('AudioTrack.fromAssetPath', () {
    test('creates a readable title from underscores and the extension', () {
      final track = AudioTrack.fromAssetPath('assets/audio/show_intro.mp3');

      expect(track.assetPath, 'assets/audio/show_intro.mp3');
      expect(track.title, 'Show Intro');
    });

    test('normalises hyphens, whitespace and letter case', () {
      final track = AudioTrack.fromAssetPath(
        'assets/audio/GROSSER--APPLAUS.m4a',
      );

      expect(track.title, 'Grosser Applaus');
    });

    test('shows numbered music tracks with a hash in the title', () {
      final track = AudioTrack.fromAssetPath(
        'assets/audio/Music 2 - Schlag den Raab Soundtrack Extended.mp3',
      );

      expect(track.assetPath, contains('Music 2'));
      expect(track.title, 'Music #2 Schlag Den Raab Soundtrack Extended');
    });
  });
}
