import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/jellyfin.dart';
import '../../main.dart';

int crossAxisCount = 3;

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
          itemCount: ref
              .watch(jellyfinAPIProvider.select((value) => value.albumsCount)),
          itemBuilder: (context, index) {
            final album = ref.watch(jellyfinAPIProvider
                .select((value) => value.getAlbums()[index]));

            return ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: GridTile(
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: _albumsGridStack(context, album, ref, index),
                  ),
                ),
              ),
            );
          },
        ));
  }
}

List<Widget> _albumsGridStack(
  BuildContext context,
  Album album,
  WidgetRef ref,
  int index,
) {
  List<Widget> result = [];

  result.add(ShaderMask(
    shaderCallback: (Rect rect) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black54, Colors.black54],
        stops: [0.8, 0.95, 1.0],
      ).createShader(rect);
    },
    blendMode: BlendMode.srcATop,
    child: AspectRatio(aspectRatio: 1 / 1, child: _albumCover(album)),
  ));
  result.add(Text(index.toString(), style: TextStyle(color: Colors.white)));

  return result;
}

Widget _albumCover(Album album) {
  return Container(color: Colors.blue);
}
