import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../main.dart';

class PanelQueue extends ConsumerStatefulWidget {
  const PanelQueue({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PanelQueueState();
}

class _PanelQueueState extends ConsumerState<PanelQueue> {
  @override
  Widget build(BuildContext context) {
    final sequenceState = ref.watch(sequenceStateProvider);

    return sequenceState.when(
      data: (state) {
        final sequence = state!.sequence;

        return ListView.builder(
          itemCount: sequence.length,
          itemBuilder: (context, index) {
            final track = sequence[index];

            return ListTile(
              selected: index == state.currentIndex,
              title: Text(track.tag.title),
              subtitle: Text(track.tag.artist),
              minLeadingWidth: 0,
              // ignore: sized_box_for_whitespace
              leading: Container(
                height: double.infinity,
                child: ClipOval(
                  child: ref.read(jellyfinAPIProvider).futureItemImage(
                        item: track.tag,
                        alternative: const Icon(Icons.music_note_rounded),
                      ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text('Error: $error \n $stackTrace'),
    );
  }
}
