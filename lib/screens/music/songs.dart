import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../utilities/grid.dart';

int crossAxisCount = 2;

// ignore: must_be_immutable
class SongsScreen extends ConsumerWidget {
  SongsScreen(this.toggleSelecting, {Key? key}) : super(key: key);

  Function toggleSelecting;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scrollbar(
      controller: scrollController,
      isAlwaysShown: true,
      interactive: true,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.0,
        ),
        itemCount: ref.watch(jellyfinAPIProvider.select((value) => value.songsCount)),
        itemBuilder: (context, index) {
          final song = ref.watch(jellyfinAPIProvider.select((value) => value.getSongs()[index]));

          return gridItem(
            context,
            songCover(song, ref),
            song.title,
            song.artistNames.join(', '),
          );
        },
      ),
    );
  }
}
