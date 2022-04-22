import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'jellyfin.dart';

class JustAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  late JellyfinAPI jellyfinApi;

  JustAudioHandler(JellyfinAPI jellyfinApiProvider) {
    jellyfinApi = jellyfinApiProvider;
    _init();
  }

  Future<void> playExampleSong() async {
    const exampleSongId = 'b05e92a388f97a7d321b38f92c803f33';
    final exampleSong = await jellyfinApi.mediaItemFromSongId(exampleSongId);

    if (exampleSong != null) queue.add([exampleSong]);

    try {
      await _player.setAudioSource(ConcatenatingAudioSource(
        children: queue.value
            .map(
              (item) => AudioSource.uri(
                Uri.parse(jellyfinApi.getSongDownloadUrl(item.id)),
                headers: jellyfinApi.reqHeaders,
              ),
            )
            .toList(),
      ));
      play();
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
    }
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

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> seek(Duration position) => _player.seek(position);
}
