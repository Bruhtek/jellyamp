import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../main.dart';
import '../../utilities/grid.dart';

int crossAxisCount = 2;

// ignore: must_be_immutable
class AlbumsScreen extends ConsumerWidget {
  AlbumsScreen(this.toggleSelecting, this.displayMode, {Key? key}) : super(key: key);

  Function toggleSelecting;
  int displayMode;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(jellyfinAPIProvider.select((value) => value.getAlbums()));

    return Scrollbar(
      controller: scrollController,
      isAlwaysShown: true,
      interactive: true,
      child: AlignedGridView.count(
        addAutomaticKeepAlives: true,
        controller: scrollController,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];

          // compact = 0, comfortable = 1
          switch (displayMode) {
            case 0: // compact
              return gridItem(
                context,
                albumCover(album, ref, rounded: true),
                album.title,
                album.artistNames.join(', '),
                onClick: () => Navigator.pushNamed(context, '/albumInfo', arguments: album),
              );
            case 1:
              return comfortableGridItem(
                context,
                albumCover(album, ref, rounded: true),
                album.title,
                album.artistNames.join(', '),
                onClick: () => Navigator.pushNamed(context, '/albumInfo', arguments: album),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
