import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:jellyamp/external/audio_video_progress_bar.dart';

import 'package:jellyamp/api/jellyfin.dart';
import 'package:jellyamp/audio/audio_player_service.dart';

class PlayerMain extends StatelessWidget {
  const PlayerMain({Key? key}) : super(key: key);

  Widget _playerMain(
      BuildContext context,
      Duration positionStream,
      SequenceState sequenceStateStream,
      Duration durationStream,
      PlaybackEvent playbackEventStream) {
    //Provider.of<JellyfinAPI>(context).imageIfTagExists
    final state = sequenceStateStream;

    final currentItemTag = state.sequence[state.currentIndex].tag;

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48.0),
                  child: Provider.of<JellyfinAPI>(context).imageIfTagExists(
                    primaryImageTag: currentItemTag.primaryImageTag,
                    itemId: currentItemTag.albumId,
                    alternative: const Icon(
                      Icons.music_note_rounded,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            child: ProgressBar(
              progress: positionStream,
              buffered: playbackEventStream.bufferedPosition,
              total: durationStream,
              onSeek: (Duration duration) =>
                  Provider.of<AudioPlayerService>(context, listen: false)
                      .seek(duration.inSeconds),
            ),
          ),
          Text(
            currentItemTag.title,
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
          Text(
            currentItemTag.artists.join(", "),
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService =
        Provider.of<AudioPlayerService>(context);

    return StreamBuilder4<Duration, SequenceState?, Duration?, PlaybackEvent>(
      streams: Tuple4(
        audioPlayerService.positionStream,
        audioPlayerService.sequenceStateStream,
        audioPlayerService.durationStream,
        audioPlayerService.playbackEventStream,
      ),
      builder: (context, snapshot) {
        final position = snapshot.item1;
        final sequenceState = snapshot.item2;
        final duration = snapshot.item3;
        final playbackEvent = snapshot.item4;

        if (position.hasData &&
            sequenceState.hasData &&
            duration.hasData &&
            playbackEvent.hasData) {
          return _playerMain(context, position.data!, sequenceState.data!,
              duration.data!, playbackEvent.data!);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
