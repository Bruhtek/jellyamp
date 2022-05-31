import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

        return Column(children: [
          const SizedBox(height: 8.0),
          Text(
            "Queue",
            style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: sequence.length,
                itemBuilder: (context, index) {
                  final track = sequence[index];
                  final selected = index == state.currentIndex;

                  return ListTile(
                    textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    selected: selected,
                    title: selected
                        ? Text(track.tag.title, style: const TextStyle(fontWeight: FontWeight.bold))
                        : Text(track.tag.title),
                    subtitle: selected
                        ? Text(track.tag.artist,
                            style: const TextStyle(fontWeight: FontWeight.bold))
                        : Text(track.tag.artist),
                    minLeadingWidth: 0,
                    contentPadding: EdgeInsets.zero,
                    leading: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: SizedBox(
                        height: double.infinity,
                        child: ClipOval(
                          child: ref.read(jellyfinAPIProvider).futureItemImage(
                                item: track.tag,
                                alternative: const Icon(Icons.music_note_rounded),
                              ),
                        ),
                      ),
                    ),
                    onTap: () {
                      ref.read(justAudioProvider).skipToQueueItem(index);
                    },
                  );
                },
              ),
            ),
          ),
        ]);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text('Error: $error \n $stackTrace'),
    );
  }
}
