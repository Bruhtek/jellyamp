import 'package:flutter/material.dart';
import 'package:jellyamp/api/images.dart';
import 'package:provider/provider.dart';

import 'package:jellyamp/api/albums.dart';
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

    futureAlbumInfo = Provider.of<Albums>(context, listen: false)
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
                        child: imageIfTagExists(
                          primaryImageTag: snapshot.data!.primaryImageTag,
                          itemId: snapshot.data!.id,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: ListView.separated(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final songInfo = albumInfos.songs![index];
                  return ListTile(
                    leading: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.0),
                        child: imageIfTagExists(
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
                  );
                },
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.black54),
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
