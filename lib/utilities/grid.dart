import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/jellyfin.dart';
import '../../../main.dart';

Widget gridItem(
  BuildContext context,
  Widget background,
  String title,
  String? subtitle, {
  Function? onClick,
}) {
  List<Widget> gridStack = [];

  gridStack.add(
    ShaderMask(
      shaderCallback: (Rect rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black45,
            Colors.black54,
          ],
          stops: [0.0, 0.7, 0.9, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.srcATop,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        // TODO STYLES: make [Colors.white] customizable in material themeing
        child: Container(
          color: Colors.white,
          child: background,
        ),
      ),
    ),
  );

  List<Widget> titleColumn = [
    Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    ),
  ];

  if (subtitle != null) {
    titleColumn.add(
      Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
        textAlign: TextAlign.center,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  gridStack.add(
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: titleColumn,
      ),
    ),
  );

  // add a click handler if one is provided
  gridStack.add(Positioned.fill(
    child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onClick?.call(),
        )),
  ));

  return ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: GridTile(
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: gridStack,
        ),
      ),
    ),
  );
}

Widget albumCover(Album album, WidgetRef ref, {bool rounded = false}) {
  if (rounded) {
    return Hero(
      tag: 'imageTag' + album.id,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: ref.read(jellyfinAPIProvider).futureItemImage(
              item: album,
              alternative: const Center(
                child: Icon(
                  Icons.album_rounded,
                  size: 72,
                  color: Colors.black54,
                ),
              ),
            ),
      ),
    );
  }

  return Hero(
    tag: 'imageTag' + album.id,
    child: ref.read(jellyfinAPIProvider).futureItemImage(
          item: album,
          alternative: const Center(
            child: Icon(
              Icons.album_rounded,
              size: 72,
              color: Colors.black54,
            ),
          ),
        ),
  );
}
Widget artistCover(Artist artist, WidgetRef ref) {
  return Hero(
    tag: 'imageTag' + artist.id,
    child: ref.read(jellyfinAPIProvider).futureItemImage(
          item: artist,
          alternative: const Center(
            child: Icon(
              Icons.person_rounded,
              size: 72,
              color: Colors.black54,
            ),
          ),
        ),
  );
}
Widget songCover(Song song, WidgetRef ref) {
  return Hero(
    tag: 'imageTag' + song.id,
    child: ref.read(jellyfinAPIProvider).futureItemImage(
          item: song,
          alternative: const Center(
            child: Icon(
              Icons.music_note_rounded,
              size: 72,
              color: Colors.black54,
            ),
          ),
        ),
  );
}
