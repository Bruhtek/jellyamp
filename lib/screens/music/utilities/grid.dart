import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../api/jellyfin.dart';
import '../../../main.dart';

Widget gridItem(
  BuildContext context,
  Widget background,
  String title,
  String? subtitle,
) {
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
            Colors.black54,
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

Widget albumCover(Album album, WidgetRef ref) {
  return FutureBuilder<Widget>(
    future: ref.read(jellyfinAPIProvider).itemImage(
          item: album,
          alternative: const Center(
            child: Icon(
              Icons.music_note_rounded,
              size: 72,
              color: Colors.black54,
            ),
          ),
        ),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return snapshot.data!;
      }

      return Container();
    },
  );
}

Widget artistCover(Artist artist, WidgetRef ref) {
  return FutureBuilder<Widget>(
    future: ref.read(jellyfinAPIProvider).itemImage(
          item: artist,
          alternative: const Center(
            child: Icon(
              Icons.person_rounded,
              size: 72,
              color: Colors.black54,
            ),
          ),
        ),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return snapshot.data!;
      }

      return Container();
    },
  );
}

Widget songCover(Song song, WidgetRef ref) {
  return FutureBuilder<Widget>(
    future: ref.read(jellyfinAPIProvider).itemImage(
          item: song,
          alternative: const Center(
            child: Icon(
              Icons.person_rounded,
              size: 72,
              color: Colors.black54,
            ),
          ),
        ),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return snapshot.data!;
      }

      return Container();
    },
  );
}
