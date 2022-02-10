import 'package:flutter/material.dart';

import 'package:jellyamp/audio/audio_player_service.dart';
import 'package:jellyamp/screens/panel/player/player_main.dart';
import 'package:jellyamp/screens/panel/player/player_buttons.dart';

import 'package:provider/provider.dart';

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService =
        Provider.of<AudioPlayerService>(context);

    return Column(
      children: [
        Expanded(
          child: PageView(
            scrollDirection: Axis.horizontal,
            children: [
              const PlayerMain(),
              Container(margin: const EdgeInsets.all(8.0), color: Colors.blue),
            ],
            controller: PageController(
              initialPage: 0,
              viewportFraction: 0.9,
              keepPage: false,
            ),
          ),
        ),
        const PlayerButtons(),
      ],
    );
  }
}
