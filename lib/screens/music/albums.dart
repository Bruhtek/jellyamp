import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../main.dart';
import '../../utilities/grid.dart';
import '../../providers/settings.dart';
import '../../providers/jellyfin.dart';

int crossAxisCount = 2;

// ignore: must_be_immutable
class AlbumsScreen extends ConsumerWidget {
  AlbumsScreen(this.toggleSelecting, {this.albumIds, Key? key}) : super(key: key);

  Function toggleSelecting;
  List<String>? albumIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DisplayMode displayMode = ref.watch(settingsProvider.select((value) => value.displayMode));
    List<Album> albums = [];
    if (albumIds != null) {
      for (var i = 0; i < albumIds!.length; i++) {
        var temp = ref.watch(jellyfinAPIProvider.select((value) => value.getAlbum(albumIds![i])));
        if (temp != null) {
          albums.add(temp);
        }
      }
    } else {
      albums = ref.watch(jellyfinAPIProvider.select((value) => value.getAlbums()));
    }

    return AlignedGridView.count(
      addAutomaticKeepAlives: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];

        // compact = 0, comfortable = 1
        switch (displayMode) {
          case DisplayMode.grid: // compact
            return gridItem(
              context,
              albumCover(album, ref, context, rounded: true),
              album.title,
              album.artistNames.join(', '),
              onClick: () => Navigator.pushNamed(context, '/albumInfo', arguments: album),
            );
          case DisplayMode.comfortableGrid:
            return comfortableGridItem(
              context,
              albumCover(album, ref, context, rounded: true),
              album.title,
              album.artistNames.join(', '),
              onClick: () => Navigator.pushNamed(context, '/albumInfo', arguments: album),
            );
          default:
            return null;
        }
      },
    );
  }
}
