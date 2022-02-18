import 'package:audio_service/audio_service.dart' hide AudioProcessingState;
import 'package:flutter/cupertino.dart';
import 'package:jellyamp/api/jellyfin.dart';
import 'package:jellyamp/audio/audio_player_service.dart';
import 'package:jellyamp/classes/audio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:jellyamp/api/uri_from_file_or_url.dart';

class JustAudioPlayer implements AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  ConcatenatingAudioSource? concatenatingAudioSource;

  @override
  void playList(List<MediaItem> songList, BuildContext context) async {
    List<UriAudioSource> uriAudioSourceList = [];

    JellyfinAPI jellyfinAPI = Provider.of<JellyfinAPI>(context, listen: false);

    for (MediaItem song in songList) {
      uriAudioSourceList.add(AudioSource.uri(
        Uri.parse("${jellyfinAPI.reqBaseUrl}/Items/${song.id}/Download"),
        headers: jellyfinAPI.reqHeaders,
        tag: MediaItem(
          id: song.id,
          title: song.title,
          artist: song.extras!['artists']?.join(', '),
          artUri:
              Provider.of<JellyfinAPI>(context, listen: false).uriIfTagExists(
            primaryImageTag: song.extras!['primaryImageTag'],
            itemId: song.id,
          ),
          extras: song.extras,
        ),
      ));
    }

    concatenatingAudioSource = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: uriAudioSourceList,
    );

    await _audioPlayer.setAudioSource(
      concatenatingAudioSource!,
      initialIndex: 0,
      initialPosition: Duration.zero,
    );

    _audioPlayer.play();
  }

  @override
  void addToQueue(List<MediaItem> items, BuildContext context) async {
    if (concatenatingAudioSource == null) {
      return playList(items, context);
    }

    JellyfinAPI jellyfinAPI = Provider.of<JellyfinAPI>(context, listen: false);

    for (var song in items) {
      await concatenatingAudioSource!.add(
        AudioSource.uri(
          Uri.parse("${jellyfinAPI.reqBaseUrl}/Items/${song.id}/Download"),
          headers: jellyfinAPI.reqHeaders,
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.extras!['artists']?.join(', '),
            artUri:
                Provider.of<JellyfinAPI>(context, listen: false).uriIfTagExists(
              primaryImageTag: song.extras!['primaryImageTag'],
              itemId: song.id,
            ),
            extras: song.extras,
          ),
        ),
      );
    }
  }

  @override
  Stream<bool> get isPlayingStream => _audioPlayer.playingStream;
  @override
  bool get isPlaying => _audioPlayer.playing;
  @override
  Stream<bool> get isShuffle => _audioPlayer.shuffleModeEnabledStream;
  @override
  Stream<AudioProcessingState> get audioProcessingStateStream =>
      _audioPlayer.playerStateStream.map((_playerStateMap));
  @override
  Stream<QueueLoopMode> get loopMode =>
      _audioPlayer.loopModeStream.map((_loopModeMap));

  @override
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  @override
  Stream<SequenceState?> get sequenceStateStream =>
      _audioPlayer.sequenceStateStream;
  @override
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  @override
  Stream<PlaybackEvent> get playbackEventStream =>
      _audioPlayer.playbackEventStream;

  @override
  bool get hasPrevious => _audioPlayer.hasPrevious;
  @override
  bool get hasNext => _audioPlayer.hasNext;

  @override
  Future<void> seekToPrevious() => _audioPlayer.seekToPrevious();
  @override
  Future<void> seekToNext() => _audioPlayer.seekToNext();

  @override
  Future<void> setLoopMode(QueueLoopMode mode) {
    switch (mode) {
      case QueueLoopMode.off:
        return _audioPlayer.setLoopMode(LoopMode.off);
      case QueueLoopMode.one:
        return _audioPlayer.setLoopMode(LoopMode.one);
      case QueueLoopMode.all:
        return _audioPlayer.setLoopMode(LoopMode.all);
    }
  }

  @override
  Future<void> setShuffle(bool shuffle) async {
    if (shuffle) {
      await _audioPlayer.shuffle();
    }
    return _audioPlayer.setShuffleModeEnabled(shuffle);
  }

  @override
  Future<void> play() => _audioPlayer.play();
  @override
  Future<void> pause() => _audioPlayer.pause();
  @override
  Future<void> seekToStart() => _audioPlayer.seek(Duration.zero,
      index: _audioPlayer.effectiveIndices?.first);
  @override
  Future<void> seekToIndex(int index) =>
      _audioPlayer.seek(Duration.zero, index: index);
  @override
  Future<void> seek(int seconds) =>
      _audioPlayer.seek(Duration(seconds: seconds));

  Future<void> dispose() => _audioPlayer.dispose();

  static AudioProcessingState _playerStateMap(PlayerState? state) {
    final processingState = state?.processingState;
    if (processingState == null) return AudioProcessingState.unknown;

    switch (processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        if (state?.playing ?? false) {
          return AudioProcessingState.playing;
        } else {
          return AudioProcessingState.ready;
        }
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  static QueueLoopMode _loopModeMap(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return QueueLoopMode.off;
      case LoopMode.one:
        return QueueLoopMode.one;
      case LoopMode.all:
        return QueueLoopMode.all;
    }
  }
}
