import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../main.dart';
import '../../utilities/grid.dart';
import '../../utilities/providers/settings.dart';

int crossAxisCount = 2;

// ignore: must_be_immutable
class ArtistsScreen extends ConsumerWidget {
  ArtistsScreen(this.toggleSelecting, {Key? key}) : super(key: key);

  Function toggleSelecting;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayMode = ref.watch(settingsProvider.select((value) => value.displayMode));
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
            case DisplayMode.grid: // compact
              return gridItem(
                context,
                artistCover(artist, ref, context),
                artist.name,
                null,
                onClick: () => Navigator.pushNamed(context, '/artistInfo', arguments: artist),
              );
            case DisplayMode.comfortableGrid:
              bool oval = ref.watch(settingsProvider.select((value) => value.useOvalArtistImages));
              return comfortableGridItem(
                context,
                artistCover(artist, ref, context, oval: oval, rounded: !oval),
                artist.name,
                null,
                onClick: () => Navigator.pushNamed(context, '/artistInfo', arguments: artist),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
