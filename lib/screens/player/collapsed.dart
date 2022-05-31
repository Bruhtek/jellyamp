import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';

class Collapsed extends ConsumerStatefulWidget {
  const Collapsed({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CollapsedState();
}

class _CollapsedState extends ConsumerState<Collapsed> {
  @override
  Widget build(BuildContext context) {
    final sequenceState = ref.watch(sequenceStateProvider);
    return sequenceState.when(
      data: (state) {
        final track = state!.sequence[state.currentIndex];

        return Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              const SizedBox(width: 4.0),
              AspectRatio(
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
              const SizedBox(width: 4.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      track.tag.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary),
                    ),
                    Text(
                      track.tag.artist,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4.0),
              StreamBuilder<bool>(
                  stream: ref.watch(justAudioProvider.select((a) => a.playingStream)),
                  builder: (context, snapshot) {
                    final playing = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      onPressed: () {
                        if (playing) {
                          ref.read(justAudioProvider).pause();
                        } else {
                          ref.read(justAudioProvider).play();
                        }
                      },
                    );
                  }),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text('Error: $error \n $stackTrace'),
    );
  }
}
