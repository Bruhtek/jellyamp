import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyamp/main.dart';

import '../../api/jellyfin.dart';
import '../../utilities/grid.dart';

// ignore: must_be_immutable
class AlbumInfo extends ConsumerWidget {
  AlbumInfo({Key? key}) : super(key: key);

  late Album album;

  Widget albumInfo(WidgetRef ref) {
    return SizedBox(
      child: Column(
        children: [
          const SizedBox(
            height: 16.0,
          ),
          SizedBox(
            height: 200,
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: albumCover(album, ref),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              album.title,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              album.artistNames.join(', '),
            ),
          ),
        ],
      ),
    );
  }
  Widget body(WidgetRef ref) {
    return ListView.separated(
      itemCount: album.songIds.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return albumInfo(ref);
        }

        index = index - 1;
        final Song song = ref.read(jellyfinAPIProvider).getSong(album.songIds[index])!;

        return ListTile(
          leading: AspectRatio(
            aspectRatio: 1.0,
            child: songCover(song, ref),
          ),
          title: Text(
            song.title,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: song.artistNames.isNotEmpty
              ? Text(
                  song.artistNames.join(', '),
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    album = ModalRoute.of(context)!.settings.arguments as Album;

    return Scaffold(
      body: body(ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
