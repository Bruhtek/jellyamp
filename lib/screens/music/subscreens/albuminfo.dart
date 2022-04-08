import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyamp/main.dart';

import '../../../api/jellyfin.dart';
import '../../../utilities/grid.dart';

// ignore: must_be_immutable
class AlbumInfo extends ConsumerWidget {
  AlbumInfo({Key? key}) : super(key: key);

  late Album album;

  Widget albumInfo(WidgetRef ref, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const SizedBox(
            height: 16.0,
          ),
          AspectRatio(
            aspectRatio: 1 / 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: albumCover(album, ref, context),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              album.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              album.artistNames.join(', '),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
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
          return albumInfo(ref, context);
        }

        index = index - 1;
        final Song song = ref.read(jellyfinAPIProvider).getSong(album.songIds[index])!;

        return ListTile(
          leading: AspectRatio(
            aspectRatio: 1.0,
            child: songCover(song, ref, context),
          ),
          title: Text(
            song.title,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          subtitle: song.artistNames.isNotEmpty
              ? Text(
                  song.artistNames.join(', '),
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
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
