import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';

class PanelPlayer extends ConsumerStatefulWidget {
  const PanelPlayer({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PanelPlayerState();
}

class _PanelPlayerState extends ConsumerState<PanelPlayer> {
  @override
  Widget build(BuildContext context) {
    final sequenceState = ref.watch(sequenceStateProvider);
    return sequenceState.when(
      data: (state) {
        final track = state!.sequence[state.currentIndex];

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: ref.read(jellyfinAPIProvider).futureItemImage(
                      item: track.tag,
                      alternative: const Icon(Icons.music_note_rounded),
                      fit: BoxFit.contain,
                    ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              track.tag.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary),
            ),
            Text(
              track.tag.artist,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => ref.read(justAudioProvider).skipToPrevious(),
                  icon: const Icon(Icons.skip_previous_rounded),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  iconSize: 40,
                ),
                StreamBuilder<bool>(
                  stream: ref.watch(justAudioProvider.select((value) => value.playingStream)),
                  builder: (context, snapshot) {
                    if (snapshot.data ?? false) {
                      return IconButton(
                        onPressed: () => ref.read(justAudioProvider).pause(),
                        icon: const Icon(Icons.pause_rounded),
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        iconSize: 48,
                      );
                    }

                    return IconButton(
                      onPressed: () => ref.read(justAudioProvider).play(),
                      icon: const Icon(Icons.play_arrow_rounded),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      iconSize: 48,
                    );
                  },
                ),
                IconButton(
                  onPressed: () => ref.read(justAudioProvider).skipToNext(),
                  icon: const Icon(Icons.skip_next_rounded),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  iconSize: 40,
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text('Error: $error \n $stackTrace'),
    );
  }
}
