import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyamp/screens/player/floating_player.dart';
import 'package:jellyamp/screens/setup/setup.dart';
import '../main.dart';

import 'home/home.dart';
import 'music/music.dart';
import 'settings/settings.dart';
import 'debug/debug.dart';

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
    final loggedIn =
        ref.watch(jellyfinAPIProvider.select((value) => value.loggedIn));
    final initialized =
        ref.watch(jellyfinAPIProvider.select((value) => value.initialized));

    if (!initialized) {
      return const MaterialApp(
          home: Scaffold(
              body: Center(
        child: CircularProgressIndicator(),
      )));
    }

    if (!loggedIn) {
      return const SetupScreen();
    }

    return MaterialApp(
      home: Scaffold(
        //pages[index],
        body: pages[index],
        bottomNavigationBar: _navigationBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
            const Align(child: FloatingPlayer(), alignment: Alignment(1, 1.05)),
      ),
    );
  }

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