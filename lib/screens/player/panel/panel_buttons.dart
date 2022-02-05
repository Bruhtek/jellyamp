import 'package:flutter/material.dart';

import 'package:jellyamp/audio/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';

import 'package:provider/provider.dart';

class PlayerButtons extends StatelessWidget {
  const PlayerButtons(this.context, {Key? key}) : super(key: key);

  final BuildContext context;

  Widget _playPauseButton(
      AudioProcessingState state, AudioPlayerService audioPlayerService) {
    if (state == AudioProcessingState.loading ||
        state == AudioProcessingState.buffering) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: const CircularProgressIndicator(),
      );
    } else if (state == AudioProcessingState.completed) {
      return IconButton(
        icon: const Icon(Icons.replay_rounded),
        iconSize: 64.0,
        onPressed: () => audioPlayerService.seekToStart(),
      );
    } else if (state == AudioProcessingState.idle ||
        state == AudioProcessingState.ready) {
      return IconButton(
        icon: const Icon(Icons.play_arrow_rounded),
        iconSize: 64.0,
        onPressed: () => audioPlayerService.play(),
      );
    } else if (state == AudioProcessingState.playing) {
      return IconButton(
        icon: const Icon(Icons.pause_rounded),
        iconSize: 64.0,
        onPressed: () => audioPlayerService.pause(),
      );
    } else {
      return const Icon(Icons.error_outline_rounded, size: 64.0);
    }
  }

  Widget _shuffleButton(bool enabled, AudioPlayerService audioPlayerService) {
    return IconButton(
      icon: enabled
          ? const Icon(Icons.shuffle_rounded)
          : const Icon(Icons.shuffle_rounded, color: Colors.blueAccent),
      onPressed: () => audioPlayerService.setShuffle(!enabled),
    );
  }

  Widget _loopButton(
      QueueLoopMode loopMode, AudioPlayerService audioPlayerService) {
    final icons = [
      const Icon(Icons.repeat_rounded),
      const Icon(Icons.repeat_rounded, color: Colors.blueAccent),
      const Icon(Icons.repeat_one_rounded, color: Colors.blueAccent),
    ];
    const cycleModes = [
      QueueLoopMode.off,
      QueueLoopMode.all,
      QueueLoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);

    return IconButton(
      icon: icons[index],
      onPressed: () => audioPlayerService
          .setLoopMode(cycleModes[(index + 1) % cycleModes.length]),
    );
  }

  Widget _previousButton(AudioPlayerService audioPlayerService) {
    return IconButton(
      icon: const Icon(Icons.skip_previous_rounded),
      onPressed: audioPlayerService.hasPrevious
          ? audioPlayerService.seekToPrevious
          : null,
    );
  }

  Widget _nextButton(AudioPlayerService audioPlayerService) {
    return IconButton(
      icon: const Icon(Icons.skip_next_rounded),
      onPressed:
          audioPlayerService.hasNext ? audioPlayerService.seekToNext : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService =
        Provider.of<AudioPlayerService>(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<bool>(
          stream: audioPlayerService.isShuffle,
          builder: (_, snapshot) =>
              _shuffleButton(snapshot.data!, audioPlayerService),
        ),
        StreamBuilder2<AudioProcessingState, QueueLoopMode>(
          streams: Tuple2(
            audioPlayerService.audioProcessingState,
            audioPlayerService.loopMode,
          ),
          builder: (_, __) => _previousButton(audioPlayerService),
        ),
        StreamBuilder<AudioProcessingState>(
          stream: audioPlayerService.audioProcessingState,
          builder: (_, snapshot) =>
              _playPauseButton(snapshot.data!, audioPlayerService),
        ),
        StreamBuilder2<AudioProcessingState, QueueLoopMode>(
          streams: Tuple2(
            audioPlayerService.audioProcessingState,
            audioPlayerService.loopMode,
          ),
          builder: (_, __) => _nextButton(audioPlayerService),
        ),
        StreamBuilder<QueueLoopMode>(
          stream: audioPlayerService.loopMode,
          builder: (_, snapshot) =>
              _loopButton(snapshot.data!, audioPlayerService),
        ),
      ],
    );
  }
}
