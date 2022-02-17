import 'package:flutter/material.dart';

import 'package:jellyamp/screens/albums/albums_list.dart';
import 'package:jellyamp/screens/albums/album_item.dart';
import 'package:provider/provider.dart';

class Albums extends StatelessWidget {
  const Albums({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/albums': (context) => const AlbumsPage(),
        '/albums/item': (context) => const AlbumItem(),
      },
      initialRoute: '/albums',
      theme: ThemeData.from(colorScheme: Provider.of<ColorScheme>(context)),
    );
  }
}

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AlbumsList();
  }
}
