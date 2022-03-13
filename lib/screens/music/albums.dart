import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../api/jellyfin.dart';
import '../../main.dart';

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
        colors: [
          Colors.transparent,
          Colors.black12,
          Colors.black54,
          Colors.black87,
        ],
        stops: [0.0, 0.7, 0.9, 1.0],
      ).createShader(rect);
    },
    blendMode: BlendMode.srcATop,
    child: AspectRatio(
        aspectRatio: 1 / 1,
        // TODO STYLES: make [Colors.white] customizable in material themeing
        child: Container(color: Colors.white, child: _albumCover(album, ref))),
  ));
  result.add(Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        album.title,
        style: const TextStyle(
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      )));

  return result;
}

Widget _albumCover(Album album, WidgetRef ref) {
  return FutureBuilder<Widget>(
    future: ref.read(jellyfinAPIProvider).itemImage(item: album),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return snapshot.data!;
      }

      return Image(image: MemoryImage(kTransparentImage));
    },
  );
}
