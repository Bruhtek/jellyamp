import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../main.dart';

import 'home/home.dart';
import 'music/music.dart';
import 'settings/settings.dart';
import 'settings/appearance.dart';
import 'debug/debug.dart';
import 'music/subscreens/album_info.dart';
import 'music/subscreens/artist_info.dart';
import 'setup/setup.dart';
import 'player/sliding_panel.dart';

import '../themes/colorscheme.dart';
import '../themes/themes.dart';

const bool debug = false;

class IndexScreen extends ConsumerStatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IndexScreenState();
}

class _IndexScreenState extends ConsumerState<IndexScreen> {
  int index = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const MusicScreen(),
    const SettingsScreen(),
    const DebugScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (CorePalette? corePalette) {
        ColorScheme scheme;

        if (corePalette != null) {
          scheme = ColorSchemeGenerator.generate(corePalette, true);
        } else {
          scheme = const ColorScheme.dark();
        }

        final loggedIn = ref.watch(jellyfinAPIProvider.select((value) => value.loggedIn));
        final initialized = ref.watch(jellyfinAPIProvider.select((value) => value.initialized));

        final theme = Themes.createTheme(context, colorScheme: scheme);

        if (!initialized) {
          return MaterialApp(
            scrollBehavior: const ScrollBehavior(
                androidOverscrollIndicator: AndroidOverscrollIndicator.stretch),
            theme: theme,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (!loggedIn) {
          return SetupScreen(theme);
        }

        return MaterialApp(
          scrollBehavior:
              const ScrollBehavior(androidOverscrollIndicator: AndroidOverscrollIndicator.stretch),
          theme: theme,
          title: 'Jellyamp',
          home: indexRoute(),
          routes: {
            '/albumInfo': (context) => const AlbumInfo(),
            '/artistInfo': (context) => const ArtistInfo(),
            '/settings/appearance': (context) => const AppearanceSettings(),
          },
        );
      },
    );
  }

  Widget indexRoute() => Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[pages[index], const SlidingPanel()],
        ),
        bottomNavigationBar: _navigationBar(),
      );

  NavigationBar _navigationBar() {
    List<NavigationDestination> dest = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.album_outlined),
        selectedIcon: Icon(Icons.album_rounded),
        label: 'Music',
      ),
      const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings_rounded),
        label: 'Settings',
      ),
    ];

    if (debug) {
      dest.add(const NavigationDestination(
        icon: Icon(Icons.bug_report_outlined),
        selectedIcon: Icon(Icons.bug_report_rounded),
        label: 'Debug',
      ));
    }

    return NavigationBar(
      selectedIndex: index,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) {
        setState(() {
          this.index = index;
        });
      },
      destinations: dest,
    );
  }
}
