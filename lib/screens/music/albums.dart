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
        itemCount: ref.watch(jellyfinAPIProvider.select((value) => value.albumsCount)),
        itemBuilder: (context, index) {
          final album = ref.watch(jellyfinAPIProvider.select((value) => value.getAlbums()[index]));

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
              return InkWell(
                onTap: () => Navigator.pushNamed(context, '/albumInfo', arguments: album),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1 / 1,
                      child: albumCover(album, ref, rounded: true),
                    ),
                    Text(
                      album.title,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      album.artistNames.join(', '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            default:
              return gridItem(
                context,
                albumCover(album, ref, rounded: true),
                album.title,
                album.artistNames.join(', '),
                onClick: () => Navigator.pushNamed(context, '/albumInfo', arguments: album),
              );
          }
        },
      ),
    );
  }
}
