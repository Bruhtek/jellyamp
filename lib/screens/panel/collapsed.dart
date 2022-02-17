import 'package:flutter/material.dart';
import 'package:jellyamp/api/jellyfin.dart';
import 'package:just_audio/just_audio.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:jellyamp/audio/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  Widget _playButton(BuildContext context) {
    final audioPlayerService = Provider.of<AudioPlayerService>(context);
    return StreamBuilder<AudioProcessingState>(
      stream: audioPlayerService.audioProcessingStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data;
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
        } else {
          return Container();
        }
      },
    );
  }

  Widget _miniPlayer(
      int position, dynamic songInfo, int duration, BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                AspectRatio(
                  aspectRatio: 1 / 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Provider.of<JellyfinAPI>(context).imageIfTagExists(
                      primaryImageTag: songInfo.primaryImageTag,
                      itemId: songInfo.id,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(songInfo.title,
                                style: Theme.of(context).textTheme.headline5,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.left),
                            Text(songInfo.artists.join(", "),
                                style: Theme.of(context).textTheme.subtitle1,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.left),
                          ],
                        ))),
                _playButton(context),
              ],
            ),
          ),
        ),
        LinearProgressIndicator(
          value: position / duration,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService =
        Provider.of<AudioPlayerService>(context);

    return Container(
      color: Provider.of<ColorScheme>(context).surface,
      child: StreamBuilder3<Duration, SequenceState?, Duration?>(
          streams: Tuple3(
            audioPlayerService.positionStream,
            audioPlayerService.sequenceStateStream,
            audioPlayerService.durationStream,
          ),
          builder: (context, data) {
            if (data.item1.hasData &&
                data.item2.hasData &&
                data.item3.hasData) {
              final position = data.item1.data!.inSeconds;
              final sequenceState = data.item2.data;
              final currentItemTag =
                  sequenceState!.sequence[sequenceState.currentIndex].tag;
              final duration = data.item3.data!.inSeconds;

              return _miniPlayer(position, currentItemTag, duration, context);
            } else {
              return const Center(child: Text("Nothing playing..."));
            }
          }),
    );
  }
}
