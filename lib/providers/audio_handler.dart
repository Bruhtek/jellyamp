import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'jellyfin.dart';

class JustAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  late JellyfinAPI jellyfinApi;
  ConcatenatingAudioSource? concatenatingAudioSource;

  JustAudioHandler(JellyfinAPI jellyfinApiProvider) {
    jellyfinApi = jellyfinApiProvider;
    _init();
  }

  List<AudioSource> get itemsFromQueue => queue.value
      .map(
        (item) => AudioSource.uri(
          Uri.parse(jellyfinApi.getSongDownloadUrl(item.id)),
          headers: jellyfinApi.reqHeaders,
          tag: item,
        ),
      )
      .toList();

  AudioSource audioSourceFromMediaItem(MediaItem item) => AudioSource.uri(
        Uri.parse(jellyfinApi.getSongDownloadUrl(item.id)),
        headers: jellyfinApi.reqHeaders,
        tag: item,
      );

  Future<void> addOrPlayFromSongId(String id) {
    if (_player.playing && concatenatingAudioSource != null) {
      return addFromSongId(id);
    }
    return playFromSongId(id);
  }

  Future<void> addOrPlayFromAlbumId(String id) async {
    bool add = false;
    if (_player.playing && concatenatingAudioSource != null) {
      add = true;
    }

    final album = jellyfinApi.getAlbum(id);
    final songs = album!.songIds;

    for (var id in songs) {
      if (add) {
        addFromSongId(id);
      } else {
        playFromSongId(id);
        add = true;
      }
    }
  }

  /// assumes that concatenatingAudioSource is not null
  Future<void> addFromSongId(String id) async {
    final item = await jellyfinApi.mediaItemFromSongId(id);

    if (item != null) {
      queue.add(queue.value + [item]);

      concatenatingAudioSource!.add(audioSourceFromMediaItem(item));
    }
  }

  Future<void> playFromSongId(String id) async {
    final item = await jellyfinApi.mediaItemFromSongId(id);

    if (item != null) {
      stop();
      queue.add([item]);
      mediaItem.add(item);
    }

    concatenatingAudioSource = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: itemsFromQueue,
    );

    await _player.setAudioSource(
      concatenatingAudioSource!,
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
    play();
  }

  Future<void> _init() async {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    _player.currentIndexStream.listen((index) {
      if (index != null && queue.value.length > index) mediaItem.add(queue.value[index]);
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) stop();
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        const MediaControl(
          androidIcon: "drawable/ic_round_skip_previous_36",
          label: "Previous",
          action: MediaAction.skipToPrevious,
        ),
        const MediaControl(
          androidIcon: "drawable/ic_round_stop_36",
          label: "Stop",
          action: MediaAction.stop,
        ),
        if (_player.playing)
          const MediaControl(
            androidIcon: "drawable/ic_round_pause_36",
            label: "Pause",
            action: MediaAction.pause,
          )
        else
          const MediaControl(
            androidIcon: "drawable/ic_round_play_arrow_36",
            label: "Play",
            action: MediaAction.play,
          ),
        const MediaControl(
          androidIcon: "drawable/ic_round_skip_next_36",
          label: "Next",
          action: MediaAction.skipToNext,
        ),
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: _player.playing ? [0, 2, 3] : [1, 2, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  @override
  Future<void> play() => _player.play();

  Stream<bool> get playingStream => _player.playingStream;

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToQueueItem(int index) => _player.seek(Duration.zero, index: index);

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> removeQueueItemAt(int index) async {
    final q = queue.value;
    q.removeAt(index);
    queue.add(q);

    concatenatingAudioSource!.removeAt(index);

    return;
  }

  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;
}
