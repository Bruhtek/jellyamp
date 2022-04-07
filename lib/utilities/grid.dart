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
        child: Container(
          color: Theme.of(context).colorScheme.onSecondary,
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

Widget comfortableGridItem(
  BuildContext context,
  Widget background,
  String title,
  String? subtitle, {
  Function? onClick,
}) {
  List<Widget> columnWidgets = [
    AspectRatio(
      aspectRatio: 1 / 1,
      child: background,
    ),
    Text(
      title,
      style: const TextStyle(
        fontSize: 15,
      ),
      textAlign: TextAlign.center,
    ),
  ];

  if (subtitle != null) {
    columnWidgets.add(
      Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  return InkWell(
    onTap: () => onClick?.call(),
    child: Column(
      children: columnWidgets,
    ),
  );
}

Widget albumCover(Album album, WidgetRef ref, BuildContext context, {bool rounded = false}) {
  if (rounded) {
    return Hero(
      tag: 'imageTag' + album.id,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: ref.read(jellyfinAPIProvider).futureItemImage(
              item: album,
              alternative: Center(
                child: Icon(
                  Icons.album_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.secondary,
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
          alternative: Center(
            child: Icon(
              Icons.album_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
  );
}
Widget artistCover(Artist artist, WidgetRef ref, BuildContext context,
    {bool rounded = false, bool oval = false}) {
  if (rounded) {
    return Hero(
      tag: 'imageTag' + artist.id,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: ref.read(jellyfinAPIProvider).futureItemImage(
              item: artist,
              alternative: Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
      ),
    );
  }

  if (oval) {
    return Hero(
      tag: 'imageTag' + artist.id,
      child: ClipOval(
        child: Container(
          color: Theme.of(context).colorScheme.onSecondary,
          child: ref.read(jellyfinAPIProvider).futureItemImage(
                item: artist,
                alternative: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
        ),
      ),
    );
  }

  return Hero(
    tag: 'imageTag' + artist.id,
    child: ref.read(jellyfinAPIProvider).futureItemImage(
          item: artist,
          alternative: Center(
            child: Icon(
              Icons.person_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
  );
}
Widget songCover(Song song, WidgetRef ref, BuildContext context, {bool rounded = false}) {
  if (rounded) {
    return Hero(
      tag: 'imageTag' + song.id,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: ref.read(jellyfinAPIProvider).futureItemImage(
              item: song,
              alternative: Center(
                child: Icon(
                  Icons.music_note_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
      ),
    );
  }

  return Hero(
    tag: 'imageTag' + song.id,
    child: ref.read(jellyfinAPIProvider).futureItemImage(
          item: song,
          alternative: Center(
            child: Icon(
              Icons.music_note_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
  );
}
