import 'package:flutter/material.dart';
import 'package:jellyamp/api/jellyfin.dart';
import 'package:jellyamp/audio/audio_player_service.dart';
import 'package:provider/provider.dart';

import 'package:jellyamp/classes/viewtype.dart';
import 'package:jellyamp/classes/audio.dart';

class AlbumsList extends StatefulWidget {
  const AlbumsList({Key? key}) : super(key: key);

  @override
  _AlbumsListState createState() => _AlbumsListState();
}

class _AlbumsListState extends State<AlbumsList> {
  late Future<List<AlbumInfo>> albumInfos;

  Viewtype _viewtype = Viewtype.grid;
  // list of selected albums, to be dynamically updated when the user selects an album
  List<String> selectedAlbums = [];

  @override
  void initState() {
    albumInfos =
        Provider.of<JellyfinAPI>(context, listen: false).fetchAlbumsSorted();
    super.initState();
  }

  Widget popupViewtype() {
    const List<Icon> iconsViewtype = [
      Icon(Icons.view_list_rounded),
      Icon(Icons.grid_view_rounded),
    ];

    return PopupMenuButton<Viewtype>(
      onSelected: (Viewtype result) {
        setState(() {
          _viewtype = result;
        });
      },
      icon: iconsViewtype[_viewtype.toInt()],
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Viewtype>(
          value: Viewtype.list,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconsViewtype[Viewtype.list.toInt()],
              const Text('List'),
            ],
          ),
        ),
        PopupMenuItem<Viewtype>(
          value: Viewtype.grid,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconsViewtype[Viewtype.grid.toInt()],
              const Text('Grid'),
            ],
          ),
        ),
      ],
    );
  }

  //TODO: make a popup menu for the sort type, like the popupViewtype one
  Widget popupSort() {
    return Container();
  }

  AppBar _appBar() {
    if (selectedAlbums.isEmpty) {
      return AppBar(
        title: const Text('Albums'),
        actions: [
          popupViewtype(),
        ],
      );
    }

    return AppBar(
      title: Text('${selectedAlbums.length} selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.play_arrow_rounded),
          tooltip: 'Play selected albums',
          onPressed: () {
            Map<String, AlbumInfo> albums =
                Provider.of<JellyfinAPI>(context, listen: false)
                    .detailedAlbumInfos!;

            List<AudioMetadata> songsList = [];

            for (String index in selectedAlbums) {
              print(index);
              for (SongInfo song in albums[index]!.songs) {
                songsList.add(AudioMetadata(
                  id: song.id,
                  albumId: song.albumId,
                  title: song.title,
                  artists: song.artists,
                  primaryImageTag: song.primaryImageTag,
                ));
              }
            }

            Provider.of<AudioPlayerService>(context, listen: false)
                .playList(songsList, context);
            setState(() {
              selectedAlbums.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _hasError(dynamic error) {
    return Text("Error: $error", style: const TextStyle(color: Colors.red));
  }

  Widget _loading() {
    return const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: FutureBuilder<List<AlbumInfo>>(
        future: albumInfos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (_viewtype) {
              case Viewtype.list:
                return _buildAlbumList(context, snapshot.data!);
              case Viewtype.grid:
                return _buildAlbumGrid(context, snapshot.data!);
              default:
                return const Text("Error! Bad Viewtype Specified!");
            }
          } else if (snapshot.hasError) {
            return _hasError(snapshot.error);
          }

          return _loading();
        },
      ),
    );
  }

  Widget _buildAlbumList(BuildContext context, List<AlbumInfo> albumInfos) {
    return ListView.builder(
      itemCount: albumInfos.length,
      itemBuilder: (context, index) {
        final albumInfo = albumInfos[index];
        return ListTile(
          onTap: () {
            setState(() {
              selectedAlbums.clear();
            });
            Navigator.pushNamed(
              context,
              '/albums/item',
              arguments: AlbumArguments(
                albumInfo.id,
                albumInfo.title,
              ),
            );
          },
          onLongPress: () {
            setState(() {
              if (selectedAlbums.contains(albumInfo.id)) {
                selectedAlbums.remove(albumInfo.id);
              } else {
                selectedAlbums.add(albumInfo.id);
              }
            });
          },
          leading: AspectRatio(
            aspectRatio: 1 / 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: Provider.of<JellyfinAPI>(context).imageIfTagExists(
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
          trailing: selectedAlbums.contains(albumInfo.id)
              ? const Icon(Icons.check_circle_rounded)
              : null,
        );
      },
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
            setState(() {
              selectedAlbums.clear();
            });
            Navigator.pushNamed(
              context,
              '/albums/item',
              arguments: AlbumArguments(
                albumInfo.id,
                albumInfo.title,
              ),
            );
          },
          onLongPress: () {
            setState(() {
              if (selectedAlbums.contains(albumInfo.id)) {
                selectedAlbums.remove(albumInfo.id);
              } else {
                selectedAlbums.add(albumInfo.id);
              }
            });
          },
          child: GridTile(
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: _albumsGridStackBuilder(context, albumInfo, index),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _albumsGridStackBuilder(
      BuildContext context, AlbumInfo albumInfo, int index) {
    List<Widget> results = [
      AspectRatio(
        aspectRatio: 1 / 1,
        child: Provider.of<JellyfinAPI>(context).imageIfTagExists(
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
    ];

    if (selectedAlbums.contains(albumInfo.id)) {
      results.add(
        Positioned(
          top: 0,
          right: 0,
          width: 32,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  color: Colors.black87,
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: Colors.white),
            ],
          ),
        ),
      );
    }

    return results;
  }
}
