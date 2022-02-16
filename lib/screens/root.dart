import 'package:flutter/material.dart';
import 'package:jellyamp/api/jellyfin.dart';
import 'package:jellyamp/screens/panel/player/player.dart';

import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:jellyamp/screens/albums/albums.dart';
import 'package:jellyamp/screens/settings/settings.dart';
import 'package:jellyamp/screens/home/home.dart';
import 'package:jellyamp/screens/panel/collapsed.dart';
import 'package:jellyamp/screens/setup/setup.dart';

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  bool allInfoFilled = false;

  void updateFilledInfo() {
    setState(() {
      //Provider.of<JellyfinAPI>(context, listen: false).allInfoFilled
      allInfoFilled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Hive.initFlutter(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder<Box>(
            future: Hive.openBox("env"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final jellyfinAPI =
                    Provider.of<JellyfinAPI>(context, listen: false);

                jellyfinAPI.setJellyfinUrl(
                    snapshot.data!.get("jellyfinUrl", defaultValue: ""));
                jellyfinAPI
                    .setUserId(snapshot.data!.get("userId", defaultValue: ""));
                jellyfinAPI.setToken(
                    snapshot.data!.get("mediaBrowserToken", defaultValue: ""));

                allInfoFilled = jellyfinAPI.allInfoFilled;

                if (allInfoFilled) {
                  return const MainScreen();
                }

                return SetupScreen(updateFilledInfo);
              } else {
                return Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Center(
                        child: Text("Loading..."),
                      ),
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ],
                  ),
                );
              }
            },
          );
        } else {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Center(
                  child: Text("Loading..."),
                ),
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          );
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  final homeWidget = const Home();
  final albumsWidget = const Albums();
  final settingWidget = const Settings();

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    final panelController = Provider.of<PanelController>(context);
    return Scaffold(
      body: SlidingUpPanel(
        controller: panelController,
        panel: const Player(),
        collapsed: const MiniPlayer(),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          children: [
            widget.homeWidget,
            widget.albumsWidget,
            widget.settingWidget,
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  NavigationBar bottomNavigationBar() {
    return NavigationBar(
      selectedIndex: currentIndex,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: (index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.album_outlined),
          selectedIcon: Icon(Icons.album_rounded),
          label: 'Albums',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}
