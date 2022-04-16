import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modals.dart';
import '../albums.dart';
import '../../../api/jellyfin.dart';
import '../../../utilities/grid.dart';
import '../../../utilities/text_height.dart';
import '../../../utilities/preferences.dart';

class ArtistInfo extends ConsumerStatefulWidget {
  const ArtistInfo({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ArtistInfoState();
}

class _ArtistInfoState extends ConsumerState<ArtistInfo> {
  late Artist artist;
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
        child: artistCover(artist, ref, context, oval: true),
      ),
    );
  }

  Widget flexibleBackground(WidgetRef ref, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: 16.0,
        left: 16.0,
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          albumCoverWidget(ref, context),
          const SizedBox(height: 8.0),
          Text(
            artist.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget body(WidgetRef ref, BuildContext context) {
    displayMode = int.tryParse(PreferencesStorage.getPreference("display", "displayMode")) ?? 1;

    final nameHeight = artist.name.textHeight(
      TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
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
                nameHeight +
                MediaQuery.of(context).padding.top +
                kToolbarHeight,
            pinned: true,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => SelectorModalSheet(setDisplayMode),
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
                    child: Text(artist.name),
                  ),
                  background: flexibleBackground(ref, context),
                );
              },
            ),
          ),
        ];
      },
      body: AlbumsScreen(
        () {},
        displayMode,
        albumIds: artist.albumIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    artist = ModalRoute.of(context)!.settings.arguments as Artist;

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
