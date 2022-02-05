import 'package:flutter/material.dart';
import 'package:jellyamp/api/jellyfin.dart';
import 'package:jellyamp/audio/audio_player_service.dart';
import 'package:jellyamp/audio/just_audio_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'package:jellyamp/classes/audio.dart';

class AlbumItem extends StatefulWidget {
  const AlbumItem({Key? key}) : super(key: key);

  @override
  _AlbumItemState createState() => _AlbumItemState();
}

class _AlbumItemState extends State<AlbumItem> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as AlbumArguments;
    late Future<AlbumInfo> futureAlbumInfo;

    futureAlbumInfo = Provider.of<JellyfinAPI>(context, listen: false)
        .fetchAlbumSongs(args.albumId);

    return FutureBuilder<AlbumInfo>(
      future: futureAlbumInfo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final albumInfos = snapshot.data!;
          int itemCount = 0;
          if (albumInfos.songs != null) {
            itemCount = albumInfos.songs!.length;
          }

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    pinned: true,
                    snap: false,
                    floating: false,
                    expandedHeight: 200,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(snapshot.data!.title),
                      background: Container(
                        foregroundDecoration: const BoxDecoration(
                          color: Colors.black54,
                        ),
                        child:
                            Provider.of<JellyfinAPI>(context).imageIfTagExists(
                          primaryImageTag: snapshot.data!.primaryImageTag,
                          itemId: snapshot.data!.id,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: ListView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final songInfo = albumInfos.songs![index];
                  return ListTile(
                    leading: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.0),
                        child:
                            Provider.of<JellyfinAPI>(context).imageIfTagExists(
                          primaryImageTag: songInfo.primaryImageTag,
                          itemId: songInfo.id,
                        ),
                      ),
                    ),
                    title: Text(
                      songInfo.title,
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: songInfo.artists != null
                        ? Text(
                            songInfo.artists!.join(', '),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () {
                      Provider.of<AudioPlayerService>(context, listen: false)
                          .playList(
                        [
                          AudioMetadata(
                            id: songInfo.id,
                            albumId: albumInfos.id,
                            title: songInfo.title,
                            primaryImageTag: songInfo.primaryImageTag,
                            artists: songInfo.artists,
                          )
                        ],
                        context,
                      );
                    },
                  );
                },
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('${snapshot.error}'),
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
