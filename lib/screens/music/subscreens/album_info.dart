import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyamp/main.dart';

import '../modals.dart';
import '../../../api/jellyfin.dart';
import '../../../utilities/grid.dart';
import '../../../utilities/text_height.dart';
import '../../../utilities/preferences.dart';

class AlbumInfo extends ConsumerStatefulWidget {
  const AlbumInfo({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlbumInfoState();
}

class _AlbumInfoState extends ConsumerState<AlbumInfo> {
  late Album album;
  int displayMode = 0;

  void setDisplayMode(int index) {
    setState(() {
      PreferencesStorage.setPreference("display", "displayMode", index.toString());
      displayMode = index;
    });
  }

  Widget albumCoverWidget(WidgetRef ref, BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: albumCover(album, ref, context),
      ),
    );
  }

  Widget flexibleBackground(WidgetRef ref, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: 16.0,
        left: 16.0,
        top: MediaQuery.of(context).padding.top,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          albumCoverWidget(ref, context),
          const SizedBox(height: 8.0),
          Text(
            album.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            album.artistNames.join(', '),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget body(WidgetRef ref, BuildContext context) {
    final titleHeight = album.title.textHeight(
      TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
      MediaQuery.of(context).size.width - 32,
    );
    final artistsHeight = album.artistNames.join(', ').textHeight(
          TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          MediaQuery.of(context).size.width - 32,
        );

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width -
                32 +
                8 +
                titleHeight +
                artistsHeight +
                MediaQuery.of(context).padding.top,
            pinned: true,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => SelectorModalSheet(),
                ),
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                bool collapsed = constraints.biggest.height ==
                    MediaQuery.of(context).padding.top + kToolbarHeight;

                return FlexibleSpaceBar(
                  title: AnimatedOpacity(
                    opacity: collapsed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 100),
                    child: Text(album.title),
                  ),
                  background: flexibleBackground(ref, context),
                );
              },
            ),
          ),
        ];
      },
      body: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: album.songIds.length,
        itemBuilder: (context, index) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    displayMode = int.tryParse(PreferencesStorage.getPreference("display", "displayMode")) ?? 1;
    album = ModalRoute.of(context)!.settings.arguments as Album;

    return Scaffold(
      body: body(ref, context),
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
