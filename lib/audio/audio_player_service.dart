import 'package:flutter/cupertino.dart';
import 'package:jellyamp/classes/audio.dart';
import 'package:just_audio/just_audio.dart';

enum AudioProcessingState {
  idle,
  loading,
  buffering,
  ready,
  playing,
  completed,
  unknown,
}
enum QueueLoopMode {
  off,
  one,
  all,
}

abstract class AudioPlayerService {
  Stream<bool> get isPlaying;
  Stream<bool> get isShuffle;

  Stream<Duration> get positionStream;
  Stream<SequenceState?> get sequenceStateStream;
  Stream<Duration?> get durationStream;

  Stream<AudioProcessingState> get audioProcessingState;
  Stream<QueueLoopMode> get loopMode;

  bool get hasPrevious;
  bool get hasNext;

  Future<void> seekToPrevious();
  Future<void> seekToNext();

  Future<void> setLoopMode(QueueLoopMode mode);
  Future<void> setShuffle(bool shuffle);

  Future<void> play();
  Future<void> pause();
  Future<void> seekToStart();
  Future<void> seekToIndex(int index);
  Future<void> seek(int seconds);

  void playList(List<AudioMetadata> items, BuildContext context);
  void addToQueue(List<AudioMetadata> items, BuildContext context);
}
