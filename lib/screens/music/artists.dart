import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jellyamp/utilities/preferences.dart';

import '../../main.dart';
import '../../utilities/grid.dart';

int crossAxisCount = 2;

// ignore: must_be_immutable
class ArtistsScreen extends ConsumerWidget {
  ArtistsScreen(this.toggleSelecting, this.displayMode, {Key? key}) : super(key: key);

  Function toggleSelecting;
  int displayMode;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(jellyfinAPIProvider.select((value) => value.getArtists()));

    return Scrollbar(
      controller: scrollController,
      isAlwaysShown: true,
      interactive: true,
      child: AlignedGridView.count(
        addAutomaticKeepAlives: false,
        controller: scrollController,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final artist = artists[index];

          switch (displayMode) {
            case 0: // compact
              return gridItem(
                context,
                artistCover(artist, ref),
                artist.name,
                null,
              );
            case 1:
              bool oval =
                  PreferencesStorage.getPreference("appearance", "useOvalArtistImages") == "true";
              return comfortableGridItem(
                context,
                artistCover(artist, ref, oval: oval, rounded: !oval),
                artist.name,
                null,
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
