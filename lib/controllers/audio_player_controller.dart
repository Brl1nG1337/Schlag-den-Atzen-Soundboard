import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/audio_track.dart';

class AudioPlayerController extends ChangeNotifier {
  AudioPlayerController({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _subscriptions = <StreamSubscription<dynamic>>[
      _player.positionStream.listen((position) {
        this.position = position;
        notifyListeners();
      }),
      _player.durationStream.listen((duration) {
        this.duration = duration;
        notifyListeners();
      }),
      _player.playerStateStream.listen((state) {
        isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          isPlaying = false;
          position = duration ?? Duration.zero;
        }
        notifyListeners();
      }),
    ];
  }

  final AudioPlayer _player;
  late final List<StreamSubscription<dynamic>> _subscriptions;
  int _loadRequest = 0;

  AudioTrack? currentTrack;
  Duration position = Duration.zero;
  Duration? duration;
  bool isPlaying = false;

  bool get hasTrack => currentTrack != null;

  Future<void> selectAndPlay(AudioTrack track) async {
    final request = ++_loadRequest;
    try {
      await _player.stop();
      await _player.setAsset(track.assetPath);
      if (request != _loadRequest) return;
      currentTrack = track;
      position = Duration.zero;
      duration = _player.duration;
      notifyListeners();
      await _player.play();
    } catch (error, stackTrace) {
      debugPrint('Unable to load ${track.assetPath}: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<void> togglePlayback() async {
    if (!hasTrack) return;
    try {
      if (isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (error, stackTrace) {
      debugPrint('Unable to change playback: $error\n$stackTrace');
    }
  }

  Future<void> stop() async {
    if (!hasTrack) return;
    await _player.pause();
    await _player.seek(Duration.zero);
    position = Duration.zero;
    isPlaying = false;
    notifyListeners();
  }

  Future<void> restart() async {
    if (!hasTrack) return;
    await _player.seek(Duration.zero);
    await _player.play();
  }

  Future<void> seek(Duration target) async {
    if (!hasTrack) return;
    final maximum = duration ?? Duration.zero;
    final clamped = target < Duration.zero
        ? Duration.zero
        : target > maximum
        ? maximum
        : target;
    await _player.seek(clamped);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }
}
