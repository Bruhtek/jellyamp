import 'package:flutter/material.dart';
import 'package:jellyamp/screens/player/panel/panel.dart';

import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:jellyamp/screens/albums/albums.dart';
import 'package:jellyamp/screens/settings/settings.dart';
import 'package:jellyamp/screens/home/home.dart';

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  Widget build(BuildContext context) {
    return const MainScreen();
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
  PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Consumer<PanelController>(
      builder: (_, panelController, __) {
        return Scaffold(
          body: SlidingUpPanel(
            controller: panelController,
            panel: const Player(),
            collapsed: InkWell(
              onTap: () {
                panelController.open();
              },
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Collapsed"),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("Button"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
      },
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
