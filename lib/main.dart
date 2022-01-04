import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jellyamp/classes/prefs.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// jellyamp packages
import 'package:jellyamp/screens/root.dart';
import 'package:jellyamp/api/albums.dart';
import 'package:jellyamp/audio/just_audio_player.dart';
import 'package:jellyamp/audio/audio_player_service.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PanelController>(
          create: (_) => PanelController(),
        ),
        Provider<AudioPlayerService>(
          create: (_) => JustAudioPlayer(),
          dispose: (_, value) => (value as JustAudioPlayer).dispose(),
        ),
        Provider<Albums>(
          create: (_) => Albums(),
        ),
        Provider<EssentialInfo>(
          create: (_) => EssentialInfo('', '', '', ''),
        ),
      ],
      child: const MaterialApp(
        title: 'Jellyamp',
        home: Root(),
      ),
    );
  }
}
