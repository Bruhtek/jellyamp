import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../main.dart';
import '../../utilities/grid.dart';
import '../../utilities/providers/settings.dart';

int crossAxisCount = 2;

// ignore: must_be_immutable
class SongsScreen extends ConsumerWidget {
  SongsScreen(this.toggleSelecting, {Key? key}) : super(key: key);

  Function toggleSelecting;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayMode = ref.watch(settingsProvider.select((value) => value.displayMode));
    final songs = ref.watch(jellyfinAPIProvider.select((value) => value.getSongs()));

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
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];

          switch (displayMode) {
            case DisplayMode.grid: // compact
              return gridItem(
                context,
                songCover(song, ref, context),
                song.title,
                song.artistNames.join(', '),
              );
            case DisplayMode.comfortableGrid:
              return comfortableGridItem(
                context,
                songCover(song, ref, context, rounded: true),
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
