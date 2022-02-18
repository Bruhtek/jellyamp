import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:just_audio_background/just_audio_background.dart';

//theming
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:jellyamp/classes/colorscheme.dart';

// jellyamp packages
import 'package:jellyamp/screens/root.dart';
import 'package:jellyamp/audio/just_audio_player.dart';
import 'package:jellyamp/audio/audio_player_service.dart';
import 'package:jellyamp/api/jellyfin.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.bruhtek.jellyamp.channel.audio',
    androidNotificationChannelName: 'Jellyamp Playback',
    androidNotificationOngoing: false,
    androidResumeOnClick: true,
    androidNotificationClickStartsActivity: true,
    preloadArtwork: true,
  );

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
        Provider<JellyfinAPI>(
          create: (_) => JellyfinAPI(),
        ),
      ],
      child: DynamicColorBuilder(
        builder: (CorePalette? corePalette) {
          ColorScheme scheme;

          if (corePalette != null) {
            scheme = ColorSchemeGenerator.generate(corePalette, true);
          } else {
            scheme = const ColorScheme.dark();
          }
          return Provider<ColorScheme>(
            create: (_) => scheme,
            child: MaterialApp(
              title: 'Jellyamp',
              home: const Root(),
              darkTheme: ThemeData.from(
                colorScheme: scheme,
              ),
              themeMode: ThemeMode.dark,
            ),
          );
        },
      ),
    );
  }
}
