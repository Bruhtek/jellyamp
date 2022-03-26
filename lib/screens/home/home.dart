import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../api/jellyfin.dart';
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

  Widget stylishHomeText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24.0,
        ),
      ),
    );
  }

  Widget placeHolderContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 100,
            ),
            stylishHomeText('Placeholder'),
          ],
        ),
      ),
    );
  }
  Widget rediscoverAlbums(BuildContext context, WidgetRef ref, int count) {
    List<Album> albums = ref.read(jellyfinAPIProvider).getRecommendedAlbums();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: Colors.black12,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            stylishHomeText("Rediscover Albums"),
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
                      albumCover(album, ref),
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
      ),
    );
  }
  Widget rediscoverArtists(BuildContext context, WidgetRef ref, int count) {
    List<Artist> artists = ref.read(jellyfinAPIProvider).getRecommendedArtists();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: Colors.black12,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            stylishHomeText("Rediscover Artists"),
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

                    return gridItem(context, artistCover(artist, ref), artist.name, null);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget rediscoverSongs(BuildContext context, WidgetRef ref, int count) {
    List<Song> songs = ref.read(jellyfinAPIProvider).getRecommendedSongs();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: Colors.black12,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            stylishHomeText("Rediscover Songs"),
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

                    return gridItem(
                        context, songCover(song, ref), song.title, song.artistNames.join(', '));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> homeWidgets = [];

    homeWidgets.add(placeHolderContainer());
    homeWidgets.add(rediscoverAlbums(context, ref, 20));
    homeWidgets.add(rediscoverArtists(context, ref, 20));
    homeWidgets.add(rediscoverSongs(context, ref, 20));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Jellyamp"),
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
