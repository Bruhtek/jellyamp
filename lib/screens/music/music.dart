import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyamp/utilities/preferences.dart';

import 'albums.dart';
import 'artists.dart';
import 'songs.dart';

import 'modals.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  bool _isSelecting = false;

  void showSelectorModalSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SelectorModalSheet(),
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
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: Theme.of(context).colorScheme.primary,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
      tabs: [
        Tab(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.album_rounded),
            SizedBox(width: 8),
            Text("Albums"),
          ],
        )),
        Tab(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_rounded),
            SizedBox(width: 8),
            Text("Artists"),
          ],
        )),
        Tab(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.music_note_rounded),
            SizedBox(width: 8),
            Text("Songs"),
          ],
        )),
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
              AlbumsScreen(toggleSelecting),
              ArtistsScreen(toggleSelecting),
              SongsScreen(toggleSelecting),
            ],
          ),
        ));
  }
}
