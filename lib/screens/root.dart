import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:jellyamp/classes/prefs.dart';
import 'package:jellyamp/screens/albums/albums.dart';
import 'package:jellyamp/screens/settings/settings.dart';
import 'package:jellyamp/screens/home/home.dart';
import 'package:jellyamp/screens/setup/main.dart';
import 'package:jellyamp/preferences/essentialPrefs.dart';

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  late Future<EssentialInfo> _essentialInfo;

  int currentIndex = 1;

  @override
  void initState() {
    _essentialInfo = getEssentialInfo();
    super.initState();
  }

  void navigateToIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    EssentialInfo eInfo = Provider.of<EssentialInfo>(context);

    return FutureBuilder<EssentialInfo>(
      future: _essentialInfo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          eInfo.jellyfinUrl = snapshot.data!.jellyfinUrl;
          eInfo.mediaBrowserToken = snapshot.data!.mediaBrowserToken;
          eInfo.userId = snapshot.data!.userId;
          eInfo.libraryId = snapshot.data!.libraryId;

          if (eInfo.allInfoFilled()) {
            final NavigationBar _navigationBar = NavigationBar(
              selectedIndex: currentIndex,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: navigateToIndex,
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

            final Widget _body;
            switch (currentIndex) {
              case 0:
                _body = const Home();
                break;
              case 1:
                _body = const Albums();
                break;
              case 2:
                _body = const Settings();
                break;
              default:
                _body = const Text("Error!");
            }

            return Consumer<PanelController>(
              builder: (_, panelController, __) {
                return Scaffold(
                  body: SlidingUpPanel(
                    controller: panelController,
                    panel: const Center(
                      child: Text("Panel"),
                    ),
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
                    body: _body,
                  ),
                  bottomNavigationBar: _navigationBar,
                );
              },
            );
          } else {
            // TODO: Initialize essential info
            return const Setup();
          }
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                children: [
                  const Text("Error!"),
                  Text('${snapshot.error}'),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
