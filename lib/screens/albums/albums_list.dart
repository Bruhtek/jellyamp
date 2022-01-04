import 'package:flutter/material.dart';
import 'package:jellyamp/api/images.dart';
import 'package:provider/provider.dart';

import 'package:jellyamp/api/albums.dart';
import 'package:jellyamp/classes/viewtype.dart';
import 'package:jellyamp/classes/audio.dart';

class AlbumsList extends StatefulWidget {
  final Viewtype viewport;
  const AlbumsList(this.viewport, {Key? key}) : super(key: key);

  @override
  _AlbumsListState createState() => _AlbumsListState();
}

class _AlbumsListState extends State<AlbumsList> {
  late Future<List<AlbumInfo>> albumInfos;

  @override
  void initState() {
    albumInfos =
        Provider.of<Albums>(context, listen: false).fetchAlbumsSorted();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlbumInfo>>(
      future: albumInfos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          switch (widget.viewport) {
            case Viewtype.list:
              return _buildAlbumList(context, snapshot.data!);
            case Viewtype.grid:
              return _buildAlbumGrid(context, snapshot.data!);
            default:
              return const Text("Error! Bad Viewtype Specified!");
          }
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red));
        }

        return const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

Widget _buildAlbumList(BuildContext context, List<AlbumInfo> albumInfos) {
  return ListView.separated(
    itemCount: albumInfos.length,
    itemBuilder: (context, index) {
      final albumInfo = albumInfos[index];
      return ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/albums/item',
            arguments: AlbumArguments(
              albumInfo.id,
              albumInfo.title,
            ),
          );
        },
        leading: AspectRatio(
          aspectRatio: 1 / 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: imageIfTagExists(
              primaryImageTag: albumInfo.primaryImageTag,
              itemId: albumInfo.id,
            ),
          ),
        ),
        title: Text(
          albumInfo.title,
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: albumInfo.artists != null
            ? Text(
                albumInfo.artists!.join(', '),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      );
    },
    separatorBuilder: (context, index) => const Divider(color: Colors.black54),
  );
}

Widget _buildAlbumGrid(BuildContext context, List<AlbumInfo> albumInfos) {
  return GridView.builder(
    padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 200),
    shrinkWrap: true,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      //mainAxisExtent: 130,
    ),
    itemCount: albumInfos.length,
    itemBuilder: (context, index) {
      final albumInfo = albumInfos[index];
      return InkResponse(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/albums/item',
            arguments: AlbumArguments(
              albumInfo.id,
              albumInfo.title,
            ),
          );
        },
        child: GridTile(
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AspectRatio(
                    aspectRatio: 1 / 1,
                    child: imageIfTagExists(
                      primaryImageTag: albumInfo.primaryImageTag,
                      itemId: albumInfo.id,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          albumInfo.title,
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Center(
                          child: albumInfo.artists != null
                              ? Text(albumInfo.artists!.join(', '),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10,
                                  ))
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
