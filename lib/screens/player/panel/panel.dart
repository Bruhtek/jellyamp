import 'package:flutter/material.dart';

import 'package:jellyamp/audio/audio_player_service.dart';
import 'package:jellyamp/screens/player/panel/panel_main.dart';
import 'package:jellyamp/screens/player/panel/panel_buttons.dart';

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

    return PlayerButtons(context);
  }
}
