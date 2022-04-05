import 'package:flutter/material.dart';

import 'appearance.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Widget index(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 16.0),
        child: ListView(
          children: [
            const SizedBox(
              height: 130,
              child: Center(
                child: Icon(
                  Icons.settings_rounded,
                  size: 128,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
              child: Center(
                child: Text(
                  "Settings",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            cardBuilder(
                context, "Appearance", Icons.palette_rounded, "Change the app's appearance"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case "/appearance":
            builder = (BuildContext context) => AppearanceSettings();
            break;
          default:
            builder = (BuildContext context) => index(context);
            break;
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}

Widget cardBuilder(BuildContext context, String title, IconData leading, String? subtitle) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.0),
      color: Colors.blue[100],
    ),
    margin: const EdgeInsets.all(8.0),
    child: ListTile(
      leading: SizedBox(
        height: double.infinity,
        child: Icon(leading, size: 32),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: () => Navigator.of(context).pushNamed('/appearance'),
    ),
  );
}
