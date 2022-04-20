import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../providers/jellyfin.dart';
import '../../utilities/grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Shader fadeInOut(Rect rect) {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.purple,
        Colors.black38,
        Colors.transparent,
        Colors.transparent,
        Colors.black38,
        Colors.purple,
      ],
      stops: [
        0.0,
        0.02,
        0.03,
        0.97,
        0.98,
        1.0,
      ],
    ).createShader(rect);
  }

  Widget stylishHomeText(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6!.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
      ),
    );
  }

  Widget placeHolderContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 100,
          ),
          stylishHomeText(context, 'Placeholder'),
        ],
      ),
    );
  }
  Widget rediscoverAlbums(BuildContext context, WidgetRef ref, int count) {
    List<Album> albums = ref.read(jellyfinAPIProvider).getRecommendedAlbums();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4.0),
          stylishHomeText(context, "Rediscover Albums"),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 120.0,
            child: ShaderMask(
              shaderCallback: (Rect rect) => fadeInOut(rect),
              blendMode: BlendMode.dstOut,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                separatorBuilder: ((context, index) => Container(width: 4.0)),
                scrollDirection: Axis.horizontal,
                itemCount: count,
                itemBuilder: (context, index) {
                  final Album album = albums[index];

                  return gridItem(
                    context,
                    albumCover(album, ref, context),
                    album.title,
                    album.artistNames.join(', '),
                    onClick: () => Navigator.pushNamed(context, '/albumInfo', arguments: album),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget rediscoverArtists(BuildContext context, WidgetRef ref, int count) {
    List<Artist> artists = ref.read(jellyfinAPIProvider).getRecommendedArtists();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4.0),
          stylishHomeText(context, "Rediscover Artists"),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 120.0,
            child: ShaderMask(
              shaderCallback: (Rect rect) => fadeInOut(rect),
              blendMode: BlendMode.dstOut,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                separatorBuilder: ((context, index) => Container(width: 4.0)),
                scrollDirection: Axis.horizontal,
                itemCount: count,
                itemBuilder: (context, index) {
                  final Artist artist = artists[index];

                  return gridItem(
                    context,
                    artistCover(artist, ref, context),
                    artist.name,
                    null,
                    onClick: () => Navigator.pushNamed(context, '/artistInfo', arguments: artist),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget rediscoverSongs(BuildContext context, WidgetRef ref, int count) {
    List<Song> songs = ref.read(jellyfinAPIProvider).getRecommendedSongs();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4.0),
          stylishHomeText(context, "Rediscover Songs"),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 120.0,
            child: ShaderMask(
              shaderCallback: (Rect rect) => fadeInOut(rect),
              blendMode: BlendMode.dstOut,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                separatorBuilder: ((context, index) => Container(width: 4.0)),
                scrollDirection: Axis.horizontal,
                itemCount: count,
                itemBuilder: (context, index) {
                  final Song song = songs[index];

                  return gridItem(context, songCover(song, ref, context), song.title,
                      song.artistNames.join(', '));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> homeWidgets = [];

    homeWidgets.add(placeHolderContainer(context));
    homeWidgets.add(rediscoverAlbums(context, ref, 20));
    homeWidgets.add(rediscoverArtists(context, ref, 20));
    homeWidgets.add(rediscoverSongs(context, ref, 20));

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Jellyamp",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.9,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            )),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        itemCount: homeWidgets.length,
        itemBuilder: ((context, index) => homeWidgets[index]),
        separatorBuilder: ((context, index) => Container(height: 16.0)),
      ),
    );
  }
}
