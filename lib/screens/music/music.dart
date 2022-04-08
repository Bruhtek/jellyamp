import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyamp/utilities/preferences.dart';

import 'albums.dart';
import 'artists.dart';
import 'songs.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  bool _isSelecting = false;
  int displayMode = 0;

  void showSelectorModalSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          void setDisplayMode(int index) {
            setState(() {
              PreferencesStorage.setPreference("display", "displayMode", index.toString());
              displayMode = index;
            });
            setModalState(() {
              displayMode = index;
            });
          }

          return Wrap(
            children: [
              ListTile(
                minLeadingWidth: 0,
                visualDensity: VisualDensity.compact,
                title: Text(
                  "Display mode",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                minLeadingWidth: 0,
                visualDensity: VisualDensity.compact,
                leading: displayMode == 0
                    ? const Icon(Icons.radio_button_on_rounded)
                    : const Icon(Icons.radio_button_off_rounded),
                selected: displayMode == 0,
                title: Text("Compact grid",
                    style: TextStyle(
                      color: displayMode == 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    )),
                onTap: () => setDisplayMode(0),
              ),
              ListTile(
                minLeadingWidth: 0,
                visualDensity: VisualDensity.compact,
                leading: displayMode == 1
                    ? const Icon(Icons.radio_button_on_rounded)
                    : const Icon(Icons.radio_button_off_rounded),
                selected: displayMode == 1,
                title: Text("Comfortable grid",
                    style: TextStyle(
                      color: displayMode == 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    )),
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
    displayMode = int.tryParse(PreferencesStorage.getPreference("display", "displayMode")) ?? 1;

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
              AlbumsScreen(toggleSelecting, displayMode),
              ArtistsScreen(toggleSelecting, displayMode),
              SongsScreen(toggleSelecting, displayMode),
            ],
          ),
        ));
  }
}
