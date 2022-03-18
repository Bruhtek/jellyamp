import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import 'utilities/grid.dart';

int crossAxisCount = 2;

class AlbumsScreen extends ConsumerWidget {
  AlbumsScreen(this.toggleSelecting, {Key? key}) : super(key: key);

  Function toggleSelecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.0,
        ),
        itemCount:
            ref.watch(jellyfinAPIProvider.select((value) => value.albumsCount)),
        itemBuilder: (context, index) {
          final album = ref.watch(
              jellyfinAPIProvider.select((value) => value.getAlbums()[index]));

          return gridItem(context, albumCover(album, ref), album.title,
              album.artistNames.join(', '));
        },
      ),
    );
  }
}
