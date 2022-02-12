import 'package:flutter/material.dart';

import 'package:jellyamp/screens/panel/player/player_main.dart';
import 'package:jellyamp/screens/panel/player/player_buttons.dart';
import 'package:jellyamp/screens/panel/player/queue.dart';


class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            scrollDirection: Axis.horizontal,
            children: const [
              PlayerMain(),
              Queue(),
            ],
            controller: PageController(
              initialPage: 0,
              viewportFraction: 0.8,
              keepPage: false,
            ),
          ),
        ),
        const PlayerButtons(),
      ],
    );
  }
}
