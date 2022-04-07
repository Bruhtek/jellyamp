import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../main.dart';
import '../../utilities/grid.dart';

int crossAxisCount = 2;

// ignore: must_be_immutable
class SongsScreen extends ConsumerWidget {
  SongsScreen(this.toggleSelecting, this.displayMode, {Key? key}) : super(key: key);

  Function toggleSelecting;
  int displayMode;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scrollbar(
      controller: scrollController,
      isAlwaysShown: true,
      interactive: true,
      child: AlignedGridView.count(
        addAutomaticKeepAlives: false,
        controller: scrollController,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        itemCount: ref.watch(jellyfinAPIProvider.select((value) => value.songsCount)),
        itemBuilder: (context, index) {
          final song = ref.watch(jellyfinAPIProvider.select((value) => value.getSongs()[index]));

          switch (displayMode) {
            case 0: // compact
              return gridItem(
                context,
                songCover(song, ref),
                song.title,
                song.artistNames.join(', '),
              );
            case 1:
              return comfortableGridItem(
                context,
                songCover(song, ref, rounded: true),
                song.title,
                song.artistNames.join(', '),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
