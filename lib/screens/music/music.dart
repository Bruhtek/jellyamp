import 'package:flutter/material.dart';

import 'albums.dart';
import 'artists.dart';
import 'songs.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  bool _isSelecting = false;

  void toggleSelecting() {
    setState(() {
      _isSelecting = !_isSelecting;
    });
  }

  @override
  Widget build(BuildContext context) {
    TabBar tabBar = TabBar(
      isScrollable: false,
      tabs: [
        Tab(
            child: Row(children: const [
          Icon(Icons.album_rounded),
          SizedBox(width: 8),
          Text("Albums"),
        ])),
        Tab(
            child: Row(children: const [
          Icon(Icons.person_rounded),
          SizedBox(width: 8),
          Text("Artists"),
        ])),
        Tab(
            child: Row(children: const [
          Icon(Icons.music_note_rounded),
          SizedBox(width: 8),
          Text("Songs"),
        ])),
      ],
    );

    AppBar appBarDefault = AppBar(
      title: const Text("Music Library"),
      bottom: tabBar,
    );

    AppBar appBarSelecting = AppBar(
      title: const Text("\$ selected"),
      bottom: tabBar,
    );

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: _isSelecting ? appBarSelecting : appBarDefault,
          body: TabBarView(
            children: [
              AlbumsScreen(toggleSelecting),
              ArtistsScreen(toggleSelecting),
              SongsScreen(toggleSelecting),
            ],
          ),
        ));
  }
}
