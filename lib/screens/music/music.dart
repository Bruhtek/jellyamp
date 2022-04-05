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
  int displayMode = 0;

  void showSelectorModalSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          void setDisplayMode(int index) {
            setState(() {
              displayMode = index;
            });
            setModalState(() {
              displayMode = index;
            });
          }

          return Wrap(
            children: [
              const ListTile(title: Text("Display mode")),
              ListTile(
                leading: displayMode == 0
                    ? const Icon(Icons.radio_button_on_rounded)
                    : const Icon(Icons.radio_button_off_rounded),
                selected: displayMode == 0,
                title: const Text("Compact grid"),
                onTap: () => setDisplayMode(0),
              ),
              ListTile(
                leading: displayMode == 1
                    ? const Icon(Icons.radio_button_on_rounded)
                    : const Icon(Icons.radio_button_off_rounded),
                selected: displayMode == 1,
                title: const Text("Comfortable grid"),
                onTap: () => setDisplayMode(1),
              ),
            ],
          );
        });
      },
    );
  }

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
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          onPressed: () => showSelectorModalSheet(),
        ),
      ],
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
              AlbumsScreen(toggleSelecting, displayMode),
              ArtistsScreen(toggleSelecting),
              SongsScreen(toggleSelecting),
            ],
          ),
        ));
  }
}
