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

  Stream<AudioProcessingState> get audioProcessingState;
  Stream<QueueLoopMode> get loopMode;

  bool get hasPrevious;
  bool get hasNext;

  //TODO: currentQueue

  Future<void> seekToPrevious();
  Future<void> seekToNext();

  Future<void> setLoopMode(QueueLoopMode mode);
  Future<void> setShuffle(bool shuffle);

  Future<void> play();
  Future<void> pause();
  Future<void> seekToStart();
  Future<void> seekToIndex(int index);

  //TODO: add loading playlists
  //Future<Duration?> loadQueue(list of playlist items)
}
