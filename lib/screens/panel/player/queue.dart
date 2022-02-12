import 'package:flutter/material.dart';
import 'package:jellyamp/api/jellyfin.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import 'package:jellyamp/audio/audio_player_service.dart';

class Queue extends StatelessWidget {
  const Queue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService =
        Provider.of<AudioPlayerService>(context);

    return StreamBuilder<SequenceState?>(
      stream: audioPlayerService.sequenceStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data;
          final sequence = state!.sequence;

          return ListView.builder(
            itemCount: sequence.length,
            itemBuilder: (context, index) {
              return ListTile(
                selected: index == state.currentIndex,
                leading: Provider.of<JellyfinAPI>(context).imageIfTagExists(
                  primaryImageTag: sequence[index].tag.primaryImageTag,
                  itemId: sequence[index].tag.albumId,
                  alternative: const Icon(
                    Icons.music_note_rounded,
                    size: 50,
                  ),
                ),
                title: Text(sequence[index].tag.title),
                subtitle: Text(sequence[index].tag.artists.join(', ')),
                onTap: () => audioPlayerService.seekToIndex(index),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}