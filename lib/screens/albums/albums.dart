import 'package:flutter/material.dart';

import 'package:jellyamp/screens/albums/albums_list.dart';
import 'package:jellyamp/screens/albums/album_item.dart';
import 'package:jellyamp/classes/viewtype.dart';

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
    );
  }
}

Viewtype _viewtype = Viewtype.grid;

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({Key? key}) : super(key: key);

  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  Widget popupViewtype() {
    const List<Icon> iconsViewtype = [
      Icon(Icons.view_list_rounded),
      Icon(Icons.grid_view_rounded),
    ];

    return PopupMenuButton<Viewtype>(
      onSelected: (Viewtype result) {
        setState(() {
          _viewtype = result;
        });
      },
      icon: iconsViewtype[_viewtype.toInt()],
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Viewtype>(
          value: Viewtype.list,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconsViewtype[Viewtype.list.toInt()],
              const Text('List'),
            ],
          ),
        ),
        PopupMenuItem<Viewtype>(
          value: Viewtype.grid,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconsViewtype[Viewtype.grid.toInt()],
              const Text('Grid'),
            ],
          ),
        ),
      ],
    );
  }

  //TODO: make a popup menu for the sort type, like the popupViewtype one
  Widget popupSort() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Albums'),
        actions: [
          popupViewtype(),
        ],
      ),
      body: AlbumsList(_viewtype),
    );
  }
}
