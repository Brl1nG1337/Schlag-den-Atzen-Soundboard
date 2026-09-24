import 'package:flutter/services.dart';

import '../models/audio_track.dart';

class AudioAssetService {
  AudioAssetService({AssetBundle? assetBundle})
    : assetBundle = assetBundle ?? rootBundle;

  static const _audioDirectory = 'assets/audio/';
  static const _supportedExtensions = <String>{'.mp3', '.wav', '.m4a', '.ogg'};
  final AssetBundle assetBundle;

  Future<List<AudioTrack>> loadTracks() async {
    final manifest = await AssetManifest.loadFromAssetBundle(assetBundle);
    final tracks =
        manifest
            .listAssets()
            .where(_isSupportedAudioAsset)
            .map(AudioTrack.fromAssetPath)
            .toList()
          ..sort((first, second) => first.title.compareTo(second.title));
    return tracks;
  }

  bool _isSupportedAudioAsset(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.startsWith(_audioDirectory) &&
        _supportedExtensions.any(lowerPath.endsWith);
  }
}
