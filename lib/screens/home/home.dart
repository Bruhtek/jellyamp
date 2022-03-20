import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../api/jellyfin.dart';
import '../../utilities/grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Text stylishHomeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget rediscoverAlbums(BuildContext context, WidgetRef ref, int count) {
    List<Album> albums = ref.read(jellyfinAPIProvider).getRandomAlbums(count: count);

    return Column(
      children: [
        stylishHomeText("Rediscover Albums"),
        SizedBox(
          height: 120.0,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            separatorBuilder: ((context, index) => Container(width: 4.0)),
            scrollDirection: Axis.horizontal,
            itemCount: count,
            itemBuilder: (context, index) {
              final Album album = albums[index];

              return gridItem(
                  context, albumCover(album, ref), album.title, album.artistNames.join(', '));
            },
          ),
        )
      ],
    );
  }
  Widget rediscoverArtists(BuildContext context, WidgetRef ref, int count) {
    List<Artist> artists = ref.read(jellyfinAPIProvider).getRandomArtists(count: count);

    return Column(
      children: [
        stylishHomeText("Rediscover Artists"),
        SizedBox(
          height: 120.0,
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
        )
      ],
    );
  }
  Widget rediscoverSongs(BuildContext context, WidgetRef ref, int count) {
    List<Song> songs = ref.read(jellyfinAPIProvider).getRandomSongs(count: count);

    return Column(
      children: [
        stylishHomeText("Rediscover Songs"),
        SizedBox(
          height: 120.0,
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
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> homeWidgets = [];

    homeWidgets.add(rediscoverAlbums(context, ref, 20));
    homeWidgets.add(rediscoverArtists(context, ref, 20));
    homeWidgets.add(rediscoverSongs(context, ref, 20));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Jellyamp"),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16.0),
        // child: ListView(
        //   children: homeWidgets,
        // ),
        child: ListView(
          children: homeWidgets,
        ),
      ),
    );
  }
}
