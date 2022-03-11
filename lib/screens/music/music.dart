import 'package:flutter/material.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabBar tabBar = TabBar(
      isScrollable: true,
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

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Music Library"),
            bottom: tabBar,
          ),
          body: const TabBarView(
            children: [
              Center(child: Text('Albums')),
              Center(child: Text('Artists')),
              Center(child: Text('Songs')),
            ],
          ),
        ));
  }
}
